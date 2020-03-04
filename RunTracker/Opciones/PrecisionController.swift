//
//  PrecisionController.swift
//  RunTracker
//
//  Created by Máster Móviles on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation

import QuickTableViewController

final class PrecisionController: QuickTableViewController {
    
let prefs = UserDefaults()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Precisión GPS"

    tableContents = [
      RadioSection(title: "Precisión", options: [
        OptionRow(text: "Baja", isSelected: self.prefs.integer(forKey: "precision") == 0, action: didToggleSelection()),
        OptionRow(text: "Media", isSelected: self.prefs.integer(forKey: "precision") == 1, action: didToggleSelection()),
        OptionRow(text: "Óptima", isSelected: self.prefs.integer(forKey: "precision") == 2, action: didToggleSelection())
      ], footer: "Selecciona un valor de precisión para el GPS")
      
    ]
  }

  private func didToggleSelection() -> (Row) -> Void {
    return { [weak self] row in
        if row.text == "Baja" {
            self!.prefs.set(0, forKey:"precision")
        } else if row.text == "Media" {
            self!.prefs.set(1, forKey:"precision")
        } else {
            self!.prefs.set(2, forKey:"precision")
        }
        UserDefaults().synchronize()
    }
  }

}
