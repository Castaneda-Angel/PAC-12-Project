//
//  VodTableViewCell.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import UIKit

class VodTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var sportsLabel: UILabel!
    
    @IBOutlet weak var schoolOneImageView: UIImageView!
    @IBOutlet weak var schoolTwoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
