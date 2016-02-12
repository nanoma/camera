//
//  ViewController.swift
//  camera
//
//  Created by 花田奈々 on 2016/02/12.
//  Copyright © 2016年 com.litech. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //写真表示用
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //カメラ、アプリの呼び出しメソッド
    func precentPickerController(sourceType: UIImagePickerControllerSourceType){
        //ライブラリが使用できるかどうか判定
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //画像を出力
        photoImageView.image = image
    }
    
    //「画像を取得」ボタンを押したときに呼ばれるメソッド
    @IBAction func selectButtonTapped(sender: UIButton){
        
        //選択肢の上に表示するタイトル
        let alertController = UIAlertController(title: "画像の取得先を選択", message: nil, preferredStyle:  .ActionSheet)
        //選択肢の名前と処理を1つずつ設定
        let firstAction = UIAlertAction(title: "カメラ", style: .Default){
            action in
            self.precentPickerController(.Camera)
        }
        let secondAction = UIAlertAction(title: "アルバム", style: .Default){
            action in
            self.precentPickerController(.PhotoLibrary)
                
            }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
            
            //設定したアラートに登録
            alertController.addAction(firstAction)
            alertController.addAction(secondAction)
            alertController.addAction(cancelAction)
        
        //アラートを表示
        presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    //元の画像にテキストを合成するメソッド
    func drawText(image: UIImage) -> UIImage{
        let text = "LifeicTech!\nXmasCamp2015♥"
        
        //グラフィックコンテキスト生成・編集を開始
        UIGraphicsBeginImageContext(image.size)
        
        //読み込んだ写真を書き出す
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        //描き出す位置と大きさの設定
        let textRect = CGRectMake(5, 5, image.size.width - 5, image.size.height - 5)
        
        //文字の特性（フォント、カラー、スタイル）
        let textFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(120),
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle()
        ]
        //textを書き出す
        text.drawInRect(textRect, withAttributes: textFontAttributes)
        //グラフィックスコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //グラフィックコンテキストの編集を終了
        UIGraphicsEndImageContext()
        return newImage
    }
    //マークを書き出す
    func drawMaskImage(image: UIImage) -> UIImage{
        
        UIGraphicsBeginImageContext(image.size)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        let maskImage = UIImage(named: "heart")
        
        //書き出す位置と大きさ
        let offset: CGFloat = 100.0
        let maskRect = CGRectMake(
            image.size.width - maskImage!.size.width - offset,
            image.size.height - maskImage!.size.height - offset,
            maskImage!.size.width,
            maskImage!.size.height
        )
        
        //maskRectで限定した範囲にmaskaimageを書き出す
        maskImage!.drawInRect(maskRect)
        //グラフィックスコンテキストの画像を取得
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //グラフィックコンテキストの編集を終了
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //任意のメッセージとOKボタンを持つアラートのメソッド
    func simpleAllert(titleString: String){
        
    let alertController = UIAlertController(title: titleString, message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //合成ボタンを押した
    @IBAction func processButtonTapped(sender: UIButton){
        //photoImageView.imageがnilでなければselectedに値が入る
        guard let selectedPhoto = photoImageView.image else{
            //nilならアラートを表示してメソッドを抜ける
            simpleAllert("画像がありません")
            return
        }
        
        let alertController = UIAlertController(title: "合成するパーツを選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "テキスト", style: .Default){
            action in
            self.photoImageView.image = self.drawText(selectedPhoto)
        }
        let secondAction = UIAlertAction(title: "ハートマーク", style: .Default){
            action in
            self.photoImageView.image = self.drawMaskImage(selectedPhoto)
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        //設定したアラートに登録
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        //アラートを表示
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //SNSに投稿するメソッド
    func postToSNS(serviceType: String){
        //インスタンス化
        let myComposeView = SLComposeViewController(forServiceType: serviceType)
        myComposeView.setInitialText("photoMasterからの投稿！")
        myComposeView.addImage(photoImageView.image)
        self.presentViewController(myComposeView, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonTrapped(sender: UIButton){
        guard let selectedPhoto = photoImageView.image else{
            return
        }
        
        
        let alertController = UIAlertController(title: "アップロード先を選択", message: nil, preferredStyle: .ActionSheet)
        let firstAction = UIAlertAction(title: "Facebookに投稿", style: .Default){
            action in
            self.postToSNS(SLServiceTypeFacebook)
        }
        let secondAction = UIAlertAction(title: "twitterに投稿", style: .Default){
            action in
            self.postToSNS(SLServiceTypeTwitter)
        }
        
        let thirdAction = UIAlertAction(title: "カメラロールに保存", style: .Default){
            action in
            UIImageWriteToSavedPhotosAlbum(selectedPhoto, self, nil, nil)
            self.simpleAllert("アルバムに保存されました")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        //設定したアラートに登録
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(thirdAction)
        alertController.addAction(cancelAction)
        
        //アラートを表示
        presentViewController(alertController, animated: true, completion: nil)
        

        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

