//
//  NetworkManager.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import UIKit

class NetworkManager {
    
    static var shared: NetworkManager = {
        let networkManager = NetworkManager()
        return networkManager
    }()
    
    var allSports: [Int:Sport] = [:]
    var allSchools: [Int:School] = [:]
    
    let baseURL = "https://api.pac-12.com/v3"
    let callQueue = OperationQueue()
    
    func getVODsList(completionHandler: @escaping(_ allVods: [Vod]) -> Void) {
        var vods: [Vod] = []
        
        let getVODsCalls = BlockOperation {
            let group = DispatchGroup()
            
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
                
                // FIX, could be more efficient by being asynchronous
                // value is the School struct
                for (key, value) in self.allSchools {
                    if let url = value.images?.small {
                        group.enter()
                        self.getImageData(imageURL: url, completionHandler: { data in
                            var school = value
                            school.imageData = data
                            self.allSchools[key] = school
                            group.leave()
                        })
                        group.wait()
                    }
                }
            }
            
            group.enter()
            self.getVODs(completionHandler: {
                vodsList in
                var updatedVODs = vodsList
                for i in 0..<updatedVODs.count {
                    if let schools = updatedVODs[i].schoolsInfo {
                        for school in schools {
                            updatedVODs[i].schools.append(self.allSchools[school.id ?? -1] ?? School())
                        }
                    }
                    
                    if let sports = updatedVODs[i].sportsInfo {
                        for sport in sports {
                            updatedVODs[i].sports.append(self.allSports[sport.id ?? -1] ?? Sport())
                        }
                    }
                }
                vods = updatedVODs
                for vod in vods {
                    for school in vod.schools {
                        //print("TEST: \(school.name)")
                    }
                }
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
    
    
    func getVODs(completionHandler: @escaping (_ vodList: [Vod]) -> Void) {
        guard let vodURL = URL(string: "\(baseURL)/vod") else { return }
        
        let task = URLSession.shared.dataTask(with: vodURL) { (data, response, error) in
            guard error == nil, let data = data else { return }
            let decoder = JSONDecoder()
            
            do {
                let vods = try decoder.decode(Programs.self, from: data)
                if let programs = vods.programs {
                    completionHandler(programs)
                }
            } catch {
                print(error)
            }
            
        }
        task.resume()
    }
    
    func getSports(completionHandler: @escaping () -> Void) {
        guard let sportsURL = URL(string: "\(baseURL)/sports") else { return }
        
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
        guard let schoolsURL = URL(string: "\(baseURL)/schools") else { return }
        
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
    
    func getImage(imageURL: String, completionHandler: @escaping (_ image: UIImage) -> Void) {
        guard let url = URL(string: imageURL) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completionHandler(image)
            }
        }
        task.resume()
    }
    
    func getImageData(imageURL: String, completionHandler: @escaping (_ data: Data) -> Void) {
        guard let url = URL(string: imageURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completionHandler(data)
            }
        }.resume()
    }
}
