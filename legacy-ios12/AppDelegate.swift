import UIKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
final class HomeViewController: UIViewController {
    private let urlField = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuvio Legacy"
        view.backgroundColor = UIColor(red: 0.07, green: 0.09, blue: 0.14, alpha: 1)
        let heading = UILabel()
        heading.text = "Nuvio Legacy • iOS 12"
        heading.textColor = .white
        heading.font = .boldSystemFont(ofSize: 26)
        heading.textAlignment = .center
        heading.numberOfLines = 0
        let note = UILabel()
        note.text = "Versão experimental para iPad Air 1. Reproduza um vídeo próprio em MP4 ou HLS."
        note.textColor = .lightGray
        note.numberOfLines = 0
        note.textAlignment = .center
        urlField.placeholder = "https://exemplo.com/video.m3u8"
        urlField.borderStyle = .roundedRect
        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no
        urlField.returnKeyType = .done
        let button = UIButton(type: .system)
        button.setTitle("Reproduzir", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(play), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [heading, note, urlField, button])
        stack.axis = .vertical
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    @objc private func play() {
        guard let raw = urlField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let url = URL(string: raw),
              ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
            let alert = UIAlertController(title: "URL inválida", message: "Informe um endereço HTTP(S) de vídeo MP4 ou HLS.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        urlField.resignFirstResponder()
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        present(playerVC, animated: true) { playerVC.player?.play() }
    }
}
