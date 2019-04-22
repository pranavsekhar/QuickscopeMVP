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
import FirebaseAuth
import FirebaseDatabase

class DiscoverPageViewController: UITableViewController {
    
    var limit = 13
    
    var games = [GameData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var gamesToAdd = [GameData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var ref = Database.database().reference()
    var uID = Auth.auth().currentUser?.uid
    var followedGameIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "QSLogo_Small")
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "DarkBG")!)
        
        self.tableView.separatorStyle = .none

        TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
        
        Twitch.Games.getTopGames(first: 100) {
            switch $0 {
            case .success(let getGamesData):
                self.games += getGamesData.gameData
                //initial population
                if self.gamesToAdd.count == 0 {
                    self.gamesToAdd.append(self.games[0])
                }

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
        
        gameNameCell.gameLabel.text = gameNameCell.gameData?.name
        
        var rawUrl = gameNameCell.gameData?.boxArtURLString
        let rawUrl1 = rawUrl!.replacingOccurrences(of: "{width}", with: "100")
        let rawUrl2 = rawUrl1.replacingOccurrences(of: "{height}", with: "100")
        
        let url = URL.init(string: rawUrl2)
        self.downloadImage(url: url!, imageView: gameNameCell.gameThumbnail)
        
        gameNameCell.followButton.imageView?.image = nil
        
        if uID != nil { //Grab Game Ids
            self.ref.child("users").child(uID!).child("gameIds").observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let storedGameId = snap.value as! String
                    if !self.followedGameIds.contains(storedGameId) {
                        self.followedGameIds.append(storedGameId)
                    }
                }
            })
        }
        
        if self.followedGameIds.contains(gameNameCell.gameData!.id) {
            print("yes")
            gameNameCell.followButton.setImage(UIImage(named: "FollowingIcon"), for: .normal)
        }
        else {
            gameNameCell.followButton.setImage(UIImage(named: "FollowIcon"), for: .normal)
        }
        
        return gameNameCell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        let reload_distance:CGFloat = 10.0
        if y > (h + reload_distance) {
            print("load more rows")
            
            
            if gamesToAdd.count < games.count - limit {
                // we need to bring more records as there are some pending records available
                var index = gamesToAdd.count
                limit = index + 3
                while index < limit {
                    gamesToAdd.append(games[index])
                    index = index + 1
                }
                self.perform(#selector(loadMore), with: nil, afterDelay: 1.0)
            }
            
            
        }
    }
    
    @objc func loadMore() {
        self.tableView.reloadData()
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async { // Make sure you're on the main thread here
                imageView.layer.cornerRadius = imageView.frame.height/2
                imageView.clipsToBounds = true
                imageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
