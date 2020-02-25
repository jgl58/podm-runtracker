//
//  LocationPoint+CoreDataProperties.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 25/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//
//

import Foundation
import CoreData


extension LocationPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationPoint> {
        return NSFetchRequest<LocationPoint>(entityName: "LocationPoint")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var course: Double
    @NSManaged public var horizontalAccuracy: Double
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var speed: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var verticalAccuracy: Double

}
