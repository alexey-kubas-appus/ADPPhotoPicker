//
//  ADPPhotoPicker.swift
//  ADPPhotoPicker
//
//  Created by Dmitry Pashinskiy on 11/3/15.
//  Copyright © 2015 Appus LLC. All rights reserved.
//

import Foundation
import UIKit
import Photos

let CellIdentifier = "ADPPhotoCellIdentifier"
let PhotoPickerNibName = "ADPPhotoPickerView"


@objc protocol ADPPhotoPickerDelegate {
    
    /// after Done button will be tapped, this method will send array of **PHAsset**
    func photoPicker(photoPicker: ADPPhotoPicker, didEndSelectingImageAssets assets: [PHAsset]?)
    
    /// will be called before dismiss
    optional func willHidePhotoPicker(photoPicker: ADPPhotoPicker)
    
}


class ADPPhotoPicker: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topBarView: UIView!
    
    private var assetsFetchResults: PHFetchResult!
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var selectedIndexPaths: Set<NSIndexPath>! = Set()
    
    
    var delegate: ADPPhotoPickerDelegate?
    
    /// Width of collection view will be automatically configured for this value. **Default 4**
    var cellsCountInRow: UInt = 4
    
    /// Space for cells between cells and bounds in superview (`collectionView`). **Default 5**
    var spaceInset: CGFloat = 5
    
    /// background color for `collectionView`. **Default whiteColor**
    var backgroundColor = UIColor.whiteColor()
    
    /// topBar background color. **Default lightGray**
    var topBarColor = UIColor(red:0.83, green:0.83, blue:0.83, alpha:1)
    
    /// contentMode for each *imageView* in cells. **Default AspectFit**
    var contentMode = PHImageContentMode.AspectFit
    
    /// target size for images which will be received from PHAssets. **Defautlt CGSizeMake(100, 100)**
    var imageSize = CGSizeMake(100, 100)
    
    
    class func photoPicker() -> ADPPhotoPicker{
        return ADPPhotoPicker(nibName: PhotoPickerNibName, bundle: NSBundle.mainBundle())
    }
    
//MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultsInit()
        
        self.updateDataSource()
        
        self.registerCell()
        
    }
    
    
//MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ADPPhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! ADPPhotoCell
        
        
        let asset:PHAsset = self.assetsFetchResults[indexPath.item] as! PHAsset
        self.imageManager.requestImageForAsset(asset,
            targetSize: self.imageSize,
            contentMode: self.contentMode,
            options: nil)
            { (image, object) -> Void in
                let isChecked = self.selectedIndexPaths.contains(indexPath)
                cell.initWithImage(image, checked: isChecked)
        }
        
        return cell
    }
    
    
//MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let isSelected = self.selectedIndexPaths.contains(indexPath)
        // update dataSource of indexPaths
        if  isSelected {
            self.selectedIndexPaths.remove(indexPath)
        } else {
            self.selectedIndexPaths.insert(indexPath)
        }
        
        // unchecked current cell
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! ADPPhotoCell
        cell.isChecked = !isSelected
    }
    
    
//MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        let countOfSpaceLines = CGFloat(self.cellsCountInRow + 1)  // count of space lines always bigger on 1.
        
        // full width of spaceLines
        let widthAllLines  = self.spaceInset * CGFloat(countOfSpaceLines)
        
        // final size of width
        let cellWidth: CGFloat = (screenWidth - widthAllLines) / CGFloat(self.cellsCountInRow)
        
        return CGSizeMake(cellWidth, cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let inset = self.spaceInset
        return UIEdgeInsets(top: inset,
            left: inset,
            bottom: inset,
            right: inset)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.spaceInset
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.spaceInset
    }
    
//MARK: - Actions, Selectors

    @IBAction private func didTappedDoneButton(sender: UIButton) {
        
        let selectedAssets = self.getSelectedAssets()
        
        self.delegate?.photoPicker(self, didEndSelectingImageAssets: selectedAssets)
        
        self.delegate?.willHidePhotoPicker?(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func backTapped(sender: UIButton) {
        self.delegate?.willHidePhotoPicker?(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//MARK: - Private Methods

    /// set default configuration to class
    private func defaultsInit() {
        self.collectionView.backgroundColor = self.backgroundColor
        self.topBarView.backgroundColor = self.topBarColor
    }
    
    /// register cell from xib for `collectionView`
    private func registerCell() {
        
        let cellNib = UINib(nibName: "ADPPhotoCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: CellIdentifier)
    }
/**
    Fetch all Images as **PHAssets** from device
*/
    private func updateDataSource() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        self.assetsFetchResults = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
    }
    
    private func getSelectedAssets() -> [PHAsset]? {
        if selectedIndexPaths.count == 0 {
            //there is no selected indexPath
            return nil
        }
        
        var selectedAssets: [PHAsset] = [PHAsset]()
        
        //select assets which contains in selectedIndexPaths
        for indexPath in self.selectedIndexPaths {
            let asset = self.assetsFetchResults[indexPath.item] as! PHAsset
            selectedAssets.append(asset)
        }
        
        return selectedAssets
    }
    
}