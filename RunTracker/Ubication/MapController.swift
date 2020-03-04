  import UIKit
  import MapKit
  import CoreLocation
  import CoreData
  
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

  class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,  NSFetchedResultsControllerDelegate
  {
      @IBOutlet weak var bigMap: MKMapView!
      @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    private let locationManager = CLLocationManager()
    private var locationsHistory: [CLLocation] = []
    private var totalMovementDistance = CLLocationDistance(0)
    
    var training = Training()
    
    var timer = Timer()
    var seconds = 0
    var isTimerRunning = false
    
    var frc : NSFetchedResultsController<LocationPoint>!
    
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
            if(locationsHistory.count > 0){
                training.distance = 200.0
               training.finalPoint = locationsHistory.last!.coordinate
               training.route = locationsHistory
                saveTraining()
            }
           
            
        } else {
            runTimer()
            self.btn.setTitle("Pause", for: .normal)
            locationManager.startUpdatingLocation()
            self.isTimerRunning = true
        }
    }

    @objc func long() {
        print("Long press")
        locationManager.stopUpdatingLocation()
        
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
              if newLocation.horizontalAccuracy < 20 && newLocation.horizontalAccuracy >= 0 {
                 
                  if let previousPoint = locationsHistory.last {
                        print("movement distance: " + "\(newLocation.distance(from: previousPoint))")
                    
                    print(previousPoint.coordinate.latitude)
                            totalMovementDistance += newLocation.distance(from: previousPoint)
                            var area = [previousPoint.coordinate, newLocation.coordinate]
                            let polyline = MKPolyline(coordinates: &area, count: area.count)
                            bigMap.addOverlay(polyline)
                  } else
                  {
                   
                    training.startPoint = newLocation.coordinate
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
    
    
    func readLocation(){
        let miDelegate = UIApplication.shared.delegate! as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext

        do{
        let point = try miContexto.fetch(LocationPoint.fetchRequest() as NSFetchRequest<LocationPoint>)
        print(point.count)
        }catch{
            print("Error al leer los puntos")
        }
    }
    
    func saveTraining(){
        let miDelegate = UIApplication.shared.delegate! as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let train = Entrenamiento(context: miContexto)
        train.timestamp = Date()
        train.distancia = (distanceLabel.text! as NSString).doubleValue

        for location in locationsHistory {
            let point = LocationPoint(context: miContexto)
            
            point.latitude = location.coordinate.latitude
            point.longitude = location.coordinate.longitude
            point.timestamp = location.timestamp
            print(point)
            train.addToPuntos(point)
        }
        
        do{
            try miContexto.save()
            print("Punto guardado")
        }catch
        {
            print("Error al guardar el punto")
        }
        
    }
  }
  
  
