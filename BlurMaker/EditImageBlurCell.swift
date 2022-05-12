//
//  EditImageBlurCell.swift
//  BlurMaker
//
//  Created by 许浩渊 on 2022/5/11.
//

import UIKit
import XHYCategories
class EditImageBlurCell: UICollectionViewCell {


    var valueHandler: SingleHandler<CGFloat>?

    private let slider = UISlider(frame: .zero)

    private let label = UILabel(text: "拖动滑块改变毛玻璃效果", font: UIFont.systemFont(ofSize: 16, weight: .bold), color: UIColor.white, alignment: .center)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentView.addSubview(slider)
        contentView.addSubview(label)
        slider.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.leading.equalTo(18)
            make.trailing.equalTo(-18)
        }
        slider.addTarget(self, action: #selector(valueChange), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 100

        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset(6)
        }
    }

    @objc func valueChange() {
        valueHandler?(CGFloat(slider.value))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
