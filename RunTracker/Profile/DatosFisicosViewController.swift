//
//  DatosFisicosViewController.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 03/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit

class DatosFisicosViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var generoPicker: UIPickerView!
    @IBOutlet weak var edadTextField: UITextField!
    @IBOutlet weak var alturaTextField: UITextField!
    @IBOutlet weak var pesoTextField: UITextField!
    
    let generos = ["Masculino","Femenino"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        generoPicker.delegate = self
        generoPicker.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return generos.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return generos[row]
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "primerosDatos"{
            if nombreTextField.text!.isEmpty || edadTextField.text!.isEmpty || alturaTextField.text!.isEmpty || pesoTextField.text!.isEmpty {
                mostrarAlerta(title: "Datos necesarios", message: "Introduce todos tus datos para continuar")
            }else{
                let destino = segue.destination as! RegisterViewController
                destino.nombre = nombreTextField.text ?? ""
                destino.genero = generos[generoPicker.selectedRow(inComponent: 0)]
                destino.edad = Int(edadTextField?.text ?? "0") ?? 0
                destino.altura = Int(alturaTextField.text ?? "0") ?? 0
                destino.peso = Int(pesoTextField.text ?? "0") ?? 0
            }
            
        }
    }
    
    func mostrarAlerta(title: String, message: String) {
        let alertGuia = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertGuia.addAction(ok)
        present(alertGuia, animated: true, completion: nil)
    }

}
