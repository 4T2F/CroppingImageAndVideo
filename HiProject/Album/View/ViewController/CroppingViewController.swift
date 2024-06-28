//
//  CroppingViewController.swift
//  HiProject
//
//  Created by 노주영 on 6/7/24.
//

import SnapKit

import UIKit

final class CroppingViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Private properties
    let selectImage: UIImage
    
    var originSpaceX: Double = 0.0
    var originSpaceY: Double = 0.0
    var originCropViewY: Double = 0.0
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didSelectCheckButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var cropView: CustomCropView = {
        let view = CustomCropView(frame: .zero, imageSize: selectImage.size)
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // MARK: - Life Cycle
    init(selectImage: UIImage) {
        self.selectImage = selectImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUserInterface()
        configLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.photoImageView.image = selectImage
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        view.addSubview(cancelButton)
        view.addSubview(checkButton)
        scrollView.addSubview(photoImageView)
        scrollView.addSubview(cropView)
    }
    
    private func configLayout() {
        scrollView.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
            if selectImage.size.height > ViewValues.width * 1.16 {
                make.width.equalTo(ViewValues.width)
                make.height.equalTo(selectImage.size.height * ViewValues.width / selectImage.size.width)
            } else {
                make.width.equalTo(selectImage.size.width * ViewValues.width * 1.16 / selectImage.size.height)
                make.height.equalTo(ViewValues.width * 1.16)
            }
        }
        
        cropView.snp.makeConstraints { make in
            make.center.equalTo(self.view.snp.center)
            make.width.equalTo(ViewValues.width)
            make.height.equalTo(ViewValues.width * 1.16)
        }
        
        self.view.layoutIfNeeded()
        originCropViewY = cropView.frame.origin.y
        
        if selectImage.size.height > ViewValues.width * 1.16 {
            scrollView.contentSize = CGSize(
                width: ViewValues.width,
                height: ViewValues.height + (photoImageView.frame.height - selectImage.size.height))
            
            originSpaceY = (photoImageView.frame.height - selectImage.size.height) / 2
            scrollView.contentInset = .init(top: originCropViewY + originSpaceY, left: 0, bottom: originCropViewY - originSpaceY, right: 0)
        } else {
            scrollView.contentSize = CGSize(
                width: ViewValues.width,
                height: ViewValues.height)
            originSpaceX = (photoImageView.frame.width - selectImage.size.width) / 2
            scrollView.contentInset = .init(top: 0, left: originSpaceX, bottom: 0, right: originSpaceX)
        }
    }
    
    // MARK: - Actions
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func didSelectCheckButton(_ sender: UIButton) {
        let image = cropImage()
        self.navigationController?.pushViewController(SelectCategoryPhotoViewController(selectImage: image), animated: true)
    }
    
    private func cropImage() -> UIImage {
        self.view.layoutIfNeeded()
        var newImage = UIImage()
        
        if selectImage.size.height > ViewValues.width * 1.16 {
            newImage = selectImage.resized(
                to: CGSize(
                    width: ViewValues.width,
                    height: selectImage.size.height * ViewValues.width / selectImage.size.width))
        } else {
            newImage = selectImage.resized(
                to: CGSize(
                    width: selectImage.size.width * ViewValues.width * 1.16 / selectImage.size.height,
                    height: ViewValues.width * 1.16))
        }
        
        // 확대된 이미지 반환
        guard let transformedImage = newImage.transformed(by: photoImageView.transform) else { return UIImage() }
        
        // 크롭 영역을 스케일 팩터에 맞게 조정
        let cutFrame = CGRect(
            x: cropView.frame.origin.x - photoImageView.frame.origin.x,
            y: cropView.frame.origin.y - photoImageView.frame.origin.y,
            width: cropView.frame.width,
            height: cropView.frame.height)
        
        print(cutFrame)
        
        guard let cgImage = transformedImage.cgImage?.cropping(to: cutFrame) else { return UIImage() }
        
        // 크롭된 이미지의 스케일과 방향을 유지
        return UIImage(cgImage: cgImage, scale: transformedImage.scale, orientation: transformedImage.imageOrientation)
    }
    
    // 줌할 뷰 설정
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.view.layoutIfNeeded()
        
        if selectImage.size.height > ViewValues.width * 1.16 {
            scrollView.contentSize = CGSize(
                width: photoImageView.frame.width,
                height: photoImageView.frame.height)
        } else {
            scrollView.contentSize = CGSize(
                width: photoImageView.frame.width - originSpaceX * 2,
                height: photoImageView.frame.height + originCropViewY * 2)
        }
    }
}

extension UIImage {
    func transformed(by transform: CGAffineTransform) -> UIImage? {
        let transformedRect = CGRect(origin: .zero, size: self.size).applying(transform)
        let newSize = transformedRect.size
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.concatenate(transform)
        self.draw(at: CGPoint(x: 0, y: 0))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let resizedImage = resizedImage else { return UIImage() }
        return resizedImage
    }
}
