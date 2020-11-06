//
//  ShowFailureAlertExt.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-05.
//

import UIKit

extension UIViewController {
    func showFailureAlert(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
