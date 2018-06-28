//
//  ArticlesLikesTableViewController.swift
//  Home24
//
//  Created by Erick Martins on 25/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit

class ArticlesLikesTableViewController: UITableViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set status bar to white
        UIApplication.shared.statusBarStyle = .lightContent
        
        // checks articles was loaded and loads it if it's not
        if APIClient.articles.count < Constants.NUM_OF_POSTS {
            APIClient.getArticles { (success, articles) in
                if success {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /**
     * Changes to grid view mode and saves it as the prefered view mode
     */
    @IBAction func changeToGridViewMode(_ sender: Any) {
        
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "articlesLikesCollectionNav") as? UINavigationController else {
            print("Could not instantiate view controller with identifier of type ArticlesLikesCollection")
            return
        }
        
        UserDefaults.standard.set("grid", forKey: "preferedReviewMode")
        present(vc, animated: false, completion: nil)
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * returns the number of articles
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIClient.articles.count
    }
    
    
    /**
     * sets articles data for each row
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articlesTableCell", for: indexPath) as! ArticlesTableViewCell
        cell.setup(article: APIClient.articles[indexPath.row])
        return cell
    }
    
    
    /**
     * Goes back to QuizView so the user can vote again
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "quizViewController") as? QuizViewController else {
            print("Could not instantiate view controller with identifier of type QuizViewController")
            return
        }
        vc.needle = indexPath.row
        present(vc, animated: true, completion: nil)
    }

}
