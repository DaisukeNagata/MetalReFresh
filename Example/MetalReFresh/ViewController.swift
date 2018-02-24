//
//  ViewController.swift
//  MetalReFresh
//
//  Created by daisuke nagata on 09/29/2017.
//  Copyright (c) 2017 daisuke nagata. All rights reserved.
//

import UIKit
import MetalReFresh
import AVFoundation
import AssetsLibrary
import Photos

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    private var cameraView = UIImageView()
    private var cameraViewRoll = UIImageView()
    private var captureSession : AVCaptureSession!
    private var stillImageOutput : AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        previewLayer = AVCaptureVideoPreviewLayer()

        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720

        let device = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: device!)

            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)

                if (captureSession.canAddOutput(stillImageOutput!)) {
                    captureSession.addOutput(stillImageOutput!)

                    captureSession.startRunning()
    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    previewLayer?.position = CGPoint(x:self.view.frame.width,y:self.view.frame.height/2)

                    cameraView.frame = self.view.frame
                    previewLayer?.frame = cameraView.frame
    
                    cameraView.layer.addSublayer(previewLayer!)
                    self.view.addSubview(cameraView)

                }
            }

        }catch{ }
        swipeMethod()
    }

    private func swipeMethod() {
        let leftRightdirections: [UISwipeGestureRecognizerDirection] = [.right, .left]
        for direction in leftRightdirections {
            let gesture = UISwipeGestureRecognizer(target: self,
                                                   action:#selector(handleLeftRightSwipe(sender:)))

            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }

        let updirection: UISwipeGestureRecognizerDirection = .up
            let gesture = UISwipeGestureRecognizer(target: self,
                                                   action:#selector(handleUpSwipe(sender:)))
            gesture.direction = updirection
            self.view.addGestureRecognizer(gesture)

        let downdirection: UISwipeGestureRecognizerDirection = .down
        let gestureDown = UISwipeGestureRecognizer(target: self,
                                               action:#selector(handleDownSwipe(sender:)))

        gestureDown.direction = downdirection
        self.view.addGestureRecognizer(gestureDown)

    }

    @objc func handleLeftRightSwipe(sender: UISwipeGestureRecognizer) {
        // フラッシュとかカメラの細かな設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        self.stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
    @objc func handleUpSwipe(sender: UISwipeGestureRecognizer) { openCameraRoll()}

    @objc func handleDownSwipe(sender: UISwipeGestureRecognizer) { self.dismiss(animated: true, completion: nil) }

    //MARK: -AVCapturePhotoOutput Method
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

            let photoData = photo.fileDataRepresentation()
            let photoDataImage = UIImage(data: photoData!)
            cameraView.image = photoDataImage

            UIImageWriteToSavedPhotosAlbum(photoDataImage!, nil, nil, nil)
            openCameraRoll()
    }

    //MARK: -UIImagePickerController delegate
    func openCameraRoll() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

            let pickerView = UIImagePickerController()
            pickerView.sourceType = .photoLibrary
            pickerView.delegate = self

            self.present(pickerView, animated: true)
        }

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraView.removeFromSuperview()
 
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        cameraViewRoll.frame = self.view.frame
        cameraViewRoll.image = image
        ImageEntity.imageArray.append(image)
        TextManager().writeObject(images: ImageEntity.imageArray)
        ObjectDefaults().objectIndexDefaults(index: ImageEntity.imageArray.count)

        self.view.addSubview(cameraViewRoll)
        self.dismiss(animated: true, completion: nil)

        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let table = storyboard.instantiateViewController(withIdentifier: "tableViewController") as! UINavigationController
 
        present(table, animated: true, completion: nil)
    }

}
