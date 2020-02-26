//
//  HistorialViewController.swift
//  RunTracker
//
//  Created by Jonay Gilabert López on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData

class HistorialViewController: UIViewController {

    var historial : [Entrenamiento] = [Entrenamiento]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         let miDelegate = UIApplication.shared.delegate! as! AppDelegate
           let miContexto = miDelegate.persistentContainer.viewContext

           do{
               historial = try miContexto.fetch(Entrenamiento.fetchRequest() as NSFetchRequest<Entrenamiento>)
           }catch{
               print("Error al leer los puntos")
           }
           
           
           if historial.count > 0 {
               for train in historial {
                   print(train.distancia)
                   print(train.timestamp)
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
