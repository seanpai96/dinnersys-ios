//
//  AlertController.swift
//  DinnerSystem
//
//  Created by Sean on 2018/1/27.
//  Copyright © 2018年 Sean.Inc. All rights reserved.
//

import UIKit

extension UIAlertController{
    func addImage(image: UIImage){
        let maxSize = CGSize(width: 330, height: 300)
        let imgsize = image.size
        var sizedImage = image
        
        if (imgsize.height > imgsize.width){
            let left = (maxSize.width - imgsize.width) / 2
            sizedImage = sizedImage.withAlignmentRectInsets(UIEdgeInsetsMake(0, -left, 0, 0))
        }
        
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(sizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
}