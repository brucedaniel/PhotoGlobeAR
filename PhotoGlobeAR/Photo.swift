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
                                  font: UIFont(name: "Futura-Medium", size: 0.5)!,
                                            containerFrame: CGRect(x: Double(0.1 * defaultCardSize), y: Double(-0.01 * defaultCardSize), width: Double(2.0 * defaultCardSize), height: Double(0.5 * defaultCardSize)),
                                       alignment: .left,
                                   lineBreakMode: .byCharWrapping),
                materials: [SimpleMaterial(color: UIColor.cyan, isMetallic: false)]
            )

            self.text?.orientation = simd_quatf(angle: .pi / -2.0, axis: [1.0,0,0])
            self.text?.setPosition(SIMD3.init(Float(-0.5 * defaultCardSize), Float(-1.5 * defaultCardSize), -0.0), relativeTo: text)
            
            
            self.textFront = ModelEntity(
                mesh: .generateText("\(formatter.string(for: asset?.creationDate) ?? "no date")",
                                  extrusionDepth: 0.01,
                                  font: UIFont(name: "Futura-Medium", size: 0.5)!,
                                            containerFrame: CGRect(x: Double(0.1 * defaultCardSize), y: Double(-0.01 * defaultCardSize), width: Double(2.0 * defaultCardSize), height: Double(0.5 * defaultCardSize)),
                                       alignment: .left,
                                   lineBreakMode: .byCharWrapping),
                materials: [SimpleMaterial(color: UIColor.magenta, isMetallic: false)]
            )

            self.textFront?.orientation = simd_quatf(angle: .pi / -2.0, axis: [1.0,0,0])
            self.textFront?.setPosition(SIMD3.init(0, 0, 0.10), relativeTo: text)
            
            self.base?.addChild(text!)
            self.base?.addChild(textFront!)
            
            
            let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
            option.isSynchronous = true
     
            manager.requestImage(for: asset!, targetSize: CGSize(width: 400.0, height: 400.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                if let data = result!.pngData() {
                    let filename = self.getDocumentsDirectory().appendingPathComponent("PhotoGlobe_thumb_\(self.index).png")
                    
                    try? data.write(to: filename)
                    //print("filename: \(filename)")
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
    var textFront : ModelEntity?
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
        
        
    }
}
