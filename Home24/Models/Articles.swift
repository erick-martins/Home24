//
//  Articles.swift
//  Home24
//
//  Created by Erick Martins on 24/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire


public struct Article: Mappable {
    
    public var title: String?
    public var sku: Int?
    public var description: String?
    
    public var prevPrice: Price?
    public var price: Price?
    public var manufacturePrice: Price?
    
    public var delivery: Delivery?
    public var brand: Brand?
    public var media: [Media]?
    public var assemblyService: String?
    public var availability: Bool?
    public var url: URL?
    public var energyClass: String?
    public var apiDataHref: URL?
    
    private var liked: Bool = false
    
    public var isLiked: Bool {
        get {
            return liked
        }
        set (value) {
            if !voted && Constants.PERSISTENT_DATA{
                // Update votes counter if not voted yet and if the data shoud be persistent
                let userDefaults = UserDefaults.standard
                let votedCounter = userDefaults.integer(forKey: "votedCounter")
                userDefaults.set(votedCounter + 1, forKey: "votedCounter")
                userDefaults.synchronize()
            }
            voted = true
            liked = value
        }
    }
    public var voted: Bool = false
    
    public init() {}
    
    public init?(map: Map) {}
    
    /**
     * Set mapped data from JSON
     */
    mutating public func mapping(map: Map) {
        sku <- (map["sku"], StringToIntTransform())
        title <- map["title"]
        description <- map["description"]
        
        prevPrice <- map["prevPrice"]
        price <- map["price"]
        manufacturePrice <- map["manufacturePrice"]
        
        delivery <- map["delivery"]
        brand <- map["brand"]
        
        media <- map["media"]
        assemblyService <- map["assemblyService"]
        availability <- map["availability"]
        
        url <- (map["url"], URLTransform())
        
        energyClass <- map["energyClass"]
        apiDataHref <- (map["_links.self.href"], URLTransform())
    }
    
    
    /**
     * Set mapped data from Database
     */
    public static func parseDataFromDB(data: String, voted:Bool, liked:Bool) -> Article? {
        var article = Mapper<Article>().map(JSONString: data);
        article?.voted = voted
        article?.liked = liked
        return article
    }
    
    
    /**
     * Get all articles from database
     */
    public static func getAll() -> [Article] {
        return Database.getAllArticles()
    }
    
    
    
    
    /**
     * Get all articles from server
     */
    public static func getAllFromServer(completion: @escaping (_ success: Bool, _ warehouses: [Article?]?, _ error: NSError?) -> Void) {
        
        // request URL
        let requestURLString = NSURL(
            string: Constants.ARTICLES_LIST_URL,
            relativeTo: NSURL(string: Constants.BASE_URL) as URL?
        )!.absoluteString
        
        Alamofire.request(requestURLString!)
            .responseJSON { response in
                switch response.result {
                case .success:
                    
                    // Check if data exists
                    if let completeJSON = response.result.value as? [String: Any] {
                        print("------------ completeJSON -------------")
                        if let embedded = completeJSON["_embedded"] as? [String: Any] {
                            print("------------ embedded -------------")
                            if let articles = embedded["articles"] as? [[String: Any]] {
                                print("------------ articles -------------")
                                
                                // Map the response as a array of Article Object
                                let object = Mapper<Article>().mapArray(JSONArray: articles)
                                completion(true, object, nil)
                                return
                            }
                        }
                    }
                    // if it gets here it respondes with error
                    let userInfo: [AnyHashable : Any] = [
                        NSLocalizedDescriptionKey :  "Error Parsing JSON",
                        NSLocalizedFailureReasonErrorKey : "json_parse_error"
                    ]
                    let err = NSError(domain: "articleGetFromServer", code: 401, userInfo: userInfo as? [String : Any])
                    completion(false, nil, err)
                
                case .failure(let error):
                    // respondes with error in case of failure
                    if let dataUnwrapped = response.data {
                        let data = String(data: dataUnwrapped, encoding: .utf8)
                        print(data ?? "nodata ")
                    }else{
                        print("URLRequest error and unable to unwrap data")
                    }
                    completion(false, nil, error as NSError)
                }
                
        }
        
    }
    
    /**
     Saves article to database
     */
    public func save(){
        Database.update(with: self)
    }
    
    
    /**
     It resets votes to unvoted
     */
    public mutating func resetVote(){
        self.voted = false
        self.liked = false
        self.save()
    }
}

// MARK: - Extra Structs for Articles object

public struct Price: Mappable {
    public var amount: String?
    public var currency: String?
    public var recommendedRetailPrice: Bool?
    
    public init() {}
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        amount <- map["amount"]
        currency <- map["currency"]
        recommendedRetailPrice <- map["recommendedRetailPrice"]
    }
}

public struct Delivery: Mappable {
    public var time:ArticleTime?
    public var type: String?
    public var terms: String?
    public var deliveredBy: String?
    public var text: String?
    public var typeLabelLink: String?
    public var details: [Any]?
    
    public init() {}
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        time <- map["time"]
        type <- map["type"]
        terms <- map["terms"]
        deliveredBy <- map["deliveredBy"]
        text <- map["text"]
        typeLabelLink <- map["typeLabelLink"]
        details <- map["details"]
    }
}

public struct ArticleTime: Mappable {
    public var renderAs: String?
    public var amount: Int?
    public var units: String?
    
    public init() {}
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        renderAs <- map["renderAs"]
        amount <- map["amount"]
        units <- map["units"]
    }
}

public struct Brand: Mappable {
    public var id: String?
    public var title: String?
    public var logo: [String]?
    public var description: String?
    
    public init() {}
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        logo <- map["logo"]
        description <- map["description"]
    }
}
public struct Media: Mappable {
    public var uri: URL?
    public var mimeType: String?
    public var type: String?
    public var priority: Int?
    public var size: Int?
    public init() {}
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        uri <- (map["uri"], URLTransform())
        mimeType <- map["mimeType"]
        type <- map["type"]
        priority <- map["priority"]
        size <- map["size"]
    }
}
