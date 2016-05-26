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

class GameScene: SKScene {
    // CoreMotion
    var myMotionManager: CMMotionManager!
 
    var selectId : Int! = 1
    var scale : CGFloat! = 1
    var ptMax : Int! = 10
    var image : UIImage!

    var ptArray = NSMutableArray()
    var sizeArray = NSMutableArray()
    var colorArray = NSMutableArray()
    
    var ptNodes = Array(arrayLiteral:SKNode())
    
    var touchPt: SKShapeNode!
    let detector = Detector()
    
    override func didMoveToView(view: SKView){

        touchPt = SKShapeNode(circleOfRadius: 30)
        touchPt.fillColor = SKColor.whiteColor()
        touchPt.alpha = 0
        self.addChild(touchPt)
        
        let xLabel = SKLabelNode()
        let yLabel = SKLabelNode()
        let zLabel = SKLabelNode()
        xLabel.position = CGPointMake(80, 30)
        yLabel.position = CGPointMake(80, 20)
        zLabel.position = CGPointMake(80, 10)
        xLabel.fontSize = 8
        yLabel.fontSize = 8
        zLabel.fontSize = 8
        xLabel.fontName = "Courier"
        yLabel.fontName = "Courier"
        zLabel.fontName = "Courier"
        xLabel.color = SKColor.whiteColor()
        yLabel.color = SKColor.whiteColor()
        zLabel.color = SKColor.whiteColor()
        /*
        self.addChild(xLabel)
        self.addChild(yLabel)
        self.addChild(zLabel)
        
        myMotionManager = CMMotionManager()
        myMotionManager.accelerometerUpdateInterval = 0.1
        myMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) { data, error in
            guard data != nil else {
                print("There was an error: \(error)")
                return
            }
            xLabel.text = "x:\(data!.acceleration.x)"
            yLabel.text = "y:\(data!.acceleration.y)"
            zLabel.text = "z:\(data!.acceleration.z)"
        }
        */
        
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        touchPt.position = CGPointMake(location.x, location.y)
        touchPt.alpha = 1
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

        self.removeChildrenInArray(self.ptNodes)
        self.ptNodes = []
        if (self.selectId == 4) {
            iwashitaPts()
        } else {
            commonPts()
        }
    }

    
    private func iwashitaPts() {
        
        
        // as3delaunay を使ってDelaunay 生成
        let voronoiPts = ptArray as NSArray as! [Point]
        //let voronoiColor = colorArray as NSArray as! [UIColor]
        let voronoiColor = colorArray as NSArray as! [UInt]
        let plotBounds = Rectangle(x: 0, y: 0, width: Int(self.frame.width), height: Int(self.frame.height))
        let voronoi = Voronoi(points: voronoiPts, colors: voronoiColor, plotBounds: plotBounds)
        
        let sites = voronoi.siteCoords()
        var points = [CGPoint]()
        for site in sites {
            let pt0 = CGPointMake(CGFloat(site.x), self.size.height - CGFloat(site.y))
            let circle0 = SKShapeNode(circleOfRadius: 5)
            circle0.position = pt0
            let c = image.colorAtPixel(pt0)
            var hue : CGFloat = 0
            var saturation : CGFloat = 0
            var brightness : CGFloat = 0
            var alpha : CGFloat = 0
            c.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            var color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 0.5)
            let white = UIColor.whiteColor()
            if (saturation < 0.2) {
                color = white
            }
            
            

            //let color = UIColor(red: 1, green: 1 - brightness, blue: 1 - brightness, alpha: 0.5)
            circle0.fillColor = white
            circle0.strokeColor = white
            circle0.zPosition = 1
            circle0.alpha = 0.5
            self.ptNodes.append(circle0)
            self.addChild(circle0)

            let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            label.position = CGPointMake(pt0.x + 10, pt0.y + 10)
            label.text = String(Int(pt0.x)) + "," + String(Int(pt0.y))
            label.fontColor = white
            label.fontSize = 6
            self.ptNodes.append(label)
            self.addChild(label)

            /*
            let pts = voronoi.neighborSitesForSite(site)
            for pt in pts {
                let pt0 = CGPointMake(CGFloat(pt.x), self.size.height - CGFloat(pt.y))
                let circle0 = SKShapeNode(circleOfRadius: 2)
                circle0.position = pt0
                self.ptNodes.append(circle0)
                self.addChild(circle0)
            }
              */

            let lines = voronoi.delaunayLinesForSite(site)
            
            
            for line in lines {
                let pt0 = CGPointMake(CGFloat(line.p0.x), self.size.height - CGFloat(line.p0.y))
                let pt1 = CGPointMake(CGFloat(line.p1.x), self.size.height - CGFloat(line.p1.y))
                points.append(pt0)
                points.append(pt1)
                let line = SKShapeNode(points: &points, count: points.count)
                line.strokeColor = color
                line.strokeColor = color
                line.lineWidth = 0.2
                line.alpha = 0.2
                line.glowWidth = 1
                line.zPosition = -1
                
                self.ptNodes.append(line)
                
                self.addChild(line)
            }
        }
        
        


