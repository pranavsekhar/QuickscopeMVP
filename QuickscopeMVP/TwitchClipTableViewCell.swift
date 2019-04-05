//
//  TwitchClipTableViewCell.swift
//  SwiftTwitch_Example
//
//  Created by Christopher Perkins on 1/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SwiftTwitch

class TwitchClipTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var viewLabel: UILabel!
    
    var clipData: ClipData? {
        didSet {
            loadVideoData()
        }
    }
    
    public func loadVideoData() {
        guard let videoData = clipData else {
            videoThumbnailImageView.image = nil
            return
        }
        titleLabel.text = clipData?.title
        userLabel.text = clipData?.broadcasterName
        viewLabel.text = "\(videoData.viewCount) view(s)"
    }
    
}
