//
//  ProfileController.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 24/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var generoImage: UIImageView!
    @IBOutlet weak var pesoLabel: UILabel!
    @IBOutlet weak var edadLabel: UILabel!
    @IBOutlet weak var alturaLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.nombreLabel.text = self.defaults.string(forKey: "nombre")
        self.pesoLabel.text = (self.defaults.string(forKey: "peso") ?? "00") + " Kg"
        self.edadLabel.text = (self.defaults.string(forKey: "edad") ?? "00") + " años"
        self.alturaLabel.text = (self.defaults.string(forKey: "altura") ?? "00") + " cm"
        if (self.defaults.data(forKey: "imagen") != nil){
            self.userImage.image = UIImage(data: self.defaults.data(forKey: "imagen")!)
        }
        if (self.defaults.string(forKey: "genero") == "Masculino"){
            self.generoImage.image = UIImage(named: "maleIcon")
        }else{
            self.generoImage.image = UIImage(named: "femaleIcon")
        }
        
        
    }
    
    
    @IBAction func cerrarSesion(_ sender: Any) {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "mainController") as UIViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
