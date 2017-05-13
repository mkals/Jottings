//
//  Jotting+CoreDataClass.swift
//  Jottings
//
//  Created by Morten Kals on 07/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import Foundation
import CoreData


public class Jotting: NSManagedObject {
        
    var current : Version? {
        get {
            return versionsArray.last
        }
    }
    
    var versionsArray : Array<Version> {
        get {
            if let verSet = self.versions {
                return verSet.sorted(by: {$0.timestamp < $1.timestamp})
            }
            return Array<Version>()
        }
    }
    
    var versionsArrayDates : Array<Array<Version>> {
        get {
            var returnArray = Array<Array<Version>>()
            
            for version in self.versionsArray {
                if let temp = returnArray.last {
                    
                    let deltat = NSCalendar.current.dateComponents([Calendar.Component.day], from: version.timestamp, to: temp.first!.timestamp)

                    if deltat.day == 0 {
                        returnArray[returnArray.count - 1].append(version)
                    } else {
                        returnArray.append([version])
                    }
                } else {
                    returnArray.append([version])
                }
            }
            return returnArray
        }
    }
    
    func versionAt(indexPath: IndexPath?) -> Version {
        if let path = indexPath {
            return versionsArrayDates[path.section][path.row]
        } else {
            if let last = versionsArray.last {
                return last
            } else {
                let ver = Version(context: self.managedObjectContext!)
                ver.jotting = self
                ver.timestamp = Date()
                return ver
            }
        }
    }
    
    func cleanVesions() {
        for i in 0...(versionsArray.count-2) {
            
            let deltat = NSCalendar.current.dateComponents([Calendar.Component.minute], from: versionsArray[i].timestamp, to: versionsArray[i+1].timestamp)
            
            if deltat.minute! < 10 {
                self.managedObjectContext?.delete(versionsArray[i])
            }
        }
    }
}
