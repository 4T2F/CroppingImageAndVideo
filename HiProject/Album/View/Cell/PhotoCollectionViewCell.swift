//
//  PhotoCollectionViewCell.swift
//  HiProject
//
//  Created by 노주영 on 6/4/24.
//

import SnapKit

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    // MARK: - Private properties
    private var viewModel = SignUpViewModel()
    
    private lazy var plusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus")
        imageView.tintColor = UIColor(named: "plusCellImageColor")
        return imageView
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
        contentView.backgroundColor = UIColor(named: "gray03")
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(plusImageView)

    }
    
    private func configLayout() {
        plusImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    override func prepareForReuse() {
        contentView.backgroundColor = UIColor(named: "gray03")
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.white.cgColor
        
        plusImageView.tintColor = UIColor(named: "plusCellImageColor")
    }

    // MARK: - Actions
    func setProperties(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
    }
    
    func setCellCustom(item: Int) {
        switch item {
        case 0:
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor(named: "mainColor")?.cgColor
            
            plusImageView.tintColor = UIColor(named: "mainColor")
        default:
            break
        }
    }
}

extension PhotoCollectionViewCell: Reusable { }

