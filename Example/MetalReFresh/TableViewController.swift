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

class TableViewController: UITableViewController,UITableViewDragDelegate,UITableViewDropDelegate {
   
    var pull = PullToObject()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        swipeMethod()
        
        self.tableView.reloadData()

        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self

        navigationItem.rightBarButtonItem = editButtonItem
        
    }
    
    @objc private func update(tm: Timer)
    {
        timer.invalidate()
        offSetSize()
    }
  
    func refresh()
    {
        refreshControl?.alpha = 0
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshSet), for: UIControlEvents.valueChanged)
    }
    
    @objc func refreshSet()
    {
        
        guard ImageEntity.imageArray.count !=  0 else {
            
            tableReload()
            pull.imageCount = 0
            refreshControl?.endRefreshing()
            
            return
        }
        
        tableView.reloadData()
        tableView.isScrollEnabled = false
        pull.timerSet(view:self.tableView)
        
        timer = Timer.scheduledTimer(timeInterval: 5.0,
                                     target: self,
                                     selector: #selector(self.update),
                                     userInfo: nil, repeats: true)
    }
    
    private func swipeMethod()
    {
        
        let directions: UISwipeGestureRecognizerDirection = .right
        
        let gesture = UISwipeGestureRecognizer(target: self,
                                           action:#selector(handleSwipe(sender:)))
        
        gesture.direction = directions
        gesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(gesture)

    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer)
    {
        
        let vc = ViewController()
        self.present(vc, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return  ImageEntity.imageArray.count
        
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
        
        if pull.metalView == nil {
        
        ObjectDefaults().objectDefaults(index: indexPath.row, images: [ImageEntity.imageArray[indexPath.row]])
        TextManager().removeObject(index:indexPath.row)
        ImageEntity.imageArray.remove(at: indexPath.row)
        
        if ImageEntity.imageArray.count != 0 {
            
            pull.imageCount = ObjectDefaults().setObject().0.count
         
            ObjectDefaults().objectIndexDefaults(index: ImageEntity.imageArray.count)
            
        }else{
            
            pull.invalidate()
            
            pull.imageCount = 0
            
            ObjectDefaults().userDefaults.removeObject(forKey: "index")
            
            tableReload()
            
        }
        
        tableView.reloadData()
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.text = EncodesSample().encodeSet(images: ImageEntity.imageArray[indexPath.row], index: indexPath.row)
        
        tableReload()
        
        pull.imageCount = indexPath.row
        
    }
    
    func tableReload()
    {
        
        if  pull.metalView != nil {
            
            pull.metalView = nil
            pull.metalView.removeFromSuperview()
            
        }
        offSetSize()
    }
    
    private func offSetSize()
    {
        tableView.isScrollEnabled = true
        
        guard (Double(UIDevice.current.systemVersion)) != nil else {
            
            tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-20)
            return
            
        }
        
        //In case of iphone X
        if (Double(UIDevice.current.systemVersion))! > 11.0 {
            
            tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-40)
            
        }else{
            
            tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-20)
            
        }
        
    }
    
    //MARK:- ios 11 tableViewMethod-------------------------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
     
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
    
    func tableView(_ tableView: UITableView,dragSessionAllowsMoveOperation session: UIDragSession) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
    {
        
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession,at indexPath: IndexPath) -> [UIDragItem]
    {
        return[]
    }
    
    func tableView(_ tableView: UITableView,dragSessionWillBegin session: UIDragSession)
    {
        
    }
    
    func tableView(_ tableView: UITableView,dragSessionDidEnd session: UIDragSession)
    {
        
    }
    
}

