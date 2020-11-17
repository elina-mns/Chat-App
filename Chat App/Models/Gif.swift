//
//  Gif.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-16.
//

import Foundation
import MessageKit

struct Gif: Codable {
    let imageOriginalURL: String
    let imageURL: String
    let imageFrames: String
    let imageWidth: String
    let imageHeight: String
    
    enum CodingKeys: String, CodingKey {
        case imageOriginalURL = "image_original_url"
        case imageURL = "image_url"
        case imageFrames = "image_frames"
        case imageWidth = "image_width"
        case imageHeight = "image_height"
    }
}

struct Image: Codable {
    let images: Gif
}

struct GifData: Codable {
    let data: Image
}
