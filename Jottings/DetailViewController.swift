//
//  DetailViewController.swift
//  Jottings
//
//  Created by Morten Kals on 06/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var detailDateCreated: UILabel!
    @IBOutlet weak var detailBody: UITextView!
    @IBOutlet weak var detailTitle: UITextField!
    
    @IBOutlet weak var lockButton: UIButton!
    
    var indexForVersion : IndexPath?
    
    var detailItem: Jotting? {
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

    private func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem  {
            
            if let field = detailDateCreated {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                
                field.text = "Created: " + dateFormatter.string(from: detail.timestamp) + " with versions: " + String(describing: detail.versions?.count)
            }
            
            if let field = detailBody {
                field.text = detail.versionAt(indexPath: indexForVersion).body
            }
            
            if let field = detailTitle {
                
                if let title = detail.versionAt(indexPath: indexForVersion).title {
                    field.text = title
                    if detail.versions?.count == 1 {
                        detailTitle.delegate = self
                        detailTitle.becomeFirstResponder()
                    }
                } else {
                    detailTitle.delegate = self
                    detailTitle.becomeFirstResponder()
                }
            }
            
            if indexForVersion != nil {
                lockButton.isHidden = true
                
                let saveButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(revertToThisVersion))
                self.navigationItem.rightBarButtonItem = saveButton
            }
        } else {
            showWelcomeDisplay()
        }
    }
    
    var lock : Bool = false {
        didSet {
            if lock {
                lockButton.setImage(UIImage.init(named: "locked"), for: .normal)
                lockButton.setImage(UIImage.init(named: "lockedSelected"), for: .selected)
                
                self.detailTitle.isEnabled = false
                self.detailBody.isEditable = false
            } else {
                lockButton.setImage(UIImage.init(named: "unlocked"), for: .normal)
                lockButton.setImage(UIImage.init(named: "unlockedSelected"), for: .selected)
                
                self.detailTitle.isEnabled = true
                self.detailBody.isEditable = true
            }
        }
    }
    
    @IBAction func locking(_ sender: AnyObject) {
        lock = !lock
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Alterts to autosave when ending editing
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
        
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func save() {
        if let detail = self.detailItem {
            if let context = self.detailItem?.managedObjectContext {
                let newVersion = Version(context: context)
                newVersion.jotting = detail
                newVersion.timestamp = Date()
                newVersion.body = detailBody.text
                newVersion.title = detailTitle.text
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVersions" {
            let controller = (segue.destination as! UINavigationController).topViewController as! VersionsTableViewController
            controller.jotting = detailItem
        }
    }
    
    func revertToThisVersion() {
        if let detail = self.detailItem {
            if let context = self.detailItem?.managedObjectContext {
                let newVersion = Version(context: context)
                newVersion.jotting = detail
                newVersion.timestamp = Date()
                let oldVersion = detail.versionAt(indexPath: indexForVersion)
                newVersion.body = oldVersion.body
                newVersion.title = oldVersion.title
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showWelcomeDisplay() {
        self.detailTitle.text = "Welcome!"
        self.detailTitle.isUserInteractionEnabled = false
        
        self.navigationItem.rightBarButtonItem = nil
        self.lockButton.isHidden = true
        self.detailBody.isHidden = true
        self.detailDateCreated.isHidden = true
    }
}

