//
//  PhotoViewController.swift
//  HiProject
//
//  Created by 노주영 on 5/29/24.
//

import Photos
import SnapKit

import UIKit

final class PhotoViewController: UIViewController {
    // MARK: - Private properties
    private let viewModel = CropViewModel()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.text = "A - TEEN은 사용자가 선택한 사진만 엑세스할 수 있습니다."
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.customFont(forTextStyle: .caption2, weight: .regular)
        return label
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.setTitle("사진", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "mainColor")
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .footnote, weight: .regular)
        button.isSelected = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didSelectChangeButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoButton: UIButton = {
        let button = UIButton()
        button.setTitle("동영상", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .footnote, weight: .regular)
        button.isSelected = false
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didSelectChangeButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: ViewValues.cellWidth, height: ViewValues.cellWidth)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
        return collectionView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUserInterface()
        configLayout()
        
        loadAlbums(mediaType: .image) { [weak self] in
            self?.loadImages()
        }
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        self.navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        view.addSubview(explanationLabel)
        view.addSubview(photoButton)
        view.addSubview(videoButton)
        view.addSubview(collectionView)
    }
    
    private func configLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(cancelButton.snp.bottom).offset(22)
            make.height.equalTo(15)
        }
        
        photoButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.view.snp.centerX).offset(-8)
            make.top.equalTo(explanationLabel.snp.bottom).offset(20)
            make.width.equalTo(98)
            make.height.equalTo(39)
        }
        
        videoButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view.snp.centerX).offset(8)
            make.top.equalTo(explanationLabel.snp.bottom).offset(20)
            make.width.equalTo(98)
            make.height.equalTo(39)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(photoButton.snp.bottom).offset(27)
        }
    }
    
    // MARK: - Actions
    @objc func didSelectChangeButton(_ sender: UIButton) {
        switch sender {
        case photoButton:
            photoButton.isSelected = true
            photoButton.backgroundColor = UIColor(named: "mainColor")
            
            videoButton.isSelected = false
            videoButton.backgroundColor = .gray
            
            loadAlbums(mediaType: .image) { [weak self] in
                self?.loadImages()
            }
            
        case videoButton:
            photoButton.isSelected = false
            photoButton.backgroundColor = .gray
            
            videoButton.isSelected = true
            videoButton.backgroundColor = UIColor(named: "mainColor")
            
            loadAlbums(mediaType: .video) { [weak self] in
                self?.loadImages()
            }
            
        default:
            break
        }
    }
    
    private func loadAlbums(
        mediaType: MediaType,
        completion: @escaping () -> Void
    ) {
        viewModel.loadAlbums(mediaType: mediaType) {
            completion()
        }
    }
    
    private func loadImages() {
        viewModel.loadAsset {
            self.collectionView.reloadData()
        }
    }
    
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as? PhotoCell
        else { return UICollectionViewCell() }
        
        viewModel.fetchImage(
            item: indexPath.item,
            size: CGSize(width: ViewValues.cellWidth, height: ViewValues.cellWidth),
            contentMode: .aspectFill,
            version: .current
        ) { [weak cell] asset, image in
            cell?.setImage(
                info: .init(
                    phAsset: asset,
                    image: image,
                    avAsset: nil,
                    avAudio: nil))
        }
        
//        let imageInfo = viewModel.photos[indexPath.item]
//        let phAsset = imageInfo.phAsset
//        let imageSize = CGSize(width: ViewValues.cellWidth, height: ViewValues.cellWidth)
//
//        photoService.fetchImage(
//                        phAsset: viewModel.photos[indexPath.item],
//                        size: imageSize,
//                        contentMode: .aspectFill,
//                        completion: { [weak cell] image in
//                            cell?.setImage(info: .init(phAsset: phAsset, image: image))
//                        }
//                    )
        
//        if phAsset.mediaType == .video {
//            
//            photoService.fetchVideo(
//                phAsset: phAsset,
//                size: imageSize) { [weak cell] avAsset, avAudio in
//                    guard let avAsset = avAsset else { return }
//                    cell?.setPlayer(
//                        info: .init(
//                            phAsset: phAsset,
//                            avAsset: avAsset,
//                            avAudio: avAudio))
//            }
//        } else {
//            photoService.fetchImage(
//                phAsset: phAsset,
//                size: imageSize,
//                contentMode: .aspectFit,
//                completion: { [weak cell] image in
//                    cell?.prepare(info: .init(phAsset: phAsset, image: image))
//                }
//            )
//        }
        return cell
    }
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.fetchImage(
            item: indexPath.item,
            size: CGSize(width: ViewValues.width, height: ViewValues.height),
            contentMode: .aspectFit,
            version: .current
        ) { _, image in
            let controller = CroppingViewController(selectImage: image)
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
