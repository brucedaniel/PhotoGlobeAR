//
//  HideVC.swift
//  PhotoGlobeAR
//
//  Created by Bruce Daniel on 12/16/20.
//

import Foundation
import UIKit
import Firebase

class HideVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HideImageCell")!
        cell.textLabel?.text = ")"
        cell.imageView?.image = nil
        
        self.items[indexPath.row].downloadURL(completion: {url,error in
            cell.textLabel?.text = "index: \(url?.absoluteString)"
        })
        return cell
    }
    
    
    @IBOutlet var cameraFrame : UIView!
    @IBOutlet var table : UITableView!
    var items = [StorageReference]()
    override func viewDidLoad() {
        super.viewDidLoad()
        Storage.storage(url:"gs://photoglobear-fb387.appspot.com").reference(withPath: "mySessionString").listAll(completion: { [self]result,error in
            items.removeAll()
            items.append(contentsOf: result.items)
            self.table.reloadData()
        })

    }
}
