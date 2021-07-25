//
//  ViewerCoordinator.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation
import UIKit

class ViewerCoordinator: Coordinator {
	private let apiClient: ApiClient
	private weak var navigationController: UINavigationController?
	
	init(
		navigationController: UINavigationController,
		apiClient: ApiClient
	) {
		self.navigationController = navigationController
		self.apiClient = apiClient
	}
	
	func start() {
		let interactor = ViewerInteractor(client: apiClient)
		let downloader = PhotoDownloader(client: apiClient)
		let viewModel = ViewerViewModel(
			interactor: interactor, 
			downloader: downloader,
			coordinator: self
		)
		let vc = ViewerViewController(viewModel: viewModel)
		navigationController?.pushViewController(vc, animated: false)
	}
	
	func share(photo: PhotoViewModel) {
		guard let data = photo.data, let image = UIImage(data: data) else { return }
		let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		vc.popoverPresentationController?.sourceView = navigationController?.view
		navigationController?.present(vc, animated: true, completion: nil)
	}
}
