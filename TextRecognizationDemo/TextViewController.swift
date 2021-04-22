//
//  TextViewController.swift
//  TextRecognizationDemo
//
//  Created by mac-0004 on 22/04/21.
//

import UIKit
import Vision

final class TextViewController: UIViewController {
	// MARK:- @IBOutlet -
	@IBOutlet private weak var textView: UITextView!
	
	// MARK:- Global Variables -
	private var transcript = ""
	
	// MARK:- View Life Cycle -
	override func viewDidLoad() {
        super.viewDidLoad()
		textView?.text = transcript
    }
}

// MARK: RecognizedTextDataSource
extension TextViewController: RecognizedTextDataSource {
	func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
		// Create a full transcript to run analysis on.
		let maximumCandidates = 1
		for observation in recognizedText {
			guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
			transcript += candidate.string
			transcript += "\n"
		}
		textView?.text = transcript
	}
}

