//
//  ArticlesCollectionCell.swift
//  Home24
//
//  Created by Erick Martins on 26/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit
import Kingfisher

class ArticlesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    
    
    
    public func setup(article: Article){
        
        // Sets cell informations
        let resource = ImageResource(downloadURL: article.media![0].uri!, cacheKey: "article_image_\(article.sku!)")
        imageView.kf.setImage(with: resource)
        iconContainerView.layer.cornerRadius = iconContainerView.layer.bounds.height / 2
        
        
        if article.isLiked {
            iconImage.image = UIImage(named: "thumbs-up")
            iconContainerView.backgroundColor = Constants.LIKE_COLOR
        }else{
            iconImage.image = UIImage(named: "thumbs-down")
            iconContainerView.backgroundColor = Constants.DISLIKE_COLOR
        }
        
        // Sets icons color to white
        iconImage.image = iconImage.image!.withRenderingMode(.alwaysTemplate)
        iconImage.contentMode = .scaleAspectFit
        iconImage.tintColor = UIColor(hex: "#FFF") //"#FF55FF"
    }
    
}
