//
//  MessageTableViewCell.swift
//  Chat App
//
//  Created by Elina Mansurova on 2021-07-05.
//

import UIKit
import SDWebImage

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with model: Conversation) {
        lastMessage.text = model.latestMessage.text
        userName.text = model.name

        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageFirebase.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImage.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }
    
    public func configure(with model: SearchResult) {
        userName.text = model.name

        let path = "images/\(model.email)_profile_picture.png"
        StorageFirebase.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImage.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }
}
