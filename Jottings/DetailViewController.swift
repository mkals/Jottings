//
//  DetailViewController.swift
//  Jottings
//
//  Created by Morten Kals on 06/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDateCreated: UILabel!
    @IBOutlet weak var detailBody: UITextView!
    @IBOutlet weak var detailTitle: UITextField!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let field = detailDateCreated {
                field.text = "Created: " + detail.timestamp!.description
            }
            if let field = detailBody {
                field.text = detail.body
            }
            if let field = detailTitle {
                field.text = detail.title
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // Notification for end of editing
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func save() {
        if let detail = self.detailItem {
            detail.body = detailBody.text
            
            do {
                try detail.managedObjectContext?.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

}

