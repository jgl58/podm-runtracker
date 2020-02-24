//
//  EditProfileController.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 24/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit

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
