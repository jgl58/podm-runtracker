//
//  Peripherals.swift
//  RunTracker
//
//  Created by Máster Móviles on 17/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BandaController: CBPeripheralDelegate {

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services
        {
            for servicePeripheral in servicePeripherals
            {
                peripheral.discoverCharacteristics(nil, for: servicePeripheral)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charactericsArr = service.characteristics {
            for cc in charactericsArr{
                switch cc.uuid.uuidString{
                case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                    peripheral.readValue(for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                    peripheral.setNotifyValue(true, for: cc)
                    break
                default:
                    print("Service: "+service.uuid.uuidString+" Characteristic: "+cc.uuid.uuidString)
                    break
                }
            }
            
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString{
        case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
            updateBattery(miBand.getBattery(batteryData: characteristic.value!))
        case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
            updateHeartRate(miBand.getHeartRate(heartRateData: characteristic.value!))
        default:
            print(characteristic.uuid.uuidString)
        }
    }

}
