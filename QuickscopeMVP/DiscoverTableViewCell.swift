//
//  DiscoverTableViewCell.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/10/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import SwiftTwitch

class DiscoverTableViewCell: UITableViewCell {

    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var gameData: GameData? {
        didSet {
            loadGameData()
        }
    }
    
    public func loadGameData() {
        gameLabel.text = gameData?.name
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        followButton.setImage(UIImage(named: "FollowingIcon"), for: .normal)
        let gameId = gameData?.id
        print(gameId!)
    }
    

}
