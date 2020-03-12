//
//  HistorialViewController.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class HistorialViewController: UITableViewController, NSFetchedResultsControllerDelegate{

    var historial : [Entrenamiento] = [Entrenamiento]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
      
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else {
            return
        }
           let credSort = NSSortDescriptor(key:"timestamp", ascending:false)
        self.historial = StateSingleton.shared.usuarioActual.entrenamientos?.sortedArray(using: [credSort]) as! [Entrenamiento]
           
           
          self.tableView.reloadData()
           
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.historial.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "miCelda", for: indexPath)

        let train = self.historial[indexPath.row]
        
        print("Distancia: "+String(format: "%.2f", (self.historial[indexPath.row].distancia))+" km")
        cell.textLabel?.text = String(format: "%.2f", (train.distancia / 1000))+" km"
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: train.timestamp!)
        cell.detailTextLabel?.text = strDate
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            if let indexPath = self.tableView.indexPathForSelectedRow{
               let detailVC = segue.destination as! DetailViewController
    
               let train = Training()
                train.distance = self.historial[indexPath.row].distancia
                train.date = self.historial[indexPath.row].timestamp!
                train.ritmoMedio = self.historial[indexPath.row].ritmoMedio
                train.pasos = self.historial[indexPath.row].pasosTotales
                train.cadenciaMedia = self.historial[indexPath.row].cadenciaMedia
                print("Segundos "+String(self.historial[indexPath.row].segundos))
                train.segundos = self.historial[indexPath.row].segundos
                
                train.calorias = self.historial[indexPath.row].calorias
                
                let credSort = NSSortDescriptor(key:"id", ascending:true)
                let arrayPuntos = self.historial[indexPath.row].puntos?.sortedArray(using: [credSort]) as! [LocationPoint]
                
                
                for p in arrayPuntos {
                    train.route.append(CLLocation(latitude: p.latitude, longitude: p.longitude))
                    detailVC.arrayLocationsIsPaused.append(p.isPaused)
                }
                train.startPoint = CLLocationCoordinate2D(latitude: arrayPuntos.first!.latitude, longitude: arrayPuntos.first!.longitude)
                train.finalPoint = CLLocationCoordinate2D(latitude: arrayPuntos.last!.latitude, longitude: arrayPuntos.last!.longitude)
                
               detailVC.entrenamiento = train
           }
        }
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
