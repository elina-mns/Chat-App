//
//  GiphyAPI.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-16.
//

import UIKit

//class GiphyAPI {
//
//    static let APIkey = "2ETzPkxoPDUwIIgs1Vt465sBAvQeuiZK"   //API key for gifs
//
//    enum EndPoint {
//        case randomGifFromAllCollection
//        case searchForTrendingGifs
//        case searchForSpecificGifMood(String)
//
//        var url: URL {
//            return URL(string: self.stringValue)!
//        }
//
//        var stringValue: String {
//            switch self {
//            case .randomGifFromAllCollection:
//                return "http://api.giphy.com/v1/gifs/random?api_key=\(GiphyAPI.APIkey)&tag=&rating=g"
//            case .searchForTrendingGifs:
//                return "http://api.giphy.com/v1/gifs/trending?api_key=\(GiphyAPI.APIkey)&limit=25&rating=g"
//            case .searchForSpecificGifMood(let searchWord):
//                return "https://api.giphy.com/v1/gifs/search?api_key=\(GiphyAPI.APIkey)&q=\(searchWord)&limit=25&offset=0&rating=g&lang=en"
//            }
//        }
//    }
//
//    class func requestRandomGifs(gifs: URL, completionHandler: @escaping (Gif?, Error?) -> Void) {
//        let endpoint = GiphyAPI.EndPoint.randomGifFromAllCollection
//        let randomGifURL = endpoint.url
//        let task = URLSession.shared.dataTask(with: randomGifURL, completionHandler: { (data, response, error) in
//            guard let data = data else {
//                completionHandler(nil, error)
//                return
//            }
//            let decoder = JSONDecoder()
//            let gifData = try! decoder.decode(Gif.self, from: data)
//            completionHandler(gifData, nil)
//        })
//        task.resume()
//    }
//
//    class func requestTrendingGifs(gifs: URL, completionHandler: @escaping (Gif?, Error?) -> Void) {
//        let endpoint = GiphyAPI.EndPoint.searchForTrendingGifs
//        let trendingGifURL = endpoint.url
//        let task = URLSession.shared.dataTask(with: trendingGifURL, completionHandler: { (data, response, error) in
//            guard let data = data else {
//                completionHandler(nil, error)
//                return
//            }
//            let decoder = JSONDecoder()
//            let gifData = try! decoder.decode(Gif.self, from: data)
//            completionHandler(gifData, nil)
//        })
//        task.resume()
//    }
//
//    class func requestSpecificGif(with searchWord: String, gifs: URL, completionHandler: @escaping (Gif?, Error?) -> Void) {
//        let endpoint = GiphyAPI.EndPoint.searchForSpecificGifMood(searchWord)
//        let specificGifURL = endpoint.url
//        let task = URLSession.shared.dataTask(with: specificGifURL, completionHandler: { (data, response, error) in
//            guard let data = data else {
//                completionHandler(nil, error)
//                return
//            }
//            let decoder = JSONDecoder()
//            let gifData = try! decoder.decode(Gif.self, from: data)
//            completionHandler(gifData, nil)
//        })
//        task.resume()
//    }
//}

