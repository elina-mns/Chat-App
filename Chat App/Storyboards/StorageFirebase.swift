//
//  StorageFirebase.swift
//  Chat App
//
//  Created by Elina Mansurova on 2020-11-10.
//

import Foundation
import FirebaseStorage

class StorageFirebase {
    static let shared = StorageFirebase()
    private let storage = Storage.storage().reference()
    
    enum Errors: Error {
        case failedToUpload
        case failedToGetURL
    }
    
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase")
                completion(.failure(Errors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("failed to get URL")
                    completion(.failure(Errors.failedToGetURL))
                    return
                }
                let urlString = url.absoluteString
                print("downloaded url: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
}
