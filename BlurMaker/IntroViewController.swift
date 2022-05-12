import UIKit
import AVFoundation
import Photos
import SnapKit
import XHYCategories

class IntroViewController: UIViewController {


    private var photosButton = Button(imageName: "photo", name: "相册")
    private var cameraButton = Button(imageName: "camera", name: "相机")

    private lazy var stackView = UIStackView(arrangedSubviews: [photosButton, cameraButton])

    private lazy var previewView = UILabel(text: "Blur", font: UIFont(name: "Noteworthy-Light", size: 120) ?? .systemFont(ofSize: 12), color: UIColor.white, alignment: .center)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private lazy var backgroundImage: UIImageView = {
        return UIImageView(image: UIImage(named: "image1"))
    }()

    override func viewDidLoad() {

        makeUI()
        detectUserActions()
    }

    private func makeUI() {
        view.backgroundColor = UIColor.black

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 18

        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(previewView)
        previewView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.snp.centerY).multipliedBy(0.5)
        }

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        photosButton.alpha = 0
        cameraButton.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseOut) { [weak self] in
            self?.photosButton.alpha = 1
        } completion: { _ in

        }

        UIView.animate(withDuration: 1, delay: 0.4, options: .curveEaseOut) { [weak self] in
            self?.cameraButton.alpha = 1
        } completion: { _ in

        }
    }

    private func detectUserActions() {
        cameraButton.addTarget(self, action: #selector(cameraButtonTouched), for: UIControl.Event.touchUpInside)
        photosButton.addTarget(self, action: #selector(photosButtonTouched), for: UIControl.Event.touchUpInside)
    }

    @objc private func randomButtonTouched() {

//        let vc = MyPicLIstViewController()
//        let navi = UINavigationController(rootViewController: vc)
//        navi.modalPresentationStyle = .fullScreen
//        present(navi, animated: true, completion: nil)

    }

    @objc private func cameraButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.camera
        displayMediaPicker(sourceType: sourceType)
    }

    @objc private func photosButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        displayMediaPicker(sourceType: sourceType)
    }
}

extension IntroViewController {

    func displayMediaPicker(sourceType: UIImagePickerController.SourceType) {

        let usingCamera = sourceType == .camera
        let media = usingCamera ? "Camera" : "Photos"

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let noPermissionTitle = "Access to your \'\(media)\' denied"
            let noPermissionMessage = "\nGo to \'Settings\' to allow the access."

            if usingCamera {
                actionAccordingTo(status: AVCaptureDevice.authorizationStatus(for: AVMediaType.video),
                                  noPermissionTitle: noPermissionTitle,
                                  noPermissionMessage: noPermissionMessage)
            } else {
                actionAccordingTo(status: PHPhotoLibrary.authorizationStatus(),
                                  noPermissionTitle: noPermissionTitle,
                                  noPermissionMessage: noPermissionMessage)
            }
        } else {
            let title = "\'\(media)\' unavailable"
            let message = "cannot have acces to your \'\(media)\' at this time."
            troubleAlert(title: title, message: message)
        }
    }

    func actionAccordingTo(status: AVAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.camera
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) {
                self.checkAuthorizationAccess(granted: $0,
                                              sourceType: sourceType,
                                              noPermissionTitle: noPermissionTitle,
                                              noPermissionMessage: noPermissionMessage)
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        @unknown default:
            fatalError()
        }
    }

    func actionAccordingTo(status: PHAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.checkAuthorizationAccess(granted: status == .authorized,
                                                  sourceType: sourceType,
                                                  noPermissionTitle: noPermissionTitle,
                                                  noPermissionMessage: noPermissionMessage)
                }
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        case .limited:
            self.presentImagePicker(sourceType: sourceType)
        @unknown default:
            fatalError()
        }
    }

    func checkAuthorizationAccess(granted: Bool,
                                  sourceType: UIImagePickerController.SourceType,
                                  noPermissionTitle: String?,
                                  noPermissionMessage: String?) {
        if granted {
            self.presentImagePicker(sourceType: sourceType)
        } else {
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        }
    }

    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.modalPresentationStyle = .fullScreen
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }


    func openSettingsWithUIAlert(title: String?, message: String?) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) {
            _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }


    func troubleAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

extension IntroViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true, completion: nil)

        var image: UIImage?

        if picker.allowsEditing {
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        } else {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        if let image = image {
            let vc = EditImageViewController(image: image)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
