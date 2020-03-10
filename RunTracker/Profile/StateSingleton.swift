//
//  StateSingleton.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 09/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

//singleton para almacenar el estado de la aplicación
class StateSingleton{
    var usuarioActual:Usuario!
    
    private init(){}
    
    static let shared = StateSingleton()
}
