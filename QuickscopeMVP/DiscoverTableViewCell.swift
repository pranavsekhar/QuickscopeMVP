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
    
    var gameData: GameData? {
        didSet {
            loadGameData()
        }
    }
    
    public func loadGameData() {
        gameLabel.text = gameData?.name
    }

}
