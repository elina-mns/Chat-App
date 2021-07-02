//
//  LogOutTableViewCell.swift
//  Chat App
//
//  Created by Elina Mansurova on 2021-06-30.
//

import UIKit

protocol LogOutTableViewCellDelegate: AnyObject {
    func logOutButtonPressed()
}

class LogOutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var logOutButton: UIButton! {
        didSet {
            logOutButton.layer.cornerRadius = 10
        }
    }
    
    weak var delegate: LogOutTableViewCellDelegate? = nil
    
    @IBAction func didTapLogOutButton(_ sender: Any) {
        self.delegate?.logOutButtonPressed()
    }
    
}
