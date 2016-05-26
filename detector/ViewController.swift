//
//  ViewController.swift
//  AVFoundation002
//

import UIKit
import SpriteKit
import AVFoundation
import FontAwesome_swift

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureVideoDataOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    //var imageView: UIImageView!
    var myName:Int!
    let mySize = CGSize(width: 180, height: 180) // detectorで使う画像サイズ

    let detector = Detector()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var skView: SKView!
    
    var cameraFront: Bool = false

    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = UIColor.clearColor()
        
        /* Set the scale mode to scale to fit the window */
        /*
        let scene = SuzukiScene()
        scene.scaleMode = .AspectFill
        scene.size = skView.bounds.size
        scene.backgroundColor = SKColor.clearColor()
        
        skView.presentScene(scene)
        */
        switchScene(myName)
    }
    
    private func switchScene(myName: Int) {
        var scene: SKScene!
        if (myName == 0) {
            scene = SuzukiScene()
        } else if (myName == 1) {
            scene = TaruiScene()
        } else {
            scene = GameScene()
        }
        scene.scaleMode = .AspectFill
        scene.size = skView.bounds.size
        scene.backgroundColor = SKColor.clearColor()
        skView.presentScene(scene)
    }
    
    override func viewWillAppear(animated: Bool) {
        // スクリーン設定
        setupDisplay()
        // カメラの設定
        setupCamera()
    }
    
    // メモリ解放
    override func viewDidDisappear(animated: Bool) {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }
    
    func setupDisplay(){
        //スクリーンの幅
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        //スクリーンの高さ
        //let screenHeight = UIScreen.mainScreen().bounds.size.height;
        
        // プレビュー用のビューを生成
        //imageView = UIImageView()
        imageView.frame = CGRectMake(0.0, 0.0, screenWidth, screenWidth)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    func setupCamera(){
        // AVCaptureSession: キャプチャに関する入力と出力の管理
        session = AVCaptureSession()
        
        // sessionPreset: キャプチャ・クオリティの設定
        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetPhoto
        //        session.sessionPreset = AVCaptureSessionPresetHigh
        //        session.sessionPreset = AVCaptureSessionPresetMedium
        //        session.sessionPreset = AVCaptureSessionPresetLow
        
        // AVCaptureDevice: カメラやマイクなどのデバイスを設定
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            if (!cameraFront){
                // 背面カメラを取得
                if caputureDevice.position == AVCaptureDevicePosition.Back {
                    camera = caputureDevice as? AVCaptureDevice
                }
            } else {
                // 前面カメラを取得
                if caputureDevice.position == AVCaptureDevicePosition.Front {
                    camera = caputureDevice as? AVCaptureDevice
                }
            }
        }
        
        // カメラからの入力データ
        // swift 2.0
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        
        // 入力をセッションに追加
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        
        // AVCaptureStillImageOutput:静止画
        // AVCaptureMovieFileOutput:動画ファイル
        // AVCaptureAudioFileOutput:音声ファイル
        // AVCaptureVideoDataOutput:動画フレームデータ
        // AVCaptureAudioDataOutput:音声データ
        
        // AVCaptureVideoDataOutput:動画フレームデータを出力に設定
        output = AVCaptureVideoDataOutput()
        // 出力をセッションに追加
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        // ピクセルフォーマットを 32bit BGR + A とする
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
        
        // フレームをキャプチャするためのサブスレッド用のシリアルキューを用意
        output.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        
        output.alwaysDiscardsLateVideoFrames = true
        
        // カメラの向きを合わせる
        for connection in output.connections {
            if let conn = connection as? AVCaptureConnection {
                if conn.supportsVideoOrientation {
                    conn.videoOrientation = AVCaptureVideoOrientation.Portrait
                }
            }
        }
        
        // ビデオ出力に接続
        //        let connection = output.connectionWithMediaType(AVMediaTypeVideo)
        
        session.startRunning()
        
        // deviceをロックして設定
        // swift 2.0
        do {
            try camera.lockForConfiguration()
            // フレームレート
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    @IBAction func changeCamera(sender: AnyObject) {

        //セッションからvideoInputの取り消し
        session?.removeInput(input);

        //今と反対の向きを判定
        cameraFront = !cameraFront;

        self.setupCamera()
        
    }

    @IBAction func accessPhoto(sender: AnyObject) {
        // ユーザーに許可を促す.
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            controller
            controller.navigationBar.barStyle = UIBarStyle.Black
            controller.navigationBar.translucent = false
            controller.navigationBar.tintColor = UIColor.whiteColor()
            self.presentViewController(controller, animated: true, completion: nil)

        }
    }

    

    
    
    // 新しいキャプチャの追加で呼ばれる
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        // キャプチャしたsampleBufferからUIImageを作成
        let image:UIImage = self.captureImage(sampleBuffer)

        
        // 画像を画面に表示
        dispatch_async(dispatch_get_main_queue()) {
            let reimage = self.resizeImage(image, size: self.mySize)
            let pt = self.detector.detectPoint(reimage)
            
            if let scene = self.skView.scene as? TaruiScene {
                scene.image = image
            }
            if let scene = self.skView.scene as? SuzukiScene {
                scene.scale = CGFloat(self.imageView.frame.size.width / self.mySize.width)
                scene.convertPts(pt)
            }
            if let scene = self.skView.scene as? GameScene {
                scene.scale = CGFloat(self.imageView.frame.size.width / self.mySize.width)
                scene.selectId = 4
                scene.image = image
                scene.convertPts(pt)

            }
            self.imageView.image = image
        }
    }
    
    func resizeImage(image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let reimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reimage
    }
    
    // sampleBufferからUIImageを作成
    func captureImage(sampleBuffer:CMSampleBufferRef) -> UIImage{
        
        // Sampling Bufferから画像を取得
        let imageBuffer:CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // pixel buffer のベースアドレスをロック
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress:UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        
        // 色空間
        let colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitsPerCompornent:Int = 8
        // swift 2.0
        let newContext:CGContextRef = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace,  CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue)!

        let imageRef:CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Up)

        // iwa add
        let imageRef2 = CGImageCreateWithImageInRect(resultImage.CGImage, CGRectMake(0, 0, resultImage.size.width, resultImage.size.width))!
        let resultImage2 = UIImage(CGImage: imageRef2, scale: 1.0, orientation: UIImageOrientation.Up)
        return resultImage2
    }

    // タップイベント.
    @IBAction func takePicture(sender: AnyObject) {
        takeStillPicture()
        shutterAnimation()
    }
    
    func takeStillPicture(){
        if var _:AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo){
            // spritekit
            UIGraphicsBeginImageContextWithOptions(self.skView.frame.size, false, 0.0)
            self.skView.drawViewHierarchyInRect(self.skView.bounds, afterScreenUpdates: true)
            let skimage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            //UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)

            // 合成
            let image = self.imageView.image!
            let rect = CGRectMake(0, 0, image.size.width, image.size.height)
            UIGraphicsBeginImageContext(image.size);
            image.drawInRect(rect)
            skimage.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            
            // アルバムに追加
            UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil)
        }
    }
    
    func shutterAnimation() {
        AudioServicesPlaySystemSound(1108)

        let animation = CATransition()
        //animation.type = "cameraIris"
        animation.type = kCATransitionFade
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        self.view.layer.opaque = true
        self.view.layer.addAnimation(animation, forKey:"transitionViewAnimation")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}