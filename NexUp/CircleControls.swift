//
//  CircleControls.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/20/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

class CircleControls: UIViewController
{
    var timer = Timer()
    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBAction func pauseAction(_ sender: Any) { self.togglePlaybackIcon(); audio.togglePlayback() }
    @IBOutlet weak var dislikeButton: UIButton!
    @IBAction func dislikeAction(_ sender: Any) {
        self.dislikeButton.setImage(#imageLiteral(resourceName: "thumbs-down-red"), for: .normal)
        account.addSongToDislikes()
        self.dislikeButton.setImage(#imageLiteral(resourceName: "thumbs-down"), for: .normal)
    }
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteAction(_ sender: Any) {
        account.addSongToFavorites()
    }
    
    @IBOutlet weak var skipButton: UIButton!
    @IBAction func skipAction(_ sender: Any) {
        if let vc = self.parent as? NowPlayingVC { vc.toggleLoading(isLoading: true) }
        audio.skip(didFinish: false)
    }
    
    @IBOutlet weak var skipsRemaining: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface() {
        if let info = audio.metadata {
            if let name = (info["Name"] as? String), let artist = info["Artist"] as? String {
                self.songName?.text = name
                self.songArtist?.text = artist
                
                account.isFavoriteSong(Name: name) { (isFavorite) in
                    if isFavorite { self.favoriteButton.setImage(#imageLiteral(resourceName: "thumbs-up-red"), for: .normal) }
                    else { self.favoriteButton.setImage(#imageLiteral(resourceName: "thumbs-up-white"), for: .normal) }
                }
            }
            if account.isPremium {
                self.skipsRemaining?.text = "Unlimited Skips"
            }
            else {
                self.skipsRemaining?.text = "\(account.skipCount) Skips Remaining"
            }
        }
    }
    
    private func togglePlaybackIcon() {
        if self.pauseButton?.currentImage == #imageLiteral(resourceName: "play") { self.pauseButton?.setImage(#imageLiteral(resourceName: "pause"), for: .normal) }
        else if self.pauseButton?.currentImage == #imageLiteral(resourceName: "pause") { self.pauseButton?.setImage(#imageLiteral(resourceName: "play"), for: .normal) }
    }
}
