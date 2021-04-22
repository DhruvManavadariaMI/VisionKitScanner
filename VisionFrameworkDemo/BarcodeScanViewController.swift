//
//  BarcodeScanViewController.swift
//  TextRecognizationDemo
//
//  Created by mac-0004 on 22/04/21.
//

import UIKit
import AVFoundation
import SafariServices
import Vision

class BarcodeScanViewController: UIViewController {
	
	var captureSession = AVCaptureSession()
	
	lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
	  guard error == nil else {
		self.showAlert(
		  withTitle: "Barcode error",
		  message: error?.localizedDescription ?? "error")
		return
	  }
	  self.processClassification(request)
	}


    override func viewDidLoad() {
        super.viewDidLoad()
		checkPermissions()
		setupCameraLiveView()
    }
	override func viewWillDisappear(_ animated: Bool) {
	  super.viewWillDisappear(animated)
	  // TODO: Stop Session
		captureSession.stopRunning()
	}
}

extension BarcodeScanViewController {
	// MARK: - Camera
	private func checkPermissions() {
		// TODO: Checking permissions
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		// 1
		case .notDetermined:
		  AVCaptureDevice.requestAccess(for: .video) { [self] granted in
			if !granted {
			  showPermissionsAlert()
			}
		  }

		// 2
		case .denied, .restricted:
		  showPermissionsAlert()

		// 3
		default:
		  return
		}
	}
	
	private func setupCameraLiveView() {
		// TODO: Setup captureSession
		captureSession.sessionPreset = .hd1280x720
		// TODO: Add input
		// 1
		let videoDevice = AVCaptureDevice
		  .default(.builtInWideAngleCamera, for: .video, position: .back)

		// 2
		guard
		  let device = videoDevice,
		  let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
		  captureSession.canAddInput(videoDeviceInput)
		  else {
			// 3
			showAlert(
			  withTitle: "Cannot Find Camera",
			  message: "There seems to be a problem with the camera on your device.")
			return
		  }

		// 4
		captureSession.addInput(videoDeviceInput)

		// TODO: Add output
		let captureOutput = AVCaptureVideoDataOutput()
		// TODO: Set video sample rate
		captureOutput.videoSettings =
		  [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
		captureOutput.setSampleBufferDelegate(
		  self,
		  queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
		
		captureSession.addOutput(captureOutput)

		configurePreviewLayer()
		
		// TODO: Run session
		captureSession.startRunning()

	}
	
	// MARK: - Vision
	func processClassification(_ request: VNRequest) {
		// TODO: Main logic
		// 1
		guard let barcodes = request.results else { return }
		DispatchQueue.main.async { [self] in
		  if captureSession.isRunning {
			view.layer.sublayers?.removeSubrange(1...)

			// 2
			for barcode in barcodes {
				guard
				  // TODO: Check for QR Code symbology and confidence score
				  let potentialQRCode = barcode as? VNBarcodeObservation,
				  potentialQRCode.confidence > 0.9
				  else { return }
				print(potentialQRCode.symbology.rawValue.description)
				print("barcode:\(potentialQRCode.barcodeDescriptor)")
				observationHandler(payload: potentialQRCode)
			}
		  }
		}

	}
	
	// MARK: - Handler
	func observationHandler(payload: VNBarcodeObservation) {
		// TODO: Open it in Safari
		// 1
		guard
			let payloadString = payload.payloadStringValue,
		  let url = URL(string: payloadString),
		  ["http", "https"].contains(url.scheme?.lowercased())
		  else {
			showAlert(
			  withTitle: payload.symbology.rawValue,
			  // TODO: Check the confidence score
				message: payload.payloadStringValue ?? "")
			return
		}
		// 2
		let config = SFSafariViewController.Configuration()
		config.entersReaderIfAvailable = true

		// 3
		let safariVC = SFSafariViewController(url: url, configuration: config)
		safariVC.delegate = self
		present(safariVC, animated: true)

	}
}


// MARK: - AVCaptureDelegation
extension BarcodeScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		// TODO: Live Vision
		// 1
		guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
		  return
		}

		// 2
		let imageRequestHandler = VNImageRequestHandler(
		  cvPixelBuffer: pixelBuffer,
		  orientation: .right)

		// 3
		do {
		  try imageRequestHandler.perform([detectBarcodeRequest])
		} catch {
		  print(error)
		}

	}
}


// MARK: - Helper
extension BarcodeScanViewController {
	private func configurePreviewLayer() {
		let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		cameraPreviewLayer.videoGravity = .resizeAspectFill
		cameraPreviewLayer.connection?.videoOrientation = .portrait
		cameraPreviewLayer.frame = view.frame
		view.layer.insertSublayer(cameraPreviewLayer, at: 0)
	}
	
	private func showAlert(withTitle title: String, message: String) {
		DispatchQueue.main.async {
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(alertController, animated: true)
		}
	}
	
	private func showPermissionsAlert() {
		showAlert(
			withTitle: "Camera Permissions",
			message: "Please open Settings and grant permission for this app to use your camera.")
	}
}


// MARK: - SafariViewControllerDelegate
extension BarcodeScanViewController: SFSafariViewControllerDelegate {
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		captureSession.startRunning()
	}
}
