//
//  extension.swift
//  detector
//
//  Created by iwa on 2015/11/14.
//  Copyright © 2015年 jaxx. All rights reserved.
//

import Foundation
import SpriteKit

extension SKColor {
    class func hexStr (hexStr : NSString, alpha : CGFloat) -> SKColor {
        let hexStr = hexStr.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return SKColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return SKColor.whiteColor();
        }
    }
}
