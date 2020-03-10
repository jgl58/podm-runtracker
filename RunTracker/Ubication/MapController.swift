  import UIKit
  import MapKit
  import CoreLocation
  import CoreMotion
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
  
  enum estadoEntreno: String {
    case play, pause, stop
  }

  class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,  NSFetchedResultsControllerDelegate
  {
      @IBOutlet weak var bigMap: MKMapView!
      @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var ritmoLabel: UILabel!
    @IBOutlet weak var cadenciaLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    private var locationsHistory: [CLLocation] = []
    private var totalMovementDistance = CLLocationDistance(0)
    
    var training = Training()
    
    var timer = Timer()
    var seconds = 0

    var isRunning : estadoEntreno = .stop
    
    var pins = [mapPin]()
    
    let pedometer = CMPedometer()
    var averagePace: Double = 0
    
    let prefs = UserDefaults()
    var precision = 100
    
    var tiempoIntervalo = 0
    var distanciaIntervalo = 0.0
    var contadorIntervalos = 0
    var contadorDistanciaIntervalos = 0.0
    var cadenciaIntervalo = 0.0
    
    var frc : NSFetchedResultsController<LocationPoint>!
          
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        switch self.prefs.integer(forKey:"precision") {
        case 0:
            self.precision = 100
        case 1:
            self.precision = 50
        case 2:
            self.precision = 20
        default:
            self.precision = 100
        }
    }
    
    
    //Funcion para controlar el tap del botnon play
    @objc func tap() {
        
        switch self.isRunning {
        case .play :
            timer.invalidate()
            self.btn.setTitle("Play", for: .normal)
            locationManager.stopUpdatingLocation()
            pararPodometro()
            self.isRunning = .pause
        case .stop,
            .pause:
            runTimer()
            self.btn.setTitle("Pause", for: .normal)
            locationManager.startUpdatingLocation()
            self.locationManager.allowsBackgroundLocationUpdates = true
            iniciarPodometro()
            setIntervalos()
            self.isRunning = .play
        }
        print("Tap happend")
        
    }
    
    func setIntervalos(){
        let intervaloTiempoActivado = UserDefaults().bool(forKey: "intervaloTiempoActivado")
        let intervaloDistanciaActivada = UserDefaults().bool(forKey: "intervaloDistanciaActivada")
        let intervaloCadenciaActivada = UserDefaults().bool(forKey: "cadenciaActivada")
        
         if intervaloTiempoActivado == true {
             let intervaloTiempo = UserDefaults().integer(forKey: "intervaloTiempo")
             switch intervaloTiempo {
             case 0:
                self.tiempoIntervalo = 60
             case 1:
               self.tiempoIntervalo = 300
             case 2:
                self.tiempoIntervalo = 600
             case 3:
                self.tiempoIntervalo = 1800
             default:
                self.tiempoIntervalo = 3600
            }
             
         }
        if intervaloDistanciaActivada == true {
             let intervaloTiempo = UserDefaults().integer(forKey: "intervaloDistancia")
             switch intervaloTiempo {
             case 0:
                self.distanciaIntervalo = 1000.0
             case 1:
                self.distanciaIntervalo = 2500.0
             case 2:
                self.distanciaIntervalo = 5000.0
             case 3:
                self.distanciaIntervalo = 10000.0
             default:
                self.distanciaIntervalo = 20000.0
            }
             
         }
        
        if intervaloCadenciaActivada == true {
            let intervaloTiempo = UserDefaults().integer(forKey: "cadencia")
            switch intervaloTiempo {
            case 0:
               self.cadenciaIntervalo = 50.0
            case 1:
               self.cadenciaIntervalo = 500.0
            default:
               self.cadenciaIntervalo = 5000.0
           }
            
        }
        
    }

    @objc func long(gesture: UILongPressGestureRecognizer) {
        
        if self.isRunning != .stop {
            if gesture.state == UIGestureRecognizer.State.began {
                UIView.animate(withDuration: 0.6,
                animations: {
                    self.btn.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.6) {
                        self.btn.transform = CGAffineTransform.identity
                    }
                })
            }
            self.timer = Timer()
            self.seconds = 0
            self.timerLabel.text = self.timeString(time: 0) //Actualizamos el label.
            self.btn.setTitle("Play", for: .normal)
            self.isRunning = .stop
            locationManager.stopUpdatingLocation()
            self.locationManager.allowsBackgroundLocationUpdates = false
            pararPodometro()
            self.bigMap.removeOverlays(bigMap.overlays)
            if(locationsHistory.count > 0){
                training.distance = 200.0
                training.finalPoint = locationsHistory.last!.coordinate
                training.route = locationsHistory
                saveTraining()
            }
        }
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
            if Int(newLocation.horizontalAccuracy) < self.precision && newLocation.horizontalAccuracy >= 0 {
                 
                  if let previousPoint = locationsHistory.last {
                        print("movement distance: " + "\(newLocation.distance(from: previousPoint))")
                    
                    print(previousPoint.coordinate.latitude)
                    totalMovementDistance += newLocation.distance(from: previousPoint)
                    self.contadorDistanciaIntervalos += newLocation.distance(from: previousPoint)
                    var area = [previousPoint.coordinate, newLocation.coordinate]
                    let polyline = MKPolyline(coordinates: &area, count: area.count)
                    bigMap.addOverlay(polyline)
                    
                    if UserDefaults().bool(forKey: "intervaloTiempoActivado") == true && (self.contadorIntervalos == self.tiempoIntervalo) {
                        self.contadorIntervalos = 0
                        Sonidos.notificarIntervaloTiempo()
                    }
                    
                    if UserDefaults().bool(forKey: "intervaloDistanciaActivada") == true && (self.contadorDistanciaIntervalos >= self.distanciaIntervalo) {
                        self.contadorDistanciaIntervalos = 0.0
                        Sonidos.notificarIntervaloDistancia()
                    }
                    
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
            self.contadorIntervalos += 1
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
    
    func iniciarPodometro(){
        if CMPedometer.isPedometerEventTrackingAvailable() || CMPedometer.isStepCountingAvailable(){
            self.ritmoLabel.text = "0.00"
            self.cadenciaLabel.text = "0.00"
            self.pedometer.startUpdates(from: Date()) { (data, error) in
                DispatchQueue.main.async {
                    let formatter = NumberFormatter()
                    formatter.maximumFractionDigits = 2
                    formatter.minimumFractionDigits = 2
                    
                    let currentPace = data?.currentPace
                    let averagePace = data?.averageActivePace
                    if currentPace != nil{
                        let conversedCurrentPace = Double(truncating: currentPace!) * (1000/60)
                        let conversedAveragePace = Double(truncating: averagePace!) * (1000/60)
                        self.averagePace = conversedAveragePace
                        self.ritmoLabel.text = String(format: "%.2f", conversedCurrentPace)
                        
                    }else{
                        self.ritmoLabel.text = "0.00"
                    }
                    
                    let currentCadence = data?.currentCadence
                    if currentCadence != nil{
                        let conversedCurrentCadence = Double(truncating: currentCadence!) * (1000/60)
                        self.cadenciaLabel.text = String(format: "%.2f", conversedCurrentCadence)
                        
                        if UserDefaults().bool(forKey: "cadenciaActivada") == true && (conversedCurrentCadence <= self.cadenciaIntervalo) {
                            Sonidos.notificarCadencia()
                        }
                    }else{
                        self.cadenciaLabel.text = "0.00"
                    }
                
                    print("Ritmo: " + (data?.currentPace?.stringValue ?? "Nada"))
                    print("Cadencia: " + (data?.currentCadence?.stringValue ?? "Nada"))
                }
            }
        }else{
            print("Podómetro no disponible")
        }
        
    }
    
    func pararPodometro(){
        self.pedometer.stopUpdates()
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
  
  
