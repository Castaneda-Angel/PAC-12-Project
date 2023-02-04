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
    
    var vods: [Vod] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "VodTableViewCell", bundle: nil), forCellReuseIdentifier: "VodTableViewCell")
        
        NetworkManager.shared.getVODsList(fromNextPage: false, completionHandler: { vods in
            self.vods = vods
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) {
            vc.player?.play()
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
        cell.durationLabel.text = secondsToMinutesString(milliseconds: vods[indexPath.row].duration ?? 0)
        cell.sportsLabel.text = vods[indexPath.row].sports[0].name ?? ""
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
        
        NetworkManager.shared.getImageData(imageURL: vods[indexPath.row].images?.large ?? "", completionHandler: {
            data in
            DispatchQueue.main.async {
                cell.thumbnail.image = UIImage(data: data)
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stringURL = vods[indexPath.row].manifest_url, let url = URL(string: stringURL) else { return }
        playVideo(url: url)
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            tableView.tableFooterView = Bundle.loadView(fromNib: "loadingFooterView")
            guard !NetworkManager.shared.isPaginating else { return }
            NetworkManager.shared.getVODsList(fromNextPage: true, completionHandler: { vods in
                self.vods += vods
                DispatchQueue.main.async {
                    self.tableView.tableFooterView = nil
                    self.tableView.reloadData()
                }
            })
        }
    }
}

extension Bundle {
    static func loadView(fromNib name: String) -> UIView {
        if let view = Bundle.main.loadNibNamed(name, owner: nil)?.first as? UIView {
            return view
        } else {
            return UIView()
        }
    }
}

