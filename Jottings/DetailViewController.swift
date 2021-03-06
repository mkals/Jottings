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
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var indexForVersion: IndexPath?
    var detailItem: Jotting?
    
    var saveTimer: Timer = Timer.init()
    var needsSave: Bool = false {
        didSet {
            if needsSave == true && !saveTimer.isValid {
                saveTimer = Timer.scheduledTimer(timeInterval: TimeInterval.init(3), target: self, selector: #selector(save), userInfo: nil, repeats: false)
            }
            if needsSave == false {
                saveTimer.invalidate()
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
                }
            }
            
            if indexForVersion != nil {
                self.detailTitle.isEnabled = false
                self.detailBody.isEditable = false
                self.lockButton.isHidden = true
                
                let restoreButton = UIBarButtonItem.init(title: "Restore", style: .plain, target: self, action: #selector(revertToThisVersion))
                self.navigationItem.rightBarButtonItem = restoreButton
            } else if lockButton != nil {
                locked = detail.locked
            }

        } else {
            showWelcomeDisplay()
        }
    }
    
    
    
    var locked : Bool = false {
        didSet {
            //Update UI to reflext new locked state
            if indexForVersion != nil {
                return
            }
            
            if locked {
                lockButton.setImage(UIImage.init(named: "locked"), for: .normal)
                lockButton.setImage(UIImage.init(named: "lockedSelected"), for: .selected)
                
                self.detailTitle.isEnabled = false
                self.detailBody.isEditable = false
                
                save()
                
            } else {
                lockButton.setImage(UIImage.init(named: "unlocked"), for: .normal)
                lockButton.setImage(UIImage.init(named: "unlockedSelected"), for: .selected)
                
                self.detailTitle.isEnabled = true
                self.detailBody.isEditable = true
            }
        }
    }
    
    @IBAction func locking(_ sender: AnyObject) {
        locked = !locked
        
        // save locked state
        detailItem?.locked = locked
        needsSave = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Alterts to autosave when ending editing
        NotificationCenter.default.addObserver(self, selector: #selector(textEditingOccured), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textEditingOccured), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillMove), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillMove), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        save()
    }
    
    func keyboardWillMove(notification: NSNotification) {
        let userInfo = notification.userInfo!
            
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions.init(rawValue: UInt(rawAnimationCurve))
        
        bottomHeight.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func textEditingOccured() {
        needsSave = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*!
     * @discussion Function to save current detail item at appropirate time intervals to ensure power efficiency and limit the possibility of data loss.
     */
    func save() {
        if !needsSave {
            return
        }
        
        if let detail = self.detailItem {
            if let context = self.detailItem?.managedObjectContext {
                let newVersion = Version(context: context)
                newVersion.jotting = detail
                newVersion.timestamp = Date()
                newVersion.body = detailBody.text
                newVersion.title = detailTitle.text
                
                // Update the database
                do {
                    try context.save()
                    needsSave = false
                    detailItem?.cleanVesions()
                } catch {
                    // alert user
                    let alert = UIAlertController(title: "Warning", message: "We can not save your data for some reason. Do not exit the application before you have copied the new inforation you have inserted since you started editing this text field. ", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)") // TODO: remove before deploy
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVersions" {
            let controller = (segue.destination as! UINavigationController).topViewController as! VersionsTableViewController
            controller.jotting = detailItem
        }
        save()
    }
    
    /*!
     * @discussion Reverts to current version by copying its state to a new version with the current time stamp.
     */
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
        
        if self.navigationItem.rightBarButtonItem != nil {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        if self.navigationItem.rightBarButtonItem != nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        if let button = self.lockButton {
            button.isHidden = true
        }
        
        if let body = self.detailBody {
            body.isHidden = true
        }
        
        if let date = self.detailDateCreated {
            date.isHidden = true
        }
    }
}

