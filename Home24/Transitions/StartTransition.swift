//
//  StartTransition.swift
//  Home24
//
//  Created by Erick Martins on 26/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import UIKit

/**
 * It's a class used to create a circular transition between windows
 */
class StartTransition: NSObject {
    var circle = UIView()
    
    // starting point for the transition
    var startingPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
    
    // Default color
    var circleColor = UIColor.white
    
    // Default duration
    var duration = 0.5
    
    // Transition Mode
    enum CircularTransitionMode:Int {
        case present, dismiss, pop
    }
    
    // Default transition mode
    var transitionMode:CircularTransitionMode = .present
}

extension StartTransition:UIViewControllerAnimatedTransitioning {
    
    /**
     * Sets the transition duration
     */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    /**
     * Perform the circular transition
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // gets the container view
        let containerView = transitionContext.containerView
        
        // check which transition mode is
        if transitionMode == .present {
            
            // check if it's set a destination
            if let presentedView = transitionContext.view(forKey: .to) {
                
                // gets the center point of presented view and its size
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                
                // set presented view scale to 80% of its original size and add to container view
                presentedView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                presentedView.alpha = 0
                presentedView.center = viewCenter
                containerView.addSubview(presentedView)
                
                // Create a circular view on the top filling the whole screen, changes its scale to zero to animate later and add to container view
                circle = UIView()
                circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
                circle.layer.cornerRadius = circle.frame.size.height / 2
                circle.center = startingPoint
                circle.backgroundColor = circleColor
                circle.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                circle.alpha = 0.3
                containerView.addSubview(circle)
                
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn,
                    animations: {
                        // Animate circle to its original size and opacity
                        self.circle.transform = CGAffineTransform.identity
                        self.circle.alpha = 1
                        
                    }, completion: { (success:Bool) in
                        transitionContext.completeTransition(success)
                    })
                UIView.animate(withDuration: 0.4, delay: duration, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut,
                    animations: {
                        // Animate circle opacity to zero
                        self.circle.alpha = 0
                        
                        // Animate presented view to its original size and opacity
                        presentedView.alpha = 1
                        presentedView.transform = CGAffineTransform.identity
                    }, completion: nil)
            }
            
        }else{
            // TODO - Reversed animation - not implemented yet because its not used
            
            
        }
        
    }
    
    
    /**
     * Calculates the size the circle needs to be to fill the whole screen
     */
    func frameForCircle (withViewCenter viewCenter:CGPoint, size viewSize:CGSize, startPoint:CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offestVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offestVector, height: offestVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
        
    }
}





