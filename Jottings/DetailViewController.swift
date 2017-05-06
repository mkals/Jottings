//
//  DetailViewController.swift
//  Jottings
//
//  Created by Morten Kals on 06/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var detailDateCreated: UILabel!
    @IBOutlet weak var detailBody: UITextView!
    @IBOutlet weak var detailTitle: UITextField!
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
            if let field = detailDateCreated {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                
                field.text = "Created: " + dateFormatter.string(from: (detail.timestamp! as Date))
            }
            
            if let field = detailBody {
                field.text = detail.body
            }
            
            if let field = detailTitle {
                
                if let title = detail.title {
                    field.text = title
                } else {
                    detailTitle.delegate = self
                    detailTitle.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // Alterts to autosave when ending editing
        NotificationCenter.default.addObserver(self, selector: #selector(saveBody), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveTitle), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            self.configureView()
            
            // Update the database
            do {
                try self.detailItem?.managedObjectContext?.save()
            } catch {
                // alert user
                let alert = UIAlertController(title: "Warning", message: "We can not save your data for some reason. Do not exit the application before you have coppied the new inforation you have inserted since you started editing this text field. ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)") // TODO: remove before deploy
            }
        }
    }
    
    func saveTitle() {
        if let detail = self.detailItem {
            detail.title = detailTitle.text
        }
    }
    
    func saveBody() {
        if let detail = self.detailItem {
            detail.body = detailBody.text
        }
    }
}

