//
//  VodTableViewCell.swift
//  VOD
//
//  Created by Angel Castaneda on 2/1/23.
//

import UIKit

class VodTableViewCell: UITableViewCell {
    
    var onReuse: () -> Void = {}

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var sportsLabel: UILabel!
    
    // School
    @IBOutlet weak var SchoolsHorizontalStackView: UIStackView!
    @IBOutlet weak var schoolOneStackView: UIStackView!
    @IBOutlet weak var schoolOneImageView: UIImageView!
    @IBOutlet weak var schoolOneLabel: UILabel!
    @IBOutlet weak var schoolTwoStackView: UIStackView!
    @IBOutlet weak var schoolTwoImageView: UIImageView!
    @IBOutlet weak var schoolTwoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        thumbnail.image = UIImage()
        schoolOneImageView.image = UIImage()
        schoolTwoImageView.image = UIImage()
    }
    
}