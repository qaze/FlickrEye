//
//  PhotoNetworkModel.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation

struct PhotoContainerNetworkModel: Decodable {
	let photos: PhotosNetworkModel?
}

struct PhotosNetworkModel: Decodable {
	let page: Int?
	let pages: Int?
	let perpage: Int?
	let photo: [PhotoNetworkModel]?
}

struct PhotoNetworkModel: Decodable {
	let id: String?
	let title: String?
	let url_m: String?
}
