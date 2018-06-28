//
//  ThanksForVotingViewController.swift
//  Home24
//
//  Created by Erick Martins on 25/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit

class ThanksForVotingViewController: UIViewController, UIViewControllerTransitioningDelegate {

    let transition = StartTransition()
    
    @IBOutlet weak var reviewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set status bar to black
        UIApplication.shared.statusBarStyle = .default
        
        // makes button rounded
        reviewButton.layer.cornerRadius = reviewButton.frame.height / 2
    }
    
    
    
    
    /**
     * It presents the review window
     */
    @IBAction func reviewButtonAction(_ sender: Any) {
        // Check which is the latest review's view mode
        var identifier = "articlesLikesTableNav"
        if UserDefaults.standard.string(forKey: "preferedReviewMode") == "list" {
            identifier = "articlesLikesTableNav"
        }
        
        // greb it from storyboard
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: identifier) as? UINavigationController else {
            print("Could not instantiate view controller with identifier of type \(identifier)")
            return
        }
        
        // set itself to delegate transition to destination
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    /**
     * Configures transition when presented
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = reviewButton.center
        transition.circleColor = reviewButton.backgroundColor!
        
        return transition
    }
    
    /**
     * Configures transition when dismissed
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = reviewButton.center
        transition.circleColor = reviewButton.backgroundColor!
        
        return transition
    }

}
