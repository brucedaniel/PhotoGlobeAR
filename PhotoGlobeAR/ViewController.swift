//
//  ViewController.swift
//  PhotoGlobeAR
//
//  Created by Bruce Daniel on 12/9/20.
//

import UIKit
import RealityKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}
