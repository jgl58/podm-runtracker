//
//  HistorialViewController.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData

class HistorialViewController: UITableViewController, NSFetchedResultsControllerDelegate{

    var frc : NSFetchedResultsController<Entrenamiento>!
    var historial : [Entrenamiento] = [Entrenamiento]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
      
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
       /*  let request : NSFetchRequest<Entrenamiento> = NSFetchRequest(entityName:"Entrenamiento")
         guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
             return
         }
         let credSort = NSSortDescriptor(key:"timestamp", ascending:false)
         request.sortDescriptors = [credSort]
         let miContexto = miDelegate.persistentContainer.viewContext
         if let entrenamientos = try? miContexto.fetch(request){
             self.historial = entrenamientos
         }
        */
        let miContexto = miDelegate.persistentContainer.viewContext
           let request : NSFetchRequest<Entrenamiento> = NSFetchRequest(entityName:"Entrenamiento")
           let credSort = NSSortDescriptor(key:"distancia", ascending:true)
           request.sortDescriptors = [credSort]
           self.frc = NSFetchedResultsController<Entrenamiento>(fetchRequest: request, managedObjectContext: miContexto, sectionNameKeyPath: "distancia", cacheName: "miCache")
           
           try! self.frc.performFetch()
           
           self.frc.delegate = self
          self.tableView.reloadData()
           
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.frc.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.frc.sections![section].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "miCelda", for: indexPath)

        let train = self.frc.object(at: indexPath)
        
        cell.textLabel?.text = String(format: "%.2f", train.distancia)+" m"
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: train.timestamp!)
        cell.detailTextLabel?.text = strDate
        return cell
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
