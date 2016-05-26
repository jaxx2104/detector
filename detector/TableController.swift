//
//  TableController.swift
//  uni
//
//  Created by iwa on 2015/08/27.
//  Copyright © 2015年 jaxx. All rights reserved.
//

import UIKit
import FLAnimatedImage

class TableController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    
    // セルに表示するテキスト
    let texts = ["RADIATE", "DOT", "EDGE"]
    let imgArray: NSArray = [
        "2月 06, 2016 01:34",
        "1月 31, 2016 21:56",
        "1月 30, 2016 21:53",
    ]
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //let path = NSBundle.mainBundle().pathForResource("appicon", ofType: "jpg")!
        //let image = UIImage(contentsOfFile: path)
        
        
        let image = UIImage(named: "icon")
        self.navigationItem.titleView = UIImageView(image: image)
        
        
        //self.items.append(Item(title: "タイトル1", subtitle: "サブタイトル1"))
        //self.tableView.rowHeight = UITableViewAutomaticDimension

    }

    //Table Viewのセルの数を指定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return texts.count
        return self.texts.count
    }

    func tableView(table: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as UITableViewCell
        // Tag番号 1 で UIImageView インスタンスの生成
        /*
        let img = UIImage(named:imgArray[indexPath.row] as! String)
        let imageView = table.viewWithTag(1) as! UIImageView
        imageView.image = img
        */
        table.rowHeight = self.view.frame.size.height / CGFloat(self.texts.count)
        let path = NSBundle.mainBundle().pathForResource(imgArray[indexPath.row] as? String, ofType: "gif")!
        let flimage = FLAnimatedImage(animatedGIFData: NSData(contentsOfFile: path))
        let flimageView = table.viewWithTag(1) as! FLAnimatedImageView
        flimageView.animatedImage = flimage


        
        
        // Tag番号 ２ で UILabel インスタンスの生成
        let label = table.viewWithTag(2) as! UILabel
        label.text = texts[indexPath.row]

        return cell
    }

    // Cell が選択された場合
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        // SubViewController へ遷移するために Segue を呼び出す
        performSegueWithIdentifier("toDetailController", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nextViewController = segue.destinationViewController as? ViewController {
            nextViewController.myName = sender as? Int
        } else {
            let viewController = segue.destinationViewController
            viewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
    }
    
    /*
    * SecondViewから戻ってきた時の処理
    */
    @IBAction func backFromSegue(segue:UIStoryboardSegue){

    }

}