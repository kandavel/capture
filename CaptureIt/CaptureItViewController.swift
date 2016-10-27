//
//  CaptureItViewController.swift
//  CaptureIt
//
//  Created by Tushar Sharma on 29/08/16.
//  Copyright © 2016 Edbinx. All rights reserved.
//

import UIKit
import AVFoundation

final internal class CaptureItViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private let captureSession = AVCaptureSession()
    private var captureDevice:AVCaptureDevice?
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private var output = AVCaptureStillImageOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photo = UIImage()
    private var imagePicker = UIImagePickerController()
    private var animateActivity: Bool!
    var animationSquare = CABasicAnimation()
    @IBOutlet private weak var takePhoto: UIButton!
    @IBOutlet private weak var selectPhoto: UIButton!
    
    
    
    @IBOutlet weak var cameraView: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(CaptureItViewController.AutoFocusGesture(_:)))
        tapgesture.numberOfTapsRequired = 2
        tapgesture.numberOfTouchesRequired = 1
        self.view .addGestureRecognizer(tapgesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(CaptureItViewController.zoomgesture(_:)))

        self.view .addGestureRecognizer(pinchGesture)
        AVCSessionProperties()
       
    }
    
    private func AVCSessionProperties()
    {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        output.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ]
        captureSession.addOutput(output)
        
        if captureDevice != nil {
            try! captureDevice!.lockForConfiguration()
           captureDevice!.focusMode = .AutoFocus
           
            captureDevice!.unlockForConfiguration()

           
            beginSession()
        }
    }
    
    private func beginSession()
    {
        do
        {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error
        {
            print(error)
            errorOccured()
        }
        
        //Add UITap Gesture Capture Frame for Focus and Exposure
       
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.frame = self.view.frame
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraView.layer.addSublayer(previewLayer)
        self.cameraView.layer .addSublayer(self.takePhoto.layer)
        captureSession.startRunning()
       
    }
    
    
    @IBAction func takePhoto(sender: AnyObject) {
  
            guard let connection = output.connectionWithMediaType(AVMediaTypeVideo) else { return }
        connection.videoOrientation = .Portrait
        
        output.captureStillImageAsynchronouslyFromConnection(connection)
        {
            (sampleBuffer, error) in
            guard sampleBuffer != nil && error == nil else { self.errorOccured(); return }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            guard let image = UIImage(data: imageData) else { self.errorOccured(); return }
            
            self.photo = image
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
            self.performSegueWithIdentifier("image", sender: self)
        }
    }
    
    func imageSaved(image: UIImage!, didFinishSavingWithError error: NSError?, contextInfo: AnyObject?)
    {
            if (error != nil) {
                print("image couldn't be saved")
            } else {
                print("Image saved!")
            }
        }

    
    @IBAction private func selectPhoto(sender: UIButton)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!)
    {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
        self.photo = image
        print(photo)
        self.performSegueWithIdentifier("image", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let identifier = segue.identifier
        {
            switch identifier {
            case "image" :
                if let viewcontroller = segue.destinationViewController as? CaptureImageViewController {
                    viewcontroller.imageData = photo
                }
            default: break
            }
            
        }
    }

    private func errorOccured()
    {
        let errorView = UIAlertController(title: "Error", message: "An Error Occured", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        errorView.addAction(defaultAction)
        self.presentViewController(errorView, animated: true, completion: nil)
    }
    
    
     func AutoFocusGesture(RecognizeGesture: UITapGestureRecognizer)
     {
        let touchPoint: CGPoint = RecognizeGesture.locationInView(self.view)
        let convertedPoint = previewLayer.captureDevicePointOfInterestForPoint(touchPoint)
        print(touchPoint)
        print(convertedPoint)
        
        let animationView =  UIView();
        animationView.frame =  CGRectMake(touchPoint.x-40, touchPoint.y-40, 50, 50)
        animationView.backgroundColor = UIColor.clearColor()
        animationView.layer.borderColor = UIColor.yellowColor().CGColor
        
        animationView.layer.borderWidth = 1.0
      animationView.layer .addAnimation(animationSquare, forKey: "selectionAnimation")
        animationSquare = CABasicAnimation(keyPath: "borderColor")
        animationSquare.toValue = UIColor.yellowColor()
        animationSquare.repeatCount = 5
        animationSquare.repeatDuration = 2
        self.view .addSubview(animationView)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(3)
        animationView.alpha = 0.0
        UIView.setAnimationCurve(.Linear)
        UIView.commitAnimations()
       
        
                try! captureDevice!.lockForConfiguration()
        
                   
                    let point = CGPoint.init(x: (convertedPoint.x)*2, y: (convertedPoint.y)*2)
                    captureDevice!.focusPointOfInterest = point
                    captureDevice!.focusMode = AVCaptureFocusMode.AutoFocus
                    captureDevice!.exposurePointOfInterest = point
                    captureDevice!.exposureMode = AVCaptureExposureMode.AutoExpose
                    captureDevice!.unlockForConfiguration()
           
        
    }
    
    func zoomgesture(zoom:UIPinchGestureRecognizer)
    {
     
        print(zoom.scale)
        print(2 - zoom.scale)
        print(zoom.velocity)
      //  print(try captureDevice!.lockForConfiguration())
        print(try! captureDevice!.lockForConfiguration())
     
            try! captureDevice!.lockForConfiguration()
        
            captureDevice!.videoZoomFactor = (2*zoom.scale)+1.0
        captureDevice!.unlockForConfiguration()
           }
    
    
}
