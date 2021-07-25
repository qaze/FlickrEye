//
//  ViewerInteractorProtocol.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Combine

protocol ViewerInteractorProtocol {
	func fetchPhotos(for tag: String, page: Int) -> AnyPublisher<PhotoContainerNetworkModel, Error>
}
