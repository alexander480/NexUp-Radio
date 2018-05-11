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
//
//

let auth = Auth.auth()
let storage = Storage.storage()
let db = Database.database()

let AccountWorker = DispatchQueue.init(label: "AccountWorker", qos: DispatchQoS.userInteractive)

class Account: NSObject
{
    var isPremium = false
    
    var favorites = [[String: String]]()
    var dislikes = [[String: String]]()
    var recents = [[String: String]]()
    
    override init()
    {
        super.init()
        self.isPremiumUser(completion: { (isPremium) in self.isPremium = isPremium })
    }
    
    func favoriteSong()
    {
        if let user = auth.currentUser
        {
            if let metadata = audio.metadata
            {
                let dbReference = db.reference(withPath: "users/\(user.uid)/favorites")
                let storageReference = storage.reference(withPath: "users/\(user.uid)/favorites")
                
                let songName = String(describing: metadata["Name"]!)
                let songArtist = String(describing: metadata["Artist"]!)
                let songURL = String(describing: metadata["URL"]!)
                
                if let imageData = UIImageJPEGRepresentation((metadata["Image"]! as! UIImage), 1.0) {
                    storageReference.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageReference.child(songName).downloadURL(completion: { (url, err) in
                                if let imageURL = url {
                                    dbReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": imageURL, "URL": songURL])
                                }
                                else {
                                    dbReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": "", "URL": songURL])
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    func dislikeSong() {
        if let user = auth.currentUser {
            if let metadata = audio.metadata {
                let dbReference = db.reference(withPath: "users/\(user.uid)/dislikes")
                let storageReference = storage.reference(withPath: "users/\(user.uid)/dislikes")
                
                let songName = String(describing: metadata["Name"]!)
                let songArtist = String(describing: metadata["Artist"]!)
                let songURL = String(describing: metadata["URL"]!)
                
                if let imageData = UIImageJPEGRepresentation((metadata["Image"]! as! UIImage), 1.0) {
                    storageReference.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageReference.child(songName).downloadURL(completion: { (url, err) in
                                if let imageURL = url {
                                    dbReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": imageURL, "URL": songURL])
                                }
                                else {
                                    dbReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": "", "URL": songURL])
                                }
                            })
                        }
                    })
                }
            }
        }
        
        audio.skip(didFinish: false)
    }
    
    func recentSong()
    {
        if let user = auth.currentUser
        {
            if let metadata = audio.metadata
            {
                let databaseReference = db.reference(withPath: "users/\(user.uid)/recents")
                let storageReference = storage.reference(withPath: "users/\(user.uid)/recents")
                
                guard let songName = metadata["Name"] as? String, let songArtist = metadata["Artist"] as? String, let songURL = metadata["URL"] as? String else { return; }
                
                if let image = metadata["Image"] as? UIImage
                {
                    guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return; }
                    storageReference.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageReference.child(songName).downloadURL(completion: { (url, err) in
                                if let imageURL = url {
                                    databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": imageURL, "URL": songURL])
                                }
                                else {
                                    databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": "", "URL": songURL])
                                }
                            })
                        }
                    })
                }
                else
                {
                    guard let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "nexup"), 1.0) else { return; }
                    storageReference.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if meta != nil {
                            storageReference.child(songName).downloadURL(completion: { (url, err) in
                                if let imageURL = url {
                                    databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": imageURL, "URL": songURL])
                                }
                                else {
                                    databaseReference.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": "", "URL": songURL])
                                }
                            })
                        }
                    })
                }
            }
        }
        
        audio.skip(didFinish: false)
    }
    
    func fetchFavorites()
    {
        if let user = auth.currentUser
        {
            let favoriteRef = db.reference(withPath: "users/\(user.uid)/favorites")
            favoriteRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot]
                {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot]
                    {
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
        else
        {
            print("[WARNING] Can Not Fetch User Favorites - No User Signed In")
        }
    }
    
    func fetchDislikes()
    {
        if let user = auth.currentUser
        {
            let dislikeRef = db.reference(withPath: "users/\(user.uid)/dislikes")
            dislikeRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot]
                {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot]
                    {
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
        else
        {
            print("[WARNING] Can Not Fetch User Dislikes - No User Signed In")
        }
    }
    
    func fetchRecents()
    {
        if let user = auth.currentUser
        {
            let dislikeRef = db.reference(withPath: "users/\(user.uid)/recents")
            dislikeRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot]
                {
                    var dict = [String: String]()
                    for property in song.children.allObjects as! [DataSnapshot]
                    {
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
        else
        {
            print("[WARNING] Can Not Fetch User Recents - No User Signed In")
        }
    }
    
    func removeUserDislikes(Playlist: [URL]) -> [URL]
    {
        var playlistBuffer = Playlist
        
        guard let disliked = dislikedURLs() else { return [URL]() }
        for dislikedURL in disliked {
            for playlistURL in playlistBuffer {
                if dislikedURL == playlistURL {
                    guard let idx = playlistBuffer.index(of: playlistURL) else { return [URL]() }
                    playlistBuffer.remove(at: idx)
                }
            }
        }
        
        return playlistBuffer
    }
    
    private func dislikedURLs() -> [URL]?
    {
        var urls = [URL]()
        
        if let uid = auth.currentUser?.uid
        {
            db.reference(withPath: "users/\(uid)/dislikes").observeSingleEvent(of: .value, with: { (snapshot) in
                for song in snapshot.children.allObjects as! [DataSnapshot]
                {
                    if let url = (song.value as? String)?.toURL()
                    {
                        urls.append(url)
                    }
                }
            })
        }
        
        return urls
    }
    
    // -------------- Premium Features -------------- //
    // ---------------------------------------------- //
    
    func isPremiumUser(completion: @escaping (Bool) -> Void)
    {
        if let user = auth.currentUser
        {
            let ref = db.reference(withPath: "/users/\(user.uid)")
            ref.child("isPremium").observeSingleEvent(of: .value, with: { (snap) in
                let isTrue = snap.value as! Bool
                self.isPremium = isTrue
                if isTrue { print("[INFO] Premium User."); completion(true) }
                else { print("[INFO] Standard User."); completion(false) }
            })
        }
        else {
            completion(false)
        }
    }
}
