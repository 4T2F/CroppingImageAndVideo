//
//  LoginBirthSelectViewController.swift
//  HiProject
//
//  Created by 노주영 on 5/28/24.
//

import SnapKit

import UIKit

protocol LoginBirthSelectViewControllerCoordinator: AnyObject {
    func didSelectBirth()
}

final class LoginBirthSelectViewController: UIViewController {
    // MARK: - Private properties
    private let monthList: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    private let dayList: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    
    private var yearList: [String] = []
    
    private var beforeYear: String
    private var beforeMonth: String
    private var beforeDay: String
    
    private var alertViewHeightAnchor: Constraint?
    private var viewModel: LoginBirthViewModel
    
    private weak var coordinator: LoginBirthSelectViewControllerCoordinator?
    
    private lazy var alertView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: ViewValues.height, width: ViewValues.height, height: 0))
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = ViewValues.defaultRadius
        view.layer.maskedCorners = CACornerMask(arrayLiteral: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "태어난 날을 선택해주세요"
        label.textAlignment = .center
        label.font = UIFont.customFont(forTextStyle: .callout, weight: .bold)
        return label
    }()
    
    //TODO: picker
    private lazy var upLine = CustomLineView(
        frame: CGRect(
            x: 0,
            y: 0,
            width: ViewValues.componentPickerWidth * 3,
            height: 1))
    
    private lazy var underLine = CustomLineView(
        frame: CGRect(
            x: 0,
            y: ViewValues.componentPickerHight,
            width: ViewValues.componentPickerWidth * 3,
            height: 1))

    private lazy var birthPicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.customFont(forTextStyle: .callout, weight: .regular)
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.addTarget(self, action: #selector(didSelectOkButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    init(
        coordinator: LoginBirthSelectViewControllerCoordinator,
        viewModel: LoginBirthViewModel,
        beforeYear: String,
        beforeMonth: String,
        beforeDay: String
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.beforeYear = beforeYear
        self.beforeMonth = beforeMonth
        self.beforeDay = beforeDay
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUserInterface()
        configTapGesture()
    }
    
    override func viewWillLayoutSubviews() {
        birthPicker.subviews[1].backgroundColor = .clear
        birthPicker.subviews[1].addSubview(upLine)
        birthPicker.subviews[1].addSubview(underLine)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTime()
        animateView()
    }
    
    // MARK: - Helpers
    private func configTapGesture() {
        //탭 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectBackView(_:)))
        view.addGestureRecognizer(tapGesture)
        
        let alertTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectTouchView(_:)))
        alertView.addGestureRecognizer(alertTapGesture)
    }
    
    private func configUserInterface() {
        //메인 뷰
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        view.addSubview(alertView)
        
        alertView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            
            self.alertViewHeightAnchor = make.height.equalTo(0).constraint
        }
        
        alertView.addSubview(titleLabel)
        alertView.addSubview(okButton)
        alertView.addSubview(birthPicker)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(27)
            make.height.equalTo(19)
        }
        
        birthPicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(52)
            make.leading.equalToSuperview().offset(ViewValues.componentPickerWidth)
            make.trailing.equalToSuperview().offset(-ViewValues.componentPickerWidth)
            make.height.equalTo(ViewValues.componentPickerHight * 3)
        }
        
        okButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-ViewValues.defaultPadding)
            make.bottom.equalToSuperview().offset(-64)
            make.width.equalTo(116)
            make.height.equalTo(50)
        }
    }
    
    /// 가능한 날짜 설정
    private func setTime() {
        /// 선택 가능한 연도 설정
        let formatterYear = DateFormatter()
        formatterYear.dateFormat = "yyyy MM dd"
        let todayYear = formatterYear.string(from: Date())
        let todayArr = todayYear.components(separatedBy: " ")
        
        for i in 1990..<Int(todayArr[0])! {
            yearList.append(String(i))
        }
        
        if viewModel.month.isEmpty || viewModel.day.isEmpty {
            let changeString = String(Int(todayArr[1])!)
            
            guard let monthIndex = monthList.firstIndex(of: changeString) else { return }
            guard let dayIndex = dayList.firstIndex(of: todayArr[2]) else { return }
            
            viewModel.year = yearList[0]
            viewModel.month = String(monthIndex + 1)
            viewModel.day = String(dayIndex + 1)
            
            birthPicker.selectRow(monthIndex, inComponent: 1, animated: false)
            birthPicker.selectRow(dayIndex, inComponent: 2, animated: false)
        } else {
            birthPicker.selectRow((Int(viewModel.month) ?? 0) - 1, inComponent: 1, animated: false)
            birthPicker.selectRow((Int(viewModel.day) ?? 0) - 1, inComponent: 2, animated: false)
        }
    }

    // MARK: - Actions
    @objc func didSelectOkButton(_ sender: UIButton) {
        coordinator?.didSelectBirth()
        closeAnimation()
    }
    
    @objc func didSelectBackView(_ sender: Any) {
        viewModel.year = beforeYear
        viewModel.month = beforeMonth
        viewModel.day = beforeDay
        closeAnimation()
    }
    
    @objc func didSelectTouchView(_ sender: Any) {
        self.alertView.endEditing(true)
    }
}

// MARK: - Animation
extension LoginBirthSelectViewController {
    func animateView() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .showHideTransitionViews) {
            self.alertViewHeightAnchor?.update(offset: self.view.frame.height / 2)
            
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.okButton.isHidden = false
        }
    }
    
    func closeAnimation() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .showHideTransitionViews) {
            self.okButton.isHidden = true
            
            self.alertViewHeightAnchor?.update(offset: 0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension LoginBirthSelectViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return yearList.count
        case 1:
            return monthList.count
        case 2:
            return dayList.count
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension LoginBirthSelectViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ViewValues.componentPickerWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return ViewValues.componentPickerHight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        lazy var textLabel: UILabel = {
            let label = UILabel(frame: CGRect(
                x: 10,
                y: 0,
                width: ViewValues.componentPickerWidth - 20,
                height: ViewValues.componentPickerHight))
            label.textAlignment = .center
            label.textColor = .black
            label.font = UIFont.customFont(forTextStyle: .callout, weight: .regular)
            label.layer.transform = CATransform3DIdentity
            return label
        }()
        
        switch component {
        case 0:
            textLabel.text = yearList[row]
        case 1:
            textLabel.text = monthList[row]
        case 2:
            textLabel.text = dayList[row]
        default:
            break
        }
        return textLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            changeYearPickerSelectRow(row: row)
        case 1:
            changeMonthPickerSelectRow(row: row)
        case 2:
            changeDayPickerSelectRow(row: row)
        default:
            break
        }
    }
    
    private func changeYearPickerSelectRow(row: Int) {
        viewModel.year = yearList[row]
        
        self.birthPicker.selectRow(
            viewModel.changeMonthState(),
            inComponent: 2,
            animated: true)
    }
    
    private func changeMonthPickerSelectRow(row: Int) {
        viewModel.month = monthList[row]
        
        self.birthPicker.selectRow(
            viewModel.changeMonthState(),
            inComponent: 2,
            animated: true)
    }
    
    private func changeDayPickerSelectRow(row: Int) {
        viewModel.day = dayList[row]
        
        self.birthPicker.selectRow(
            viewModel.changeMonthState(),
            inComponent: 2,
            animated: true)
    }
}
