//
//  ArtistsCell.swift
//  TheLocalPlug
//
//  Created by Designs By LAGB on 1/9/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

//  TODO
// ----------------------------------------------
//
//

class ArtistHeaderCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDetail: UILabel!
}

class ArtistCell: UITableViewCell {
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
}

class SongCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDetail: UILabel!
}

class AccountHeaderCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDetail: UILabel!
}

class AccountCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
}

/*
class GenreCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
}

class AdCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
}
*/
