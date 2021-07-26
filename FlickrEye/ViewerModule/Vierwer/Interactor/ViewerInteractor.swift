//
//  ViewerInteractor.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation
import Combine

final class ViewerInteractor: ViewerInteractorProtocol {
	private let client: ApiClient
	
	init(client: ApiClient) {
		self.client = client
	}
	
	private func prepareQueryItems(for tag: String, page: Int) -> [URLQueryItem] {
		[
			URLQueryItem(name: "method", value: "flickr.photos.search"),
			URLQueryItem(name: "tags", value: tag),
			URLQueryItem(name: "format", value: "json"),
			URLQueryItem(name: "nojsoncallback", value: "true"),
			URLQueryItem(name: "extras", value: "media"),
			URLQueryItem(name: "extras", value: "url_sq"),
			URLQueryItem(name: "extras", value: "url_m"),
			URLQueryItem(name: "per_page", value: "30"),
			URLQueryItem(name: "page", value: "\(page)")
		]
	}
	
	func fetchPhotos(for tag: String, page: Int) -> AnyPublisher<PhotoContainerNetworkModel, Error> {
		let request = Request(
			path: "services/rest", 
			queryItems: prepareQueryItems(for: tag, page: page) 
		)
		
		return client.perform(request: request)
	}
}
