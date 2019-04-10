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
    
    var clipData: ClipData? {
        didSet {
            loadVideoData()
        }
    }
    
//    override func prepareForReuse() { //prevent incorrect thumbnail images from appearing
//        super.prepareForReuse()
//        userProfileImage.image = nil
//    }
    
    public func loadVideoData() {
        titleLabel.text = clipData?.title
        userLabel.text = clipData?.broadcasterName
        clipPlayer.clipId = (clipData?.clipId)!
        viewLabel.text = "\(clipData?.viewCount ?? 0) views"
        
        
        // Timestamp presentaton conversion
        let secondsAgo = Int(Date().timeIntervalSince((clipData?.creationDate)!))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        var finalDateString = ""
        
        if secondsAgo < minute {
            finalDateString = "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            finalDateString = "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            finalDateString = "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            finalDateString = "\(secondsAgo / day) days ago"
        } else {
            finalDateString = "\(secondsAgo / week) weeks ago"
        }

        dateLabel.text = finalDateString
        
        
    }
}
