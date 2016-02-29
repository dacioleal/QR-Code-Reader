//
//  ViewController.swift
//  QRreader
//
//  Created by Dacio Leal Rodriguez on 29/2/16.
//  Copyright © 2016 Dacio Leal Rodriguez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var isReading = false;
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var viewPreview: UIView!
    
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var barButtonStart: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBeepSound()
    }

    @IBAction func startStopReading(sender: UIBarButtonItem) {
        
        if isReading == false {
            
            if startReading() {
                labelStatus.text = "Scanning for QR code..."
                barButtonStart.title = "Stop"
            } else {
                stopReading()
                barButtonStart.title = "Start"
            }
        }
    }
    
    func startReading() -> Bool {
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input: AVCaptureDeviceInput?
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch _ {
            input = nil
            return false
        }
        captureSession = AVCaptureSession()
        captureSession!.addInput(input)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession!.addOutput(captureMetadataOutput)
        
        let dispatchQueue = dispatch_queue_create("myQueue", nil)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer!.frame = viewPreview.layer.bounds
        viewPreview.layer.addSublayer(videoPreviewLayer!)
        captureSession!.startRunning()
        
        return true
    }
    
    func stopReading() {
        
        if let session = captureSession {
            session.stopRunning()
            captureSession = nil
        }
        if let videoLayer = videoPreviewLayer {
            videoLayer.removeFromSuperlayer()
        }
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if (metadataObjects != nil && metadataObjects.count>0)  {
            let metadataObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            if metadataObject.type == AVMetadataObjectTypeQRCode {
                labelStatus.performSelectorOnMainThread("setText:", withObject:metadataObject.stringValue, waitUntilDone: false)
                performSelectorOnMainThread("stopReading", withObject: nil, waitUntilDone: false)
                performSelectorOnMainThread("setTitle:", withObject: "Start", waitUntilDone: false)
                isReading = false
                
                if let player = audioPlayer {
                    player.play()
                }
            }
        }
    }
    
    func loadBeepSound() {
        
        let beepFilePath = NSBundle.mainBundle().pathForResource("beep", ofType: "mp3")
        if let beepPath = beepFilePath {
            let beepURL = NSURL(fileURLWithPath: beepPath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: beepURL)
            } catch _ {
                audioPlayer = nil
            }
            audioPlayer?.prepareToPlay()
        }
    }
}






















