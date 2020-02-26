//
//  Training.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation
import CoreLocation

class Training {
    var distance : Double
    var startPoint : CLLocationCoordinate2D
    var finalPoint : CLLocationCoordinate2D
    var route : [CLLocation]
    
    init(){
        self.distance = 0.0
        self.startPoint = CLLocationCoordinate2D()
        self.finalPoint = CLLocationCoordinate2D()
        self.route = [CLLocation]()
    }
}
