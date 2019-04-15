//
//  DiscoverPageViewController.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/10/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import SwiftTwitch
import Firebase
import FirebaseDatabase
import FirebaseAuth

class DiscoverPageViewController: UITableViewController {
    
    var ref : DatabaseReference!
    
    var games = [GameData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc public func saveFollowed() {
        print("wssup tho")
        let uID = Auth.auth().currentUser?.uid
        
        let userInfo: [String : Any] = ["gameIds" : ["new value "]]
        
        //self.ref?.child("users").child(uID!).child("gameIds").updateChildValues(userInfo)
        self.ref?.child("users").child(uID!).child("gameIds").setValue(["gameIds" : ["stopwatchString"]])

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uID = Auth.auth().currentUser?.uid
        
        let userInfo: [String : Any] = ["gameIds" : ["new value "]]
        
        //self.ref?.child("users").child(uID!).child("gameIds").updateChildValues(userInfo)
        self.ref?.child("users").child(uID!).child("gameIds")
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "QSLogo_Small")
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "DarkBG")!)
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "OKIcon"), style: .done, target: self, action: #selector(saveFollowed))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

        
        TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
        
        Twitch.Games.getTopGames(first: 50) {
            switch $0 {
            case .success(let getGamesData):
                self.games += getGamesData.gameData
            case .failure(let data, _, _):
                print("The API call failed! Unable to get videos. Did you set an access token?")
                if let data = data,
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                    let jsonDict = jsonObject as? [String: Any] {
                    //print(jsonDict)
                }
                self.games = [GameData]()
            }
        }
            
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    /// Retrieve a DiscoverTableViewCell with the reuse identifier "GameNameCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameNameCell"),
            let gameNameCell = cell as? DiscoverTableViewCell else {
                fatalError("Unable to dequeue a DiscoverTableViewCell!")
        }
        gameNameCell.gameData = games[indexPath.row]
        return gameNameCell
    }
}
