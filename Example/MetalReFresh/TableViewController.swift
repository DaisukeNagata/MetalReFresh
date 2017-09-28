//
//  TableViewController.swift
//  MetalPullRefresh
//
//  Created by daisuke nagata on 09/29/2017.
//  Copyright (c) 2017 daisuke nagata. All rights reserved.
//

import UIKit
import MetalReFresh

class TableViewController: UITableViewController {
    
    var pull = PullToObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh()
        
    }
    
    func refresh()
    {
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshSet), for: UIControlEvents.valueChanged)
        refreshControl?.alpha = 0
    }
    
    @objc func refreshSet()
    {
        if self.pull.imageCount == 5 {
            
            self.pull.imageCount = 0
            
        }
        
        tableView.reloadData()
        self.pull.timerSet(view:self.tableView)
        tableView.isScrollEnabled = false
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return ImageEntity.imageArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        for _ in 0...0{
            
            self.refresh()
            
        }
        
        cell.textLabel?.text = ImageEntity.imageArray[indexPath.row]
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.pull.invalidate()
        
        tableView.isScrollEnabled = true
        tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-20)
        
        self.pull.imageCount = indexPath.row
        
    }
}

