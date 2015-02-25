//
//  BlurbCell.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/21/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var blurb: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
