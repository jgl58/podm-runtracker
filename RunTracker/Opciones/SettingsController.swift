//
//  IASKAppSettingsViewController.swift
//  RunTracker
//
//  Created by Máster Móviles on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//
import Foundation
import QuickTableViewController

final class SettingsController: QuickTableViewController {
    
    let prefs = UserDefaults()
    var precision = "Baja";

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Opciones"
        self.setOpciones()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setOpciones()
    }
    
    func setOpciones() -> Void {
        let cadenciaValue = self.prefs.bool(forKey:"cadenciaActivada") ? self.getCadencia(self.prefs.integer(forKey:"cadencia")) : "Desactivada"
        let precisionValue =  self.getPrecision(self.prefs.integer(forKey:"precision"))
        var intervaloValue = "Desactivado"
        if self.prefs.bool(forKey:"intervaloTiempoActivado") {
            intervaloValue = self.getIntervaloTiempo(self.prefs.integer(forKey:"intervaloTiempo"))
        }
        if self.prefs.bool(forKey:"intervaloDistanciaActivada") {
            intervaloValue = self.getIntervaloDistancia(self.prefs.integer(forKey:"intervaloDistancia"))
        }
        tableContents = [
          Section(title: "Notificaciones", rows: [
            NavigationRow(text: "Cadencia", detailText: .value1(cadenciaValue), icon: .named("indicador"), action: { _ in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Cadencia") as! CadenciaController
                self.navigationController!.pushViewController(newViewController, animated: true)
            }),
            NavigationRow(text: "Intervalos", detailText: .value1(intervaloValue), icon: .named("hora"), action: { _ in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Intervalos") as! IntervalosController
                self.navigationController!.pushViewController(newViewController, animated: true)
            }),
          ]),

          Section(title: "Entreno", rows: [
            NavigationRow(text: "Precisión GPS", detailText: .value1(precisionValue), icon: .named("mapa"), action: { _ in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Precision") as! PrecisionController
                self.navigationController!.pushViewController(newViewController, animated: true)
            }),
            SwitchRow(text: "Autopause", switchValue: self.prefs.bool(forKey:"autopause"), icon: .named("pausa"), action: { _ in
                self.prefs.set(!self.prefs.bool(forKey:"autopause"), forKey:"autopause")
                UserDefaults().synchronize()
            })
          ]),
          
          Section(title: "Conectividad", rows: [
            NavigationRow(text: "Banda HRM", detailText: .value1("Desconectada"), icon: .named("corazon"), action: { _ in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "Banda") as! BandaController
                self.navigationController!.pushViewController(newViewController, animated: true)
            }),
          ], footer: "Iconos por icons8.es")

        ]
    }
    
    func getCadencia(_ cadencia : Int) -> String {
        switch cadencia {
            case 0:
                return "50 pasos/minuto"
            case 1:
                return "500 pasos/minuto"
            case 2:
                return "5000 pasos/minuto"
            default:
                return "Desactivada"
        }
    }
    
    func getPrecision(_ precision : Int) -> String {
        switch precision {
            case 0:
                return "Baja"
            case 1:
                return "Media"
            case 2:
                return "Óptima"
            default:
                return "Desactivado"
        }
    }
    
    func getIntervaloTiempo(_ intervalo : Int) -> String {
        switch intervalo {
            case 0:
                return "Tiempo: 1 min"
            case 1:
                return "Tiempo: 5 mins"
            case 2:
                return "Tiempo: 10 mins"
            case 3:
                return "Tiempo: 30 mins"
            case 4:
                return "Tiempo: 60 mins"
            default:
                return "Desactivado"
        }
    }
    
    func getIntervaloDistancia(_ intervalo : Int) -> String {
        switch intervalo {
            case 0:
                return "Distancia: 1000 m"
            case 1:
                return "Distancia: 2500 m"
            case 2:
                return "Distancia: 5000 m"
            case 3:
                return "Distancia: 10000 m"
            case 4:
                return "Distancia: 20000 m"
            default:
                return "Desactivada"
        }
    }

}
