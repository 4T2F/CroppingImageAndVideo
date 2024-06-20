//
//  SelectPhotoViewController.swift
//  HiProject
//
//  Created by 노주영 on 5/29/24.
//

import Photos
import SnapKit

import UIKit

protocol SelectPhotoViewControllerCoordinator: AnyObject {
    func didSelectCell(item: Int)
}

class SelectPhotoViewController: UIViewController {
    private let viewModel = SignUpViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: ViewValues.width, height: ViewValues.cellHeight + 130)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.dataSource = self
        collectionView.register(SelectPhotoCollectionViewCell.self, forCellWithReuseIdentifier: SelectPhotoCollectionViewCell.reuseIdentifier)
       
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUserInterface()
        configLayout()
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func configLayout() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SelectPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectPhotoCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.setProperties(coordinator: self, viewModel: viewModel)
        
        return cell
    }
}

extension SelectPhotoViewController: SelectPhotoViewControllerCoordinator {
    func didSelectCell(item: Int) {
        let controller = PhotoViewController()
        controller.modalPresentationStyle = .fullScreen
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true)
    }
}
