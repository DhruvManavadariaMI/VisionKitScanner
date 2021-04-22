//
//  ViewController.swift
//  TextRecognizationDemo
//
//  Created by mac-0004 on 21/04/21.
//

import UIKit
import VisionKit
import Vision
import Photos

final class ScannerViewController: UIViewController {

	// MARK:- @IBOutlet -
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	
	// MARK:- Global Variables -
	private var resultsViewController: (UIViewController & RecognizedTextDataSource)?
	private var textRecognitionRequest = VNRecognizeTextRequest()
	
	// MARK:- View Life Cycle -
	override func viewDidLoad() {
		super.viewDidLoad()
		initialization()
	}
}

// MARK:- General Methods -
extension ScannerViewController {
	fileprivate func initialization() {
		requestTextRecognizerHandler()
	}
	fileprivate func requestTextRecognizerHandler() {
		textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
			guard let resultsViewController = self.resultsViewController else {
				print("resultsViewController is not set")
				return
			}
			if let results = request.results, !results.isEmpty {
				if let requestResults = request.results as? [VNRecognizedTextObservation] {
					DispatchQueue.main.async {
						resultsViewController.addRecognizedText(recognizedText: requestResults)
					}
				}
			}
		})
		// This doesn't require OCR on a live camera feed, select accurate for more accurate results.
		textRecognitionRequest.recognitionLevel = .accurate
		textRecognitionRequest.usesLanguageCorrection = true
	}
	private func processImage(image: UIImage) {
		guard let cgImage = image.cgImage else {
			print("Failed to get cgimage from input image")
			return
		}
		
		let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
		do {
			try handler.perform([textRecognitionRequest])
		} catch {
			print(error)
		}
	}
	private func openGallery() {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true
		picker.sourceType = .photoLibrary
		self.present(picker, animated: true, completion: nil)
	}
	private func scanDocumentFromCamera() {
		let documentCameraViewController = VNDocumentCameraViewController()
		documentCameraViewController.delegate = self
		present(documentCameraViewController, animated: true)
	}
	private func redirectToShowText() {
		DispatchQueue.main.async {
			self.activityIndicator.stopAnimating()
			if let resiltVC = self.resultsViewController {
				self.navigationController?.pushViewController(resiltVC, animated: true)
			}
		}
	}
	private func showScanoption() {
		let alert = UIAlertController(title: "Choose From", message: nil, preferredStyle: .actionSheet)
		let cameraAction = UIAlertAction(title: "Camera", style: .default){
			UIAlertAction in
			self.scanDocumentFromCamera()
		}
		let galleryAction = UIAlertAction(title: "Gallery", style: .default){
			UIAlertAction in
			self.openGallery()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
			UIAlertAction in
		}
		alert.addAction(cameraAction)
		alert.addAction(galleryAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}
}

// MARK:- VNDocumentCameraViewControllerDelegate -
extension ScannerViewController: VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		self.resultsViewController = self.storyboard?.instantiateViewController(withIdentifier: "TextViewController") as? (UIViewController & RecognizedTextDataSource)
		self.activityIndicator.startAnimating()
		controller.dismiss(animated: true) {
			DispatchQueue.global(qos: .userInitiated).async {
				for pageNumber in 0 ..< scan.pageCount {
					let image = scan.imageOfPage(at: pageNumber)
					self.processImage(image: image)
				}
				self.redirectToShowText()
			}
		}
	}
}

// MARK:- UIImagePickerControllerDelegate -
extension ScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			picker.dismiss(animated: true, completion: nil)
		}
		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			picker.dismiss(animated: true, completion: nil)
			guard let image = info[.originalImage] as? UIImage else {
				fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
			}
			self.activityIndicator.startAnimating()
			self.resultsViewController = self.storyboard?.instantiateViewController(withIdentifier: "TextViewController") as? (UIViewController & RecognizedTextDataSource)
			DispatchQueue.global(qos: .userInitiated).async {
				self.processImage(image: image)
				self.redirectToShowText()
			}
		}

}

// MARK:- Action Event -
extension ScannerViewController {
	@IBAction private func onScanClicke(_ sender: UIButton) {
		showScanoption()
	}
}
