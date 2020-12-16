import RealityKit
import UIKit
import Photos
import RealityUI

class PhotoGlobe: Entity, HasAnchoring, HasCollision {
    var allPhotos : PHFetchResult<PHAsset>?
    var photos = [Photo].init()
    let arView:ARView?
    var exclusions = [PHAsset].init()
    var carouselAngle = 0.0
    var numPhotos = 100
    var numRows = 2
    var heightOffset = 2.0
    var albumPositionScrollStart = 0
    
    
  init(view:ARView) {
        arView = view
        super.init()
    
    self.checkAuthorizationForPhotoLibraryAndGet()
        
    let pointLight = Lighting().light
    self.components.set(pointLight)
    
    
    let stepper = RUIStepper(upTrigger: { _ in
        self.numRows += 1
        if self.numRows > 10 {
            self.numRows = 10
        } else if self.numRows < 1 {
            self.numRows = 1
        }
    }, downTrigger: { _ in
        self.numRows -= 1
        if self.numRows < 0 {
            self.numRows = 0
        }
    })
    stepper.scale = SIMD3.init(x: 0.05, y: 0.05, z: 0.05)
    self.addChild(stepper)
    
    let heightSlider = RUISlider(
        slider: SliderComponent(startingValue: 0.2, isContinuous: true)
    ) { (slider, _) in
        self.heightOffset = Double(slider.value * 10)
    }
    heightSlider.scale = SIMD3.init(x: 0.02, y: 0.02, z: 0.02)
    heightSlider.position = SIMD3.init(x: 0.1, y: 0.1, z: 0.0)
    heightSlider.orientation = simd_quatf(angle: .pi / 2.0, axis: [0,0,1])
    self.addChild(heightSlider)
    
    let albumScroll = RUISlider(
        slider: SliderComponent(startingValue: 0.0, isContinuous: false)
    ) { (albumScroll, _) in
        self.albumPositionScrollStart = Int(albumScroll.value * Float(self.allPhotos!.count - self.numRows - 1))
        print("scroll offset: \(self.albumPositionScrollStart)")
        DispatchQueue.main.async {
            self.updateAssets()
        }
    }
    albumScroll.scale = SIMD3.init(x: 0.02, y: 0.02, z: 0.02)
    albumScroll.position = SIMD3.init(x: 0.2, y: 0.1, z: 0.0)
    albumScroll.orientation = simd_quatf(angle: .pi / 2.0, axis: [0,0,1])
    self.addChild(albumScroll)
        
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
    
    func updateAssets() {
        for index in 0...self.numPhotos-1 {
            if index + self.albumPositionScrollStart >= self.allPhotos!.count {
                return
            }
            let photo = self.photos[index]
            photo.index = index
            photo.asset = self.allPhotos!.object(at: index + self.albumPositionScrollStart)
        }
    }
    
    private func getPhotosAndVideos(){

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        self.allPhotos = PHAsset.fetchAssets(with: fetchOptions)
                
        for _ in 0...self.numPhotos-1 {
            let newPhoto = Photo()
            self.photos.append(newPhoto)
            self.addChild(newPhoto.base!)
        }
        self.updateAssets()
        self.updateCarousel()
    }

        
    var defaultCarouselRadius = 9.0
    var radialVelocity = 0.1
    var defaultRadialVelocityDecay = 0.9
    
    func updateCarousel() {
        for index in 0...self.photos.count-1 {
            let scaleFactor =  (Float(self.numRows) / Float(self.photos.count)) * 60
            
            let angle = self.carouselAngle + Double(Double(index / self.numRows) * .pi * 2.0) / Double(self.photos.count / self.numRows)
            let photo = self.photos[index]
            photo.base?.orientation = simd_quatf(angle: .pi / 2.0, axis: [1.0,0,0])
            photo.base?.orientation = photo.base!.orientation * simd_quatf(angle: Float(angle) + .pi / 2.0, axis: [0.0,0,1.0])
            photo.base?.position.x = Float(defaultCarouselRadius * cos(angle))
            let heightFactor = photo.defaultCardSize * Double(scaleFactor)
            photo.base?.position.y = Float(Double(index % self.numRows) * heightFactor) - Float(heightFactor * self.heightOffset)
            photo.base?.position.z = Float(defaultCarouselRadius * sin(angle))
            photo.base?.setScale(SIMD3(x: scaleFactor, y: scaleFactor, z: scaleFactor), relativeTo: nil)
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
        self.position = SIMD3.init(0.0, 0.0, 3.0)
        self.light = PointLightComponent(color: .white,
                                     intensity: 10000000,
                             attenuationRadius: 1000000)
    }
}
