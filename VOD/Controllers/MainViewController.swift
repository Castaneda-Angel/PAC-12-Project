//
//  MainViewController.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import UIKit
import AVKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    var vods: [Vod] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "VodTableViewCell", bundle: nil), forCellReuseIdentifier: "VodTableViewCell")
        
        NetworkManager.shared.getVODsList(fromNextPage: false, completionHandler: { vods in
            self.vods = vods
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.loadingView.isHidden = true
                self.tableView.reloadData()
            }
        })
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) {
            if let videoPlayer = vc.player {
                videoPlayer.play()
            }
        }
    }
}

// Table View
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vods.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VodTableViewCell", for: indexPath) as? VodTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = vods[indexPath.row].title
        cell.durationLabel.text = getDurationString(from: vods[indexPath.row].duration ?? 0)
        
        // When there's more than one sport associated with each VOD, we add a + to the end of label text to signify that there are more sports. My current UI doesn't have space to show multiple sports cleanly, but one way to adjust the current UI to show more could be to allow a tap gesture of the cell to expand the cell a bit and show more sports names!
        let sportsCount = vods[indexPath.row].sports.count
        if sportsCount > 0, let sport = vods[indexPath.row].sports[0].name {
            if sportsCount > 1 {
                cell.sportsLabel.text = "\(sport) + \(sportsCount - 1)"
            } else {
                cell.sportsLabel.text = sport
            }
        } else {
            cell.sportsLabel.isHidden = true
        }
        
        cell.createdDateLabel.text = getDaysAgoString(from: vods[indexPath.row].created!)
        
        if vods[indexPath.row].schools.count == 1 {
            if let schoolOneImageData = vods[indexPath.row].schools[0].imageData {
                cell.schoolOneImageView.image = UIImage(data: schoolOneImageData)
            }
            cell.schoolOneLabel.text = vods[indexPath.row].schools[0].name ?? ""
            cell.schoolTwoStackView.isHidden = true
        } else if vods[indexPath.row].schools.count == 2 {
            if let schoolOneImageData = vods[indexPath.row].schools[0].imageData {
                cell.schoolOneImageView.image = UIImage(data: schoolOneImageData)
            }
            
            if let schoolTwoImageData = vods[indexPath.row].schools[1].imageData {
                cell.schoolTwoImageView.image = UIImage(data: schoolTwoImageData)
            }
            
            cell.schoolOneLabel.text = vods[indexPath.row].schools[0].name ?? ""
            cell.schoolTwoLabel.text = vods[indexPath.row].schools[1].name ?? ""
        } else {
            cell.SchoolsHorizontalStackView.isHidden = true
        }
        
        let token = NetworkManager.shared.getImageData(imageURL: vods[indexPath.row].images?.large ?? "", completionHandler: {
            data in
            if let data = data {
                DispatchQueue.main.async {
                    cell.thumbnail.image = UIImage(data: data)
                }
            }
        })
        
        cell.onReuse = {
            if let token = token {
                NetworkManager.shared.cancelRequest(token)
            }
        }
        
        return cell
    }
    
    // Ideally we would only be able to tap the video thumbnail to play the video, but for simplicity we allow any tap of the cell to play the video.
    // To tap thumbnail, we would add a tap gesture to the image and have a protocol from the cell that we conform to here, we would then play the video from that function and wouldn't need to keep this function.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stringURL = vods[indexPath.row].manifest_url, let url = URL(string: stringURL) else { return }
        playVideo(url: url)
    }
}

// Scroll View
extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        // position variable gives position from top, so to get proper calculation we need to subtract scroll view height
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            tableView.tableFooterView = loadViewFromNib("loadingFooterView")
            guard !NetworkManager.shared.isPaginating else { return }
            NetworkManager.shared.getVODsList(fromNextPage: true, completionHandler: { vods in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.tableView.tableFooterView = nil
                    self.vods += vods
                    self.tableView.beginUpdates()
                    // Manually inserts new rows, prevents image blinking when adding new VODs to array
                    for i in self.vods.count - vods.count..<self.vods.count {
                        self.tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    }
                    self.tableView.endUpdates()
                }
            })
        }
    }
}

