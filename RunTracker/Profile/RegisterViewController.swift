//
//  RegisterViewController.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 03/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var nombre: String = ""
    var genero: String = ""
    var edad: Int = 0
    var altura: Int = 0
    var peso: Int = 0
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func registroUsuario(_ sender: Any) {
        if let email = self.emailTextField.text, let password = self.passwordTextField.text, let confirmationPassword = self.confirmPasswordTextField.text{
            if password == confirmationPassword {
                let miDelegate = UIApplication.shared.delegate as! AppDelegate
                let miContexto = miDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<Usuario>(entityName: "Usuario")
                let pred = NSPredicate(format: "email CONTAINS %@", argumentArray: [email])
                request.predicate = pred
                if let resultados = try? miContexto.fetch(request){
                    if resultados.count > 0{
                        mostrarAlerta(title: "Error", message: "Email ya registrado")
                    }else{
                        let u = Usuario(context: miContexto)
                        u.nombre = nombre
                        u.email = email
                        u.password = password
                        u.edad = Int32(edad)
                        u.genero = genero
                        u.altura = Int32(altura)
                        u.peso = Int32(peso)
                        do{
                            try miContexto.save()
                            
                            self.defaults.set(nombre, forKey: "nombre")
                            self.defaults.set(peso, forKey: "peso")
                            self.defaults.set(edad, forKey: "edad")
                            self.defaults.set(altura, forKey: "altura")
                            self.defaults.set(genero, forKey: "genero")
                            self.defaults.set(email, forKey: "email")
                            self.defaults.set(password, forKey: "password")
                            
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(identifier: "tabBarController") as UIViewController
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                            
                            print("Guardado usuario")
                        }catch{
                            print("Error al guardar usuario")
                            mostrarAlerta(title: "Error", message: "Usuario no guardado")
                        }

                    }
                }
                

            }else{
                mostrarAlerta(title: "Error", message: "Contraseñas no coinciden")
            }
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