        /*

        let regions = voronoi.regions()
        for region in regions {
            var count = 0;
            let path:CGMutablePathRef = CGPathCreateMutable()
            let myLine:SKShapeNode = SKShapeNode(path:path)
            for pt in region {
                if (count == 0) {
                    CGPathMoveToPoint(path, nil, CGFloat(pt.x), self.size.height - CGFloat(pt.y))
                } else {
                    //CGPathAddLineToPoint(path, nil, CGFloat(pt.x), self.size.height - CGFloat(pt.y))
                    CGPathAddArc(path, nil, CGFloat(pt.x), self.size.height - CGFloat(pt.y), 20, 0, CGFloat(M_PI*Double(1.2)), false)
                }
                count++
            }
            CGPathCloseSubpath(path)

            myLine.path = path
            myLine.strokeColor = SKColor.whiteColor()
            //myLine.fillColor = SKColor.yellowColor()
            myLine.alpha = 0.5
            self.addChild(myLine)
            self.ptNodes.append(myLine)

        }
        */
        /*
        let delaunay = voronoi.delaunayTriangulation()
        //let delaunay = voronoi.voronoiDiagram()
        points = [CGPoint]()
        for delaunayItem in delaunay {
            let pt0 = CGPointMake(CGFloat(delaunayItem.p0.x), self.size.height - CGFloat(delaunayItem.p0.y))
            let pt1 = CGPointMake(CGFloat(delaunayItem.p1.x), self.size.height - CGFloat(delaunayItem.p1.y))
            points.append(pt0)
            points.append(pt1)
            let line = SKShapeNode(points: &points, count: points.count)
            self.ptNodes.append(line)
            self.addChild(line)

        }
        */

        /*
        let voronoiCollors = voronoi.siteColors() as NSArray
        let voronoiRegions = voronoi.regions() as NSArray
        for var i = 0; i < voronoiRegions.count; i++ {
            let voronoiRegion = voronoiRegions.objectAtIndex(i)
            let points = voronoiRegion as! NSArray
            // セル作成
            var pointRegions = [CGPoint]()
            for point in points {
                let point = point as! Point
                let p0x = CGFloat(point.x)
                let p0y = self.size.height - CGFloat(point.y)
                pointRegions.append(CGPointMake(p0x, p0y))
            }
            let shapeRegion = SKShapeNode(points: &pointRegions, count: pointRegions.count)
            if let voronoiColor = voronoiCollors.objectAtIndex(i) as? UIColor {
                var hue : CGFloat = 0
                var saturation : CGFloat = 0
                var brightness : CGFloat = 0
                var alpha : CGFloat = 0
                voronoiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                shapeRegion.strokeColor = voronoiColor.colorWithAlphaComponent(0.9)
                shapeRegion.fillColor = voronoiColor.colorWithAlphaComponent(0.9)
            }
            self.ptNodes.append(shapeRegion)
            self.addChild(shapeRegion)
        }
        */
        

    }

    private func commonPts() {
        for i in 0  ..< ptArray.count  {
            let circle = SKShapeNode(circleOfRadius: sizeArray.objectAtIndex(i) as! CGFloat)
            let pt = ptArray.objectAtIndex(i) as! Point
            let color = colorArray.objectAtIndex(i) as! SKColor
            var hue : CGFloat = 0
            var saturation : CGFloat = 0
            var brightness : CGFloat = 0
            var alpha : CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            circle.fillColor = color.colorWithAlphaComponent(1)
            circle.strokeColor = color.colorWithAlphaComponent(1)
            circle.position = CGPointMake(CGFloat(pt.x), self.size.height - CGFloat(pt.y))
            /*
            if (nspoint["classid"] as! Float == 1) {
                circle.strokeColor = SKColor.yellowColor()
            } else {
                circle.strokeColor = SKColor.redColor()
            }
            */
            self.ptNodes.append(circle)
            self.addChild(circle)
        }
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
                //let color = UIColor.whiteColor()
                colorArray.addObject(0)
                //colorArray.addObject(color)
                sizeArray.addObject(ptSize)
                ptArray.addObject(Point(x: Double(CGFloat(ptVal.x) * self.scale), y: Double(CGFloat(ptVal.y) * self.scale)))
                if (i == self.ptMax) {
                    break
                }
            }
        }
    }
    
}
