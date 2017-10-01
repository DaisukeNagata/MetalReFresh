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
        swipeMethod()
    }
    
    func refresh()
    {
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshSet), for: UIControlEvents.valueChanged)
        refreshControl?.alpha = 0
    }
    
    @objc func refreshSet()
    {
        if  ImageEntity.imageArray.count == 0 {
            
            self.pull.imageCount = 0
            
        }
        
        tableView.reloadData()
        self.pull.timerSet(view:self.tableView)
        tableView.isScrollEnabled = false
        
    }
    
    private func swipeMethod()
    {
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self,
                                                   action:#selector(handleSwipe(sender:)))
            
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
            
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer)
    {
        
        let vc = ViewController()
        self.present(vc, animated: true)
        
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
        
        cell.textLabel?.text = ImageEntity.imageArray[indexPath.row].description
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
        ImageEntity.imageArray.remove(at: indexPath.row)
        
        if ImageEntity.imageArray.count-1 != 0 {
            
        self.pull.imageCount = ImageEntity.imageArray.count-1
            
        }else{
            
        self.pull.imageCount = ImageEntity.imageArray.count
            
        }
        
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.pull.invalidate()
        
        tableView.isScrollEnabled = true
        tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-20)
        
        self.pull.imageCount = indexPath.row
        
    }
}

