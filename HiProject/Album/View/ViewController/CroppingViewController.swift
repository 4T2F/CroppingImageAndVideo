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
    
    var initialCenter = CGPoint()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //guard let cgImage = selectImage.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 100, height: 100)) else { return }
        self.photoImageView.image = selectImage
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        view.addSubview(photoImageView)
        
        photoImageView.addSubview(cropView)
        photoImageView.addSubview(topView)
        photoImageView.addSubview(bottomView)
        
        view.bringSubviewToFront(cancelButton)
    }
    
    private func configLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
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
            make.centerX.equalToSuperview()
            
            if selectImage.size.height < 500 {
                make.width.equalTo(selectImage.size.height / 1.16)
                make.height.equalTo(selectImage.size.height)
                self.cropViewTopAnchor = make.top.equalToSuperview().constraint
            } else {
                make.width.equalToSuperview()
                make.height.equalTo(500)
                self.cropViewTopAnchor = make.top.equalToSuperview().offset(selectImage.size.height / 2 - 250).constraint
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
    }
    
    // MARK: - Actions
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: cropView)
        if gestureRecognizer.state == .began {
            if selectImage.size.height < 500 {
                gestureRecognizer.state = .cancelled
            } else {
                cropView.linesChangeState(isCropping: true)
            }
        } else if gestureRecognizer.state == .changed {
            initialCenter = cropView.center
            
            cropView.center = CGPoint(
                x: initialCenter.x,
                y: initialCenter.y + translation.y)
            
            self.cropViewTopAnchor?.update(offset: cropView.frame.origin.y)

            // 경계 체크
            if cropView.frame.origin.y < 0 {
                self.cropViewTopAnchor?.update(offset: 0)
                cropView.frame.origin.y = 0
            } else if cropView.frame.origin.y + cropView.frame.height > photoImageView.frame.height {
                self.cropViewTopAnchor?.update(offset: photoImageView.frame.height - cropView.frame.height)
                cropView.frame.origin.y = photoImageView.frame.height - cropView.frame.height
            }
            
            gestureRecognizer.setTranslation(CGPoint.zero, in: cropView)
        } else if gestureRecognizer.state == .cancelled {
            cropView.linesChangeState(isCropping: false)
        } else if gestureRecognizer.state == .ended {
            cropView.linesChangeState(isCropping: false)
            gestureRecognizer.setTranslation(.zero, in: cropView)
            initialCenter = CGPoint.zero
        }
    }
}
