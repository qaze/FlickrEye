//
//  Cache.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 26.07.2021.
//

import Foundation

protocol Cache {
	func data(for name: String) -> Data?
	func save(data: Data, for name: String)
}
