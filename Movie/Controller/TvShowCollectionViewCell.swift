//
//  TvShowCollectionViewCell.swift
//  Movie
//
//  Created by Idris on 12/09/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import UIKit

class TvShowCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tvShowsImage: UIImageView!
    @IBOutlet weak var originalTitle: UILabel!
    @IBOutlet weak var overview: UIView!
    
    override func awakeFromNib() {
        self.overview.layer.cornerRadius = 8
    }
    
}
