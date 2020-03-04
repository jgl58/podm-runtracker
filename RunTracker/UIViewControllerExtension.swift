//
//  UIViewControllerExtension.swift
//  RunTracker
//
//  Created by Sergio Muñoz on 03/03/2020.
//  Copyright © 2020 Jonay Gilabert López. All rights reserved.
//

import UIKit
//Extension que nos permite ocultar el teclado en todos los controladores que la implementen
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
