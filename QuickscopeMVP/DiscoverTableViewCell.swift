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
    
    var ref = Database.database().reference()
    var uID = Auth.auth().currentUser?.uid
    
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
        
        self.ref.child("users").child(uID!).child("gameIds").observeSingleEvent(of: .value, with: { snapshot in
            var storedGameIds = [String]()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let storedGameId = snap.value as! String
                storedGameIds.append(storedGameId)
            }
            
            //print(storedGameIds)
            storedGameIds.append(gameId!)
            
            
            var indicesArray: [String] = []
            for i in 0..<storedGameIds.count {
                indicesArray.append(String(i))
            }
            
            var uploadFirebaseDict: [String: String] = [:]
            
            for (index, element) in indicesArray.enumerated() {
                uploadFirebaseDict[element] = storedGameIds[index]
            }
            
            self.ref.child("users").child(self.uID!).child("gameIds").updateChildValues(uploadFirebaseDict)
        })
        
    }
    

}
