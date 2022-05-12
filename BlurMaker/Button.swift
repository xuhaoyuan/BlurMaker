//
//  Button.swift
//  Gridy
//
//  Created by Spencer Forrest on 28/03/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class Button: UIControl {

    private let imageView = UIImageView()
    private let label = UILabel()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    init(imageName: String, name: String) {
        super.init(frame: .zero)
        imageView.image = UIImage(named: imageName)
        label.text = name
        label.textColor = UIColor(r: 70, g: 70, b: 70)
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        backgroundColor = UIColor.clear
        let stackView = UIStackView(subviews: [imageView, label], axis: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 6)
        addSubview(stackView)
        stackView.isUserInteractionEnabled = false
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
