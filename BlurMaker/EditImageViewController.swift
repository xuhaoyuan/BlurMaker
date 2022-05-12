import UIKit
import XHYCategories
import DynamicBlurView
import ZLPhotoBrowser
import SwiftEntryKit

let H_00BF3C = #colorLiteral(red: 0, green: 0.7490196078, blue: 0.2352941176, alpha: 1)

public class EditImageViewController: UIViewController {

    static let maxDrawLineImageWidth: CGFloat = 600
    private var drawPaths: [ZLDrawPath] = []

    var animate = false
    
    var originalImage: UIImage
    
    // 第一次进入界面时，布局后frame，裁剪dimiss动画使用
    var originalFrame: CGRect = .zero
    
    // 图片可编辑rect
    var editRect: CGRect

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.clipsToBounds = true
        return containerView
    }()
    
    // Show image.
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: self.originalImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()
    
    private var blurContainer: DynamicBlurView = DynamicBlurView()
    private var blurMaskLayer: CAShapeLayer = CAShapeLayer()

    private var systemBlurView = UIVisualEffectView()
    
    private lazy var topShadowView: UIView = {
        let view = UIView()
        view.layer.addSublayer(self.topShadowLayer)
        return view
    }()
    
    private var topShadowLayer: CAGradientLayer = {
        let color1 = UIColor.black.withAlphaComponent(0.5).cgColor
        let color2 = UIColor.black.withAlphaComponent(0).cgColor
        let topShadowLayer = CAGradientLayer()
        topShadowLayer.colors = [color1, color2]
        topShadowLayer.locations = [0, 1]
        return topShadowLayer
    }()

    private lazy var bottomShadowView: UIView = {
        let view = UIView()
        view.layer.addSublayer(bottomShadowLayer)
        return view
    }()
    
    private var bottomShadowLayer: CAGradientLayer = {
        let color1 = UIColor.black.withAlphaComponent(0.5).cgColor
        let color2 = UIColor.black.withAlphaComponent(0).cgColor
        let bottomShadowLayer = CAGradientLayer()
        bottomShadowLayer.colors = [color2, color1]
        bottomShadowLayer.locations = [0, 1]
        return bottomShadowLayer
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.registerCell(EditImageBlurCell.self)
        collectionView.registerCell(EditImageDrawCell.self)
        collectionView.registerCell(SystemBlurCell.self)
        return collectionView
    }()

    var selectedTool: Section? {
        didSet {
            guard selectedTool != oldValue else { return }
            guard let tool = selectedTool else { return }
            switch tool {
            case .blur:
                titleLabel.text = "自定义Blur"
                blurContainer.isHidden = false
                systemBlurView.isHidden = true
            case .system:
                titleLabel.text = "系统Blur"
                blurContainer.isHidden = true
                systemBlurView.isHidden = false
                guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: tool.rawValue)) as? SystemBlurCell else { return }
                systemBlurView.effect = UIBlurEffect(style: cell.selectStyle)
            }
        }
    }

    private var titleLabel: UILabel = {
        let label = UILabel(font: UIFont.systemFont(ofSize: 18, weight: .bold), color: UIColor.white, alignment: .center)
        return label
    }()

    private var saveButton: UIButton = {
        let button = UIButton(title: "保存", titleColor: .white, font: UIFont.systemFont(ofSize: 15, weight: .regular), bgColor: H_00BF3C, edge: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), cornerRadius: 4)
        return button
    }()

    private var chooseButton: UIButton = {
        let button = UIButton(title: "取消", titleColor: .white, font: UIFont.systemFont(ofSize: 15, weight: .regular), bgColor: UIColor.orange, edge: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), cornerRadius: 4)
        return button
    }()

    

    var drawLineWidth: CGFloat = 5

    var mosaicLineWidth: CGFloat = 10

    var mosaicPaths: [ZLMosaicPath] = []

    var isScrolling = false
    
    var shouldLayout = true
    
    var imageStickerContainerIsHidden = true
    
    var angle: CGFloat
    
    var panGes: UIPanGestureRecognizer!
    
    var imageSize: CGSize {
        if self.angle == -90 || self.angle == -270 {
            return CGSize(width: self.originalImage.size.height, height: self.originalImage.size.width)
        }
        return self.originalImage.size
    }
    
    @objc public var editFinishBlock: ( (UIImage, ZLEditImageModel?) -> Void )?
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc public init(image: UIImage, editModel: ZLEditImageModel? = nil) {
        self.originalImage = image
        self.editRect = editModel?.editRect ?? CGRect(origin: .zero, size: image.size)
        self.angle = editModel?.angle ?? 0
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.rotationImageView()

        selectedTool = .blur
    }

    private var isFirstDidAppear = true
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstDidAppear else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: Section.system.rawValue), at: .centeredHorizontally, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: Section.blur.rawValue), at: .centeredHorizontally, animated: true)

            }
        }

        isFirstDidAppear = false
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.topShadowLayer.frame = self.topShadowView.bounds
        self.bottomShadowLayer.frame = self.bottomShadowView.bounds

        guard self.shouldLayout else {
            return
        }
        self.shouldLayout = false

        self.scrollView.frame = self.view.bounds
        self.resetContainerViewFrame()

    }

    func resetContainerViewFrame() {
        self.scrollView.setZoomScale(1, animated: true)

        let editSize = self.editRect.size
        let scrollViewSize = self.scrollView.frame.size
        let ratio = min(scrollViewSize.width / editSize.width, scrollViewSize.height / editSize.height)
        let w = ratio * editSize.width * self.scrollView.zoomScale
        let h = ratio * editSize.height * self.scrollView.zoomScale
        self.containerView.frame = CGRect(x: max(0, (scrollViewSize.width-w)/2), y: max(0, (scrollViewSize.height-h)/2), width: w, height: h)
        
        let scaleImageOrigin = CGPoint(x: -self.editRect.origin.x*ratio, y: -self.editRect.origin.y*ratio)
        let scaleImageSize = CGSize(width: self.imageSize.width * ratio, height: self.imageSize.height * ratio)
        self.imageView.frame = CGRect(origin: scaleImageOrigin, size: scaleImageSize)
        self.blurMaskLayer.frame = self.imageView.bounds

        // 针对于长图的优化
        if (self.editRect.height / self.editRect.width) > (self.view.frame.height / self.view.frame.width * 1.1) {
            let widthScale = self.view.frame.width / w
            self.scrollView.maximumZoomScale = widthScale
            self.scrollView.zoomScale = widthScale
            self.scrollView.contentOffset = .zero
        } else if self.editRect.width / self.editRect.height > 1 {
            self.scrollView.maximumZoomScale = max(3, self.view.frame.height / h)
        }
        
        self.originalFrame = self.view.convert(self.containerView.frame, from: self.scrollView)
        self.isScrolling = false
    }
    
    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(imageView)
        imageView.addSubview(blurContainer)
        imageView.addSubview(systemBlurView)

        blurContainer.isDeepRendering = true
