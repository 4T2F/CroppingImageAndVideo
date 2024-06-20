//
//  asdsad.swift
//  HiProject
//
//  Created by 노주영 on 6/4/24.
//

import SnapKit

import UIKit

final class SelectPhotoCollectionViewCell: UICollectionViewCell {
    // MARK: - Private properties
    private var coordinator: SelectPhotoViewControllerCoordinator?
    private var viewModel = SignUpViewModel()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TEEN에서 자랑할\n사진이나 동영상을 추가해보세요"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.customFont(forTextStyle: .title3, weight: .bold)
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "*최대 10개을 등록할 수 있어요"
        label.textAlignment = .left
        label.textColor = UIColor(named: "gray01")
        label.font = UIFont.customFont(forTextStyle: .footnote, weight: .regular)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: ViewValues.selectPhotoCellWidth, height: ViewValues.cellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)
       
        return collectionView
    }()

    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUserInterface()
        configLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(collectionView)
    }
    
    private func configLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(ViewValues.defaultPadding)
            make.trailing.equalToSuperview().offset(-ViewValues.defaultPadding)
            make.top.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(ViewValues.defaultPadding)
            make.trailing.equalToSuperview().offset(-ViewValues.defaultPadding)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(31)
        }
    }

    // MARK: - Actions
    func setProperties(coordinator: SelectPhotoViewControllerCoordinator, viewModel: SignUpViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }
}

// MARK: - UICollectionViewDataSource
extension SelectPhotoCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.selectPhotoAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoCollectionViewCell
        else { return UICollectionViewCell() }
        cell.setProperties(viewModel: viewModel)
        cell.setCellCustom(item: indexPath.item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectPhotoCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.requestAuthorization { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                coordinator?.didSelectCell(item: indexPath.item)
            case .failure:
                return
            }
        }
    }
}


extension SelectPhotoCollectionViewCell: Reusable { }
