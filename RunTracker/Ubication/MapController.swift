  import UIKit
  import MapKit
  import CoreLocation
  import CoreMotion
  import CoreData
  import anim
  
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
  
  enum valoresEntreno: Int {
    case tiempo = 0, ritmo = 1, distancia = 2, cadencia = 3
  }

  class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,  NSFetchedResultsControllerDelegate
  {
    @IBOutlet weak var bigMap: MKMapView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var rootView: UIView!
    
    @IBOutlet weak var icono: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var ritmoLabel: UILabel!
    @IBOutlet weak var cadenciaLabel: UILabel!
    @IBOutlet weak var firstText: UILabel!
    @IBOutlet weak var middleText: UILabel!
    @IBOutlet weak var lastText: UILabel!
    
    private let locationManager = CLLocationManager()
    private var locationsHistory: [CLLocation] = []
    private var totalMovementDistance = CLLocationDistance(0)
    
    var training = Training()
    
    var timer = Timer()
    var seconds = 0

    var isRunning : estadoEntreno = .stop
    var isPaused = false
    
    var pins = [mapPin]()
    
    let pedometer = CMPedometer()
    var averagePace: Double = 0
    var totalSteps = 0
    var cadence : Double = 0
    
    let prefs = UserDefaults()
    var precision = 100
    
    var tiempoIntervalo = 0
    var distanciaIntervalo = 0.0
    var contadorIntervalos = 0
    var contadorDistanciaIntervalos = 0.0
    var cadenciaIntervalo = 0.0
    
    var valoresEntrenoPositions : [valoresEntreno] = [.tiempo, .ritmo, .distancia, .cadencia]
    
    var frc : NSFetchedResultsController<LocationPoint>!
    
    var locationIsPaused: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        restoreValoresEntreno()
        initValoresEntreno()
        
        // Get the Graphics Context
        let context = UIGraphicsGetCurrentContext()

        // Set the rectangle outerline-width
        context?.setLineWidth( 5.0)

        // Set the rectangle outerline-colour
        UIColor.red.set()

        // Create Rectangle
        context?.addRect( CGRect(x: 0, y: 0, width: 100, height: 100))

        // Draw
        context?.strokePath()
        
        bigMap.delegate = self
        bigMap.mapType = .standard
        bigMap.userTrackingMode = .follow
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))
        longGesture.minimumPressDuration = 2.0
        //btn.addGestureRecognizer(tapGesture)
        btn.addGestureRecognizer(longGesture)
        btn.addTarget(self, action:#selector(BtnPressed(_:)), for: .touchDown);

        btn.addTarget(self, action:#selector(BtnReleased(_:)), for: .touchUpInside);
        btn.addTarget(self, action:#selector(BtnReleased(_:)), for: .touchCancel);
        btn.addTarget(self, action:#selector(BtnReleased(_:)), for: .touchUpOutside);
          
        let tapGestureTiempo = UITapGestureRecognizer(target: self, action: #selector (tapTiempo))
        tapGestureTiempo.numberOfTapsRequired = 1
        self.timerLabel.addGestureRecognizer(tapGestureTiempo)
        let tapGestureRitmo = UITapGestureRecognizer(target: self, action: #selector (tapRitmo))
        tapGestureRitmo.numberOfTapsRequired = 1
        self.ritmoLabel.addGestureRecognizer(tapGestureRitmo)
        let tapGestureDistancia = UITapGestureRecognizer(target: self, action: #selector (tapDistancia))
        tapGestureDistancia.numberOfTapsRequired = 1
        self.distanceLabel.addGestureRecognizer(tapGestureDistancia)
        let tapGestureCadencia = UITapGestureRecognizer(target: self, action: #selector (tapCadencia))
        tapGestureCadencia.numberOfTapsRequired = 1
        self.cadenciaLabel.addGestureRecognizer(tapGestureCadencia)
        
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
    
    func getValoresEntrenoByLabel(value : UILabel) -> valoresEntreno {
        switch value {
            case self.timerLabel:
                return .tiempo
            case self.ritmoLabel:
                return .ritmo
            case self.distanceLabel:
                return .distancia
            case self.cadenciaLabel:
                return .cadencia
        default:
            return .tiempo
        }
    }
    
    func getLabelbyValoresEntreno(value : valoresEntreno) -> UILabel! {
        switch value {
            case .tiempo:
                return self.timerLabel
            case .ritmo:
                return self.ritmoLabel
            case .distancia:
                return self.distanceLabel
            case .cadencia:
                return self.cadenciaLabel
        }
    }
    
    func getLabelTextbyValoresEntreno(value : valoresEntreno) -> String {
        switch value {
            case .tiempo:
                return "Tiempo"
            case .ritmo:
                return "Ritmo"
            case .distancia:
                return "Distancia"
            case .cadencia:
                return "Cadencia"
        }
    }
    
    func changeLabelTextByPosition(_ value : Int, _ label : UILabel) {
        switch value {
            case 1:
                self.firstText.text = getLabelTextbyValoresEntreno(value: getValoresEntrenoByLabel(value: label))
            case 2:
                self.middleText.text = getLabelTextbyValoresEntreno(value: getValoresEntrenoByLabel(value: label))
            case 3:
                self.lastText.text = getLabelTextbyValoresEntreno(value: getValoresEntrenoByLabel(value: label))
            default:
                break
        }
    }
    
    func initValoresEntreno(){
        let width = self.rootView.frame.size.width
        let height = self.rootView.frame.size.height
        let bottomFontSize = 15
        // TOP
        let label0 = getLabelbyValoresEntreno(value: valoresEntrenoPositions[0])
        changeIcon(valoresEntrenoPositions[0])
        label0!.font = UIFont.systemFont(ofSize: 55)
        label0!.sizeToFit()
        self.icono.frame.size.width = 55
        self.icono.frame.size.height = 55
        let xTotal = label0!.frame.size.width + self.icono.frame.size.width + 20
        let xIcono =  width/2 - xTotal/2 + self.icono.frame.size.width/2
        self.icono.center = CGPoint(x: xIcono,y: 80)
        let xTimer = label0!.frame.size.width/2 + 20
        label0!.center = CGPoint(x: self.icono.center.x + self.icono.frame.size.width/2 +  xTimer,y: 80)
        // LEFT
        let label1 = getLabelbyValoresEntreno(value: valoresEntrenoPositions[1])
        label1!.font = UIFont.systemFont(ofSize: CGFloat(bottomFontSize))
        label1!.sizeToFit()
        label1!.frame.size.width = 75
        label1!.center = CGPoint(x: width*0.08 + label1!.frame.size.width/2,y: height-80)
        self.firstText.text = getLabelTextbyValoresEntreno(value: valoresEntrenoPositions[1])
        self.firstText.frame.size.width = 75
        self.firstText.center = CGPoint(x: width*0.08 + self.firstText.frame.size.width/2,y: height-40)
        //BOTTOM
        let label2 = getLabelbyValoresEntreno(value: valoresEntrenoPositions[2])
        label2!.font = UIFont.systemFont(ofSize: CGFloat(bottomFontSize))
        label2!.sizeToFit()
        label2!.frame.size.width = 75
        label2!.center = CGPoint(x: width/2,y: height-80)
        self.middleText.text = getLabelTextbyValoresEntreno(value: valoresEntrenoPositions[2])
        self.middleText.frame.size.width = 75
        self.middleText.center = CGPoint(x: width/2,y: height-40)
        //RIGHT
        let label3 = getLabelbyValoresEntreno(value: valoresEntrenoPositions[3])
        label3!.font = UIFont.systemFont(ofSize: CGFloat(bottomFontSize))
        label3!.sizeToFit()
        label3!.frame.size.width = 75
        label3!.center = CGPoint(x: width*0.92 - label3!.frame.size.width/2,y: height-80)
        self.lastText.text = getLabelTextbyValoresEntreno(value: valoresEntrenoPositions[3])
        self.lastText.frame.size.width = 75
        self.lastText.center = CGPoint(x: width*0.92 - self.lastText.frame.size.width/2,y: height-40)
    }
    
    func saveValoresEntreno(){
        let auxIntArray : [Int] = [valoresEntrenoPositions[0].rawValue, valoresEntrenoPositions[1].rawValue, valoresEntrenoPositions[2].rawValue, valoresEntrenoPositions[3].rawValue]
        prefs.set(auxIntArray, forKey: "valoresEntrenoPositions")
    }
    
    func restoreValoresEntreno(){
        if prefs.array(forKey: "valoresEntrenoPositions") != nil {
            let auxIntArray = prefs.array(forKey: "valoresEntrenoPositions")  as? [Int] ?? [Int]()
            valoresEntrenoPositions = [valoresEntreno.init(rawValue: auxIntArray[0])!, valoresEntreno.init(rawValue: auxIntArray[1])!, valoresEntreno.init(rawValue: auxIntArray[2])!, valoresEntreno.init(rawValue: auxIntArray[3])!]
        }
    }
    
    func changeIcon(_ value : valoresEntreno){
        switch value {
            case .tiempo:
                self.icono.image = UIImage(named: "clock")
            case .ritmo:
                self.icono.image = UIImage(named: "pulse")
            case .distancia:
                self.icono.image = UIImage(named: "ruler")
            case .cadencia:
                self.icono.image = UIImage(named: "indicador")
        }
    }
    
    var animatingSwap : Bool = false
    
    func animateSwapValues(_ toTop : UILabel, _ position : Int) {
        let top = getLabelbyValoresEntreno(value: valoresEntrenoPositions[0])
        let auxToTop = toTop.center
        
        toTop.font = UIFont.systemFont(ofSize: 55)
        toTop.sizeToFit()
        toTop.font = UIFont.systemFont(ofSize: 15)
        toTop.center = auxToTop
        //toTop.lineBreakMode = .byClipping
        
        self.animatingSwap = true
        
        anim { (settings) -> (animClosure) in
        settings.duration = 0.7
        settings.ease = .easeInOutBack
            return {
                self.changeIcon(self.valoresEntrenoPositions[position])
                
                self.changeLabelTextByPosition(position, top!)
                top!.center = auxToTop
                top!.font = UIFont.systemFont(ofSize: 15)
                
                //toTop.center = auxTop
                let xTotal = toTop.frame.size.width + self.icono.frame.size.width + 20
                let xIcono =  self.rootView.frame.size.width/2 - xTotal/2 + self.icono.frame.size.width/2
                self.icono.center = CGPoint(x: xIcono,y: 80)
                let xTimer = toTop.frame.size.width/2 + 20
                toTop.center = CGPoint(x: self.icono.center.x + self.icono.frame.size.width/2 +  xTimer,y: 80)
            }
        }
        .callback {
            self.animatingSwap = false
        }
        .then{
            toTop.font = UIFont.systemFont(ofSize: 55)
            toTop.sizeToFit()
            let xTotal = toTop.frame.size.width + self.icono.frame.size.width + 20
            let xIcono =  self.rootView.frame.size.width/2 - xTotal/2 + self.icono.frame.size.width/2
            self.icono.center = CGPoint(x: xIcono,y: 80)
            let xTimer = toTop.frame.size.width/2 + 20
            toTop.center = CGPoint(x: self.icono.center.x + self.icono.frame.size.width/2 +  xTimer,y: 80)
        }
        
        /*anim {
            self.changeIcon(self.valoresEntrenoPositions[position])
            
            self.changeLabelTextByPosition(position, top!)
            top!.center = auxToTop
            top!.font = UIFont.systemFont(ofSize: 15)
            
            //toTop.center = auxTop
            let xTotal = toTop.frame.size.width + self.icono.frame.size.width + 20
            let xIcono =  self.rootView.frame.size.width/2 - xTotal/2 + self.icono.frame.size.width/2
            self.icono.center = CGPoint(x: xIcono,y: 80)
            let xTimer = toTop.frame.size.width/2 + 20
            toTop.center = CGPoint(x: self.icono.center.x + self.icono.frame.size.width/2 +  xTimer,y: 80)
        }*/
    }
    
    func adjustAnimateTopValue(){
        if !self.animatingSwap {
            let top = getLabelbyValoresEntreno(value: valoresEntrenoPositions[0])
            top!.sizeToFit()
            anim {
                let xTotal = top!.frame.size.width + self.icono.frame.size.width + 20
                let xIcono =  self.rootView.frame.size.width/2 - xTotal/2 + self.icono.frame.size.width/2
                self.icono.center = CGPoint(x: xIcono,y: 80)
                let xTimer = top!.frame.size.width/2 + 20
                top!.center = CGPoint(x: self.icono.center.x + self.icono.frame.size.width/2 +  xTimer,y: 80)
            }
        }
    }
    
    @objc func tapTiempo() {
        if(valoresEntrenoPositions[0] != .tiempo){
            let auxPos = valoresEntrenoPositions.firstIndex(of: .tiempo)!
            animateSwapValues(getLabelbyValoresEntreno(value: .tiempo), auxPos)
            valoresEntrenoPositions[auxPos] = valoresEntrenoPositions[0]
            valoresEntrenoPositions[0] = .tiempo
            saveValoresEntreno()
        }
    }
    
    @objc func tapRitmo() {
        if(valoresEntrenoPositions[0] != .ritmo){
            let auxPos = valoresEntrenoPositions.firstIndex(of: .ritmo)!
            animateSwapValues(getLabelbyValoresEntreno(value: .ritmo), auxPos)
            valoresEntrenoPositions[auxPos] = valoresEntrenoPositions[0]
            valoresEntrenoPositions[0] = .ritmo
            saveValoresEntreno()
        }
    }
    
    @objc func tapDistancia() {
        if(valoresEntrenoPositions[0] != .distancia){
            let auxPos = valoresEntrenoPositions.firstIndex(of: .distancia)!
            animateSwapValues(getLabelbyValoresEntreno(value: .distancia), auxPos)
            valoresEntrenoPositions[auxPos] = valoresEntrenoPositions[0]
            valoresEntrenoPositions[0] = .distancia
            saveValoresEntreno()
        }
    }
    
    @objc func tapCadencia() {
        if(valoresEntrenoPositions[0] != .cadencia){
            let auxPos = valoresEntrenoPositions.firstIndex(of: .cadencia)!
            animateSwapValues(getLabelbyValoresEntreno(value: .cadencia), auxPos)
            valoresEntrenoPositions[auxPos] = valoresEntrenoPositions[0]
            valoresEntrenoPositions[0] = .cadencia
            saveValoresEntreno()
        }
    }
    
    var animation : anim? = nil
    var isBtnLongPressed : Bool = false
    
    @objc func BtnPressed(_ sender: Any)
    {
        print("pressed")
        self.isBtnLongPressed = false
         self.animation = anim { (settings) -> (animClosure) in
                 settings.duration = 2
            settings.ease = .easeInOutCubic
                 return {
                     self.btn.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                 }
         }
        
     }
    @objc func BtnReleased(_ sender: Any)
    {
        print("released")
         if self.animation != nil {
            self.animation!.stop()
            anim { (settings) -> (animClosure) in
                settings.duration = 0.1
                settings.ease = .easeInOutCubic
                return {
                    self.btn.transform = CGAffineTransform.identity
                }
            }
         }
        if(!isBtnLongPressed){
            print("doThings")
            switch self.isRunning {
            case .play :
                timer.invalidate()
                self.btn.setTitle("Play", for: .normal)
                //locationManager.stopUpdatingLocation()
                pararPodometro()
                self.isRunning = .pause
                self.isPaused = true
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
        }
    }
    
    @objc func long(gesture: UILongPressGestureRecognizer) {
        print("looooong")
        self.isBtnLongPressed = true
        if self.isRunning != .stop {
            if gesture.state == UIGestureRecognizer.State.began {
                
                self.animation!.stop()
                anim { (settings) -> (animClosure) in
                    settings.duration = 0.1
                    settings.ease = .easeInOutCubic
                    return {
                        self.btn.transform = CGAffineTransform.identity
                    }
                }
            }
            self.timer.invalidate()
            self.timer = Timer()
            self.seconds = 0
            self.timerLabel.text = self.timeString(time: 0) //Actualizamos el label.
            self.adjustAnimateTopValue()
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
            self.locationsHistory = []
            self.isPaused = false
            self.locationIsPaused = []
            self.totalMovementDistance = 0
            self.averagePace = 0
            self.totalSteps = 0
        }
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
            
            if(locationsHistory.count > 0){
               training.distance = 200.0
               training.finalPoint = locationsHistory.last!.coordinate
               training.route = locationsHistory
               saveTraining()
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
           
            self.locationsHistory = []
            self.isPaused = false
            self.locationIsPaused = []
            self.totalMovementDistance = 0
            self.averagePace = 0
            self.totalSteps = 0
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
        
        if self.isRunning == .play {
            for newLocation in locations {
              if Int(newLocation.horizontalAccuracy) < self.precision && newLocation.horizontalAccuracy >= 0 {
                   
                    if let previousPoint = locationsHistory.last {
                          print("movement distance: " + "\(newLocation.distance(from: previousPoint))")
                      
                      print(previousPoint.coordinate.latitude)
                        var area = [CLLocationCoordinate2D]()
                        self.locationIsPaused.append(self.isPaused)
                        if self.isPaused == true{
                           area = [newLocation.coordinate, newLocation.coordinate]
                            self.isPaused = false
                        }else{
                            area = [previousPoint.coordinate, newLocation.coordinate]
                            totalMovementDistance += newLocation.distance(from: previousPoint)

                        }
                      
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
                        self.locationIsPaused.append(self.isPaused)
                    }
                    self.locationsHistory.append(newLocation)
                    let distanceString = String(format:"%gm", totalMovementDistance)
                    distanceLabel.text = distanceString
                }
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
            self.checkAutopause()
            self.adjustAnimateTopValue()
        }
    }
    
    var contadorAutopause : Int = 0
    var currentDistancia : String = ""
    //Funcion Autopause
    func checkAutopause() {
        contadorAutopause += 1
        if self.currentDistancia != self.distanceLabel.text! {
            contadorAutopause = 0
            self.currentDistancia = self.distanceLabel.text!
        }
        if contadorAutopause > 28 {
            contadorAutopause = 0
            self.currentDistancia = ""
            timer.invalidate()
            self.btn.setTitle("Play", for: .normal)
            //locationManager.stopUpdatingLocation()
            pararPodometro()
            self.isRunning = .pause
            self.isPaused = true
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
                    let averageActivePace = data?.averageActivePace
                    if currentPace != nil{
                        let conversedCurrentPace = Double(truncating: currentPace!) * (1000/60)
                        let conversedAveragePace = Double(truncating: averageActivePace!) * (1000/60)
                        self.averagePace = conversedAveragePace
                        self.ritmoLabel.text = String(format: "%.2f", conversedCurrentPace)
                        
                    }else{
                        self.ritmoLabel.text = "0.00"
                    }
                    
                    let currentCadence = data?.currentCadence
                    if currentCadence != nil{
                        let conversedCurrentCadence = Double(truncating: currentCadence!) / 60
                        self.cadence = conversedCurrentCadence
                        self.cadenciaLabel.text = String(format: "%.2f", conversedCurrentCadence)
                        
                        if UserDefaults().bool(forKey: "cadenciaActivada") == true && (conversedCurrentCadence <= self.cadenciaIntervalo) {
                            Sonidos.notificarCadencia()
                        }
                    }else{
                        self.cadenciaLabel.text = "0.00"
                    }
                    
                    self.totalSteps = data?.numberOfSteps as! Int
                
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
        train.usuario = StateSingleton.shared.usuarioActual
        train.ritmoMedio = self.averagePace
        train.pasosTotales = Int16(self.totalSteps)
        train.cadenciaMedia = Double(self.totalSteps) / Double(self.seconds)
        print(self.seconds)
        train.segundos = Int16(self.seconds)
        
        var id = 0
        for location in locationsHistory {
            let point = LocationPoint(context: miContexto)
            
            point.latitude = location.coordinate.latitude
            point.longitude = location.coordinate.longitude
            point.timestamp = location.timestamp
            point.id = Int16(id)
            point.isPaused = self.locationIsPaused[id]
            print(point)
            train.addToPuntos(point)
            
            id+=1
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
  
  
