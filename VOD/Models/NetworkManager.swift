//
//  NetworkManager.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import UIKit

// Would have been writen differently without a time constraint. For example, the sports/school dictionaries being a part of this is for simplicity, but they should have their own space without being a part of the Network Manager.
class NetworkManager {
    
    static var shared: NetworkManager = {
        let networkManager = NetworkManager()
        return networkManager
    }()
    
    // Keeps sports/schools after first load
    var allSports: [Int:Sport] = [:]
    var allSchools: [Int:School] = [:]
    
    // Image cache
    var thumbnailImages: [String:Data] = [:]
    var requestsForImages: [UUID:URLSessionDataTask] = [:]
    
    // Pagination
    var nextPage: String?
    var isPaginating: Bool = false
    
    let baseURL = "https://api.pac-12.com"
    let callQueue = OperationQueue()
    
    func getVODsList(fromNextPage: Bool, completionHandler: @escaping(_ allVods: [Vod]) -> Void) {
        var vods: [Vod] = []
        
        // Sports -> Schools -> VODs
        let getVODsCalls = BlockOperation {
            let group = DispatchGroup()
            
            // The sports and schools calls can be asynchronous, they don't rely on each other to finish so they don't need to be queued one after the other.
            if self.allSports.isEmpty {
                group.enter()
                self.getSports {
                    group.leave()
                }
                group.wait()
            }
            
            if self.allSchools.isEmpty {
                group.enter()
                self.getSchools {
                    group.leave()
                }
                group.wait()
                
                // Could be more efficient by being asynchronous
                // value is the School struct
                for (key, value) in self.allSchools {
                    if let url = value.images?.small {
                        group.enter()
                        let _ = self.getImageData(imageURL: url, completionHandler: { data in
                            if let data = data {
                                var school = value
                                school.imageData = data
                                self.allSchools[key] = school
                            }
                            group.leave()
                        })
                        group.wait()
                    }
                }
            }
            
            group.enter()
            self.getVODs(fromNextPage: fromNextPage, completionHandler: {
                vodsList in
                
                // Need to add extra data to Vod struct, we know the schools/sports are loaded in by this point so it's safe to grab data from them
                var updatedVODs = vodsList
                for i in 0..<updatedVODs.count {
                    if let schools = updatedVODs[i].schoolsInfo {
                        for school in schools {
                            if let id = school.id, let schoolToAdd = self.allSchools[id] {
                                updatedVODs[i].schools.append(schoolToAdd)
                            }
                        }
                    }
                    
                    if let sports = updatedVODs[i].sportsInfo {
                        for sport in sports {
                            if let id = sport.id, let sportToAdd = self.allSports[id] {
                                updatedVODs[i].sports.append(sportToAdd)
                            }
                        }
                    }
                }
                vods = updatedVODs

                group.leave()
            })
            group.wait()
        }
        
        let finished = BlockOperation {
            completionHandler(vods)
        }
        
        finished.addDependency(getVODsCalls)
        
        callQueue.addOperation(getVODsCalls)
        callQueue.addOperation(finished)
        
    }
    
    
    func getVODs(fromNextPage: Bool, completionHandler: @escaping (_ vodList: [Vod]) -> Void) {
        var vodURL = ""
        if fromNextPage {
            isPaginating = true
            if let nextPage = nextPage {
                vodURL = "\(nextPage)"
            } else {
                completionHandler([])
                isPaginating = false
                return
            }
        } else {
            vodURL = "\(baseURL)/v3/vod"
        }
        
        guard let vodURL = URL(string: vodURL) else { return }
        
        URLSession.shared.dataTask(with: vodURL) { (data, response, error) in
            guard error == nil, let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let vods = try decoder.decode(Programs.self, from: data)
                self.nextPage = vods.nextPage
                if let programs = vods.programs {
                    completionHandler(programs)
                    if fromNextPage {
                        self.isPaginating = false
                    }
                }
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    func getSports(completionHandler: @escaping () -> Void) {
        guard let sportsURL = URL(string: "\(baseURL)/v3/sports") else { return }
        
        URLSession.shared.dataTask(with: sportsURL) { (data, response, error) in
            guard error == nil, let data = data else { return }
            
            let decoder = JSONDecoder()
            do {
                let sports = try decoder.decode(Sports.self, from: data)
                if let sportsList = sports.sports {
                    for sport in sportsList {
                        if let id = sport.id {
                            self.allSports[id] = sport
                        }
                    }
                }
                completionHandler()
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getSchools(completionHandler: @escaping () -> Void) {
        guard let schoolsURL = URL(string: "\(baseURL)/v3/schools") else { return }
        
        URLSession.shared.dataTask(with: schoolsURL) { (data, response, error) in
            guard error == nil, let data = data else { return }
            
            let decoder = JSONDecoder()
            do {
                let schools = try decoder.decode(Schools.self, from: data)
                if let schoolsList = schools.schools {
                    for school in schoolsList {
                        if let id = school.id {
                            self.allSchools[id] = school
                        }
                    }
                }
                completionHandler()
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getImageData(imageURL: String, completionHandler: @escaping (Data?) -> Void) -> UUID? {
        if let imageData = thumbnailImages[imageURL] {
            completionHandler(imageData)
            return nil
        }
        
        guard let url = URL(string: imageURL) else { return nil }
        
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            defer {
                self.requestsForImages.removeValue(forKey: uuid)
            }
            
            if let data = data {
                self.thumbnailImages[imageURL] = data
                completionHandler(data)
                return
            }
        }
        task.resume()
        
        requestsForImages[uuid] = task
        return uuid
    }
    
    func cancelRequest(_ uuid: UUID) {
        requestsForImages[uuid]?.cancel()
        requestsForImages.removeValue(forKey: uuid)
    }
}
