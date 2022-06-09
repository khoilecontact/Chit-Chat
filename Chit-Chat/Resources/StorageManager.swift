//
//  StorageManager.swift
//  Chit-Chat
//
//  Created by KhoiLe on 25/01/2022.
//

import Foundation
import FirebaseStorage

//Allow get, fetch and upload files to Firebase storage
final class StorageManager {
    static let shared = StorageManager()
    
    //force to use this init
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload picture to Firebase storage and return url string to download
    public func uploadFrofilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print("Failed to upload profile picture")
                completion(.failure(storageError.failedToUpload))
                return
            }
            
            self?.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    print("Failed to get download URL")
                    completion(.failure(storageError.failedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    /// Upload image that will be sent in a conversation to Firebase storage and return url string to download
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print("Failed to upload conversation's video")
                completion(.failure(storageError.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    print("Failed to get download URL")
                    completion(.failure(storageError.failedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    /// Upload video that will be sent in a conversation to Firebase storage and return url string to download
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        if let videoData = NSData(contentsOf: fileUrl) as Data? {
            storage.child("message_videos/\(fileName)").putData( videoData, metadata: nil, completion: { [weak self] metadata, error in
                guard error == nil else {
                    print("Failed to upload conversation's video: \(String(describing: error))")
                    completion(.failure(storageError.failedToUpload))
                    return
                }
                
                self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        print("Failed to get download URL")
                        completion(.failure(storageError.failedToDownloadURL))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("Download URL returned: \(urlString)")
                    completion(.success(urlString))
                })
            })
        }
    }
    
    public enum storageError: Error {
        case failedToUpload
        case failedToDownloadURL
    }
    
    ///Download the url from the Firebase storage
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(storageError.failedToDownloadURL))
                return
            }
            
            completion(.success(url))
        })
    }
    
    public func uploadGroupPicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("group_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print("Failed to upload group picture")
                completion(.failure(storageError.failedToUpload))
                return
            }
            
            self?.storage.child("group_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    print("Failed to get download URL")
                    completion(.failure(storageError.failedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
}

