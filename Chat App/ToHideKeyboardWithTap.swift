//
//  ToAddDoneOnKeyboard.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-13.
//


import UIKit


extension ChatViewController {
    // to hide a keyboard with a tap
    
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        messagesCollectionView.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        messageInputBar.inputTextView.resignFirstResponder()
    }
}

