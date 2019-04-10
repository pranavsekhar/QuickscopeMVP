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
    
    @objc func loadNewContent() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
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
        
        // Twitch Clips Integration:
        TwitchTokenManager.shared.accessToken = "wx5au1mej4255hr2jrldi1vtw9gzt3"
        
        let startedAtDate = Calendar.current.date(
            byAdding: .hour,
            value: -48,
            to: Date())
        
        let gameIds = ["32399"] // , "493057"]
        
        //var pagTok = ""
        
        for gid in gameIds {
            Twitch.Clips.getClips(broadcasterId: nil, gameId: gid, clipIds: nil, startedAt: startedAtDate, endedAt: Date(), first: 3) { //19571641
                switch $0 {
                case .success(let getVideosData):
                    self.clips += getVideosData.clipData
                    self.clips.shuffle()
                    //pagTok = (getVideosData.paginationData?.token)!
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoData = clips[indexPath.row]
        //UIApplication.shared.openURL(videoData.clipURL)
    }
    
    /// Retrieve a TwitchClipTableViewCell with the reuse identifier "ClipCell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClipCell"),
            let clipCell = cell as? TwitchClipTableViewCell else {
                fatalError("Unable to dequeue a TwitchClipTableViewCell!")
        }
        clipCell.clipData = clips[indexPath.row]
        return clipCell
    }
}
