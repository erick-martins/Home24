//
//  APIClient.swift
//  Home24
//
//  Created by Erick Martins on 24/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper
import SQLite

public class APIClient {
    
    public static var articles:[Article] = []
    public static var sharedClient = APIClient()
    public static var sharedDatabase : Connection? = nil
    
    public static func getArticles(completion: @escaping (_ success: Bool, _ articles: [Article]) -> Void) {
        
        if articles.count != Constants.NUM_OF_POSTS {
            // open a database connection
            self.connectToDatabase()
            
            // try to get all articles from database first
            articles = Article.getAll();
            
            if articles.count < Constants.NUM_OF_POSTS {
                // if the number of articles on the database is smaller than the number required, than we get more from the server
                self.getAllDataFromServer { success in
                    if success {
                        self.articles = Article.getAll();
                        completion(true, self.articles)
                    }else{
                        completion(false, self.articles)
                    }
                }
            }else{
                completion(true, articles)
            }
        }else{
            completion(true, articles)
        }
        
    }
    
    /**
     Open a database connection
     
     */
    public static func connectToDatabase(){
        if APIClient.sharedDatabase != nil { return }
        do {
            let path = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true).first!
            let db = try Connection("\(path)/db.sqlite3")
            APIClient.sharedDatabase = db
            print("Success Connecting to DB")
        }catch{
            print("Error Connecting to DB \(error)")
        }
        if let conn = APIClient.sharedDatabase {
            Database.create(conn: conn)
        }
    }
    
    /**
     Gets all the data from server and then saves to the database
     
     */
    public static func getAllDataFromServer(completion: @escaping (_ success: Bool) -> Void){
        self.connectToDatabase()
        Article.getAllFromServer { success, articles, error in
            
            if !success {
                print(error ?? "No Erro information")
                completion(false)
            }else{
                if articles != nil {
                    //print(success, articles!)
                    Database.update(with: articles! as! [Article])
                    completion(true)
                }else{
                    completion(false)
                }
                print(articles!)
            }
        }
        
    }
}
