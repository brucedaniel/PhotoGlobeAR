//
//  HideVC.swift
//  PhotoGlobeAR
//
//  Created by Bruce Daniel on 12/16/20.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class HideVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HideImageCell")!

        let imgView = cell.viewWithTag(3) as! UIImageView
        imgView.image = nil
        self.items[indexPath.row].downloadURL(completion: {url,error in
            imgView.kf.setImage(with: url)
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "hideDetailSegue", sender: self.items[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let details = segue.destination as? HideDetailsVC {
            let path = self.table.indexPathForSelectedRow!.row
            let item = self.items[path]
            details.storage = item
            self.table.deselectRow(at: self.table.indexPathForSelectedRow!, animated: false)
        }
    }
    
    @IBOutlet var cameraFrame : UIView!
    @IBOutlet var table : UITableView!
    var items = [StorageReference]()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name("uploadedHide"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name("deleteHide"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update()
    }
    
    @objc func update() {
        Storage.storage(url:"gs://photoglobear-fb387.appspot.com").reference(withPath: "mySessionString").listAll(completion: { [self]result,error in
            items.removeAll()
            items.append(contentsOf: result.items)
            self.table.reloadData()
        })
    }
}
