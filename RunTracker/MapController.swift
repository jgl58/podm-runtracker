  import UIKit
  import MapKit
  import CoreLocation

  class mapPin {
      let title : String
      let subtitle : String
      let coordinates : [Double]
      
      init(_ title : String, _ subtitle : String, _ coordinates : [Double]){
          self.title = title
          self.subtitle = subtitle
          self.coordinates = coordinates
      }
  }

  class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
      
  {
      @IBOutlet weak var bigMap: MKMapView!
      
      let locationManager = CLLocationManager()
      var pins = [mapPin]()
      
      override func viewDidLoad() {
          super.viewDidLoad()
          self.locationManager.delegate = self
          self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
          self.locationManager.requestWhenInUseAuthorization()
          self.locationManager.startUpdatingLocation()
          /// LA UBICACION POR DEFECTO DEL EMULADOR ES SAN FRANCISCO
          self.bigMap.showsUserLocation = true
          
          
          /// DESPLAZARSE A ESPAÑA PARA VER LOS PINS
          pins.append(mapPin("Compás Musical (Elche)", "Carrer Ruperto Chapí, 51, 03201 Elx, Alicante", [38.268247, -0.703280]))
          pins.append(mapPin("Valencia Musical (Valencia)", "Carrer d'Àngel Guimerà, 11, 46008 València, Valencia", [39.470174, -0.385633]))
          pins.append(mapPin("Instrumentos Musicales Musical 72 (Madrid)", "Calle de la Independencia, 3, 28013 Madrid", [40.417725, -3.709789]))
          pins.append(mapPin("Tempo Instruments (Ontinyent)", "Av. d'Albaida, 12, 46870 Ontinyent, Valencia", [38.823880, -0.599586]))
          pins.append(mapPin("GuitarShop Barcelona (Barcelona)", "Carrer dels Tallers, 27, 08001 Barcelona", [41.384768, 2.168808]))
          pins.append(mapPin("Musical Guima (Granada)", "Camino de Ronda, 71, 18004 Granada", [37.170576, -3.606482]))
          pins.append(mapPin("Musica Bilbao (Bilbao)", "Urkixo Zumarkalea, 92, 48013 Bilbo, Bizkaia", [43.262189, -2.945567]))
          pins.append(mapPin("Rockbox (La Coruña)", "Rúa José Luis Pérez Cepeda, 26, 15004 A Coruña", [43.365512, -8.413180]))
          pins.append(mapPin("Alteisa Sonido Salamanca (Salamanca)", "Calle Azafranal, 44, 37001 Salamanca", [40.967562, -5.659875]))
          pins.append(mapPin("Musical Barragán (Cáceres)", "Calle Colón, 12, 10002 Cáceres", [39.469845, -6.373455]))
          
          var annotation = MKPointAnnotation()
          for pin in pins {
              annotation = MKPointAnnotation()
              annotation.title = pin.title
              annotation.subtitle = pin.subtitle
              annotation.coordinate = CLLocationCoordinate2D(latitude: pin.coordinates[0], longitude: pin.coordinates[1])
              bigMap.addAnnotation(annotation)
          }
          
      
          
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
      
      override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
      }
      
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          let location = locations.last
          let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
          let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
          
          self.bigMap.setRegion(region, animated: true)
  self.locationManager.stopUpdatingLocation()
          
      }
      
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Errors " + error.localizedDescription)
      }
  }
