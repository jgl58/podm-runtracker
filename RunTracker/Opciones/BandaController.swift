//
//  BandaController.swift
//  RunTracker
//
//  Created by Máster Móviles on 26/02/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import Foundation

import QuickTableViewController

final class BandaController: QuickTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Banda HRM"

    tableContents = [
      Section(title: "", rows: [
        SwitchRow(text: "Activar", switchValue: true, action: { _ in })
      ]),
      
    ]
  }

}
