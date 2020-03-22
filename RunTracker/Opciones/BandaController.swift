//
//  BandaController.swift
//  RunTracker
//
//  Created by Máster Móviles on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation

import QuickTableViewController
import CoreBluetooth

//let heartRateServiceCBUUID = CBUUID(string: "0x180D")

final class BandaController : QuickTableViewController {
    
    var centralManager:CBCentralManager!
    var miBand:MiBand2!
    
    var dispositivo = "Conectando..."
    var bateria = "..."
    var pulso = "Pulsa el botón"
    var iconoBateria = "fullBattery"
    var conectado = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banda HRM"
        
        centralManager = CBCentralManager()
        centralManager.delegate = self
        actualizarTabla()

    }
    
    
    func actualizarTabla() -> Void {
        tableContents = [
            Section(title: "Disposivito", rows: [
                NavigationRow(text: "Dispositivo", detailText: .value1(self.dispositivo), icon: .named("bracelet")),
                NavigationRow(text: "Batería", detailText: .value1(self.bateria), icon: .named(self.iconoBateria)),
            ]),
            
            Section(title: "Pulso", rows: [
                NavigationRow(text: "Pulso", detailText: .value1(self.pulso), icon: .named("pulse")),
                TapActionRow(text: "Obtener pulso", action: { [weak self] in self?.getHeartRate($0) })
            ]),

        ]
    }
    
    func updateBattery(_ battery:Int){
        if battery > 60{
            self.iconoBateria = "fullBattery"
        }else if battery > 40{
            self.iconoBateria = "middleBattery"
        }else{
            self.iconoBateria = "lowBattery"
        }
        self.bateria = battery.description+"%"
        actualizarTabla()
    }
    
    func updateHeartRate(_ heartRate:Int){
        miBand.startVibrate()
        self.pulso = heartRate.description
        if self.pulso == "0" {
            self.pulso = "Activa la banda"
        }
        actualizarTabla()
    }
    
    func getHeartRate(_ sender: Row) {
        if self.conectado {
            self.pulso = "Midiendo..."
            
            miBand.measureHeartRate()
        } else {
            self.pulso = "Conecta una MiBand2"
        }
        self.actualizarTabla()
    }

}
