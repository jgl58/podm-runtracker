//
//  CadenciaController.swift
//  RunTracker
//
//  Created by Máster Móviles on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation

import QuickTableViewController

final class CadenciaController: QuickTableViewController {
    
    let prefs = UserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Cadencia"

        let cadenciaValue = self.prefs.integer(forKey: "cadencia")

        tableContents = [
          Section(title: "", rows: [
            SwitchRow(text: "Activar", switchValue: self.prefs.bool(forKey:"cadenciaActivada"), action: { _ in
                self.prefs.set(!self.prefs.bool(forKey:"cadenciaActivada"), forKey:"cadenciaActivada")
                UserDefaults().synchronize()
            })
          ]),
          
          RadioSection(title: "Cadencia mínima", options: [
            OptionRow(text: "50 pasos/minuto", isSelected: cadenciaValue == 0, action: didToggleSelection()),
            OptionRow(text: "500 pasos/minuto", isSelected: cadenciaValue == 1, action: didToggleSelection()),
            OptionRow(text: "5000 pasos/minuto", isSelected: cadenciaValue == 2, action: didToggleSelection())
          ], footer: "Selecciona un valor mínimo de cadencia")
          
        ]
    }

    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] row in
            if row.text == "50 pasos/minuto" {
                self!.prefs.set(0, forKey:"cadencia")
            } else if row.text == "500 pasos/minuto" {
                self!.prefs.set(1, forKey:"cadencia")
            } else {
                self!.prefs.set(2, forKey:"cadencia")
            }
            UserDefaults().synchronize()
        }
    }

}
