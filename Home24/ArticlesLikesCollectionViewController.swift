//
//  ArticlesLikesCollectionViewController.swift
//  Home24
//
//  Created by Erick Martins on 25/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ArticlesLikesCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // set status bar to white
        UIApplication.shared.statusBarStyle = .lightContent

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        
        // checks articles was loaded and loads it if it's not
        if APIClient.articles.count < Constants.NUM_OF_POSTS {
            APIClient.getArticles { (success, articles) in
                if success {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    /**
     * Changes to list view mode and saves it as the prefered view mode
     */
    @IBAction func changeToListViewMode(_ sender: Any) {
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "articlesLikesTableNav") as? UINavigationController else {
            print("Could not instantiate view controller with identifier of type articlesLikesTableNav")
            return
        }
        UserDefaults.standard.set("list", forKey: "preferedReviewMode")
        present(vc, animated: false, completion: nil)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * returns the number of articles
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return APIClient.articles.count
    }
    
    /**
     * sets articles data for each cell
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articlesCollectionCell", for: indexPath) as! ArticlesCollectionCell
        cell.setup(article: APIClient.articles[indexPath.row])
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    
    
    /**
     * Goes back to QuizView so the user can vote again
     */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "quizViewController") as? QuizViewController else {
            print("Could not instantiate view controller with identifier of type QuizViewController")
            return
        }
        vc.needle = indexPath.row
        present(vc, animated: true, completion: nil)
    }

}
