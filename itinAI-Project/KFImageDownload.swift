import UIKit
import Kingfisher


extension UIImageView {
    
    func setImage(with urlString: String, placeholder: UIImage? = UIImage(named: "placeholder"), fallbackImage: UIImage? = UIImage(named: "defaultImage")) {

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            self.image = fallbackImage
            return
        }


        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2)), .cacheOriginalImage],
            completionHandler: { [weak self] result in
                switch result {
                case .success(let value):
                    print("Image loaded successfully from \(value.cacheType)")
                case .failure(let error):
                    print("Failed to load image: \(error)")
                    self?.image = fallbackImage
                }
            }
        )
    }
}
