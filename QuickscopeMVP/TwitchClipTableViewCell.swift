//
//  TwitchClipTableViewCell.swift
//  SwiftTwitch_Example
//
//  Created by Christopher Perkins on 1/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SwiftTwitch
import TwitchPlayer

class TwitchClipTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var clipPlayer: TwitchClipPlayer!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    var clipData: ClipData?
    
    override func prepareForReuse() { //prevent incorrect thumbnail images from appearing
        super.prepareForReuse()
        userProfileImage.image = nil
    }
    
}
