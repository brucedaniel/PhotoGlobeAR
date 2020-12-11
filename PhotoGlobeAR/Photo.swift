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
                                  font: UIFont(name: "Futura-Medium", size: CGFloat(self.defaultCardSize * 0.15))!,
                                            containerFrame: CGRect(x: Double(0.1 * defaultCardSize), y: Double(-0.01 * defaultCardSize), width: Double(2.0 * defaultCardSize), height: Double(0.5 * defaultCardSize)),
                                       alignment: .left,
                                   lineBreakMode: .byCharWrapping),
                materials: [SimpleMaterial(color: UIColor(hex: "#bc658dff")!, isMetallic: false)]
            )

            self.text?.orientation = simd_quatf(angle: .pi / -2.0, axis: [1.0,0,0])
            self.text?.setPosition(SIMD3.init(Float(-0.5 * defaultCardSize), Float(-1.5 * defaultCardSize), -0.0), relativeTo: text)
            
            
            self.textFront = ModelEntity(
                mesh: .generateText("\(formatter.string(for: asset?.creationDate) ?? "no date")",
                                  extrusionDepth: 0.01,
                                  font: UIFont(name: "Futura-Medium", size: CGFloat(self.defaultCardSize * 0.15))!,
                                            containerFrame: CGRect(x: Double(0.1 * defaultCardSize), y: Double(-0.01 * defaultCardSize), width: Double(2.0 * defaultCardSize), height: Double(0.5 * defaultCardSize)),
                                       alignment: .left,
                                   lineBreakMode: .byCharWrapping),
                materials: [SimpleMaterial(color: UIColor(hex: "#82c4c3ff")!, isMetallic: false)]
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
    var defaultCardSize = 1.0
    
    init(globe:PhotoGlobe) {
        self.globe = globe
        
        self.imageMaterial = SimpleMaterial()
            
        base = ModelEntity(mesh: MeshResource.generatePlane(width: Float(0.8 * defaultCardSize), depth: Float(0.8 * defaultCardSize)), materials: [self.imageMaterial!])
        
        if (false) {
            self.button = RUIButton(updateCallback: { myButton in
                        self.text?.setPosition(SIMD3.init(-0.1, -0.1, -0.0), relativeTo: self.text!)
                    })
            self.button?.orientation = simd_quatf(angle: .pi / -2.0, axis: [1.0,0,0])
            self.button?.scale = SIMD3.init(x: 1.0, y: 1.0, z: 1.0)
            self.button?.position = SIMD3.init(x: 0.0, y: 0.0, z: 0.1)
            self.base?.addChild(self.button!)
        }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
