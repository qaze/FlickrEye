//
//  PhotoDownloaderProtocol.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 26.07.2021.
//

import Combine
import Foundation

protocol PhotoDownloaderProtocol {
	func download(url: URL) -> AnyPublisher<Data?, Error>
}
