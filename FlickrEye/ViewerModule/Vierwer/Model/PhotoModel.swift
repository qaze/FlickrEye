//
//  PhotoModel.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation
import Combine

class PhotoViewModel: Hashable {
	enum State { case idle, loading, ready }
	@Published var state: State = .idle
	@Published var data: Data?
	let title: String
	let id: String
	
	private let url: URL
	private let downloader: PhotoDownloaderProtocol
	private var downloadingCancellable: AnyCancellable?
	
	init?(
		id: String,
		title: String,
		path: String?,
		downloader: PhotoDownloaderProtocol
	) {
		self.id = id
		self.title = title
		guard let path = path, let url = URL(string: path) else { return nil }
		self.url = url
		self.downloader = downloader
	}
	
	func prepare() {
		guard state == .idle else { return }
		state = .loading

		downloadingCancellable = downloader
			.download(url: url)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] _ in
					self?.state = .ready
				}, 
				receiveValue: { [weak self] data in
					self?.data = data
				}
			)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	static func == (lhs: PhotoViewModel, rhs: PhotoViewModel) -> Bool {
		lhs.id == rhs.id
	}
}
