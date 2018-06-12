//
//  AccountActions.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/7/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
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

let AccountWorker = DispatchQueue.init(label: "AccountWorker", qos: DispatchQoS.userInteractive)

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
        
        self.fetchRecents()
    }
    
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
                if let result = snapshot.value as? Int { self.skipCount = result }
                else { skipCountRef.setValue(10) }
            }
        }
    }
    
    func syncPremiumStatus() {
        if let user = auth.currentUser {
            let premiumRef = db.reference(withPath: "users/\(user.uid)/isPremium")
            premiumRef.observe(.value) { (snapshot) in
                if let result = snapshot.value as? Bool { self.isPremium = result }
                else { premiumRef.setValue(false) }
            }
        }
    }
    
    func favoriteSong() {
        var song = ["Key": "Attribute"]
        
        if let user = auth.currentUser, let metadata = audio.metadata {
            let databaseRef = db.reference(withPath: "users/\(user.uid)/favorites"), storageRef = storage.reference(withPath: "users/\(user.uid)/favorites")
            if let name = metadata["Name"] as? String, let artist = metadata["Artist"] as? String, let songURL = metadata["URL"] as? String, let image = metadata["Image"] as? UIImage {
                if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                    storageRef.child(name).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageRef.child(name).downloadURL(completion: { (url, err) in
                                if let imageURL = url { databaseRef.child(name).updateChildValues(["Name": name, "Artist": artist, "Image": imageURL, "URL": songURL]); song["Image"] = String(describing: imageURL) }
                                else { databaseRef.child(name).updateChildValues(["Name": name, "Artist": artist, "Image": "", "URL": songURL]) }
                            })
                        }
                    })
                }
            }
        }
    }
    
    func dislikeSong() {
        if let user = auth.currentUser, let metadata = audio.metadata {
            let databaseRef = db.reference(withPath: "users/\(user.uid)/dislikes"), storageRef = storage.reference(withPath: "users/\(user.uid)/dislikes")
            if let name = metadata["Name"] as? String, let artist = metadata["Artist"] as? String, let songURL = metadata["URL"] as? String, let image = metadata["Image"] as? UIImage {
                if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                    storageRef.child(name).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageRef.child(name).downloadURL(completion: { (url, err) in
                                if let imageURL = url { databaseRef.child(name).updateChildValues(["Name": name, "Artist": artist, "Image": imageURL, "URL": songURL]) }
                                else { databaseRef.child(name).updateChildValues(["Name": name, "Artist": artist, "Image": "", "URL": songURL]) }
                            })
                        }
                    })
                }
            }
        }
        
        audio.skip(didFinish: false)
    }
    
    func addToRecents() {
        if let user = auth.currentUser {
            if let metadata = audio.metadata {
                let databaseReference = db.reference(withPath: "users/\(user.uid)/recents")
                let storageReference = storage.reference(withPath: "users/\(user.uid)/recents")
                
                guard let songName = metadata["Name"] as? String, let songArtist = metadata["Artist"] as? String, let songURL = metadata["URL"] as? String else { return; }
                
                if let image = metadata["Image"] as? UIImage {
                    guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return; }
                    storageReference.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageReference.child(songName).downloadURL(completion: { (url, err) in
                                if let imageURL = url { databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": imageURL, "URL": songURL]) }
                                else { databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": "", "URL": songURL]) }
                            })
                        }
                    })
                }
                else {
                    guard let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "nexup"), 1.0) else { return; }
                    storageReference.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageReference.child(songName).downloadURL(completion: { (url, err) in
                                if let imageURL = url { databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": imageURL, "URL": songURL]) }
                                else { databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": "", "URL": songURL]) }
                            })
                        }
                    })
                }
            }
        }
        
        audio.skip(didFinish: false)
    }
    
    func fetchFavorites() {
        if let user = auth.currentUser {
            let favoriteRef = db.reference(withPath: "users/\(user.uid)/favorites")
            favoriteRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["ImageURL"] = (property.value as! String) }
                        else if property.key == "URL" { dict["URL"] = (property.value as! String) }
                    }
                    
                    self.favorites.append(dict)
                }
            })
            
            print("[INFO] Favorites Fetch Complete.")
            print("[DATA] Recieved \(self.favorites.count) From Favorites Fetch.")
        }
        else { print("[WARNING] Can Not Fetch User Favorites - No User Signed In") }
    }
    
    func fetchDislikes() {
        if let user = auth.currentUser {
            let dislikeRef = db.reference(withPath: "users/\(user.uid)/dislikes")
            dislikeRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["ImageURL"] = (property.value as! String) }
                        else if property.key == "URL" { dict["URL"] = (property.value as! String) }
                    }
                    
                    self.dislikes.append(dict)
                }
            })
            
            print("[INFO] Dislike Fetch Complete.")
            print("[DATA] Recieved \(self.dislikes.count) From Dislike Fetch.")
        }
        else { print("[WARNING] Can Not Fetch User Dislikes - No User Signed In") }
    }
    
    func fetchRecents() {
        if let user = auth.currentUser {
            let dislikeRef = db.reference(withPath: "users/\(user.uid)/recents")
            dislikeRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["ImageURL"] = (property.value as! String) }
                        else if property.key == "URL" { dict["URL"] = (property.value as! String) }
                    }
                    self.recents.append(dict)
                }
            })
            
            print("[INFO] Recents Fetch Complete.")
            print("[DATA] Recieved \(self.recents.count) From Recents Fetch.")
        }
        else { print("[WARNING] Can Not Fetch User Recents - No User Signed In") }
    }
    
    func removeDislikes() {
        if let disliked = dislikedURLs() {
            for dislike in disliked {
                for song in audio.playlist {
                    if dislike == song {
                        if let idx = audio.playlist.index(of: song) { audio.playlist.remove(at: idx) }
                    }
                }
            }
        }
    }
    
    func dislikedURLs() -> [URL]? {
        var urls = [URL]()
        
        if let uid = auth.currentUser?.uid {
            db.reference(withPath: "users/\(uid)/dislikes").observeSingleEvent(of: .value, with: { (snapshot) in
                for song in snapshot.children.allObjects as! [DataSnapshot] {
                    if let url = (song.value as? String)?.toURL() {
                        urls.append(url)
                    }
                }
            })
        }
        
        return urls
    }
    
    // -------------- Premium Features -------------- //
    // ---------------------------------------------- //
    
    func isPremiumUser(completion: @escaping (Bool) -> Void) {
        if let user = auth.currentUser {
            let ref = db.reference(withPath: "/users/\(user.uid)")
            ref.child("isPremium").observeSingleEvent(of: .value, with: { (snap) in
                let isTrue = snap.value as! Bool
                self.isPremium = isTrue
                if isTrue { print("[INFO] Premium User."); completion(true) }
                else { print("[INFO] Standard User."); completion(false) }
            })
        }
        else { completion(false) }
    }
}
