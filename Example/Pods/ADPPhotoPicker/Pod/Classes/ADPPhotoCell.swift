//
//  ADPPhotoCell.swift
//  ADPPhotoPicker
//
//  Created by Dmitry Pashinskiy on 11/3/15.
//  Copyright © 2015 Appus LLC. All rights reserved.
//

import UIKit

let checkedBoxImage = "check_icon"

class ADPPhotoCell: UICollectionViewCell {

    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    var isChecked: Bool = false {
        didSet{
            self.checkBoxImageView.hidden = !isChecked
        }
    }
    
    func initWithImage(image: UIImage?, checked: Bool! = false){
        if let receivedImage = image {
            self.imageView.image = receivedImage
            self.isChecked = checked
        }
    }
    
//MARK: - Private Methods
    private func defaultsInit(){
        
    }
}
