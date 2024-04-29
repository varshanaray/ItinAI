// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(with urlString: String, placeholder: UIImage? = UIImage(named: "placeholder"), fallbackImage: UIImage? = UIImage(named: "defaultImage")) {

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            self.image = fallbackImage
            return
        }
        
        let processor = DefaultImageProcessor()
        
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2)), .fromMemoryCacheOrRefresh],
            completionHandler: { [weak self] result in
                switch result {
                case .success(let value):
                    print("Image loaded successfully")
                    //print("image URL: \(url)")
                case .failure(let error):
                    print("Failed to load image")
                    //print("used fallback image for url: \(url)")
                    self?.image = fallbackImage
                }
            }
        )
    }
}
