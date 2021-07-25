//
//  PhotoDownloader.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 25.07.2021.
//

import Foundation
import Combine

protocol PhotoDownloaderProtocol {
	func download(url: URL) -> AnyPublisher<Data?, Error>
}

final class PhotoDownloader: PhotoDownloaderProtocol {
	private let client: ApiClient
	
	init(client: ApiClient) {
		self.client = client
	}
	
	func download(url: URL) -> AnyPublisher<Data?, Error> {
		client.download(url: url)
	}
}
