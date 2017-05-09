//
//  Version+CoreDataProperties.swift
//  Jottings
//
//  Created by Morten Kals on 07/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import Foundation
import CoreData
 

extension Version {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Version> {
        return NSFetchRequest<Version>(entityName: "Version");
    }
    
    @NSManaged public var body: String?
    @NSManaged public var timestamp: Date
    @NSManaged public var title: String?
    @NSManaged public var jotting: Jotting?

}
