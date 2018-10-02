//
//  adminAiJiaTableViewController.swift
//  DinnerSystemBeta
//
//  Created by Sean on 2018/9/25.
//  Copyright © 2018 Sean.Inc. All rights reserved.
//

import UIKit

class adminAiJiaTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return aiJiaMenuArr.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminStore2Cell", for: indexPath)
        let info = aiJiaMenuArr[indexPath.row]
        cell.textLabel?.text = info.dishName!
        cell.detailTextLabel?.text = "\(info.dishCost!)$"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = aiJiaMenuArr[indexPath.row]
        selectedFood.cost = info.dishCost!
        selectedFood.name = info.dishName!
        selectedFood.id = info.dishId!
        performSegue(withIdentifier: "dmAJSegue", sender: nil)
    }

}