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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        swipeMethod()
        
        self.tableView.reloadData()

        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self

        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func refresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshSet), for: UIControlEvents.valueChanged)
        refreshControl?.alpha = 0
    }
    
    @objc func refreshSet()
    {
        
        guard ImageEntity.imageArray.count !=  0 else {
            
            pull.imageCount = 0
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
        gesture.numberOfTouchesRequired = 2
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
        
        ObjectDefaults().objectDefaults(index: indexPath.row, images: [ImageEntity.imageArray[indexPath.row]])
        ImageEntity.imageArray.remove(at: indexPath.row)
        TextManager().removeObject(index:indexPath.row)
        
        if ImageEntity.imageArray.count != 0 {
            
            pull.imageCount = ObjectDefaults().setObject().0.count
            
        }else{
            
            pull.invalidate()
            
            pull.imageCount = 0
            
            tableReload()
            
        }
        
        tableView.reloadData()
        
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
            
            pull.metalView.removeFromSuperview()
            pull.metalView = nil
            
        }
        
        tableView.isScrollEnabled = true
        tableView.contentOffset = CGPoint(x:0, y:-Int((self.navigationController?.navigationBar.frame.size.height)!)-20)
        
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