//        blurContainer.layer.mask = blurMaskLayer
        blurMaskLayer.strokeColor = UIColor.clear.cgColor
        blurMaskLayer.fillColor = UIColor.blue.cgColor
        blurMaskLayer.lineCap = .round
        blurMaskLayer.lineJoin = .round

        blurContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        systemBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(topShadowView)
        view.addSubview(bottomShadowView)

        topShadowView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        bottomShadowView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        bottomShadowView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(100)
            make.bottom.equalTo(bottomShadowView.safeAreaLayoutGuide.snp.bottom).offset(-36)
        }

        topShadowView.addSubview(titleLabel)
        topShadowView.addSubview(chooseButton)
        topShadowView.addSubview(saveButton)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-12)
            make.height.equalTo(32)
            make.top.equalTo(topShadowView.safeAreaLayoutGuide.snp.top).offset(12)
        }

        chooseButton.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }

        saveButton.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalTo(titleLabel)
        }

        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGes.delegate = self
        view.addGestureRecognizer(tapGes)

        chooseButton.addTarget(self, action: #selector(chooseBtnClick), for: .touchUpInside)

        saveButton.addTarget(self, action: #selector(doneBtnClick), for: .touchUpInside)

        
//        panGes = UIPanGestureRecognizer(target: self, action: #selector(drawAction(_:)))
//        panGes.maximumNumberOfTouches = 1
//        panGes.delegate = self
//        view.addGestureRecognizer(self.panGes)
//        scrollView.panGestureRecognizer.require(toFail: self.panGes)
    }
    
    private func rotationImageView() {
        let transform = CGAffineTransform(rotationAngle: self.angle.toPi)
        self.imageView.transform = transform
    }

    @objc private func chooseBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func doneBtnClick() {
        guard let selectedTool = self.selectedTool else { return }
        var image: UIImage?
        switch selectedTool {
        case .system:
            guard let defimage = self.imageView.image else { return }
            UIGraphicsBeginImageContextWithOptions(defimage.size, false, defimage.scale)
            imageView.drawHierarchy(in: CGRect(origin: .zero, size: defimage.size), afterScreenUpdates: true)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        case .blur:
            image = blurContainer.screenShot() ?? imageView.image
        }
        guard let tmpImage = image else { return }
        let vc = ZLEditImageViewController(image: tmpImage, editModel: nil)
        vc.editFinishBlock = { [weak self] (ei, editImageModel) in
            guard let self = self else { return }
            UIImageWriteToSavedPhotosAlbum(ei, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: animate, completion: nil)
    }

    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        if self.bottomShadowView.alpha == 1 {
            self.setToolView(show: false)
        } else {
            self.setToolView(show: true)
        }
    }
    
    private func setToolView(show: Bool) {
        self.topShadowView.layer.removeAllAnimations()
        self.bottomShadowView.layer.removeAllAnimations()
        if show {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 1
                self.bottomShadowView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.topShadowView.alpha = 0
                self.bottomShadowView.alpha = 0
            }
        }
    }

    @objc private func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        showNote()
    }

    // Bumps a standard note
    private func showNote() {
        let text = "保存相册成功！"
        let style = EKProperty.LabelStyle(
            font: UIFont.systemFont(ofSize: 16, weight: .regular),
            color: .white,
            alignment: .center
        )
        let labelContent = EKProperty.LabelContent(
            text: text,
            style: style
        )
        let contentView = EKNoteMessageView(with: labelContent)
        contentView.backgroundColor = H_00BF3C
        SwiftEntryKit.display(entry: contentView, using: .topToast)
    }

    private func showProcessingNote() {
        let text = "Waiting for the goodies to arrive!"
        let style = EKProperty.LabelStyle(
            font: UIFont.systemFont(ofSize: 16, weight: .regular),
            color: .white,
            alignment: .center,
            displayMode: .light
        )
        let labelContent = EKProperty.LabelContent(
            text: text,
            style: style
        )
        let contentView = EKProcessingNoteMessageView(
            with: labelContent,
            activityIndicator: .white
        )
        SwiftEntryKit.display(entry: contentView, using: .topNote)
    }

