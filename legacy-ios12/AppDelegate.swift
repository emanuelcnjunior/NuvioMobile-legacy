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

final class HomeViewController: UITableViewController, UITextFieldDelegate {
    private let savedKey = "nuvio.legacy.saved.urls"
    private let sampleURL = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
    private let field = UITextField()
    private var saved: [String] = []
    private var sampleRows: [(String, String)] {
        return [("Apple HLS • vídeo de teste", sampleURL)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuvio Legacy"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.09, green: 0.11, blue: 0.18, alpha: 1)
        tableView.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.13, alpha: 1)
        tableView.separatorColor = .darkGray
        tableView.rowHeight = 64
        saved = UserDefaults.standard.stringArray(forKey: savedKey) ?? []
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sobre", style: .plain, target: self, action: #selector(about))
        buildHeader()
    }

    private func buildHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 170))
        let message = UILabel()
        message.text = "Nuvio Legacy 0.2.0\nPlayer HLS para iOS 12.5.8"
        message.numberOfLines = 2
        message.textColor = .white
        message.font = .boldSystemFont(ofSize: 21)
        message.textAlignment = .center
        field.placeholder = "Cole uma URL MP4 ou HLS"
        field.borderStyle = .roundedRect
        field.keyboardType = .URL
        field.returnKeyType = .go
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.delegate = self
        field.accessibilityLabel = "Endereço do vídeo"
        let playButton = UIButton(type: .system)
        playButton.setTitle("Reproduzir URL", for: .normal)
        playButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        playButton.addTarget(self, action: #selector(playEntered), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [message, field, playButton])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20)
        ])
        tableView.tableHeaderView = header
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return section == 0 ? "Demonstração" : "Endereços salvos"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? sampleRows.count : saved.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.19, alpha: 1)
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .lightGray
        cell.detailTextLabel?.lineBreakMode = .byTruncatingMiddle
        cell.accessoryType = .disclosureIndicator
        if indexPath.section == 0 {
            cell.textLabel?.text = sampleRows[indexPath.row].0
            cell.detailTextLabel?.text = sampleRows[indexPath.row].1
        } else {
            cell.textLabel?.text = "Vídeo salvo \(indexPath.row + 1)"
            cell.detailTextLabel?.text = saved[indexPath.row]
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        play(indexPath.section == 0 ? sampleRows[indexPath.row].1 : saved[indexPath.row])
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 && editingStyle == .delete else { return }
        saved.remove(at: indexPath.row)
        UserDefaults.standard.set(saved, forKey: savedKey)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    @objc private func playEntered() {
        let raw = field.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let url = URL(string: raw), ["https", "http"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else {
            alert("Endereço inválido", "Informe uma URL HTTP(S) válida.")
            return
        }
        if !saved.contains(raw) {
            saved.insert(raw, at: 0)
            if saved.count > 30 { saved = Array(saved.prefix(30)) }
            UserDefaults.standard.set(saved, forKey: savedKey)
            tableView.reloadData()
        }
        play(raw)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        playEntered()
        return true
    }
    private func play(_ raw: String) {
        guard let url = URL(string: raw) else { return }
        field.resignFirstResponder()
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        present(controller, animated: true) { controller.player?.play() }
    }
    @objc private func about() {
        alert("Nuvio Legacy 0.2.0", "Protótipo nativo UIKit para iOS 12.5.8. HLS validado no iPad Air 1. Catálogo e extensões do Nuvio ainda não estão integrados.")
    }
    private func alert(_ title: String, _ detail: String) {
        let alert = UIAlertController(title: title, message: detail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
