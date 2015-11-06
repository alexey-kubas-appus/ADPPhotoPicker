//
//  ViewController.swift
//  ADPPhotoPicker
//
//  Created by Dmitry Pashinskiy on 11/3/15.
//  Copyright © 2015 Appus LLC. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    var currentImage: UIImage?
    var currentIndex: Int = 0
    var dataSource: [PHAsset]?
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    //MARK: - Actions
    @IBAction func previousTapped(sender: AnyObject) {
        self.setImageAtIndex(self.currentIndex - 1)
    }
    
    @IBAction func nextTapped(sender: AnyObject) {
        self.setImageAtIndex(self.currentIndex + 1)
    }
    
    @IBAction func photoGalleryTapped(sender: AnyObject) {
        let photoPicker = ADPPhotoPicker.photoPicker()
        photoPicker.delegate = self
        self.presentViewController(photoPicker, animated: true) { () -> Void in
            
        }
    }
    
    //MARK - Private Methods
    private func setImageAtIndex(index: Int){
        
        if let correctDataSource = self.dataSource {
            
            var correctIndex = index % correctDataSource.count
            if correctIndex < 0 {
                correctIndex = correctDataSource.endIndex + correctIndex
            }
            
            
            let asset = correctDataSource[correctIndex]
            self.imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, userInfo) -> Void in
                if imageData != nil {
                    self.previewImageView.image = UIImage(data: imageData!)
                    self.currentIndex = index
                }
            })
            
        }
    }
}

    //MARK: - ADPPhotoPickerDelegate
extension ViewController : ADPPhotoPickerDelegate {
    
    func photoPicker(photoPicker: ADPPhotoPicker, didEndSelectingImageAssets assets: [PHAsset]?) {
        self.dataSource = assets
        self.setImageAtIndex(0)
    }
    
}

