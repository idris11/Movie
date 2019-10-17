//
//  MovieCollectionViewCell.swift
//  Movie
//
//  Created by Idris on 12/09/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var originalTitle: UILabel!
    @IBOutlet weak var overview: UIView!
    
    override func awakeFromNib() {
        self.overview.layer.cornerRadius = 10
    }
}
