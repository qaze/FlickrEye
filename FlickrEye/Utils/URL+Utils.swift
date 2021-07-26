//
//  URL+Utils.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 26.07.2021.
//

import Foundation

extension URL {
	var fileName: String {
		pathComponents.joined(separator: "_")
	}
}
