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
                var ver = verSet.allObjects as! [Version]
                ver.sort(by: {$0.timestamp < $1.timestamp})
                return ver
            }
            return Array<Version>()
        }
    }
    
    var versionsArrayDates : Array<Array<Version>> {
        get {
            var returnArray = Array<Array<Version>>()
            
            for version in self.versionsArray {
                if let temp = returnArray.last {
                    
                    let date1 = version.timestamp
                    let date2 = temp.first!.timestamp
                    
                    let diff = NSCalendar.current.dateComponents([Calendar.Component.day], from: date1, to: date2)
                    
                    if diff.day == 0 {
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
            return versionsArray.last!
        }
    }
}
