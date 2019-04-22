//
//  HomeFeedViewController.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/4/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import SwiftTwitch
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeFeedViewController: UITableViewController {
    
    var limit = 3
    
    var clips = [ClipData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var clipsToLoad = [ClipData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc func loadNewContent() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    var ref = Database.database().reference()
    var uID = Auth.auth().currentUser?.uid
    
    var followedGameIds = [String]()
    
    override func viewDidAppear(_ animated: Bool) {
        if self.uID != nil { //Grab Game Ids
            //print(uID)
            self.ref.child("users").child(self.uID!).child("gameIds").observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let storedGameId = snap.value as! String
                    if !self.followedGameIds.contains(storedGameId) {
                        self.followedGameIds.append(storedGameId)
                    }
                }
            })
            print(self.followedGameIds)
        }
        
        // Populate
        // Twitch Clips Integration:
        TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
        
        let startedAtDate = Calendar.current.date(
            byAdding: .hour,
            value: -48,
            to: Date())
        
        for gid in self.followedGameIds {
            self.clips = [ClipData]() //prevent duplicate clips
            Twitch.Clips.getClips(broadcasterId: nil, gameId: gid, clipIds: nil, startedAt: startedAtDate, endedAt: Date(), first: 20) {
                switch $0 {
                case .success(let getVideosData):
                    self.clips += getVideosData.clipData // key line
                    self.clips.shuffle()
                    //initial population
                    if self.clipsToLoad.count == 0 {
                        self.clipsToLoad.append(self.clips[0])
                        self.clipsToLoad.append(self.clips[1])
                    }
                    
                case .failure(let data, _, _):
                    print("The API call failed! Unable to get videos. Did you set an access token?")
                    if let data = data,
                        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                        let jsonDict = jsonObject as? [String: Any] {
                        //print(jsonDict)
                    }
                    self.clips = [ClipData]()
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Refresh with new content
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(loadNewContent), for: .valueChanged)
        self.refreshControl = refreshControl
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "QSLogo_Small")
        imageView.image = image
        navigationItem.titleView = imageView

        self.tableView.backgroundView = UIImageView(image: UIImage(named: "DarkBG")!)
        
        //Check if this line is needed later:
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clipsToLoad.count
    }
    
    /// Retrieve a TwitchClipTableViewCell with the reuse identifier "ClipCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClipCell"),
            let clipCell = cell as? TwitchClipTableViewCell else {
                fatalError("Unable to dequeue a TwitchClipTableViewCell!")
        }
        clipCell.clipData = clipsToLoad[indexPath.row]
        
        // Timestamp presentaton conversion
        let secondsAgo = Int(Date().timeIntervalSince((clipCell.clipData?.creationDate)!))
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
        
        clipCell.dateLabel.text = finalDateString
        
        TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
        
        Twitch.Users.getUsers(userIds: [(clipCell.clipData?.broadcasterId)!], userLoginNames: nil) { result in
            switch result {
            case .success(let getUsersFollowsData):
                /* If the total = 1, we know that user1 is following user2
                 as it is documented in the Twitch API docs. */
                let url = getUsersFollowsData.userData[0].profileImageURL
                self.downloadImage(url: url, imageView: clipCell.userProfileImage)
            case .failure(let data, let response, let error):
                print("The API call failed! Unable to determine relationship.")
            }
        }
        
        Twitch.Games.getGames(gameIds: [(clipCell.clipData?.gameId)!], gameNames: nil) { result in
            switch result {
            case .success(let getGameData):
                DispatchQueue.main.async {
                    clipCell.gameNameLabel.text = getGameData.gameData[0].name
                }
            case .failure(let data, let response, let error):
                print("The API call failed! Unable to determine relationship.")
            }
        }
        
        clipCell.titleLabel.text = clipCell.clipData?.title
        clipCell.userLabel.text = clipCell.clipData?.broadcasterName
        clipCell.clipPlayer.clipId = (clipCell.clipData?.clipId)!
        clipCell.viewLabel.text = "\(clipCell.clipData?.viewCount ?? 0) views"
        
        return clipCell
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
            
            
            if clipsToLoad.count < clips.count - limit {
                // we need to bring more records as there are some pending records available
                var index = clipsToLoad.count
                limit = index + 3
                while index < limit {
                    clipsToLoad.append(clips[index])
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





//if uID != nil { //Grab Game Ids
//    //print(uID)
//    self.ref.child("users").child(uID!).child("gameIds").observeSingleEvent(of: .value, with: { snapshot in
//        for child in snapshot.children {
//            let snap = child as! DataSnapshot
//            let storedGameId = snap.value as! String
//            if !self.followedGameIds.contains(storedGameId) {
//                self.followedGameIds.append(storedGameId)
//            }
//        }
//    })
//    print(self.followedGameIds)
//}
//
//// Populate
//// Twitch Clips Integration:
//TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
//
//let startedAtDate = Calendar.current.date(
//    byAdding: .hour,
//    value: -48,
//    to: Date())
//
//for gid in followedGameIds {
//    self.clips = [ClipData]() //prevent duplicate clips
//    Twitch.Clips.getClips(broadcasterId: nil, gameId: gid, clipIds: nil, startedAt: startedAtDate, endedAt: Date(), first: 20) {
//        switch $0 {
//        case .success(let getVideosData):
//            self.clips += getVideosData.clipData // key line
//            self.clips.shuffle()
//            //initial population
//            if self.clipsToLoad.count == 0 {
//                self.clipsToLoad.append(self.clips[0])
//                self.clipsToLoad.append(self.clips[1])
//            }
//
//        case .failure(let data, _, _):
//            print("The API call failed! Unable to get videos. Did you set an access token?")
//            if let data = data,
//                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
//                let jsonDict = jsonObject as? [String: Any] {
//                //print(jsonDict)
//            }
//            self.clips = [ClipData]()
//        }
//    }
//}
