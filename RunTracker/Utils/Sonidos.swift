//
//  Sonidos.swift
//  RunTracker
//
//  Created by Máster Móviles on 04/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation
import AVFoundation

class Sonidos {
    
    static var player: AVAudioPlayer?
    
    static func notificarCadencia() {
        playSound("fast-action")
    }
    
    static func notificarIntervaloTiempo() {
        playSound("iphone_notification", 2)
    }
    
    static func notificarIntervaloDistancia() {
        playSound("eventually")
    }

    static func playSound(_ sound : String, _ loop : Int = 0) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.numberOfLoops = loop
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
