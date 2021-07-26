//
//  ViewerViewModel.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation
import Combine

final class ViewerViewModel {
	enum Constants {
		static let columnsCount = 3
	}
	
	@Published var tag = "Electrolux"
	@Published var isLoading = false
	@Published var photos: [PhotoViewModel] = []
	
	private let interactor: ViewerInteractorProtocol
	private let downloader: PhotoDownloaderProtocol
	private weak var coordinator: ViewerCoordinator?
	private var page = 0
	private var totalPages: Int?
	private var disposeBag = Set<AnyCancellable>()
	private var loadingCancellable: AnyCancellable?
	
	init(
		interactor: ViewerInteractorProtocol,
		downloader: PhotoDownloaderProtocol,
		coordinator: ViewerCoordinator
	) {
		self.interactor = interactor
		self.downloader = downloader
		self.coordinator = coordinator
		bind()
	}
	
	func onViewReady() {
		search()
	}
	
	func bind() {
		$tag
			.debounce(for: .seconds(1), scheduler: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.page = 0
				self?.totalPages = nil
				self?.photos.removeAll()
				self?.search()
			}
			.store(in: &disposeBag)
	}
	
	func photoWillBeShown(at index: Int) {
		if index > photos.count - Constants.columnsCount * 2 {
			loadNextPage()
		}
	}
	
	private func loadNextPage() {
		guard let total = totalPages,
			  page < total,
			  !isLoading else { return }
		
		page += 1
		search()
	}
	
	func search() {
		isLoading = true
		loadingCancellable = interactor
			.fetchPhotos(for: tag, page: page)
			.receive(on: DispatchQueue.main)
			.sink(
				receiveCompletion: { [weak self] completion in
					self?.isLoading = false
					if case let .failure(error) = completion {
						print(error)
						// show some errors
					}
				}, 
				receiveValue: { [weak self] result in
					self?.photosLoaded(result)
				}
			)
	}
	
	private func photosLoaded(_ photosNetworkModels: PhotoContainerNetworkModel) {
		page = photosNetworkModels.photos?.page ?? 0
		totalPages = photosNetworkModels.photos?.pages
		photos.append(
			contentsOf: photosNetworkModels.photos?.photo?.compactMap { model in
				guard let id = model.id else { return nil }
				return PhotoViewModel(
					id: id,
					title: model.title ?? "", 
					path: model.url_m, 
					downloader: downloader
				)
			} ?? []
		)
	}
	
	func sharePhoto(at index: Int) {
		guard photos.indices.contains(index) else { return }
		let photo = photos[index]
		coordinator?.share(photo: photo)
	}
}
