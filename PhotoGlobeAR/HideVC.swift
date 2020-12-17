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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HideImageCell")!
        cell.textLabel?.text = "index: \(indexPath.row)"
        return cell
    }
    
    var ref: DatabaseReference?
    var storage : Storage?
    @IBOutlet var cameraFrame : UIView!
    @IBOutlet var table : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storage = Storage.storage(url:"gs://photoglobear-fb387.appspot.com")
        ref = Database.database(url: "https://photoglobear-fb387-default-rtdb.firebaseio.com/").reference()

    }
}
