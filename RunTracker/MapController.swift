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
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    private let locationManager = CLLocationManager()
    private var locationsHistory: [CLLocation] = []
    private var totalMovementDistance = CLLocationDistance(0)
    
    var timer = Timer()
    var seconds = 0
    var isTimerRunning = false
    
      var pins = [mapPin]()
      
      override func viewDidLoad() {
          super.viewDidLoad()
    
        bigMap.delegate = self
        bigMap.mapType = .standard
        bigMap.userTrackingMode = .follow
          
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tap))  //Tap function will call when user tap on button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))  //Long function will call when user long press on button.
          tapGesture.numberOfTapsRequired = 1
          btn.addGestureRecognizer(tapGesture)
          btn.addGestureRecognizer(longGesture)
          
      
          
      }
    //Funcion para controlar el tap del botnon play
    @objc func tap() {

        print("Tap happend")
        if self.isTimerRunning == true {
            timer.invalidate()
            self.btn.setTitle("Play", for: .normal)
            self.isTimerRunning = false
            locationManager.stopUpdatingLocation()
        } else {
            runTimer()
            self.btn.setTitle("Pause", for: .normal)
            locationManager.startUpdatingLocation()
            self.isTimerRunning = true
        }
    }

    @objc func long() {
        print("Long press")
    }
      
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          if (overlay is MKPolyline) {
              let pr = MKPolylineRenderer(overlay: overlay)
              pr.strokeColor = UIColor.red
              pr.lineWidth = 5
              return pr
          } else {
              return MKOverlayRenderer(overlay: overlay)
          }
          
      }
      
      override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
      }
      
    func locationManager(_ manager: CLLocationManager,
                            didChangeAuthorization status: CLAuthorizationStatus) {

           print("Authorization status changed to \(status.rawValue)")
           switch status {
           case .authorizedAlways, .authorizedWhenInUse:
               locationManager.requestLocation()
               print("Empezamos a sondear la ubicación")
               bigMap.showsUserLocation = true
           default:
               locationManager.stopUpdatingLocation()
               print("Paramos el sondeo de la ubicación")
               bigMap.showsUserLocation = false
           }
           
       }
    
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          if let location = locations.last{
              let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
              self.bigMap.setRegion(region, animated: true)
          }
          
          
          for newLocation in locations {
              if newLocation.horizontalAccuracy < 10 && newLocation.horizontalAccuracy >= 0 && newLocation.verticalAccuracy < 50 {
                 
                  if let previousPoint = locationsHistory.last {
                        print("movement distance: " + "\(newLocation.distance(from: previousPoint))")
                    
                            totalMovementDistance += newLocation.distance(from: previousPoint)
                            var area = [previousPoint.coordinate, newLocation.coordinate]
                            let polyline = MKPolyline(coordinates: &area, count: area.count)
                            bigMap.addOverlay(polyline)
                        
                  } else
                  {
                      let start = Place(title:"Inicio",
                                        subtitle:"Este es el punto de inicio de la ruta",
                                        coordinate:newLocation.coordinate)
                      bigMap.addAnnotation(start)
                  }
                  self.locationsHistory.append(newLocation)
                  let distanceString = String(format:"%gm", totalMovementDistance)
                  distanceLabel.text = distanceString
              }
          }
          
      }
      
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           let alertController = UIAlertController(title: "Location Manager Error", message: error.localizedDescription , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in })
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
      }
    
    //Funcion de cronometro
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.seconds += 1
            self.timerLabel.text = self.timeString(time: TimeInterval(self.seconds)) //Actualizamos el label.
            
        }
    }
    
    //Funcion que convierte los datos de tipo time a String
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
  }
  
  
