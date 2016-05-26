//
//  GameScene.swift
//  uni
//
//  Created by iwa on 2015/08/18.
//  Copyright © 2015年 jaxx. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import AVFoundation

class TaruiScene: SKScene {
    
    var image : UIImage!
    
    var selectId : Int!
    var selectBright : CGFloat = 1.0
    var selectDark : CGFloat = 0.0
    
    var ptsCircle : [SKShapeNode]!
    let ptsSpan = 15
    let ptsRow = 35
    let ptsCol = 35
    
    var updateNodes = Array(arrayLiteral:SKNode())
    var touchPt: SKShapeNode!
    
    override func didMoveToView(view: SKView){
        
        touchPt = SKShapeNode(circleOfRadius: 30)
        touchPt.fillColor = SKColor.whiteColor()
        touchPt.alpha = 0
        self.addChild(touchPt)
        ptsCircle = [SKShapeNode]()
        
        for i in 1  ..< ptsRow  {
            for j in 1  ..< ptsCol  {
                let pt = CGPointMake(CGFloat(i) * CGFloat(ptsSpan), CGFloat(j) * CGFloat(ptsSpan))
                let circle = SKShapeNode(circleOfRadius: CGFloat(ptsSpan) / 2)
                circle.position = pt
                circle.fillColor = SKColor.clearColor()
                circle.strokeColor = SKColor.clearColor()
                ptsCircle.append(circle)
                self.addChild(circle)
            }
        }
        self.backgroundColor = UIColor.blackColor()

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        touchPt.position = CGPointMake(location.x, location.y)
        touchPt.alpha = 1
        var white = CGFloat(0)
        self.backgroundColor.getWhite(&white, alpha: nil)
        if (white > 0.5) {
            self.backgroundColor = SKColor.blackColor()
            self.selectBright = 1.0
            self.selectDark = 0.2
        } else {
            self.backgroundColor = SKColor.whiteColor()
            self.selectBright = 0.9
            self.selectDark = 0.2
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        touchPt.alpha = 0
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        touchPt.position = CGPointMake(location.x, location.y)
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        self.removeChildrenInArray(self.updateNodes)
        self.updateNodes = []
        taruiPts()
    }
    
    private func taruiPts() {


        
        
        
        if (image == nil) {
            return
        }

        for ptCircle in ptsCircle {
            let scale = image.size.width / self.size.width
            let color = image.colorAtPixel(CGPointMake(ptCircle.position.x * scale, (self.size.height - ptCircle.position.y) * scale))
            //let color = UIColor.grayColor()
            if (color != nil) {
                var hue : CGFloat = 0
                var saturation : CGFloat = 0
                var brightness : CGFloat = 0
                var alpha : CGFloat = 0
                color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                if (selectBright > brightness && brightness > selectDark) {
                    ptCircle.xScale = brightness
                    ptCircle.yScale = brightness
                    ptCircle.fillColor = color
                    ptCircle.strokeColor = color
                }
            }
        }
        
    }
    
}
