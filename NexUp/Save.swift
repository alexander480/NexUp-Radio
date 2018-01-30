//
//  PasswordManager.swift
//  TCB Web Browser
//
//  Created by Alexander Lester on 11/16/17.
//  Copyright © 2017 LAGB Technologies. All rights reserved.
//
/*
import AVFoundation
import Foundation
import CoreData
import WebKit

class Save: NSObject
{
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    // ------ Save New Login Data ------ //
    // ------------------------------ //
    
    func storePlaylist(PlaylistName: String, PlaylistItems: [AVPlayerItem])
    {

        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Song", in: context)!
        
        for item in PlaylistItems
        {
            if let url = item.url()?.absoluteString
            {
                let object = NSManagedObject(entity: entity, insertInto: context)
                object.setValue(PlaylistName, forKey: "playlist")
                object.setValue(url, forKey: "url")
                
                do { try context.save(); print("Succesfully Saved Playlist") }
                catch { print("Error While Saving Playlist") }
            }
        }
    }
}
*/
