//
//  FileCache.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 26.07.2021.
//

import Foundation

class FileCache: Cache {
	private let cacheURL: URL
	private let fileManager = FileManager()
	
	init() throws {
		cacheURL = try fileManager.url(
			for: .cachesDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: false
		)
	}
	
	func data(for name: String) -> Data? {
		let fileURL = cacheURL.appendingPathComponent(name)
		return fileManager.contents(atPath: fileURL.path)
	}
	
	func save(data: Data, for name: String) {
		do {
			let fileURL = cacheURL.appendingPathComponent(name)
			if fileManager.fileExists(atPath: fileURL.path) {
				try fileManager.removeItem(atPath: fileURL.path)
			}
			
			fileManager.createFile(
				atPath: fileURL.path,
				contents: data,
				attributes: nil
			)
		} catch {
			print("cannot use cache: \(error.localizedDescription)")
		}
	}
}
