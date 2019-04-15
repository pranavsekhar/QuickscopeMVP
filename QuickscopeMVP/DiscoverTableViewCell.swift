//
//  DiscoverTableViewCell.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/10/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import SwiftTwitch
import Firebase
import FirebaseAuth
import FirebaseDatabase

class DiscoverTableViewCell: UITableViewCell {

    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var ref : DatabaseReference!
    
    var gameData: GameData? {
        didSet {
            loadGameData()
        }
    }
    
    var gameIds = [""]
    
    public func loadGameData() {
        gameLabel.text = gameData?.name
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        followButton.setImage(UIImage(named: "FollowingIcon"), for: .normal)
        let gameId = gameData?.id
        gameIds.append(gameId!)
        
        //print(gameId)
        print(gameIds)
        
        let uID = Auth.auth().currentUser?.uid
        
        let userInfo: [String : Any] = ["gameIds" : ["new value "]]
        
        self.ref?.child("users").child(uID!).child("gameIds").updateChildValues(userInfo)
    }
    

}
