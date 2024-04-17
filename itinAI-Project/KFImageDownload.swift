import UIKit
import Kingfisher


extension UIImageView {
    
    func setImage(with urlString: String, placeholder: UIImage? = UIImage(named: "placeholder"), fallbackImage: UIImage? = UIImage(named: "defaultImage")) {

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            self.image = fallbackImage
            return
        }
        
        /*
        let downloader = ImageDownloader.default
        
        downloader.downloadImage(with: url) { result in
            switch result {
                case .success(let value):
                print(value.image)
            case .failure(let error):
                print(error)
            }
        }*/
        
        let processor = DefaultImageProcessor()
        
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2)), .fromMemoryCacheOrRefresh],
            completionHandler: { [weak self] result in
                switch result {
                case .success(let value):
                    print("Image loaded successfully from \(value.cacheType)")
                    print("image URL: \(url)")
                case .failure(let error):
                    print("Failed to load image: \(error)")
                    print("used fallback image for url: \(url)")
                    self?.image = fallbackImage
                }
            }
        )
        
        
    }
}