//    private func generateNewMosaicImage() {
//        UIGraphicsBeginImageContextWithOptions(self.originalImage.size, false, self.originalImage.scale)
//        self.originalImage.draw(at: .zero)
//        let context = UIGraphicsGetCurrentContext()
//
//        self.mosaicPaths.forEach { (path) in
//            context?.move(to: path.startPoint)
//            path.linePoints.forEach { (point) in
//                context?.addLine(to: point)
//            }
//            context?.setLineWidth(path.path.lineWidth / path.ratio)
//            context?.setLineCap(.round)
//            context?.setLineJoin(.round)
//            context?.setBlendMode(.clear)
//            context?.strokePath()
//        }
//
//        var midImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        guard let midCgImage = midImage?.cgImage else {
//            return
//        }
//
//        midImage = UIImage(cgImage: midCgImage, scale: self.editImage.scale, orientation: .up)
//
//        UIGraphicsBeginImageContextWithOptions(self.originalImage.size, false, self.originalImage.scale)
//        self.mosaicImage?.draw(at: .zero)
//        midImage?.draw(at: .zero)
//
//        let temp = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        guard let cgi = temp?.cgImage else {
//            return
//        }
//        let image = UIImage(cgImage: cgi, scale: self.editImage.scale, orientation: .up)
//
//        self.editImage = image
//        self.imageView.image = self.editImage
//
//        self.blurMaskLayer.path = nil
//    }
}


extension EditImageViewController: UIGestureRecognizerDelegate {
    
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard self.imageStickerContainerIsHidden else {
//            return false
//        }
//        if gestureRecognizer is UITapGestureRecognizer {
//            if self.bottomShadowView.alpha == 1 {
//                let p = gestureRecognizer.location(in: self.view)
//                return !self.bottomShadowView.frame.contains(p)
//            } else {
//                return true
//            }
//        } else if gestureRecognizer is UIPanGestureRecognizer {
//            guard let st = self.selectedTool else {
//                return false
//            }
//            return !self.isScrolling
//        }
//        return true
//    }
//
}

extension EditImageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum Section: Int, CaseIterable {
        case blur
        case system
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        switch section {
        case .blur:
            let cell: EditImageBlurCell = collectionView.dequeueReusableCell(indexPath)
            cell.valueHandler = { [weak self] value in
                self?.blurContainer.blurRadius = value
            }
            return cell
        case .system:
            let cell: SystemBlurCell = collectionView.dequeueReusableCell(indexPath)
            cell.selectHandler = { [weak self] style in
                self?.systemBlurView.effect = UIBlurEffect(style: style)
            }
            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}


// MARK: scroll view delegate
extension EditImageViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        self.containerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.isScrolling = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case self.scrollView:
            self.isScrolling = true
        case collectionView:
            let offset = scrollView.contentOffset
            let index: CGFloat = (offset.x + scrollView.bounds.width/2)/scrollView.bounds.width
            self.selectedTool = Section(rawValue: Int(index))
        default:
            break
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        switch scrollView {
        case self.scrollView:
            self.isScrolling = decelerate
        case collectionView:
            break
        default:
            break
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch scrollView {
        case self.scrollView:
            self.isScrolling = false
        case collectionView:
            break
        default:
            break
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        switch scrollView {
        case self.scrollView:
            self.isScrolling = false
        case collectionView:
            break
        default:
            break
        }
    }
}

extension CGFloat {

    var toPi: CGFloat {
        return self / 180 * .pi
    }

}
