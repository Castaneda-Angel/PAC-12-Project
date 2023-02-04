//
//  MainViewController.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var networkManager = NetworkManager()
    var vods: [Vod]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "VodTableViewCell", bundle: nil), forCellReuseIdentifier: "VodTableViewCell")
        
        NetworkManager.shared.getVODsList(completionHandler: { vods in
            self.vods = vods
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
//        networkManager.getVODs(completionHandler: { (vods) in
//            DispatchQueue.main.async {
//                self.vods = vods
////                for vod in self.vods! {
////                    print("\(vod.title!)")
////                    print("--")
////                    print("Schools")
////                    for school in vod.schools! {
////                        print("\(school)")
////                    }
////                    print("--\nSports")
////                    for sport in vod.sports! {
////                        print("\(sport)")
////                    }
////                    print("\n\n")
////                }
//                self.tableView.reloadData()
//            }
//        })
    }
    
    


}

extension MainViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vods?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VodTableViewCell", for: indexPath) as? VodTableViewCell, let vods = vods else { return UITableViewCell() }
        
        cell.titleLabel.text = vods[indexPath.row].title
        cell.durationLabel.text = secondsToMinutesString(milliseconds: vods[indexPath.row].duration ?? 0)
        cell.sportsLabel.text = vods[indexPath.row].sports[0].name ?? ""
        if vods[indexPath.row].schools.count == 1 {
            cell.schoolOneImageView.image = UIImage(data: vods[indexPath.row].schools[0].imageData!)
            cell.schoolTwoImageView.isHidden = true
        } else if vods[indexPath.row].schools.count == 2 {
            cell.schoolOneImageView.image = UIImage(data: vods[indexPath.row].schools[0].imageData!)
            cell.schoolTwoImageView.image = UIImage(data: vods[indexPath.row].schools[1].imageData!)
        } else {
            cell.schoolOneImageView.isHidden = true
            cell.schoolTwoImageView.isHidden = true
        }
        
        networkManager.getImage(imageURL: vods[indexPath.row].images?.large ?? "", completionHandler: {
            image in
            DispatchQueue.main.async {
                cell.thumbnail.image = image
            }
        })
        return cell
    }
}

