import RealityKit
import UIKit
import Photos
import RealityUI

enum PhotoGlobeError: Error {
  case unevenDimensions
  case dimensionsTooLarge
}

class PhotoGlobe: Entity, HasAnchoring, HasCollision {
  var allPhotos : PHFetchResult<PHAsset>?
  var photos = [Photo].init()
  let arView:ARView?
  var exclusions = [PHAsset].init()
  var carouselAngle = 0.0
 
  init(view:ARView) {
        arView = view
        super.init()
    
        self.checkAuthorizationForPhotoLibraryAndGet()
        
        let pointLight = Lighting().light
        self.components.set(pointLight)
        
  }
    
    required init() {
        fatalError("init() has not been implemented")
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
        
        for index in 0...100 {
            let newPhoto = Photo(globe: self)
            newPhoto.index = index
            newPhoto.asset = self.allPhotos?.object(at: index)
            self.photos.append(newPhoto)
            self.addChild(newPhoto.base!)
            self.arView?.installGestures(for: newPhoto.base!)
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
            photo.base?.position.y = Float(Double(index % 5) * photo.defaultCardSize) - Float(photo.defaultCardSize * 2)
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
        self.position = SIMD3.init(0.0, 0.0, 0.0)
        self.light = PointLightComponent(color: .white,
                                     intensity: 10000000,
                             attenuationRadius: 1000000)
    }
}
