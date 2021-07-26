//
//  PhotoDownloader.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 25.07.2021.
//

import Foundation
import Combine

final class PhotoDownloader: PhotoDownloaderProtocol {
	private let client: ApiClient
	private let cache: Cache?
	
	init(
		client: ApiClient,
		cache: Cache?
	) {
		self.client = client
		self.cache = cache
	}
	
	func download(url: URL) -> AnyPublisher<Data?, Error> {
		if let data = cache?.data(for: url.fileName) { 
			return Just(data)
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		}
		
		return client
			.download(url: url)
			.subscribe(on: DispatchQueue.global())
			.tryCompactMap { [weak self] data in
				guard let data = data else { return nil }
				self?.cache?.save(data: data, for: url.fileName)
				return data
			}
			.eraseToAnyPublisher()
	}
}
