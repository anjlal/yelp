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

  
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!

   // var customSwitch = SevenSwitch()
    
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch.onTintColor = UIColor(red: 0.82, green: 0.13, blue: 0.13, alpha: 0.8)
//        customSwitch.addTarget(self, action: #selector(self.switchValueChanged(_:)), for: UIControlEvents.valueChanged)
//        customSwitch.frame = CGRect(x: self.frame.width - 54 , y: self.frame.height/2 - 12.5, width: 50, height: 25)
//        customSwitch.thumbImage = UIImage(named: "yelp_thumb.png")
//        self.addSubview(customSwitch)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
    }
}
