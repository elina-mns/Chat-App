//
//  GiphyVC.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-13.
//

import UIKit
import GiphyUISDK
import GiphyCoreSDK

class GiphyVC: UIViewController {
    
   let giphy = Giphy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        giphy.theme = GPHTheme(type: .lightBlur)
        giphy.mediaTypeConfig = [.gifs, .stickers, .text, .emoji]
    }

}

public class CustomTheme: GPHTheme {
    public override init() {
        super.init()
        self.type = .light
    }
    
    public override var textFieldFont: UIFont? {
        return UIFont.italicSystemFont(ofSize: 15.0)
    }

    public override var textColor: UIColor {
        return .black
    }
}
