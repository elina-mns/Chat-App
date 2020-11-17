//
//  ShowFailureAlertExt.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-05.
//

import UIKit
import FirebaseAuth

extension UIViewController {
    func showAlert(title: String, message: String, actionForOk: (() -> Void)?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            actionForOk?()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true)
    }
}
