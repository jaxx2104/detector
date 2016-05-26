//
//  CustomCell.swift
//  uni
//
//  Created by iwa on 2015/08/29.
//  Copyright © 2015年 jaxx. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
