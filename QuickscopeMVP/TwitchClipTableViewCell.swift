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
    
    var clipData: ClipData? {
        didSet {
            loadVideoData()
        }
    }
    
    public func loadVideoData() {
        titleLabel.text = clipData?.title
        userLabel.text = clipData?.broadcasterName
        clipPlayer.clipId = (clipData?.clipId)!
        viewLabel.text = "\(clipData?.viewCount ?? 0) view(s)"
    }
}
