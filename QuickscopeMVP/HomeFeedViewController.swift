//
//  HomeFeedViewController.swift
//  QuickscopeMVP
//
//  Created by Pranav Sekhar on 4/4/19.
//  Copyright © 2019 Pranav Sekhar. All rights reserved.
//

import UIKit
import SwiftTwitch

class HomeFeedViewController: UITableViewController {
    
    var clips = [ClipData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "QSLogo_Small")
        imageView.image = image
        navigationItem.titleView = imageView
        
        // Twitch Clips Integration:
        
        TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
        
        Twitch.Clips.getClips(broadcasterId: "19571641", gameId: nil, clipIds: nil) {
            switch $0 {
            case .success(let getVideosData):
                self.clips = getVideosData.clipData
            case .failure(let data, _, _):
                print("The API call failed! Unable to get videos. Did you set an access token?")
                if let data = data,
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                    let jsonDict = jsonObject as? [String: Any]{
                    print(jsonDict)
                }
                self.clips = [ClipData]()
            }
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return clips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoData = clips[indexPath.row]
        UIApplication.shared.openURL(videoData.clipURL)
    }
    
    /// Retrieve a TwitchClipTableViewCell with the reuse identifier "twitchyCell". Its video data
    /// should be set to the video at the index path specified.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClipCell"),
            let clipCell = cell as? TwitchClipTableViewCell else {
                fatalError("Unable to dequeue a TwitchClipTableViewCell!")
        }
        clipCell.clipData = clips[indexPath.row]
        return clipCell
    }

}
