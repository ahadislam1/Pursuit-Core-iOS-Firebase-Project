//
//  PhotoCollectionViewCell.swift
//  instagramproj
//
//  Created by Ahad Islam on 4/30/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import Combine
import SnapKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person")
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func layoutSubviews() {
        setupImageView()
    }
    
    public func configureCell(_ photo: IPhoto) {
        if let url = URL(string: photo.imageURL) {
            imageView.setImage(url: url, in: &subscriptions)
        }
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
