//
//  CentralManagerDelegate.swift
//  RunTracker
//
//  Created by Máster Móviles on 17/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BandaController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE])
            
            if lastPeripherals.count > 0{
                let device = lastPeripherals.first! as CBPeripheral;
                miBand = MiBand2(device);
                centralManager.connect(miBand.peripheral, options: nil)
            }
            else {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
            
            
            
        default:
            print(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "MI Band 2"){
            miBand = MiBand2(peripheral)
            print("try to connect to \(String(describing: peripheral.name))")
            centralManager.connect(miBand.peripheral, options: nil)
        }else{
            print("discovered: \(String(describing: peripheral.name))")
        }
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        miBand.peripheral.delegate = self as? CBPeripheralDelegate
        miBand.peripheral.discoverServices(nil)
        self.dispositivo = miBand.peripheral.name!
        actualizarTabla()
    }


}
