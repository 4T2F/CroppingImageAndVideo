
//
//  LoginBirthViewController.swift
//  ATeen
//
//  Created by 노주영 on 5/28/24.
//

import SnapKit

import UIKit

class LoginBirthViewController: UIViewController {
    // MARK: - Public properties
    
    // MARK: - Private properties
    private var viewModel = LoginBirthViewModel()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "당신의\n생년월일을 알려주세요!"
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.customFont(forTextStyle: .title3, weight: .bold)
        return label
    }()
    
    private lazy var birthButton: CustomBirthButton = {
        let button = CustomBirthButton(
            imageName: "arrowDownIcon",
            imageColor: .white,
            textColor: .black,
            labelText: "태어난 날을 선택해주세요",
            buttonBackgroundColor: .white,
            labelFont: UIFont.customFont(forTextStyle: .callout, weight: .regular),
            frame: .zero)
        button.addTarget(self, action: #selector(didSelectBirh(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var serviceButton: CustomServiceButton = {
        let button = CustomServiceButton(
            imageName: "arrowRightSmallIcon",
            imageColor: .white,
            textColor: UIColor(named: "graySchoolColor") ?? .gray,
            labelText: "서비스 약관 바로 보기",
            buttonBackgroundColor: .white,
            labelFont: UIFont.customFont(forTextStyle: .footnote, weight: .regular),
            frame: .zero)
        button.customLabel.sizeToFit()
        button.addTarget(self, action: #selector(didSelectService(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sample"
        configUserInterface()
    }
    
    // MARK: - Helpers
    private func configUserInterface() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(birthButton)
        view.addSubview(serviceButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(ViewValues.defaultPadding)
            make.trailing.equalToSuperview().offset(-ViewValues.defaultPadding)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        birthButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(ViewValues.defaultPadding)
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.width.equalTo(190)
            make.height.equalTo(24)
        }
        
        serviceButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(ViewValues.defaultPadding)
            make.top.equalTo(birthButton.snp.bottom).offset(87)
            make.width.equalTo(140)
            make.height.equalTo(24)
        }
    }
    
    // MARK: - Actions
    @objc func didSelectBirh(_ sender: UIButton) {
        let controller = LoginBirthSelectViewController(
            coordinator: self,
            viewModel: viewModel,
            beforeYear: viewModel.year,
            beforeMonth: viewModel.month,
            beforeDay: viewModel.day)
        
        controller.modalPresentationStyle = .overFullScreen
        
        self.present(controller, animated: false)
    }
    
    @objc func didSelectService(_ sender: UIButton) {
        print("234")
    }
}

// MARK: - Extensions here
extension LoginBirthViewController: LoginBirthSelectViewControllerCoordinator {
    func didSelectBirth() {
        birthButton.changeWidth(
            year: viewModel.year,
            month: viewModel.month,
            day: viewModel.day)
    }
}
