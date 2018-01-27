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

class Artists: NSObject
{
    var artists = [[String: Any]]()
    
    let artistWorker = DispatchQueue.init(label: "ArtistWorker", qos: DispatchQoS.userInteractive)
    
    override init() {
        super.init()
        
        let reference = db.reference(withPath: "/artists")
        reference.observeSingleEvent(of: .value, with: { (snapshot) in self.fetchArtists(Snapshot: snapshot) })
    }
    
    func fetchArtists(Snapshot: DataSnapshot)
    {
        var array = [[String: Any]]()
        
        for artist in Snapshot.children.allObjects as! [DataSnapshot]
        {
            var artistData = [String: Any]()
        
            for property in artist.children.allObjects as! [DataSnapshot] {
                if property.key == "Bio"
                {
                    artistData["Bio"] = (property.value! as! String)
                }
                else if property.key == "Image"
                {
                    if let image = URL(string: (property.value! as! String))?.toImageSync()
                    {
                        artistData["Image"] = image
                    }
                }
            }
            
            artistData["Name"] = artist.key
            array.append(artistData)

        }
            
        print("[DATA] Artist Array: \(array)")
        self.artists = array
    }
}
