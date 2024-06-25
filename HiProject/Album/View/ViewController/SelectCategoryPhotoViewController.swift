//
//  SelectCategoryPhotoViewController.swift
//  HiProject
//
//  Created by 최동호 on 6/25/24.
//

import SnapKit

import UIKit

final class SelectCategoryPhotoViewController: UIViewController {
    // MARK: - Public properties
    let selectImage: UIImage
    
    // MARK: - Private properties
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = selectImage
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var selectCategoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .customFont(forTextStyle: .callout, weight: .regular)
        label.text = "자랑할 사진의 카테고리를 선택해보세요!"
        return label
    }()
    
    private lazy var selectCategoryContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray01
        label.font = .customFont(forTextStyle: .footnote, weight: .regular)
        label.text = "여러 개의 태그를 선택해도 좋아요!"
        return label
    }()
    
    private lazy var exerciseCategoryButton = makeCategoryButton(title: "운동")
    private lazy var beautyCategoryButton = makeCategoryButton(title: "뷰티")
    private lazy var hobbyCategoryButton = makeCategoryButton(title: "취미")
    private lazy var studyCategoryButton = makeCategoryButton(title: "공부")
    
    private lazy var firstHorizontalStackView = makeHorizontalStackView(buttons: [exerciseCategoryButton, beautyCategoryButton])
    private lazy var secondHorizontalStackView = makeHorizontalStackView(buttons: [hobbyCategoryButton, studyCategoryButton])
    
    private lazy var verticalStackView: UIStackView = {
        let stackView =  UIStackView(arrangedSubviews: [firstHorizontalStackView, secondHorizontalStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
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
        setButtonActions()
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .black
        view.addSubview(cancelButton)
        view.addSubview(checkButton)
        view.addSubview(photoImageView)
        view.addSubview(selectCategoryTitleLabel)
        view.addSubview(selectCategoryContentLabel)
        view.addSubview(verticalStackView)
    }
    
    private func configLayout() {
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
            make.top.equalTo(cancelButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.width * 1.16)
        }
        
        selectCategoryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        
        selectCategoryContentLabel.snp.makeConstraints { make in
            make.top.equalTo(selectCategoryTitleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(selectCategoryContentLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width * 0.65)
            make.height.equalTo(UIScreen.main.bounds.width * 0.65 * 0.39)
        }
        
    }
    
    private func setButtonActions() {
        cancelButton.addTarget(self, action: #selector(didSelectCancelButton(_:)), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(didSelectCheckButton(_:)), for: .touchUpInside)
    }
    
    private func makeCategoryButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 20
        return button
    }
    
    private func makeHorizontalStackView(buttons: [UIButton]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }
    // MARK: - Actions
    
    @objc func didSelectCancelButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func didSelectCheckButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
}

// MARK: - Extensions here
