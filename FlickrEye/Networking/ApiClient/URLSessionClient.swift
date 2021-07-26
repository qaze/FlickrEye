//
//  URLSessionClient.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import Foundation
import Combine

class URLSessionClient<NetworkDecoder: TopLevelDecoder>: ApiClient where NetworkDecoder.Input == Data {
	private let session: URLSession
	private let apiKey: String
	private let decoder: NetworkDecoder
	private let baseURL: URL
	
	init(
		session: URLSession, 
		apiKey: String, 
		decoder: NetworkDecoder, 
		baseURL: URL
	) {
		self.session = session
		self.apiKey = apiKey
		self.decoder = decoder
		self.baseURL = baseURL
	}
	
	private func map(request: Request) -> URLRequest? {
		var components = URLComponents(
			url: baseURL.appendingPathComponent(request.path), 
			resolvingAgainstBaseURL: true
		)
		
		components?.queryItems = request.queryItems + 
			[.init(name: "api_key", value: apiKey)]
		
		guard let url = components?.url else { return nil }
		var result = URLRequest(url: url)
		result.httpBody = request.body
		result.httpMethod = request.type.rawValue
		return result
	}
	
	func perform<ResultModel: Decodable>(request: Request) -> AnyPublisher<ResultModel, Error> {
		guard let urlRequest = map(request: request) else {
			return Fail(error: ApiClientError.wrongRequest(request))
				.eraseToAnyPublisher()
		}
		
		return session
			.dataTaskPublisher(for: urlRequest)
			.tryMap { element in
				guard let httpResponse = element.response as? HTTPURLResponse,
					  httpResponse.statusCode == 200 else {
					throw URLError(.badServerResponse)
				}
				
				return element.data
			}
			.decode(type: ResultModel.self, decoder: decoder)
			.eraseToAnyPublisher()
	}
	
	func download(url: URL) -> AnyPublisher<Data?, Error> {
		session
			.dataTaskPublisher(for: url)
			.tryMap { element in
				guard let httpResponse = element.response as? HTTPURLResponse,
					  httpResponse.statusCode == 200 else {
					throw URLError(.badServerResponse)
				}
				
				return element.data
			}
			.eraseToAnyPublisher()
	}
}
