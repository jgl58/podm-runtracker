//
//  SignInViewController.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 03/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    var email : String = ""
    var password : String = ""
    
    override func viewDidLoad() {
        self.hideKeyboard()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButton(_ sender: Any) {
        self.email = emailTextField.text ?? ""
        self.password = passwordTextField.text ?? ""
        
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Usuario>(entityName: "Usuario")
        let pred = NSPredicate(format: "email CONTAINS %@ AND password CONTAINS %@", argumentArray: [email, password])
        request.predicate = pred
        if let resultados = try? miContexto.fetch(request){
            print("Hay \(resultados.count) resultados")
            if resultados.count > 0{
                for usuario in resultados {
                    self.defaults.set(usuario.nombre, forKey: "nombre")
                    self.defaults.set(usuario.peso, forKey: "peso")
                    self.defaults.set(usuario.edad, forKey: "edad")
                    self.defaults.set(usuario.altura, forKey: "altura")
                    self.defaults.set(usuario.genero, forKey: "genero")
                    self.defaults.set(usuario.email, forKey: "email")
                    self.defaults.set(usuario.password, forKey: "password")
                    self.defaults.set(usuario.imagen, forKey: "imagen")
                    
                    StateSingleton.shared.usuarioActual = usuario
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "tabBarController") as UIViewController
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                print("No se ha encontrado usuario")
                mostrarAlerta(title: "Error", message: "Usuario no encontrado")
            }
            
        }else{
            print("Error login")
            mostrarAlerta(title: "Error", message: "Error login")
        }
        
    }
    
    func mostrarAlerta(title: String, message: String) {
        let alertGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertGuia.addAction(ok)
        present(alertGuia, animated: true, completion: nil)
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
