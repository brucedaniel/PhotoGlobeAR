//
//  Photo.swift
//  PhotoGlobeAR
//
//  Created by Bruce Daniel on 12/11/20.
//

import Foundation
import RealityKit
import UIKit
import Photos
import RealityUI

class Photo {
    var asset : PHAsset? {
        didSet(newAsset) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            self.text = ModelEntity(
                mesh: .generateText("\(formatter.string(for: asset?.creationDate) ?? "no date")",
                                  extrusionDepth: 0.05,
                                            font: .systemFont(ofSize: 0.15),
                                            containerFrame: CGRect(x: 0.0, y: 0.0, width: Double(2.0 * defaultCardSize), height: Double(0.5 * defaultCardSize)),
                                       alignment: .left,
                                   lineBreakMode: .byCharWrapping),
                materials: [SimpleMaterial(color: UIColor.white, isMetallic: false)]
            )

            self.text?.orientation = simd_quatf(angle: .pi / -2.0, axis: [1.0,0,0])
            self.text?.setPosition(SIMD3.init(Float(-0.5 * defaultCardSize), Float(-1.5 * defaultCardSize), -0.0), relativeTo: text)
            self.base?.addChild(text!)
            
            let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
            option.isSynchronous = true
     
            manager.requestImage(for: asset!, targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                if let data = result!.pngData() {
                    let filename = self.getDocumentsDirectory().appendingPathComponent("PhotoGlobe_thumb_\(self.index).png")
                    
                    try? data.write(to: filename)
                    print("filename: \(filename)")
                    self.url = filename
                }
                
            })
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    var angle = 0.0
    var distance = 0.0
    var inclination = 0.0
    var url : URL? {
        didSet(newURL) {
            self.imageMaterial?.baseColor = try! MaterialColorParameter.texture(TextureResource.load(contentsOf:self.url!))
            self.base?.model?.materials.removeAll()
            self.base?.model?.materials.append(self.imageMaterial!)
        }
    }
    var text : ModelEntity?
    var base : ModelEntity?
    var imageMaterial : SimpleMaterial?
    let globe :PhotoGlobe
    var button : RUIButton?
    var stepper : RUIStepper?
    var slider : RUISlider?
    var uiSwitch : RUISwitch?
    var index = -1
    var defaultCardSize = 3.0
    
    init(globe:PhotoGlobe) {
        self.globe = globe
        
        self.imageMaterial = SimpleMaterial()
            
        base = ModelEntity(mesh: MeshResource.generatePlane(width: Float(0.8 * defaultCardSize), depth: Float(0.8 * defaultCardSize)), materials: [self.imageMaterial!])
        
        
//        self.button = RUIButton(updateCallback: { myButton in
//            self.text?.setPosition(SIMD3.init(-0.1, -0.1, -0.0), relativeTo: self.text!)
//        })
//        self.button?.orientation = simd_quatf(angle: .pi / 2.0, axis: [1.0,0,0])
//        self.button?.scale = SIMD3.init(x: -0.1, y: -0.1, z: -0.1)
//        self.button?.position = SIMD3.init(x: -0.1, y: 0.1, z: 0.1)
//        self.base?.addChild(self.button!)
        
//        self.stepper = RUIStepper(upTrigger: { _ in
//        }, downTrigger: { _ in
//        })
//        self.stepper?.orientation = simd_quatf(angle: .pi / 2.0, axis: [1.0,0,0])
//        self.stepper?.scale = SIMD3.init(x: -0.1, y: -0.1, z: -0.1)
//        self.stepper?.position = SIMD3.init(x: 0.0, y: 0.0, z: 0.0)
//        self.base?.addChild(self.stepper!)
//
//        self.slider = RUISlider(
//        ) { (slider, _) in
//        }
//        self.slider?.orientation = simd_quatf(angle: .pi / 2.0, axis: [1.0,0,0])
//        self.slider?.scale = SIMD3.init(x: -0.1, y: -0.1, z: -0.1)
//        self.slider?.position = SIMD3.init(x: 0.0, y: 0.0, z: 0.0)
//        self.base?.addChild(self.slider!)
//
//        self.uiSwitch = RUISwitch(
//          RUI: nil,
//          changedCallback: { mySwitch in
//
//          }
//        )
//        self.uiSwitch?.orientation = simd_quatf(angle: .pi / 2.0, axis: [1.0,0,0])
//        self.uiSwitch?.scale = SIMD3.init(x: -0.1, y: -0.1, z: -0.1)
//        self.uiSwitch?.position = SIMD3.init(x: 0.0, y: 0.0, z: 0.0)
//        self.base?.addChild(self.uiSwitch!)
        
    }
}
