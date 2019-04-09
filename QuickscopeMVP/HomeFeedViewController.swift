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
        print("hello there")
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Refresh with new content
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(loadNewContent), for: .valueChanged)
        self.refreshControl = refreshControl

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        
        let gameIds = ["32399", "493057"]
        
        var pagTok = ""
        
        for gid in gameIds {
            Twitch.Clips.getClips(broadcasterId: nil, gameId: gid, clipIds: nil, after: pagTok, startedAt: startedAtDate, endedAt: Date(), first: 5) { //19571641
                switch $0 {
                case .success(let getVideosData):
                    self.clips += getVideosData.clipData
                    self.clips.shuffle()
                    pagTok = (getVideosData.paginationData?.token)!
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
        
        
        
//        Twitch.Clips.getClips(broadcasterId: nil, gameId: "32399", clipIds: nil, startedAt: startedAtDate, endedAt: Date(), first: 10) { //19571641
//            switch $0 {
//            case .success(let getVideosData):
//                self.clips = getVideosData.clipData
//            case .failure(let data, _, _):
//                print("The API call failed! Unable to get videos. Did you set an access token?")
//                if let data = data,
//                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
//                    let jsonDict = jsonObject as? [String: Any]{
//                    print(jsonDict)
//                }
//                self.clips = [ClipData]()
//            }
        
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
    
    
    
//    func getClipIds (gameIds: [String], streamerIds: [String]) -> [String] {
//
//        let urlString = "https://api.twitch.tv/helix/clips"
//        let parameters = ["broadcaster_id": "19571641"]
//        let headers = ["Client-ID": "om99skbxrgssgxogal1j9kd31u2nlo"]
//
//        var urlComponents = URLComponents(string: urlString)
//
//        var queryItems = [URLQueryItem]()
//        for (key, value) in parameters {
//            queryItems.append(URLQueryItem(name: key, value: value))
//        }
//
//        urlComponents?.queryItems = queryItems
//
//        var request = URLRequest(url: (urlComponents?.url)!)
//        request.httpMethod = "GET"
//
//        for (key, value) in headers {
//            request.setValue(value, forHTTPHeaderField: key)
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
//            print(data)
//
//            guard let jsonArray = data as? [[String: Any]] else {
//                return
//            }
//            print(jsonArray)
//
//        }
//        task.resume()
//
//        return [""]
//
//    }

}

/*
 curl --data "client_id=om99skbxrgssgxogal1j9kd31u2nlo" --data "client_secret=doew024h8nx94sshtra2s37axoiavx"  --data "grant_type=client_credentials" https://id.twitch.tv/oauth2/token
 {"access_token":"wx5au1mej4255hr2jrldi1vtw9gzt3","expires_in":5063443,"token_type":"bearer"}
*/
