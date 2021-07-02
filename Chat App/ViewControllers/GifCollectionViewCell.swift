//
//  GifCollectionViewCell.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-16.
//

import UIKit
import MessageKit
import GiphyUISDK

open class GifCollectionViewCell: MessageContentCell {
    
    let imageView = GPHMediaView()
    var widthConstraint: NSLayoutConstraint!
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        if case let .custom(anyContent) = message.kind {
            loadMediaBy(id: (anyContent as? String) ?? "")
        }
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7).isActive = true
        imageView.isUserInteractionEnabled = false
        widthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageView.media?.aspectRatio ?? 1)
        widthConstraint.isActive = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        widthConstraint.isActive = false
        widthConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageView.media?.aspectRatio ?? 1)
        widthConstraint.isActive = true
    }
    
    func loadMediaBy(id: String) {
        GiphyCore.shared.gifByID(id) { (response, error) in
            if let media = response?.data {
                DispatchQueue.main.sync { [weak self] in
                    self?.imageView.media = media
                }
            }
        }
    }
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }
    
    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else { return .zero }
        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right
        return CGSize(width: collectionViewWidth - inset, height: 300)
    }
  
}
