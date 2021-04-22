//
//  SelectScanTypeViewController.swift
//  TextRecognizationDemo
//
//  Created by mac-0004 on 22/04/21.
//

enum VisionType: Int, CaseIterable, CustomStringConvertible {
	case textDetection
	case barcodeScanner
	
	var description: String {
		get {
			switch self {
			case .textDetection:
				return "Text Recognization"
			case .barcodeScanner:
				return "Barcode Scanner"
			}
		}
	}
}

import UIKit

class SelectScanTypeViewController: UIViewController {

	@IBOutlet weak var tableViewSelect: UITableView! {
		didSet {
			tableViewSelect.tableFooterView = UIView()
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectScanTypeViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return VisionType.allCases.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.text = VisionType(rawValue: indexPath.row)?.description
		cell.selectionStyle = .none
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var selectVC = ""
		switch indexPath.row {
		case 0:
			selectVC = "ScannerViewController"
		case 1:
			selectVC = "BarcodeScanViewController"
		default:
			print("Default")
		}
		guard let vc = storyboard?.instantiateViewController(identifier: selectVC) else { return }
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
}
