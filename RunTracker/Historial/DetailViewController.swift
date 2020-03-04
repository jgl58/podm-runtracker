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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.labelDistancia.text = String(format: "%.2f", entrenamiento!.distance)+" m"
           /* self.paceLabel.text = String(format: "%.2f", entreno.ritmoMedio)
            self.cadenceLabel.text = String(format: "%.2f", entreno.cadenciaMedia)
            self.dateLabel.text = dateFormatter.string(from: entreno.fechaInicio)
            self.durationLabel.text = timeString(time: TimeInterval(entreno.duracion))*/
            
            var locationArray = [CLLocationCoordinate2D]()
            for locationDict in entreno.route {
                let location = CLLocationCoordinate2D(latitude: locationDict.coordinate.latitude, longitude: locationDict.coordinate.longitude)
                print(String(location.latitude)+" "+String(location.longitude))
                locationArray.append(location)
            }
            
            if let inicio = locationArray.first {
                let start = Place(title: "Inicio", subtitle: "Punto inicial de tu ruta", coordinate: entrenamiento!.startPoint)
                // Añadimos la anotación.
                self.mapView.addAnnotation(start)
            }
            
            if let final = locationArray.last {
                let end = Place(title: "Final", subtitle: "Punto final de tu ruta", coordinate: entrenamiento!.finalPoint)
                // Añadimos la anotación.
                self.mapView.addAnnotation(end)
            }
            
            
            let region = coordinateRegionForCoordinates(coords: locationArray)
            self.mapView.setRegion(region, animated: true)
            
            let polyline = MKPolyline(coordinates: locationArray, count: locationArray.count)
            self.mapView.addOverlay(polyline)
        
        }
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }

}