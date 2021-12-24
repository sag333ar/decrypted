//
//  ViewController.swift
//  decrypted
//
//  Created by Sagar Kothari on 24/12/21.
//

import UIKit
import Base58
import ASKSecp256k1

extension Data {
	struct HexEncodingOptions: OptionSet {
		let rawValue: Int
		static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
	}

	func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
		return self.map { String(format: format, $0) }.joined()
	}

	var hexadecimal: String {
		return map { String(format: "%02x", $0) }
		.joined()
	}
}

extension StringProtocol {
	var hexaData: Data { .init(hexa) }
	var hexaBytes: [UInt8] { .init(hexa) }
	private var hexa: UnfoldSequence<UInt8, Index> {
		sequence(state: startIndex) { startIndex in
			guard startIndex < self.endIndex else { return nil }
			let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
			defer { startIndex = endIndex }
			return UInt8(self[startIndex..<endIndex], radix: 16)
		}
	}
}

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		do {
			let bytes = "private-key-goes-here".makeBytes()
			let pBytes = "public-key-goes-here".makeBytes()
			let decodedBytes = try Base58.decode(bytes)
			let pDecodedBytes = try Base58.decode(pBytes)
			let data = Data(bytes: decodedBytes, count: decodedBytes.count)
			let pData = Data(bytes: pDecodedBytes, count: pDecodedBytes.count)
			let pHex = pData.hexEncodedString()
			if let pubHex = CKSecp256k1.generatePublicKey(withPrivateKey: data, compression: true)?.hexadecimal,
				pHex == pubHex {
				print("Valid private key")
			}
		} catch {
			print("Error is \(error.localizedDescription)")
		}
	}


}

