//
//  SystemBlurCell.swift
//  BlurMaker
//
//  Created by 许浩渊 on 2022/5/12.
//

import UIKit
import TextAttributes
import XHYCategories

class SystemBlurCell: UICollectionViewCell {

    var selectStyle: UIBlurEffect.Style = .regular {
        didSet {
            selectHandler?(selectStyle)
        }
    }
    var selectHandler: SingleHandler<UIBlurEffect.Style>?

    private lazy var pickView: UIPickerView = {
        let pickView = UIPickerView()
        pickView.delegate = self
        pickView.dataSource = self
        return pickView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(pickView)
        pickView.snp.makeConstraints { make in
            make.leading.equalTo(18)
            make.trailing.equalTo(-18)
            make.bottom.equalTo(-6)
            make.top.equalTo(6)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SystemBlurCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UIBlurEffect.Style.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = UIBlurEffect.Style.allCases[row].name
        let attributedText = NSAttributedString(string: text, attributes: TextAttributes().font(UIFont.systemFont(ofSize: 16, weight: .bold)).foregroundColor(UIColor.white).alignment(.center).dictionary)
        return attributedText

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectStyle = UIBlurEffect.Style.allCases[row]
    }
}

extension UIBlurEffect.Style: CaseIterable {

    public var name: String {
        switch self {
        case .extraLight:
            return "extraLight"
        case .light:
            return "light"
        case .dark:
            return "dark"
        case .regular:
            return "regular"
        case .prominent:
            return "prominent"
        case .systemUltraThinMaterial:
            return "systemUltraThinMaterial"
        case .systemThinMaterial:
            return "systemThinMaterial"
        case .systemMaterial:
            return "systemThinMaterial"
        case .systemThickMaterial:
            return "systemThickMaterial"
        case .systemChromeMaterial:
            return "systemChromeMaterial"
        case .systemUltraThinMaterialLight:
            return "systemUltraThinMaterialLight"
        case .systemThinMaterialLight:
            return "systemThinMaterialLight"
        case .systemMaterialLight:
            return "systemMaterialLight"
        case .systemThickMaterialLight:
            return "systemThickMaterialLight"
        case .systemChromeMaterialLight:
            return "systemChromeMaterialLight"
        case .systemUltraThinMaterialDark:
            return "systemThinMaterialDark"
        case .systemThinMaterialDark:
            return "systemThinMaterialDark"
        case .systemMaterialDark:
            return "systemMaterialDark"
        case .systemThickMaterialDark:
            return "systemThickMaterialDark"
        case .systemChromeMaterialDark:
            return "systemChromeMaterialDark"
        @unknown default:
            return ""
        }
    }


    public static var allCases: [UIBlurEffect.Style] {
        var cases: [UIBlurEffect.Style] = [
            .light,
            .dark,
            .regular,
            .prominent,
            .extraLight
        ]
        if #available(iOS 13.0, *) {
            cases.append(contentsOf: [
                .systemUltraThinMaterial,
                .systemThinMaterial,
                .systemMaterial,
                .systemThickMaterial,
                .systemChromeMaterial,
                .systemUltraThinMaterialLight,
                .systemThinMaterialLight,
                .systemMaterialLight,
                .systemThickMaterialLight,
                .systemChromeMaterialLight,
                .systemUltraThinMaterialDark,
                .systemThinMaterialDark,
                .systemMaterialDark,
                .systemThickMaterialDark,
                .systemChromeMaterialDark

            ])
        }
        return cases
    }
}
