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
      @IBOutlet weak var btn: UIButton!

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
          
          
          
          var annotation = MKPointAnnotation()
          for pin in pins {
              annotation = MKPointAnnotation()
              annotation.title = pin.title
              annotation.subtitle = pin.subtitle
              annotation.coordinate = CLLocationCoordinate2D(latitude: pin.coordinates[0], longitude: pin.coordinates[1])
              bigMap.addAnnotation(annotation)
          }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tap))  //Tap function will call when user tap on button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))  //Long function will call when user long press on button.
          tapGesture.numberOfTapsRequired = 1
          btn.addGestureRecognizer(tapGesture)
          btn.addGestureRecognizer(longGesture)
          
      
          
      }
    
    @objc func tap() {

        print("Tap happend")
    }

    @objc func long() {

        print("Long press")
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
