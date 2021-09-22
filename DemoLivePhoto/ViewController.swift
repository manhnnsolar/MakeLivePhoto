//
//  ViewController.swift
//  DemoLivePhoto
//
//  Created by Manh Nguyen Ngoc on 22/09/2021.
//

import AVFoundation
import AVKit
import UIKit

import MobileCoreServices
import Photos
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHLivePhotoViewDelegate {
    
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    
    var livePhotoBadgeLayer = CALayer()
    private let pickedVideoName = "pickedExportedVideo.mov"
    
    var pickedPhoto = UIImage(named: "ic_baby")
    var pickedVideoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.delegate = self
        
        let livePhotoBadge = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        
        guard let livePhotoBadgeImage = livePhotoBadge.cgImage else {
            return
        }
        
        self.livePhotoBadgeLayer.frame = livePhotoView.bounds
        self.livePhotoBadgeLayer.contentsGravity = CALayerContentsGravity.topLeft
        self.livePhotoBadgeLayer.isGeometryFlipped = true
        self.livePhotoBadgeLayer.contentsScale = UIScreen.main.scale
        
        self.livePhotoBadgeLayer.contents = livePhotoBadgeImage
        livePhotoView.layer.addSublayer(self.livePhotoBadgeLayer)
        
    }

    // MARK: - Actions
    @IBAction func setupPhotoVideo(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        picker.videoQuality = .typeHigh
        picker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeQuickTimeMovie as String]
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func makeLive(_ sender: Any) {
        guard let sourceVideoPath = self.pickedVideoURL else {
            self.postAlert("It seems a video was not selected.", message:"Try again.")
            return
        }
        var photoURL: URL?
        if let sourceKeyPhoto = self.pickedPhoto {
            guard let data = sourceKeyPhoto.jpegData(compressionQuality: 1.0) else { return }
            photoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("photo.jpg")
            if let photoURL = photoURL {
                try? data.write(to: photoURL)
            }
        }
        LivePhoto.generate(from: photoURL, videoURL: sourceVideoPath, progress: { (percent) in
            DispatchQueue.main.async {
                print(Float(percent))
            }
        }) { (livePhoto, resources) in
            self.livePhotoView.livePhoto = livePhoto
            if let resources = resources {
                LivePhoto.saveToLibrary(resources, completion: { (success) in
                    if success {
                        self.postAlert("Live Photo Saved", message:"The live photo was successfully saved to Photos.")
                    }
                    else {
                        self.postAlert("Live Photo Not Saved", message:"The live photo was not saved to Photos.")
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: UIImagePickerControllerDelegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        dismiss(animated: true, completion: nil)
//    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: PHLivePhotoViewDelegate
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.livePhotoBadgeLayer.opacity = 0.0
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.livePhotoBadgeLayer.opacity = 1.0
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func didPickVideo(_ videoURL:URL) -> Void {
        self.pickedVideoURL = videoURL
//        self.playVideo(videoURL)
    }
    
    func retrieveVideoByPHAsset(_ info: [UIImagePickerController.InfoKey : Any]) -> Bool {
        
        var byPHAsset = false
        
        if #available(iOS 11.0, *) {
            
            let something = info[UIImagePickerController.InfoKey.phAsset]
            
            if let phasset = something as? PHAsset  {
                
                let options = PHVideoRequestOptions()
                
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .highQualityFormat
                
                let imageManager = PHImageManager.default()
                
                byPHAsset = true
                
                imageManager.requestAVAsset(forVideo: phasset, options: options, resultHandler: { (avAsset, avAudioMix, info) in
                    if let urlAsset = avAsset as? AVURLAsset {
                        let _ = urlAsset.self.exportToDocuments(filename: self.pickedVideoName, completion: { (outputURL) in
                            
                            self.didPickVideo(outputURL)
                        })
                    }
                })
            }
        }
        
        return byPHAsset
    }
    
    func retrieveVideoByReferenceURL(_ info: [UIImagePickerController.InfoKey : Any]) -> Bool {
        
        var byReferenceURL = false
        
        if let videoURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL  {
            
            let asset = AVURLAsset(url: videoURL)
            
            byReferenceURL = asset.self.exportToDocuments(filename: self.pickedVideoName, completion: { (outputURL) in
                
                self.didPickVideo(outputURL)
            })
        }
        
        return byReferenceURL
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        dismiss(animated: true) {
            
            if mediaType == kUTTypeMovie || mediaType == kUTTypeVideo || mediaType == kUTTypeQuickTimeMovie {
                
                if self.retrieveVideoByPHAsset(info) == false {
                    
                    if self.retrieveVideoByReferenceURL(info) == false {
                        
                        if  let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL  {
                            
                            self.didPickVideo(videoURL)
                            print(videoURL)
                        }
                    }
                }

            }
            else if mediaType == kUTTypeImage || mediaType == kUTTypeLivePhoto {
                
                guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else {
                    self.postAlert("Photo Picker", message: "Could not retrieve the picked photo.")
                    return
                }
                
                self.pickedPhoto = image
                print("image ======> \(image)")
            }
        }
    }
    
    
}

