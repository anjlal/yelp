//
//  CheckedCell.swift
//  Yelp
//
//  Created by Angie Lal on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class CheckedCell: UITableViewCell {

    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
