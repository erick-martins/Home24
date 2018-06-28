//
//  ArticlesTableViewCell.swift
//  Home24
//
//  Created by Erick Martins on 25/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit
import Kingfisher

class ArticlesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likedIconView: UIImageView!
    @IBOutlet weak var likedTextLabel: UILabel!
    
    public func setup(article: Article){
        
        // Sets cell informations
        let resource = ImageResource(downloadURL: article.media![0].uri!, cacheKey: "article_image_\(article.sku!)")
        postImageView.kf.setImage(with: resource)
        postTitleLabel.text = article.title!
        if article.isLiked {
            likedIconView.image = UIImage(named: "thumbs-up")
            likedTextLabel.text = "Liked"
        }else{
            likedIconView.image = UIImage(named: "thumbs-down")
            likedTextLabel.text = "Disliked"
            
        }
    }
    
    
}
