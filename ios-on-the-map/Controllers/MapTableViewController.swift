//
//  MapTableViewController.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/11/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation
import UIKit

class MapTableViewController: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let parseLogin = ParseClient()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for tabBarItem in tabBarController!.tabBar.items! {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        refresh()
    }
    
    func refresh() {
        parseLogin.getStudentLocations() { (response, error) -> Void in
            if error != nil {
                let mainQueue = DispatchQueue.main
                mainQueue.async(execute: {
                    
                    self.showErrorAlert(message: error!, dismissButtonTitle: "OK")
                    return
                })
            } else {
                print("Count = \(response?.count ?? 0)")
                
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        title = "Map Table View"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedMemory.instance.studentsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath as IndexPath)
        let thisEntry = SharedMemory.instance.studentsArray[indexPath.row]

        thisCell.imageView?.image = UIImage(named: "Map-Table-Pin")
        thisCell.textLabel?.text = thisEntry.firstName + " " + thisEntry.lastName
        thisCell.detailTextLabel?.text = thisEntry.mediaURL

        return thisCell
    }
    
    @IBAction func logout(_ sender: Any) {
        let udacityClient = UdacityClient()
        udacityClient.logout() { (resp, err) -> Void in
            if resp == nil {
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let thisEntry = SharedMemory.instance.studentsArray[indexPath.row]
        
        let theURL = SharedMemory.instance.addHttps(url: thisEntry.mediaURL)
        
        UIApplication.shared.open(URL(string: theURL!)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func openAddPinView(_ sender: Any) {
        let storyboard = self.storyboard
        let tabBarController = storyboard?.instantiateViewController(withIdentifier: "MapAddViewController")
        
        self.present(tabBarController!, animated: true, completion: nil)

    }
 }
