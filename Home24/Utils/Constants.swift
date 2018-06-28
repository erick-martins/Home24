//
//  Constants.swift
//  Home24
//
//  Created by Erick Martins on 24/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//
import Foundation
import UIKit

public struct Constants {
    // Change this to update the number of articles you want to show
    static let NUM_OF_POSTS = 10
    static let BASE_URL = "https://api-mobile.home24.com/api/v2.0/"
    static let ARTICLES_LIST_URL = "categories/100/articles?appDomain=1&locale=de_DE&limit=\(Constants.NUM_OF_POSTS)"
    
    
    // Set to false to reset the data when the app starts up
    static let PERSISTENT_DATA = true
    
    // Like and Dislike Color
    static let DISLIKE_COLOR = UIColor(hex: "#F45334")
    static let LIKE_COLOR = UIColor(hex: "#00B105")
    
    
}
