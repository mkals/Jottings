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
                ver.sort(by: {($0.timestamp as! Date) < ($1.timestamp as! Date)})
                return ver
            }
            return Array<Version>()
        }
    }
}
