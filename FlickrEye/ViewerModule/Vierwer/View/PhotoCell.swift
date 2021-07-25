//
//  PhotoCell.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 25.07.2021.
//

import UIKit
import Combine

final class PhotoCell: UICollectionViewCell {
	private let imageView = UIImageView()
	private weak var viewModel: PhotoViewModel?
	private var loadingCancellable: AnyCancellable?
	
	func bind(to model: PhotoViewModel) {
		viewModel = model
		loadingCancellable = viewModel?
			.$data
			.receive(on: DispatchQueue.main)
			.sink { [weak self] data in
				guard let data = data else { return }
				self?.imageView.image = UIImage(data: data)
			}
		
		viewModel?.prepare()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		loadingCancellable?.cancel()
		imageView.image = nil
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupAppearance()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupAppearance() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .white
		imageView.contentMode = .scaleAspectFit
		let constraints = [
			imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			imageView.topAnchor.constraint(equalTo: topAnchor),
			imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
		]
		
		addSubview(imageView)
		NSLayoutConstraint.activate(constraints)
	}
}
