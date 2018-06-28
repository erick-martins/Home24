//
//  DBTables.swift
//  Home24
//
//  Created by Erick Martins on 24/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import Foundation
import SQLite

class Database {
    
    /**
     Create needed tables
     
     - parameters:
        - conn: Object of type Connection
     */
    public static func create(conn: Connection){
        
        do {
            
            let sku = Expression<Int64>("sku")
            let title = Expression<String>("title")
            let liked = Expression<Bool>("liked")
            let voted = Expression<Bool>("voted")
            let fullData = Expression<String>("fullData")
            
            
            let articles = Table(TablesNames.ARTICLES)
            
            if !Constants.PERSISTENT_DATA {
                try conn.run(articles.drop(ifExists: true))
            }
            try conn.run(articles.create(ifNotExists: true) { t in
                t.column(sku, primaryKey: true)
                t.column(title)
                t.column(voted)
                t.column(liked)
                t.column(fullData)
            })
            
            
            
        }catch{
            print("Error Creating table \(error)")
        }
        
    }
    
    /**
     Updates a list of articles to database
     
     - parameters:
        - with: Array of articles object
     */
    public static func update(with articles : [Article]) {
        for article in articles {
            self.update(with: article)
        }
    }
    
    /**
     Updates a single article to database
     
     - parameters:
        - with: Article object
     */
    public static func update(with article : Article) {
        do {
            var rowid: Int64? = -1;
            rowid = try APIClient.sharedDatabase?
                .run(Table(TablesNames.ARTICLES)
                    .insert(or: .replace,
                         Expression<Int64>("sku") <- Int64(article.sku!),
                         Expression<String>("title") <- article.title!,
                         Expression<Bool>("liked") <- article.isLiked,
                         Expression<Bool>("voted") <- article.voted,
                         Expression<String>("fullData") <- article.toJSONString()!
            ))
            print("inserted id: \(rowid ?? -1)")
            
        } catch {
            print("insertion failed: \(error)")
        }
    }
    
    /**
     Get all the articles inserted on database, it's limited to the maximum number of post declared as NUM_OF_POSTS in Utils/Constants.swift
     
     - returns:
     An array of Articles object
     */
    
    public static func getAllArticles() -> [Article] {
        
        var list : [Article] = []
        do {
            let table = Table(TablesNames.ARTICLES)
            let conn = APIClient.sharedDatabase!
            for row in try conn.prepare(table.limit(Constants.NUM_OF_POSTS)) {
                let data = row[Expression<String>("fullData")]
                let liked = row[Expression<Bool>("liked")]
                let voted = row[Expression<Bool>("voted")]
                let article = Article.parseDataFromDB(data: data, voted: voted, liked: liked)!
                list.append(article);
            }
        } catch {
            print("insertion failed: \(error)")
        }
        return list
    }
}

struct TablesNames {
    public static let ARTICLES = "articles"
}
