//
//  ApiClient.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Combine
import Foundation

enum ApiClientError: Error {
	case wrongRequest(Request)
	case remoteError(Error)
}

protocol ApiClient {
	func perform<ResultModel: Decodable>(request: Request) -> AnyPublisher<ResultModel, Error>
	func download(url: URL) -> AnyPublisher<Data?, Error>
}
