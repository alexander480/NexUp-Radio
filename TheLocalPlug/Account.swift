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

class Account: NSObject
{
    var userReference: DatabaseReference?
    
    var favorites = [[String: Any]]()
    var dislikes = [[String: Any]]()
    var recents = [[String: Any]]()
    
    func isAvailable() -> Bool
    {
        if let user = auth.currentUser
        {
            print("[INFO] User \(user.uid) Available")
            userReference = db.reference(withPath: "users/" + user.uid)
            return true
        }
        else
        {
            return false
        }
    }
    
    func createAccount(Email: String, Password: String) -> User?
    {
        var newUser: User?
        
        auth.createUser(withEmail: Email, password: Password) { (usr, err) in
            if let user = usr
            {
                print("[INFO] New User \(user.uid) Created")
                newUser = user
            }
            else
            {
                print(String(describing: err))
                print("[WARNING] Could Not Create New User Account")
            }
        }
        
        return newUser
    }
    
    func signIn(Email: String, Password: String) -> User?
    {
        var thisUser: User?
        
        auth.signIn(withEmail: Email, password: Password) { (usr, err) in
            if let user = usr
            {
                print("[INFO] User \(user.uid) Has Signed In")
                thisUser = user
            }
            else
            {
                print(String(describing: err))
                print("[WARNING] Could Not Sign User In")
            }
        }
        
        return thisUser
    }
    
    func signOut() { try? auth.signOut() }
    
    func favoriteSong()
    {
        if let user = auth.currentUser
        {
            if let metadata = audio.metadata
            {
                let dbRef = db.reference(withPath: "users/\(user.uid)/favorites")
                let storageRef = storage.reference(withPath: "users/\(user.uid)/favorites")
                
                let songName = String(describing: metadata["Name"]!)
                let songArtist = String(describing: metadata["Artist"]!)
                if let imageData = UIImageJPEGRepresentation((metadata["Image"]! as! UIImage), 1.0) {
                    storageRef.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if let metadata = meta {
                            let url = (metadata.downloadURL()?.absoluteString)!
                            dbRef.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": url])
                            print("[INFO] \(songName) Added To User Favorites With an Image")
                        }
                        else if let error = err {
                            print("[ERROR] \(error.localizedDescription)")
                            
                            dbRef.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": ""])
                            print("[INFO] \(songName) Added To User Favorites Without an Image")
                        }
                    })
                }
            }
        }
    }
    
    func dislikeSong() {
        if let user = auth.currentUser {
            if let metadata = audio.metadata {
                let dbRef = db.reference(withPath: "users/\(user.uid)/dislikes")
                let storageRef = storage.reference(withPath: "users/\(user.uid)/dislikes")
                let songName = String(describing: metadata["Name"]!)
                let songArtist = String(describing: metadata["Artist"]!)
                if let imageData = UIImageJPEGRepresentation((metadata["Image"]! as! UIImage), 1.0) {
                    storageRef.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if let metadata = meta {
                            let url = (metadata.downloadURL()?.absoluteString)!
                            dbRef.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": url])
                            print("[INFO] \(songName) Added To User Dislikes With an Image")
                        }
                        else if let error = err {
                            print("[ERROR] \(error.localizedDescription)")
                            dbRef.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": ""])
                            print("[INFO] \(songName) Added To User Dislikes Without an Image")
                        }
                    })
                }
            }
        }
        
        audio.skip(didFinish: false)
    }
    
    func recentSong() {
        if let user = auth.currentUser {
            if let metadata = audio.metadata {
                let dbRef = db.reference(withPath: "users/\(user.uid)/recents")
                let storageRef = storage.reference(withPath: "users/\(user.uid)/recents")
                let songName = String(describing: metadata["Name"]!)
                let songArtist = String(describing: metadata["Artist"]!)
                if let imageData = UIImageJPEGRepresentation((metadata["Image"]! as! UIImage), 1.0) {
                    storageRef.child(songName).putData(imageData, metadata: nil, completion: { (meta, err) in
                        if let metadata = meta {
                            let url = (metadata.downloadURL()?.absoluteString)!
                            dbRef.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": url])
                            print("[INFO] \(songName) Added To User Dislikes With an Image")
                        }
                        else if let error = err {
                            print("[ERROR] \(error.localizedDescription)")
                            dbRef.child(songName).updateChildValues(["Name": songName, "Artist": songArtist, "Image": ""])
                            print("[INFO] \(songName) Added To User Dislikes Without an Image")
                        }
                    })
                }
            }
        }
        
        audio.skip(didFinish: false)
    }
    
    func fetchFavorites()
    {
        if let user = auth.currentUser {
            let favoriteRef = db.reference(withPath: "users/\(user.uid)/favorites")
            favoriteRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: Any]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["Image"] = (property.value as! String).toURL()?.toImageSync() }
                    }
                    
                    self.favorites.append(dict)
                }
            })
            
            print("[INFO] Favorites Fetch Complete.")
            print("[DATA] Recieved \(self.favorites.count) From Favorites Fetch.")
        }
        else {
            print("[WARNING] Can Not Fetch User Favorites - No User Signed In")
        }
    }
    
    func fetchDislikes()
    {
        if let user = auth.currentUser
        {
            let dislikeRef = db.reference(withPath: "users/\(user.uid)/dislikes")
            dislikeRef.observeSingleEvent(of: .value, with: { (snap) in
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: Any]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["Image"] = (property.value as! String).toURL()?.toImageSync() }
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
                for song in snap.children.allObjects as! [DataSnapshot] {
                    var dict = [String: Any]()
                    for property in song.children.allObjects as! [DataSnapshot] {
                        if property.key == "Name" { dict["Name"] = (property.value as! String) }
                        else if property.key == "Artist" { dict["Artist"] = (property.value as! String) }
                        else if property.key == "Image" { dict["Image"] = (property.value as! String).toURL()?.toImageSync() }
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
    
    func isFavorited(SongName: String) -> Bool
    {
        var bool = false
        
        if let favdb = self.userReference?.child("favorites") { favdb.observeSingleEvent(of: .value, with: { (snap) in if snap.hasChild(SongName) { bool = true } else { bool = false } }) }
        
        return bool
    }
    
    private func dislikedURLs() -> [URL]?
    {
        var urls = [URL]()
        
        if let uid = auth.currentUser?.uid {
            db.reference(withPath: "users/\(uid)/dislikes").observeSingleEvent(of: .value, with: { (snapshot) in
                for song in snapshot.children.allObjects as! [DataSnapshot] {
                    if let url = (song.value as! String).toURL() {
                        urls.append(url)
                    }
                }
            })
        }
        
        return urls
    }
    
    func removeUserDislikes()
    {
        if let dislikedURLs = dislikedURLs() {
            for dislikedURL in dislikedURLs {
                for item in audio.player.items() {
                    if let itemURL = item.url() {
                        if itemURL == dislikedURL {
                            audio.player.remove(item)
                        }
                    }
                }
            }
        }
        
        print("[INFO] Removed Dislikes From Playlist")
    }
    
}
