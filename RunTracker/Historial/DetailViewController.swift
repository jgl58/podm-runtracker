//
//  DetailViewController.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate {

    var entrenamiento : Training?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var labelDistancia: UILabel!
    
    @IBOutlet weak var labelFecha: UILabel!
    @IBOutlet weak var labelTiempo: UILabel!
    @IBOutlet weak var labelRitmo: UILabel!
    @IBOutlet weak var labelPasos: UILabel!
    @IBOutlet weak var labelCalorias: UILabel!
    @IBOutlet weak var labelCadencia: UILabel!
    var arrayLocationsIsPaused = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Indicamos el tipo de mapa que queremos. En este caso normal, ya que no queremos ver la vista de satélite. Únicamente queremos carreteras y caminos/calles.
        
        self.mapView.delegate = self
        self.mapView.mapType = .standard
        self.mapView.userTrackingMode = .follow
        
    
        configureView()
    }
    
    func configureView() {
        if let entreno = self.entrenamiento {
            
            if var previousLocation = entreno.route.first{
                var contador = 0
                for locationDict in entreno.route {
                var area : [CLLocationCoordinate2D]
                if self.arrayLocationsIsPaused[contador] == true {
                    area = [locationDict.coordinate, locationDict.coordinate]
                }else{
                    area = [previousLocation.coordinate, locationDict.coordinate]
                }
                    
                let polyline = MKPolyline(coordinates: &area, count: area.count)
                self.mapView.addOverlay(polyline)
                    
                    previousLocation = locationDict

                contador += 1
            }
            let region = MKCoordinateRegion(center: entreno.route.first!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            }
            
            if let inicio = entreno.route.first {
                let start = Place(title: "Inicio", subtitle: "Punto inicial de tu ruta", coordinate: inicio.coordinate)
                // Añadimos la anotación.
                self.mapView.addAnnotation(start)
            }
            
            if let final = entreno.route.last {
                let end = Place(title: "Final", subtitle: "Punto final de tu ruta", coordinate: final.coordinate)
                // Añadimos la anotación.
                self.mapView.addAnnotation(end)
            }
        
//           Mostrar detalles entrenamiento
            self.labelDistancia.text = String(format: "%.2f", (entrenamiento!.distance / 1000))+" km"
            
            self.labelTiempo.text = secondsToHoursMinutesSeconds(time: Int(self.entrenamiento!.segundos))
            
            self.labelRitmo.text = String(format: "%.2f",Double(self.entrenamiento!.ritmoMedio)) + " min/km"
            
            self.labelCadencia.text = String(format: "%.2f", self.entrenamiento!.cadenciaMedia) + " pasos/min"
            
            self.labelCalorias.text = String(format: "%.2f", self.entrenamiento!.calorias) + " cal"
            
            self.labelPasos.text = String(self.entrenamiento!.pasos) + " pasos"
            
            let dateFormatter = DateFormatter()
                  dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                  dateFormatter.locale = NSLocale.current
                  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
            let strDate = dateFormatter.string(from: self.entrenamiento!.date)
            self.labelFecha.text = strDate
            
            
        }
    }
    
    func secondsToHoursMinutesSeconds (time : Int) -> String{
        
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    // Método que actualiza la vista del mapa.
    // Recibe un objeto de tipo MKOverlay y devuelve uno de tipo MKOverlayRenderer, el cual no es más que un objeto que contiene toda la información necesaria
    // para que un objeto que se ajusta al protocolo MKOverlay pueda renderizarse correctamente.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.blue
            pr.lineWidth = 5
            return pr
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func coordinateRegionForCoordinates(coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var r: MKMapRect = MKMapRect.null
        for coord in coords {
            let p: MKMapPoint = MKMapPoint(coord)
            r = r.union(MKMapRect(x: p.x, y: p.y, width: 0, height: 0))
        }
        return MKCoordinateRegion(r)
    }

}
