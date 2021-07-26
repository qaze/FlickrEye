//
//  ViewerViewController.swift
//  FlickrEye
//
//  Created by Nik Rodionov on 24.07.2021.
//

import UIKit
import Combine

final class ViewerViewController: UIViewController {
	enum Section { case photos }
	enum Constants { 
		static let photoCellIdentifier = "photo_cell"
		static let interCellSpacing = 8
		static let sectionSpacing = 8
	}
	
	typealias DataSource = UICollectionViewDiffableDataSource<Section, PhotoViewModel>
	typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PhotoViewModel>
	
	private let viewModel: ViewerViewModel
	private let collectionView = UICollectionView(
		frame: .zero, 
		collectionViewLayout: UICollectionViewFlowLayout()
	)
	
	private let searchBar = UISearchBar()
	private let loadingIndicator = UIActivityIndicatorView(style: .large)
	private lazy var dataSource: DataSource = makeDataSource() 
	private var disposeBag = Set<AnyCancellable>()
	
	init(viewModel: ViewerViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupAppearance()
		bindToViewModel()
		viewModel.onViewReady()
	}
}

// MARK: - Appearance extension
fileprivate extension ViewerViewController {
	func makeDataSource() -> DataSource {
		DataSource(collectionView: collectionView) { 
			collection, indexPath, viewModel -> UICollectionViewCell? in
			let cell = collection.dequeueReusableCell(
				withReuseIdentifier: Constants.photoCellIdentifier, 
				for: indexPath
			) as? PhotoCell
			
			cell?.bind(to: viewModel)
			return cell
		}
	}
	
	func setupAppearance() {
		view.backgroundColor = .white
		navigationItem.title = "Flickr Eye Viewer"
		
		setupSearchBar()
		setupCollectionView()
		setupLayout()
		setupLoading()
	}
	
	func setupCollectionView() { 
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		let constraints = [
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		]
		
		collectionView.keyboardDismissMode = .onDrag
		collectionView.backgroundColor = .white
		view.addSubview(collectionView)
		NSLayoutConstraint.activate(constraints)
		
		collectionView
			.register(
				PhotoCell.self, 
				forCellWithReuseIdentifier: Constants.photoCellIdentifier
			)
		
		collectionView.dataSource = dataSource
		collectionView.delegate = self
	}
	
	func setupSearchBar() { 
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		
		let constraints = [
			searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
		]
		searchBar.text = viewModel.tag
		searchBar.delegate = self
		view.addSubview(searchBar)
		NSLayoutConstraint.activate(constraints)
	}
	
	func setupLayout() {
		guard let layout = collectionView.collectionViewLayout 
				as? UICollectionViewFlowLayout else { return }
		
		layout.minimumInteritemSpacing = 8
		layout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
		layout.minimumLineSpacing = 8
		
		let columnCount = ViewerViewModel.Constants.columnsCount
		let interItemSpacing = (columnCount - 1) * Constants.interCellSpacing
		let sectionSpacing = Constants.sectionSpacing * 2
		let exceedSpacing = interItemSpacing + sectionSpacing 
		let itemDimension = (Int(UIScreen.main.bounds.width) - exceedSpacing) / columnCount
		layout.itemSize = .init(width: itemDimension, height: itemDimension)
	}
	
	func setupLoading() {
		loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
		let constrains = [
			loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		]
		
		loadingIndicator.hidesWhenStopped = true
		view.addSubview(loadingIndicator)
		NSLayoutConstraint.activate(constrains)
	}
	
	func bindToViewModel() {
		viewModel
			.$isLoading
			.sink { [weak self] loading in
				loading 
					? self?.loadingIndicator.startAnimating()
					: self?.loadingIndicator.stopAnimating()
			}
			.store(in: &disposeBag)
		
		viewModel
			.$photos
			.sink { [weak self] photos in
				var snapshot = Snapshot()
				snapshot.appendSections([.photos])
				snapshot.appendItems(photos)
				
				self?.dataSource.apply(snapshot, animatingDifferences: true)
			}
			.store(in: &disposeBag)
	}
}

extension ViewerViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.tag = searchText
	}
}

extension ViewerViewController: UICollectionViewDelegate {
	func collectionView(
		_ collectionView: UICollectionView, 
		didSelectItemAt indexPath: IndexPath
	) {
		viewModel.sharePhoto(at: indexPath.row)
	}
	
	func collectionView(
		_ collectionView: UICollectionView, 
		willDisplay cell: UICollectionViewCell, 
		forItemAt indexPath: IndexPath
	) {
		viewModel.photoWillBeShown(at: indexPath.row)
	}
}
