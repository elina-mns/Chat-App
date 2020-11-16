//
//  ChatModel.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-12.
//

import Foundation
import MessageKit

struct Message: MessageType, Encodable, Equatable, Comparable {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    enum CodingKeys: String, CodingKey {
        case sender, messageId, sentDate, kind
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sender as? Sender, forKey: .sender)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(sentDate, forKey: .sentDate)
        try container.encode(kind, forKey: .kind)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.sender.displayName == rhs.sender.displayName &&
            lhs.sender.senderId == rhs.sender.senderId &&
            lhs.messageId == rhs.messageId &&
            lhs.sentDate == rhs.sentDate &&
            lhs.kind.messageTypeString == rhs.kind.messageTypeString
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        lhs.sentDate < rhs.sentDate
    }
}
 
struct Sender: SenderType, Encodable {
    var senderId: String
    var displayName: String
    var photoURL: String
}

struct LastMessage {
    let date: String
    let text: String
    let isRead: Bool
}

extension MessageKind: Encodable {
    enum CodingKeys: String, CodingKey {
        case type
        case content
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageTypeString, forKey: .type)
        try container.encode(content, forKey: .content)
    }
}

extension MessageKind {
    
    var content: String? {
        switch self {
        case let .text(content):
            return content
        case let .emoji(content):
            return content
        default:
            fatalError("Not implemented")
        }
    }
    
    var messageTypeString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .emoji(_):
            return "emoji"
        case .custom(_):
            return "custom"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link"
        }
    }
}
