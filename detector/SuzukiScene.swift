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

class SuzukiScene: SKScene, SKPhysicsContactDelegate {
    var selectId : Int!
    var scale : CGFloat! = 1
    var ptMax : Int! = 5
    
    var updateNodes = Array(arrayLiteral:SKNode())
    
    var touchPt : CGPoint!
    var beforePt : CGPoint!

    var ptArray = NSMutableArray()
    var sizeArray = NSMutableArray()
    var colorArray = NSMutableArray()
    
    let kana = ["d","e","t","e","c","t","o","r"]
    let kanaSize = [8, 11, 11, 11, 52]
    
    let detector = Detector()

    override func didMoveToView(view: SKView){
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0.0, -3.0)
        
        self.backgroundColor = UIColor.clearColor()
        //let touchPt = SKLabelNode(text: "あ")
        touchPt = CGPointMake(0, 0)
        beforePt = CGPointMake(0, 0)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //let touch = touches.first!
        //let location = touch.locationInNode(self)
        //touchPt.position = CGPointMake(location.x, location.y)
        //touchPt.alpha = 1

    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //touchPt.alpha = 0
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        touchPt = CGPointMake(location.x, location.y)
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        self.removeChildrenInArray(self.updateNodes)
        self.updateNodes = []

        suzukiPts(currentTime)
        let xDistance = (beforePt.x - touchPt.x)
        let yDistance = (beforePt.y - touchPt.y)
        let speed = sqrtf(Float(xDistance*xDistance) + Float(yDistance*yDistance));
        beforePt = touchPt
        if (speed != 0) {
            var size = CGFloat(speed)
            if (speed > 60) {
                size = 60
            }
            let moji = SKLabelNode(fontNamed: "HiraKakuProN-W6")
            moji.fontColor = SKColor.whiteColor()
            moji.position = touchPt
            moji.text = kana[Int(arc4random_uniform(UInt32(kana.count)))]
            moji.fontSize = size * 0.7
            moji.zRotation = 0
            self.addChild(moji)
            self.deleteMoji(moji)
        }

        

        
    }
    
    private func suzukiPts(currentTime: NSTimeInterval) {

        if (currentTime % 5 < 0.1) {
            let detectPts = ptArray as NSArray as! [Point]
            for detectPt in detectPts {
                let pt = CGPointMake(CGFloat(detectPt.x), self.size.height - CGFloat(detectPt.y))
                let moji = SKLabelNode(fontNamed: "HiraKakuProN-W6")
                moji.physicsBody?.affectedByGravity = false
                moji.position = pt
                moji.text = kana[Int(arc4random_uniform(UInt32(kana.count)))]
                moji.fontSize = CGFloat(kanaSize[Int(arc4random_uniform(5))])
                moji.fontColor = SKColor.whiteColor()
                //moji.zRotation = CGFloat(arc4random_uniform(5))
                self.addChild(moji)
                self.deleteMoji(moji)
                
            }
        }
    }

    
    private func deleteMoji(moji:SKLabelNode){
        let stop = SKAction.waitForDuration(1)
        let grav = SKAction.customActionWithDuration(0.0, actionBlock: { (node: SKNode!, elapsedTime: CGFloat) -> Void in
            self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
            node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(moji.fontSize, moji.fontSize))
        })
        let wait = SKAction.waitForDuration(1 + Double(arc4random_uniform(3)))
        let fade = SKAction.fadeAlphaTo(0, duration: 1)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([stop, grav, wait, fade, remove])
        moji.runAction(sequence)
    }
    
    internal func convertPts(points: NSMutableArray) {
        self.ptArray = []
        self.sizeArray = []
        self.colorArray = []
        
        // OpenCV の Points Object を変換
        if (points.count > 0) {
            for i in 0  ..< points.count  {
                let ptDict = points.objectAtIndex(i) as! NSDictionary
                let ptVal = (ptDict["pt"] as! NSValue).CGPointValue()
                let ptSize = ptDict["size"] as! CGFloat
                if (ptSize < 10) {
                    continue
                }
                // let ptColor = ptDict["color"] as! NSDictionary
                //let color = image.colorAtPixel(ptVal)
                let color = UIColor.whiteColor()
                colorArray.addObject(color)
                sizeArray.addObject(ptSize)
                ptArray.addObject(Point(x: Double(CGFloat(ptVal.x) * self.scale), y: Double(CGFloat(ptVal.y) * self.scale)))
                if (i == self.ptMax) {
                    break
                }
            }
        }
    }
    

    
}
