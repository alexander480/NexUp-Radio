//
//  AccountActions.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/7/18.
//  Copyright © 2018 LAGB Technolgies. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

//  TODO
// ----------------------------------------------
// - Fix Skip Count For Rest Of Project
// - Fix Premium Status For Rest Of Project

let auth = Auth.auth()
let storage = Storage.storage()
let db = Database.database()

class Account: NSObject {
    var skipCount = -1
    var isPremium = false
    
    var favorites = [[String: String]]()
    var dislikes = [[String: String]]()
    var recents = [[String: String]]()
    
    override init() {
        super.init()
        self.syncPremiumStatus()
        self.syncSkipCount()
    }
    
    // MARK: Skip Count Functions
    
    func updateSkipCount(To: Int) {
        if let user = auth.currentUser {
            self.skipCount = To
            let skipCountRef = db.reference(withPath: "users/\(user.uid)/skipCount")
            skipCountRef.setValue(10)
        }
    }
    
    func syncSkipCount() {
        if let user = auth.currentUser {
            let skipCountRef = db.reference(withPath: "users/\(user.uid)/skipCount")
            skipCountRef.observe(.value) { (snapshot) in
                if let result = snapshot.value as? Int { self.skipCount = result } else { skipCountRef.setValue(10) }
            }
        }
    }
    
    // MARK: Premium Status Function
    
    func syncPremiumStatus() {
        if let user = auth.currentUser {
            let premiumRef = db.reference(withPath: "users/\(user.uid)/isPremium")
            premiumRef.observe(.value) { (snapshot) in
                if let result = snapshot.value as? Bool { self.isPremium = result } else { premiumRef.setValue(false) }
            }
        }
    }
    
    // MARK: Save Favorite/Dislike/Recent Songs Functions
    
    func addSongToRecents() {
        if let user = auth.currentUser, let metadata = audio.metadata {
            let dref = db.reference(withPath: "users/\(user.uid)/recents")
            let sref = storage.reference(withPath: "users/\(user.uid)/recents")
            if let name = metadata["Name"] as? String, let artist = metadata["Artist"] as? String, let urlString = metadata["URL"] as? String {
                dref.child(name).updateChildValues(["Name": name, "Artist": artist, "URL": urlString])
                print("[INFO] Added Song To Dislikes")
                if let image = metadata["Image"] as? UIImage {
                    if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                        sref.child(name).putData(imageData, metadata: nil) { (meta, err) in
                            if meta != nil {
                                sref.child(name).downloadURL(completion: { (url, err) in
                                    if let imageURL = url {
                                        let urlString = String(describing: imageURL)
                                        dref.child(name).child("Image").setValue(urlString)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        else { print("[ERROR] User Not Signed In Or Invalid Metadata") }
    }
    
    func addSongToFavorites() {
        if let user = auth.currentUser, let metadata = audio.metadata {
            let dref = db.reference(withPath: "users/\(user.uid)/favorites")
            let sref = storage.reference(withPath: "users/\(user.uid)/favorites")
            if let name = metadata["Name"] as? String, let artist = metadata["Artist"] as? String, let url = metadata["URL"] as? String {
                print("[INFO] Added Song To Favorites")
                dref.child(name).updateChildValues(["Name": name, "Artist": artist, "URL": url])
                if let image = metadata["Image"] as? UIImage {
                    if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                        sref.child(name).putData(imageData, metadata: nil) { (meta, err) in
                            if meta != nil {
                                sref.child(name).downloadURL(completion: { (url, err) in
                                    if let imageURL = url {
                                        let urlString = String(describing: imageURL)
                                        dref.child(name).child("Image").setValue(urlString)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        else { print("[ERROR] User Not Signed In Or Invalid Metadata") }
    }
    
    func addSongToDislikes() {
        if let user = auth.currentUser, let metadata = audio.metadata {
            let dref = db.reference(withPath: "users/\(user.uid)/dislikes")
            let sref = storage.reference(withPath: "users/\(user.uid)/dislikes")
            if let name = metadata["Name"] as? String, let artist = metadata["Artist"] as? String, let urlString = metadata["URL"] as? String {
                dref.child(name).updateChildValues(["Name": name, "Artist": artist, "URL": urlString])
                print("[INFO] Added Song To Dislikes")
                if let image = metadata["Image"] as? UIImage {
                    if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                        sref.child(name).putData(imageData, metadata: nil) { (meta, err) in
                            if meta != nil {
                                sref.child(name).downloadURL(completion: { (url, err) in
                                    if let imageURL = url {
                                        let urlString = String(describing: imageURL)
                                        dref.child(name).child("Image").setValue(urlString)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        else { print("[ERROR] User Not Signed In Or Invalid Metadata") }
        audio.skip(didFinish: false)
    }

    // MARK: Fetch Recent/Favorited/Disliked Songs Functions
    
    func fetchRecentSongs() {
        if let user = auth.currentUser {
            let dref = db.reference(withPath: "users/\(user.uid)/recents")
            dref.observe(.value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["Image"] = (property.value as! String) }
                        else if property.key == "URL" { dict["URL"] = (property.value as! String) }
                    }
                    self.recents.append(dict)
                }
            })
            print("[DATA] Recieved \(self.recents.count) From Recents Fetch.")
        }
        else { print("[WARNING] Can Not Fetch User Recents - No User Signed In") }
    }
    
    func fetchFavoriteSongs() {
        if let user = auth.currentUser {
            let favoriteRef = db.reference(withPath: "users/\(user.uid)/favorites")
            favoriteRef.observe(.value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["Image"] = (property.value as! String) }
                        else if property.key == "URL" { dict["URL"] = (property.value as! String) }
                    }
                    self.favorites.append(dict)
                }
            })
            print("[DATA] Recieved \(self.favorites.count) From Favorites Fetch.")
        }
        else { print("[WARNING] Can Not Fetch User Favorites - No User Signed In") }
    }
    
    func fetchDislikedSongs() {
        if let user = auth.currentUser {
            let dislikeRef = db.reference(withPath: "users/\(user.uid)/dislikes")
            dislikeRef.observe(.value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["Image"] = (property.value as! String) }
                        else if property.key == "URL" { dict["URL"] = (property.value as! String) }
                    }
                    
                    self.dislikes.append(dict)
                }
            })
            print("[DATA] Recieved \(self.dislikes.count) From Dislike Fetch.")
        }
        else { print("[WARNING] Can Not Fetch User Dislikes - No User Signed In") }
    }
    
    // MARK: Remove Disliked Songs From Playlist
    
    func removeDislikedSongs() {
        if let user = auth.currentUser {
            let dref = db.reference(withPath: "users/\(user.uid)/dislikes")
            dref.observeSingleEvent(of: .value) { (snapshot) in
                for song in snapshot.children.allObjects as! [DataSnapshot] {
                    if let url = (song.value as? String)?.toURL() {
                        if audio.playlist.contains(url) {
                            if let idx = audio.playlist.index(of: url) {
                                audio.playlist.remove(at: idx)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isFavoriteSong(Name: String, Completion: @escaping (Bool) -> ()) {
        if let user = auth.currentUser {
            let dref = db.reference(withPath: "users/\(user.uid)/favorites")
            dref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChild(Name) { Completion(true) } else { Completion(false) }
            }
        }
    }
}
