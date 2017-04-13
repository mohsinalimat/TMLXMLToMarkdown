//
//  main.swift
//  XmlToMarkdown
//
//  Distributed under the ISC license, see LICENSE.
//

import Foundation

//
// CLI driver
//

let xmlToMarkdown = XMLToMarkdown()

if CommandLine.arguments.count > 1 {
	CommandLine.arguments.suffix(from: 1).forEach { file in
		guard let data = FileManager.default.contents(atPath: file) else {
			print("Can't open file \(file)")
			return
		}

		guard let xml = String(bytes: data, encoding: .utf8) else {
			print("Can't get contents straight for \(file)")
			return
		}

		let md = xmlToMarkdown.convert(xml: xml)

		print(md)
	}
} else {
	var xml = ""
	while let line = readLine() {
		xml += line
	}
	let md = xmlToMarkdown.convert(xml: xml)
	print(md)
}