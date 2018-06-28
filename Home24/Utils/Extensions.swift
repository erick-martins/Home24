//
//  Utils.swift
//  Home24
//
//  Created by Erick Martins on 24/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import ObjectMapper
import Alamofire

/**
 Instantiate a UIColor object using hexadecimal code
 - returns:
 UIColor
 */
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
}

/**
 Transform string to int in a ObjectMapper
 */
class StringToIntTransform: TransformType {
    
    public typealias Object = Int
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Int? {
        guard let string = value as? String else{
            return nil
        }
        return Int(string)
    }
    
    open func transformToJSON(_ value: Int?) -> String? {
        guard let inval = value else{
            return nil
        }
        return String(inval)
    }
}


/**
 Custom class o UIView with corner radius and border control at storyboard
 */
@IBDesignable
class CustomView: UIView{
    
    @IBInspectable var borderRadius: CGFloat = 0.0{
        didSet{
            self.layer.cornerRadius = borderRadius
        }
    }
    @IBInspectable var rounded: Bool = false {
        didSet{
            self.layer.cornerRadius = rounded ? min(self.layer.bounds.height, self.layer.bounds.width) / 2 : borderRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0{
        
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
}

/**
 Mimics setTimeout function that we have in Javascript
 */
func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
}
