//
//  ViewerModule.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation
import UIKit

class ViewerModule {
	private let networkClient: ApiClient
	private let cache: Cache?
	private let urlSession = URLSession(configuration: .default)
	private let coordinator: Coordinator
	
	init?(navigationController: UINavigationController) {
		guard let apiKey = Bundle
				.main
				.object(forInfoDictionaryKey: "APIKEY") as? String 
		else { return nil }
		
		guard let baseURLString = Bundle
				.main
				.object(forInfoDictionaryKey: "BASEURL") as? String,
			  let baseURL = URL(string: baseURLString)
		else { return nil }
		
		networkClient = URLSessionClient(
			session: urlSession, 
			apiKey: apiKey, 
			decoder: JSONDecoder(),
			baseURL: baseURL
		)
		
		cache = try? FileCache()
		
		coordinator = ViewerCoordinator(
			navigationController: navigationController, 
			apiClient: networkClient,
			cache: cache
		)
	}
	
	func start() {
		coordinator.start()
	}
}
