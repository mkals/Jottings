//
//  Jotting+CoreDataProperties.swift
//  Jottings
//
//  Created by Morten Kals on 07/05/2017.
//  Copyright © 2017 Kals. All rights reserved.
//

import Foundation
import CoreData


extension Jotting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Jotting> {
        return NSFetchRequest<Jotting>(entityName: "Jotting");
    }
    
    @NSManaged public var author: String
    @NSManaged public var locked: Bool
    @NSManaged public var timestamp: Date
    @NSManaged public var versions: Set<Version>?
    
}

// MARK: Generated accessors for versions
extension Jotting {

    @objc(addVersionsObject:)
    @NSManaged public func addToVersions(_ value: Version)

    @objc(removeVersionsObject:)
    @NSManaged public func removeFromVersions(_ value: Version)

    @objc(addVersions:)
    @NSManaged public func addToVersions(_ values: Set<Version>)

    @objc(removeVersions:)
    @NSManaged public func removeFromVersions(_ values: Set<Version>)

}
