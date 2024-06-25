//
//  CroppingViewController.swift
//  HiProject
//
//  Created by 노주영 on 6/7/24.
//

import SnapKit

import UIKit

final class CroppingViewController: UIViewController {
    // MARK: - Private properties
    //private var viewModel: SignUpViewModel
    let selectImage: UIImage
    
    var cropViewTopAnchor: Constraint?
    var cropViewLeadingAnchor: Constraint?
    
    var initialCenter = CGPoint()
    
    private lazy var squareView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var cropView: CustomCropView = {
        let view = CustomCropView(frame: .zero, imageSize: selectImage.size)
        //view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    private lazy var leftView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    private lazy var rightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
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
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.view.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.photoImageView.image = selectImage
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        view.addSubview(checkButton)
        view.addSubview(squareView)
        view.addSubview(topView)
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(bottomView)
        
        squareView.addSubview(photoImageView)
        squareView.addSubview(cropView)
        
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(checkButton)
    }
    
    private func configLayout() {
        squareView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
            if selectImage.size.width < ViewValues.width {
                make.width.equalTo(selectImage.size.width)
            } else {
                make.width.equalToSuperview()
            }
            
            if selectImage.size.height < ViewValues.height {
                make.height.equalTo(selectImage.size.height)
            } else {
                make.height.equalToSuperview()
            }
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
            
            if selectImage.size.width < ViewValues.width {
                make.width.equalTo(selectImage.size.width)
            } else {
                make.width.equalToSuperview()
            }
            
            if selectImage.size.height < ViewValues.height {
                make.height.equalTo(selectImage.size.height)
            } else {
                make.height.equalToSuperview()
            }
        }
        
        cropView.snp.makeConstraints { make in
            if selectImage.size.height < 500 {
                make.width.equalTo(selectImage.size.height / 1.16)
                make.height.equalTo(selectImage.size.height)
                self.cropViewTopAnchor = make.top.equalToSuperview().constraint
                self.cropViewLeadingAnchor = make.leading.equalToSuperview().offset((selectImage.size.width - selectImage.size.height / 1.16) / 2).constraint
            } else {
                make.width.equalToSuperview()
                make.height.equalTo(500)
                self.cropViewTopAnchor = make.top.equalToSuperview().offset(selectImage.size.height / 2 - 250).constraint
                self.cropViewLeadingAnchor = make.leading.equalToSuperview().constraint
                
            }
        }
        
        topView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(self.cropView.snp.top)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.cropView.snp.bottom)
        }
        
        leftView.snp.makeConstraints { make in
            make.top.bottom.equalTo(squareView)
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.cropView.snp.leading)
        }
        
        rightView.snp.makeConstraints { make in
            make.top.bottom.equalTo(squareView)
            make.leading.equalTo(self.cropView.snp.trailing)
            make.trailing.equalToSuperview()
        }
        
    }
    
    // MARK: - Actions
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let _ = gesture.view else { return }
        
        if gesture.state == .began {
            cropView.linesChangeState(isCropping: true)
        } else if gesture.state == .changed {
            let newScale = photoImageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            
            let newWidth = photoImageView.frame.size.width * gesture.scale
            let newHeight = photoImageView.frame.size.height * gesture.scale
            
            // 원래 크기보다 작아지지 않도록 제한
            if newWidth >= selectImage.size.width && newHeight >= selectImage.size.height {
                photoImageView.transform = newScale
            }
            
            gesture.scale = 1.0
        } else if gesture.state == .ended {
            cropView.linesChangeState(isCropping: false)
        }
    }
    
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func didSelectCheckButton(_ sender: UIButton) {
        self.view.layoutIfNeeded()
        
        // 확대된 이미지 반환
        guard let transformedImage = selectImage.transformed(by: photoImageView.transform) else { return }
        
        let cropRect = CGRect(x: cropView.frame.origin.x + abs(photoImageView.frame.origin.x),
                              y: cropView.frame.origin.y + abs(photoImageView.frame.origin.y),
                              width: cropView.frame.size.width,
                              height: cropView.frame.size.height)
        
        // 이미지 크롭
        guard let image = transformedImage.cropped(to: cropRect) else { return }
        
        self.navigationController?.pushViewController(SelectCategoryPhotoViewController(selectImage: image), animated: true)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: cropView)
        if gestureRecognizer.state == .began {
            
            cropView.linesChangeState(isCropping: true)
            
        } else if gestureRecognizer.state == .changed {
            
            if selectImage.size.height < 500 {
                initialCenter = cropView.center
                
                cropView.center = CGPoint(
                    x: initialCenter.x + translation.x,
                    y: initialCenter.y)
                
                self.cropViewLeadingAnchor?.update(offset: cropView.frame.origin.x)
                
                // 경계 체크
                if cropView.frame.origin.x < 0 {
                    self.cropViewLeadingAnchor?.update(offset: 0)
                    cropView.frame.origin.x = 0
                } else if cropView.frame.origin.x + cropView.frame.width > squareView.frame.width {
                    self.cropViewLeadingAnchor?.update(offset: squareView.frame.width - cropView.frame.width)
                    cropView.frame.origin.x = squareView.frame.width - cropView.frame.width
                }
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: cropView)
                
            } else {
                initialCenter = cropView.center
                
                cropView.center = CGPoint(
                    x: initialCenter.x,
                    y: initialCenter.y + translation.y)
                
                self.cropViewTopAnchor?.update(offset: cropView.frame.origin.y)
                
                // 경계 체크
                if cropView.frame.origin.y < 0 {
                    self.cropViewTopAnchor?.update(offset: 0)
                    cropView.frame.origin.y = 0
                } else if cropView.frame.origin.y + cropView.frame.height > squareView.frame.height {
                    self.cropViewTopAnchor?.update(offset: squareView.frame.height - cropView.frame.height)
                    cropView.frame.origin.y = squareView.frame.height - cropView.frame.height
                }
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: cropView)
            }
            
        } else if gestureRecognizer.state == .cancelled {
            cropView.linesChangeState(isCropping: false)
        } else if gestureRecognizer.state == .ended {
            cropView.linesChangeState(isCropping: false)
            gestureRecognizer.setTranslation(.zero, in: cropView)
            initialCenter = CGPoint.zero
        }
    }
    
    private func cropImage() -> UIImage {
        self.view.layoutIfNeeded()
        let frame = cropView.frame
        guard let cgImage = selectImage.cgImage?.cropping(to: frame) else { return UIImage() }
        
        return UIImage(cgImage: cgImage)
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
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
