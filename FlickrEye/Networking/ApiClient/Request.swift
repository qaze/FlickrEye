//
//  Request.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation

struct Request {
	enum RequestType: String { case get, post, delete, put }
	let type: RequestType
	let path: String
	let queryItems: [URLQueryItem]
	let body: Data?
	
	init(
		type: RequestType = .get,
		path: String,
		queryItems: [URLQueryItem] = [],
		body: Data? = nil
	) {
		self.type = type 
		self.path = path 
		self.queryItems = queryItems 
		self.body = body 
	}
}
