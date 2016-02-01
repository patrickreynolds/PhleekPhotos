//
//  PhleekPhotosViewController.swift
//  PhleekPhotos
//
//  Created by Patrick Reynolds on 1/31/16.
//  Copyright © 2016 Patrick Reynolds. All rights reserved.
//

import UIKit

class PhleekPhotosViewController: UIViewController {
    
    var nextUrl: String?
    var photos = [PhleekPhoto]()
    
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        setupRefreshControl()
        
        loadPhotos { reloaded in
            if reloaded {
                self.tableView.reloadData()
            }
        }
        
        tableView.registerNib(UINib(nibName: String(PhleekPhotoTableViewCell), bundle: nil), forCellReuseIdentifier: String(PhleekPhotoTableViewCell))
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Constants.refreshControlAction(), forControlEvents: .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func handleRefreshControl(refreshControl: UIRefreshControl) {
        loadPhotos { reloaded in
           if reloaded {
                refreshControl.endRefreshing()
            }
        }
    }
    
    private func loadPhotos(completion: ((reloaded: Bool) -> ())) {
        let url = NSURL(string:Constants.endpoint(tag: "sb50"))
        let request = NSURLRequest(URL: url!, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 3)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            if let data = responseDictionary["data"] as? [[String: AnyObject]] {
                                for photoData in data {
                                    self.photos.append(PhleekPhoto(data: photoData))
                                }
                                completion(reloaded: true)
                                return
                            }
                    }
                }
                completion(reloaded: false)
        });
        task.resume()
    }
}


extension PhleekPhotosViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return view.bounds.width + Constants.headerViewHeight()
    }
}

extension PhleekPhotosViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let photoCell = tableView.dequeueReusableCellWithIdentifier(String(PhleekPhotoTableViewCell)) as? PhleekPhotoTableViewCell {
            
            photoCell.prepare(self.photos[indexPath.row])
            photoCell.setImageViewHeight(view.bounds.height)
            return photoCell
        }

        return UITableViewCell()
    }
}
