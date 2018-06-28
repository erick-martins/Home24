//
//  QuizViewController.swift
//  Home24
//
//  Created by Erick Martins on 24/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit
import Kingfisher

class QuizViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let transition = StartTransition()

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var reviewButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postCounterLabel: UILabel!
    
    @IBOutlet weak var votingDownButton: UIButton!
    @IBOutlet weak var votingUpButton: UIButton!
    
    var latestButton: UIButton!
    var transitionColor: UIColor!
    
    public var needle:Int = 0  {
        didSet {
            // if needle is bigger than 0 than show preview button
            if previousButton != nil {
                previousButton.isEnabled = needle > 0
            }
        }
    }
    enum VoteButtonTag: Int {
        case DISLIKE
        case LIKE
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set status bar to white
        UIApplication.shared.statusBarStyle = .default

        // if needle is bigger than 0 than show preview button
        previousButton.isEnabled = needle > 0
        
        
        // if some article hasn't been voted yet, disable review button
        for article in APIClient.articles {
            if !article.voted {
                reviewButton.isEnabled = false;
            }
        }
        
        setButtonsColor()
        setData()
        
    }
    /**
     * Set the color of the button's icon
     */
    private func setButtonsColor(){
        votingDownButton.imageView?.image = votingDownButton.imageView?.image!.withRenderingMode(.alwaysTemplate)
        votingDownButton.imageView?.contentMode = .scaleAspectFit
        votingDownButton.imageView?.tintColor = UIColor(hex: "#505050")
        
        votingUpButton.imageView?.image = votingUpButton.imageView?.image!.withRenderingMode(.alwaysTemplate)
        votingUpButton.imageView?.contentMode = .scaleAspectFit
        votingUpButton.imageView?.tintColor = UIColor(hex: "#505050")
    }
    
    /**
     * Animates elements to present it
     */
    public func startAnimation(){
        
        // Animate Image
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.postImage.transform = CGAffineTransform.identity
            }, completion: nil
        )
        // Animate Post Title
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.postTitleLabel.transform = CGAffineTransform.identity
            },
            completion: nil
        )
        // Animate Post Voting down Button
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.votingDownButton.transform = CGAffineTransform.identity
            },
            completion: nil
        )
        // Animate Post Voting up Button
        UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
            animations: {
                self.votingUpButton.transform = CGAffineTransform.identity
            },
            completion: { (success:Bool) in
                print("Animation ended")
            }
        )
        
    }
    
    /**
     * User voted
     */
    @IBAction func voteAction(_ sender: UIButton) {
        
        // Set it's vote to articles array and seva it
        APIClient.articles[needle].isLiked = (sender.tag == VoteButtonTag.LIKE.rawValue)
        APIClient.articles[needle].save()
        
        buttonAnimation(sender)
        
        // set needle to next article
        needle = needle + 1
        
        // checks if index is out of bounds
        if needle >= APIClient.articles.count {
            
            // instantiate "Thanks for voating" view controller
            guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "thanksForVotingViewController") as? ThanksForVotingViewController else {
                print("Could not instantiate view controller with identifier of type ThanksForVotingViewController")
                return
            }
            // setup transition info and set itself to delegate transition to destination
            latestButton = sender
            transitionColor = (sender.tag == VoteButtonTag.LIKE.rawValue) ? Constants.LIKE_COLOR : Constants.DISLIKE_COLOR
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom
            present(vc, animated: true, completion: nil)
        }else{
            // if not out of bounds goes next
            goToNext()
        }
        
        // reset buttons' color
        setButtonsColor()
    }
    
    /**
     * User touched previous button
     */
    @IBAction func previousAction(_ sender: Any) {
        // set needle to previous article
        needle = needle - 1
        goToNext()
    }
    
    /**
     * Animate button
     */
    private func buttonAnimation(_ sender: UIButton){
        let anim = CustomView()
        if sender.tag == VoteButtonTag.LIKE.rawValue {
            anim.backgroundColor = Constants.LIKE_COLOR
        }else{
            anim.backgroundColor = Constants.DISLIKE_COLOR
        }
        let size = CGSize(width: 200, height: 200)
        anim.frame = CGRect(origin: CGPoint.zero, size: size)
        anim.center = sender.center
        anim.rounded = true
        self.view.addSubview(anim)
        self.view.sendSubview(toBack: anim)
        
        
        anim.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
                       animations: {
                        anim.transform = CGAffineTransform.identity
                        anim.alpha = 0
                        
        }, completion: { (success) in
            anim.removeFromSuperview()
        })
        
        for i in 0...8 {
            
            let anim2 = CustomView()
            
            let randomSize = (drand48() * 5.0) + 150.0
            
            let size = CGSize(width: randomSize, height: randomSize)
            anim2.frame = CGRect(origin: CGPoint.zero, size: size)
            anim2.center = sender.center
            
            if sender.tag == VoteButtonTag.LIKE.rawValue {
                anim2.borderColor = Constants.LIKE_COLOR
            }else{
                anim2.borderColor = Constants.DISLIKE_COLOR
            }
            
            anim2.borderWidth = 20
            anim2.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            
            anim2.rounded = true
            
            anim2.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            self.view.addSubview(anim2)
            self.view.sendSubview(toBack: anim2)
            
            let delay = (0.05 * Double(i))
            
            UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut,
                           animations: {
                            anim2.transform = CGAffineTransform.identity
                            anim2.borderWidth = 10
                            anim2.alpha = 0
                            
            }, completion: { (success) in
                anim2.removeFromSuperview()
            })
        }
        
        
    }
    
    /**
     * Configures transition when presented
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = latestButton.center
        transition.circleColor = transitionColor
        
        return transition
    }
    
    /**
     * Configures transition when dismissed
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = latestButton.center
        transition.circleColor = transitionColor
        
        return transition
    }
    
    /**
     * Moves to next article
     */
    private func goToNext(){
        
        // Animate Image - hide
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn,
            animations: {
                self.postImage.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }, completion: nil
        )
        // Animate  Post Title - hide
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn,
            animations: {
                self.postTitleLabel.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            }, completion: { (success:Bool) in
                self.setData()
                self.startAnimation()
            }
        )
        
    }
    
    /**
     * Present articles data - Picture and Title
     */
    private func setData(){
        if APIClient.articles.count > needle {
            
            let resource = ImageResource(
                downloadURL: APIClient.articles[needle].media![0].uri!,
                cacheKey: "article_image_\(APIClient.articles[needle].sku!)"
            )
            postImage.kf.setImage(with: resource)
            
            postTitleLabel.text = APIClient.articles[needle].title!
            postCounterLabel.text = "\(needle+1)/\(APIClient.articles.count)"
        }
    }
    
    /**
     * When review is available it presents the review window
     */
    @IBAction func reviewAction(_ sender: Any) {
        // Check which is the latest review's view mode
        var identifier = "articlesLikesTableNav"
        if UserDefaults.standard.string(forKey: "preferedReviewMode") == "list" {
            identifier = "articlesLikesTableNav"
        }
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: identifier) as? UINavigationController else {
            print("Could not instantiate view controller with identifier of type \(identifier)")
            return
        }
        present(vc, animated: true, completion: nil)
    }
    

}
