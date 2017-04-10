//
//  SwitchCell.swift
//  Yelp
//
//  Created by Angie Lal on 4/5/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import SevenSwitch

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    @IBOutlet weak var onSwitch: SevenSwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch.onTintColor = UIColor(red: 0.82, green: 0.13, blue: 0.13, alpha: 0.8)
        onSwitch.addTarget(self, action: #selector(self.switchValueChanged(_:)), for: UIControlEvents.valueChanged)
        onSwitch.thumbImage = #imageLiteral(resourceName: "yelp_thumb")
        onSwitch.onThumbTintColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.on)
    }
}
