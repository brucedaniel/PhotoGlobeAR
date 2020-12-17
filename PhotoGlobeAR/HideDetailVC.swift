//
//  HideDetailVC.swift
//  PhotoGlobeAR
//
//  Created by Bruce Daniel on 12/16/20.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class HideDetailsVC : UIViewController {
    var storage :StorageReference?
    @IBOutlet var imageView:UIImageView?
    @IBOutlet var textField:UITextField?
    
    @IBAction func delete() {
        
    }
    
    @IBAction func doneEditingMessage() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storage!.downloadURL(completion: { [self]url,error in
            imageView!.kf.setImage(with: url)
        })
    }
    
}
