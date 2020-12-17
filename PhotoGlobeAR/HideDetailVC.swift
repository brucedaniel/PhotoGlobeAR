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
        storage?.delete(completion: {_ in
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(Notification(name: Notification.Name("deleteHide")))
            })
        })
    }
    
    @IBAction func doneEditingMessage() {
        storage?.updateMetadata(StorageMetadata(dictionary: ["message":"\(textField!.text!)"])!, completion: {_,_ in 
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storage!.downloadURL(completion: { [self]url,error in
            imageView!.kf.setImage(with: url)
        })
    }
    
}
