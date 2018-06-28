//
//  ViewController.swift
//  Home24
//
//  Created by Erick Martins on 23/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit
import Kingfisher

class StartingController: UIViewController, ArticlesImagesDownloadProtocol, UIViewControllerTransitioningDelegate {
    
    

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var disclaimerTextLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    
    let transition = StartTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set status bar to black
        UIApplication.shared.statusBarStyle = .default
        
        // Disable start button
        startButton.isEnabled = false
        startButton.alpha = 0.3
        
        // Show initial info
        infoLabel.alpha = 0
        disclaimerTextLabel.text = "Please wait until we get all the articles from all servers"
        
        // Set initial positions of eelements
        startButton.layer.cornerRadius = startButton.frame.height / 2
        logoImage.transform = CGAffineTransform(translationX: 0 , y: 80)
        startButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        disclaimerTextLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        infoLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        
        // Tries to get all the articles
        APIClient.getArticles { (success, articles) in
            if success {
                APIClient.articles = articles
                self.onArticlesRead()
            }else{
                self.onArticlesError()
            }
        }
        startAnimation()
    }
    
    
    /**
     * Animates elements to present
     */
    private func startAnimation(){
        UIView.animate(withDuration: 2, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut,
            animations: {
                self.logoImage.transform = CGAffineTransform.identity

            }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 1.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.startButton.transform = CGAffineTransform.identity
                
            }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 1.4, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.disclaimerTextLabel.transform = CGAffineTransform.identity

            }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 1.6, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.infoLabel.transform = CGAffineTransform.identity

            }, completion: nil)
    }
    
    
    
    /**
     * it should be called once we have all the articles prepared to be presented
     */
    private func onArticlesRead(){
        
        // If data should NOT be persistent, it is reseted as NOT voted
        if !Constants.PERSISTENT_DATA {
            _ = (0 ..< (APIClient.articles.count)).map { APIClient.articles[$0].resetVote() }
            
        }
        // tell the use that it's downloading the images
        disclaimerTextLabel.text = "Please wait until we download all the required images for the quiz"
        infoLabel.alpha = 1
        infoLabel.text = "0 of \(APIClient.articles.count)"
        
        // start images download
        let downloader = ArticlesImageDownloader()
        downloader.delegate = self
        downloader.download(these: APIClient.articles)
        
        // if for some reason it stil have images to vote but it already started voting, it sets "CONTINUE" as button label
        if APIClient.articles[0].voted {
            startButton.titleLabel?.text = "CONTINUE"
        }
        
        
    }
    
    /**
     * shows the error if it couldn't download some image
     */
    func articlesImageDownloaderErrorGetting(article: Article, error: NSError, url:URL?, data:Data?, dowloader: ArticlesImageDownloader){
        print("Error downloading image: \(error) - \(error.localizedDescription)")
        // TODO - Present error to the user
    }
    
    /**
     * shows which image it is downloading now
     */
    func articlesImageDownloaderDoneGetting(article: Article, image: Image, dowloader: ArticlesImageDownloader) {
        let downloaded = dowloader.downloaded
        infoLabel.text = "\(downloaded) of \(APIClient.articles.count)"
    }
    
    /**
     * it's called when it finished downloading all the images
     */
    func articlesImageDownloaderDoneGettingAll(articles: [Article], dowloader: ArticlesImageDownloader) {
        print("Dowloaded all images")
        
        // enable start button
        startButton.isEnabled = true
        startButton.alpha = 1
        
        // change text status and hide download counter
        infoLabel.alpha = 0
        disclaimerTextLabel.text = "Thanks for waiting!\nJust touch the button above to start"
    }
    
    
    /**
     * if something goes wrong getting the articles it shows an error to the user
     */
    private func onArticlesError(){
        print("We DON'T have articles");
        // TODO - Present error to the user
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // find the first article NOT voted
        var needle = 0
        var article = APIClient.articles[needle]
        while article.voted {
            needle += needle
            article = APIClient.articles[needle]
        }
        
        // set the index of the first article not voted to the Quiz View Controller
        let vc = segue.destination as! QuizViewController
        vc.needle = needle
        
        // set itself to delegate transition to destination
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
    }
    
    /**
     * Configures transition when presented
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = startButton.center
        transition.circleColor = startButton.backgroundColor!
        
        return transition
    }
    
    /**
     * Configures transition when dismissed
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = startButton.center
        transition.circleColor = startButton.backgroundColor!
        
        return transition
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

