//
//  VersionsTableViewController.swift
//  Jottings
//
//  Created by Morten Kals on 07/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import UIKit
import CoreData

class VersionsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var jotting : Jotting?
    
    var context : NSManagedObjectContext? {
        get {
            return jotting?.managedObjectContext
        }
    }
    
    var orderedVersions : Array<Array<Version>> {
        if let object = jotting {
            return object.versionsArrayDates
        } else {
            return Array<Array<Version>>()
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return orderedVersions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedVersions[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let version = orderedVersions[indexPath.section][indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        
        cell.textLabel?.text = version.title
        cell.detailTextLabel?.text = dateFormatter.string(from: version.timestamp)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let date = orderedVersions[section][0].timestamp
        return dateFormatter.string(from: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVersionDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                controller.detailItem = jotting
                controller.indexForVersion = indexPath
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let object = orderedVersions[indexPath.section][indexPath.row]
            context?.delete(object)
            
            do {
                try context?.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//
//        }
//    }
}
