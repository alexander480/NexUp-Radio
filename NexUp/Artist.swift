//
//  ArtistActions.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/9/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import Dispatch
import AVFoundation
import MediaPlayer
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//  TODO
// ----------------------------------------------
//
//

class Artists: NSObject {
    let artistWorker = DispatchQueue.init(label: "ArtistWorker", qos: DispatchQoS.userInteractive)
    var artists = [[String: String]]()
    
    override init() {
        super.init()
        let reference = db.reference(withPath: "/artists")
        reference.observeSingleEvent(of: .value, with: { (snapshot) in self.fetchArtists(Snapshot: snapshot) })
    }
    
    func fetchArtists(Snapshot: DataSnapshot) {
        var array = [[String: String]]()
        for artist in Snapshot.children.allObjects as! [DataSnapshot] {
            var artistData = [String: String]()
            artistData["Name"] = artist.key
            for property in artist.children.allObjects as! [DataSnapshot] {
                if property.key == "Bio" { artistData["Bio"] = (property.value! as! String) }
                else if property.key == "Image" { artistData["ImageURL"] = (property.value! as! String) }
                else if property.key == "Facebook" { artistData["Facebook"] = (property.value! as! String) }
                else if property.key == "Twitter" { artistData["Twitter"] = (property.value! as! String) }
                else if property.key == "Instagram" { artistData["Instagram"] = (property.value! as! String) }
            }
            array.append(artistData)
        }
            
        print("[DATA] Artist Array: \(array)")
        self.artists = array
    }
}
