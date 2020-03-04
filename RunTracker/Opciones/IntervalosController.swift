//
//  IntervalosController.swift
//  RunTracker
//
//  Created by Máster Móviles on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation


import QuickTableViewController

final class IntervalosController: QuickTableViewController {
    
    let prefs = UserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Intervalos"
        iniciarOpcionesIntervalo()
    }

    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] row in
            if row.text == "1 min" {
                self!.prefs.set(0, forKey:"intervaloTiempo")
            } else if row.text == "5 mins" {
                self!.prefs.set(1, forKey:"intervaloTiempo")
            } else if row.text == "10 mins" {
                self!.prefs.set(2, forKey:"intervaloTiempo")
            } else if row.text == "30 mins" {
                self!.prefs.set(3, forKey:"intervaloTiempo")
            } else {
                self!.prefs.set(4, forKey:"intervaloTiempo")
            }
            UserDefaults().synchronize()
        }
    }
    
    private func didToggleSelectionDistancia() -> (Row) -> Void {
        return { [weak self] row in
            if row.text == "1000 m" {
                self!.prefs.set(0, forKey:"intervaloDistancia")
            } else if row.text == "2500 m" {
                self!.prefs.set(1, forKey:"intervaloDistancia")
            } else if row.text == "5000 m" {
                self!.prefs.set(2, forKey:"intervaloDistancia")
            } else if row.text == "10000 m" {
                self!.prefs.set(3, forKey:"intervaloDistancia")
            } else {
                self!.prefs.set(4, forKey:"intervaloDistancia")
            }
            UserDefaults().synchronize()
        }
    }
    
    func  iniciarOpcionesIntervalo() -> Void{
        let intervaloTiempoValue = self.prefs.integer(forKey:"intervaloTiempo")
        let intervaloDistanciaValue = self.prefs.integer(forKey:"intervaloDistancia")
        tableContents = [
            Section(title: "Tiempo", rows: [
                SwitchRow(text: "Activar por tiempo", switchValue: self.prefs.bool(forKey:"intervaloTiempoActivado"), action: { _ in
                    self.prefs.set(!self.prefs.bool(forKey:"intervaloTiempoActivado"), forKey:"intervaloTiempoActivado")
                    if self.prefs.bool(forKey:"intervaloTiempoActivado") {
                        self.prefs.set(!self.prefs.bool(forKey:"intervaloTiempoActivado"), forKey:"intervaloDistanciaActivada")
                        self.iniciarOpcionesIntervalo()
                    }
                    UserDefaults().synchronize()
                    
                })
            ]),

            RadioSection(title: "Intervalo de tiempo", options: [
                OptionRow(text: "1 min", isSelected: intervaloTiempoValue == 0, action: didToggleSelection()),
                OptionRow(text: "5 mins", isSelected: intervaloTiempoValue == 1, action: didToggleSelection()),
                OptionRow(text: "10 mins", isSelected: intervaloTiempoValue == 2, action: didToggleSelection()),
                OptionRow(text: "30 mins", isSelected: intervaloTiempoValue == 3, action: didToggleSelection()),
                OptionRow(text: "60 mins", isSelected: intervaloTiempoValue == 4, action: didToggleSelection())
            ], footer: "Selecciona un valor mínimo de cadencia"),

            Section(title: "Distancia", rows: [
                SwitchRow(text: "Activar por distancia", switchValue: self.prefs.bool(forKey:"intervaloDistanciaActivada"), action: { _ in
                    self.prefs.set(!self.prefs.bool(forKey:"intervaloDistanciaActivada"), forKey:"intervaloDistanciaActivada")
                    if self.prefs.bool(forKey:"intervaloDistanciaActivada") {
                        self.prefs.set(!self.prefs.bool(forKey:"intervaloDistanciaActivada"), forKey:"intervaloTiempoActivado")
                        self.iniciarOpcionesIntervalo()
                    }
                    
                    UserDefaults().synchronize()
                    
                })
            ]),

            RadioSection(title: "Intervalo de distancia", options: [
                OptionRow(text: "1000 m", isSelected: intervaloDistanciaValue == 0, action: didToggleSelectionDistancia()),
                OptionRow(text: "2500 m", isSelected: intervaloDistanciaValue == 1, action: didToggleSelectionDistancia()),
                OptionRow(text: "5000 m", isSelected: intervaloDistanciaValue == 2, action: didToggleSelectionDistancia()),
                OptionRow(text: "10000 m", isSelected: intervaloDistanciaValue == 3, action: didToggleSelectionDistancia()),
                OptionRow(text: "20000 m", isSelected: intervaloDistanciaValue == 4, action: didToggleSelectionDistancia())
            ], footer: "Selecciona un valor mínimo de cadencia")
          
        ]
    }

}
