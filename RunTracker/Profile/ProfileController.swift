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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
