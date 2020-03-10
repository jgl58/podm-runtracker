//
//  EditProfileController.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 24/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
import CoreData

class EditProfileController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usuarioImage: UIImageView!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var pesoTextField: UITextField!
    @IBOutlet weak var edadTextField: UITextField!
    @IBOutlet weak var alturaTextField: UITextField!
    @IBOutlet weak var generoPicker: UIPickerView!
    
    let generos = ["Masculino","Femenino"]
    
    //controlador que nos permite seleccionar la imagen
    let imagePicker = UIImagePickerController()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generoPicker.delegate = self
        generoPicker.dataSource = self
        
        imagePicker.delegate = self
        

        // Do any additional setup after loading the view.
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return generos.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return generos[row]
    }
    
    @IBAction func seleccionarFotoGaleria(_ sender: Any) {
        //no aparecen las herramientas de edicion al elegir imagen
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        //mostramos la galeria
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.usuarioImage.image = info[.originalImage] as? UIImage
        //oculta la galeria
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func guardar(_ sender: Any) {
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        let u = StateSingleton.shared.usuarioActual!
        u.nombre = nombreTextField.text
        u.edad = Int32(edadTextField?.text ?? self.defaults.string(forKey: "edad") ?? "0" )!
        u.genero = edadTextField?.text
        u.altura = Int32(alturaTextField.text ?? self.defaults.string(forKey: "altura") ?? "00")!
        u.peso = Int32(pesoTextField.text ?? self.defaults.string(forKey: "peso") ?? "00")!
        
        do{
            try miContexto.save()
            
            defaults.set(nombreTextField.text, forKey: "nombre")
            defaults.set(Int(pesoTextField.text ?? "0") ?? 0, forKey: "peso")
            defaults.set(Int(edadTextField?.text ?? "0") ?? 0, forKey: "edad")
            defaults.set(Int(alturaTextField.text ?? "0") ?? 0, forKey: "altura")
            defaults.set(generos[generoPicker.selectedRow(inComponent: 0)], forKey: "genero")
            defaults.set(usuarioImage.image?.pngData(), forKey: "imagen")
            self.navigationController?.popViewController(animated: true)
        }catch{
            print("Error al actualizar perfil")
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
