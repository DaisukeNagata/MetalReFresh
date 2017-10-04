//
//  TableViewController.swift
//  MetalPullRefresh
//
//  Created by daisuke nagata on 09/29/2017.
//  Copyright (c) 2017 daisuke nagata. All rights reserved.
//

import UIKit
import MetalKit
import MetalReFresh

class TableViewController: UITableViewController {
    
    var pull = PullToObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        swipeMethod()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        ImageEntity.imageArray = ObjectDefaults().setObject().0
        
    }
    
    func refresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshSet), for: UIControlEvents.valueChanged)
        refreshControl?.alpha = 0
    }
    
    @objc func refreshSet()
    {
        if  ImageEntity.imageArray.count == 0 {
            
            pull.imageCount = 0
            
        }
        
        guard ObjectDefaults().setObject().1 !=  0 else {
            
            pull.invalidate()
            refreshControl?.endRefreshing()
            tableReload()
            
            return
        }
        
        tableView.reloadData()
        pull.timerSet(view:self.tableView)
        tableView.isScrollEnabled = false
        
    }
    
    private func swipeMethod()
    {
        
        let directions: UISwipeGestureRecognizerDirection = .right
        
        let gesture = UISwipeGestureRecognizer(target: self,
                                               action:#selector(handleSwipe(sender:)))
        
        gesture.direction = directions
        self.view.addGestureRecognizer(gesture)
        
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
            
            refresh()
            
        }
        
        cell.textLabel?.text = ImageEntity.imageArray[indexPath.row].description
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
        ObjectDefaults().objectDefaults(index: indexPath.row, images: [ImageEntity.imageArray[indexPath.row]])
        ImageEntity.imageArray.remove(at: indexPath.row)
        
        if ObjectDefaults().setObject().0.count != 0 {
            
            pull.imageCount = ImageEntity.imageArray.count-1
            
        }else{
            
            pull.imageCount = 0
            
            tableReload()
            
            if pull.metalView != nil {
                
                pull.metalView.removeFromSuperview()
                
            }
            
        }
        
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        pull.invalidate()
        
        tableReload()
        
        pull.imageCount = indexPath.row
        
    }
    
    func tableReload()
    {
        
        tableView.isScrollEnabled = true
        tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-20)
        
    }
}

