//
//  Training.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

class Training {
    var distance : Double
    var startPoint : CLLocationCoordinate2D
    var finalPoint : CLLocationCoordinate2D
    var route : [CLLocation]
    var date : Date
    var ritmoMedio : Double
    var pasos : Int16
    var cadenciaMedia : Double
    var segundos : Int16
    
    init(){
        self.distance = 0.0
        self.startPoint = CLLocationCoordinate2D()
        self.finalPoint = CLLocationCoordinate2D()
        self.route = [CLLocation]()
        self.date = Date()
        self.ritmoMedio = 0.0
        self.pasos = 0
        self.cadenciaMedia = 0.0
        self.segundos = 0
    }
    
}
