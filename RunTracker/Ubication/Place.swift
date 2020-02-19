//
//  Place.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 19/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import MapKit

class Place: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    @objc init(title:String, subtitle:String, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
