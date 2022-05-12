//
//  ViewController.swift
//  BlurMaker
//
//  Created by 许浩渊 on 2022/5/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import DynamicBlurView

class ViewController: UIViewController {

    private let slider = UISlider()

    private let imageView = UIImageView(image: UIImage(named: "image0"))
    private let blurView = DynamicBlurView(frame: .zero)
    private let disposeBag = DisposeBag()

    private lazy var progressBarItem = UIBarButtonItem(customView: slider)

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        navigationController?.setNavigationBarHidden(true, animated: true)

        setToolbarItems([progressBarItem], animated: false)
        navigationController?.setToolbarHidden(false, animated: true)

        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        slider.minimumValue = 0
        slider.maximumValue = 100
    }

    private func makeUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(imageView)
        view.addSubview(blurView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        blurView.isDeepRendering = true
    }

    @objc private func valueChanged() {
        blurView.blurRadius = CGFloat(slider.value)
    }
}

