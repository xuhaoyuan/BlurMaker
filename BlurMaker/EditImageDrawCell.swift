//
//  EditImageDrawCell.swift
//  BlurMaker
//
//  Created by 许浩渊 on 2022/5/11.
//

import UIKit
import XHYCategories

class EditImageDrawCell: UICollectionViewCell {

    var valueHandler: SingleHandler<CGFloat>?

    private let slider = UISlider(frame: .zero)

    private let label = UILabel(text: "拖动滑块改变画笔大小", font: UIFont.systemFont(ofSize: 16, weight: .bold), color: UIColor.white, alignment: .center)

    private let circleView = UIView()

    private let minimumValue: Float = 10.0
    private let maximumValue: Float = 40.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        circleView.backgroundColor = UIColor.white
        contentView.addSubview(slider)
        contentView.addSubview(circleView)
        contentView.addSubview(label)
        slider.snp.makeConstraints { make in
            make.top.equalTo(6)
            let l = maximumValue + 6 + 18
            make.leading.equalTo(l)
            make.trailing.equalTo(-18)
        }
        slider.addTarget(self, action: #selector(valueChange), for: .valueChanged)
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue

        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset(6)
        }

        circleView.snp.makeConstraints { make in
            make.centerY.equalTo(slider)
            make.centerX.equalTo(contentView.snp.leading).offset(18 + maximumValue/2)
            make.size.equalTo(minimumValue)
        }
        circleView.corner = CGFloat(minimumValue/2)
    }

    @objc func valueChange() {
        valueHandler?(CGFloat(slider.value))

        circleView.snp.updateConstraints { make in
            make.size.equalTo(slider.value)
        }
        circleView.corner = CGFloat(slider.value/2)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
