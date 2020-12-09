import RealityKit
import UIKit
import Photos
import RealityUI

enum FlipTableError: Error {
  case unevenDimensions
  case dimensionsTooLarge
}

class Photo {
    var asset : PHAsset? {
        didSet(newAsset) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            self.text = ModelEntity(
                mesh: .generateText("\(formatter.string(for: asset?.creationDate) ?? "no date")",
                                  extrusionDepth: 0.05,
                                            font: .systemFont(ofSize: 0.15),
                                            containerFrame: CGRect(x: 0.0, y: 0.0, width: 2.0, height: 0.5),
                                       alignment: .left,
                                   lineBreakMode: .byCharWrapping),
                materials: [SimpleMaterial(color: UIColor.white, isMetallic: false)]
            )

            self.text?.orientation = simd_quatf(angle: .pi / -2.0, axis: [1.0,0,0])
            self.text?.setPosition(SIMD3.init(-0.5, -1.5, -0.0), relativeTo: text)
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
    let table :FlipTable
    var button : RUIButton?
    var stepper : RUIStepper?
    var slider : RUISlider?
    var uiSwitch : RUISwitch?
    var index = -1
    var defaultCardSize = 3.0
    
    init(table:FlipTable) {
        self.table = table
        
        self.imageMaterial = SimpleMaterial()
            
        base = ModelEntity(mesh: MeshResource.generatePlane(width: Float(0.9 * defaultCardSize), depth: Float(0.9 * defaultCardSize)), materials: [self.imageMaterial!])
        
        
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
class FlipTable: Entity, HasAnchoring, HasCollision {
  var allPhotos : PHFetchResult<PHAsset>?
  var photos = [Photo].init()
  var exclusions = [PHAsset].init()
  var carouselAngle = 0.0
 
    required init() {
        super.init()
    
        self.checkAuthorizationForPhotoLibraryAndGet()
        
        let pointLight = Lighting().light
        self.components.set(pointLight)
   
  }
    
    private func checkAuthorizationForPhotoLibraryAndGet(){
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.authorized) {
            getPhotosAndVideos()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {
                        self.getPhotosAndVideos()
                }else {
                        print("DID NOT GET PERMISSION")
                }
            })
        }
    }
    
    private func getPhotosAndVideos(){

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        self.allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        
        print("\(self.allPhotos!)")
        
        for index in 0...20 {
            let newPhoto = Photo(table: self)
            newPhoto.index = index
            newPhoto.asset = self.allPhotos?.object(at: index)
            self.photos.append(newPhoto)
            self.addChild(newPhoto.base!)
        }
            
        self.updateCarousel()
        }

        
    var defaultCarouselRadius = 9.0
    var radialVelocity = 0.1
    var defaultRadialVelocityDecay = 0.9
    
    func updateCarousel() {
        for index in 0...self.photos.count-1 {
            let angle = self.self.carouselAngle + Double(Double(index) * .pi * 2.0) / Double(self.photos.count)
            let photo = self.photos[index]
            photo.base?.orientation = simd_quatf(angle: .pi / 2.0, axis: [1.0,0,0])
            photo.base?.orientation = photo.base!.orientation * simd_quatf(angle: Float(angle) + .pi / 2.0, axis: [0.0,0,1.0])
            photo.base?.position.x = Float(defaultCarouselRadius * cos(angle))
            photo.base?.position.y = Float(0.5)
            photo.base?.position.z = Float(defaultCarouselRadius * sin(angle))
        }
        self.carouselAngle += radialVelocity
        radialVelocity *= defaultRadialVelocityDecay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.updateCarousel()
        }
    }
}

class Lighting: Entity, HasPointLight {
    
    required init() {
        super.init()
        self.position = SIMD3.init(0.0, 0.0, 8)
        self.light = PointLightComponent(color: .white,
                                     intensity: 100000,
                             attenuationRadius: 10)
    }
}