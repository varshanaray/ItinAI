//
//  SurveyPageVC.swift
//  itinAI-Project
//
//  Created by Erick Albarran on 3/31/24.
//

import UIKit

class SurveyPageVC: UIViewController {
    
    
    var cityName: String?
    var cityId: String?
    var cityImageUrl: String?
    @IBOutlet var topView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In survey page")

        // Do any additional setup after loading the view.
        // Create the label
        let titleLabel = UILabel()
        titleLabel.text = cityName
        titleLabel.font = UIFont.boldSystemFont(ofSize: 35)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Determine the background color's lightness/darkness
        let backgroundColor = backgroundImage.image?.averageColor
        if let backgroundColor = backgroundColor {
            // Determine if the background is light or dark
            let isLightBackground = backgroundColor.isLight
            // Set text color based on background
            titleLabel.textColor = isLightBackground ? .black : .white
        } else {
            // Default text color if background image is not available
            titleLabel.textColor = .white
        }
        
        // Add constraints for the label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
        
        
        // Create the white view
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        // Round the corners
        whiteView.layer.cornerRadius = 20 // Adjust the value as needed
        whiteView.layer.masksToBounds = true // Ensures that the content inside the view respects the corner radius
        view.addSubview(whiteView)
        
        // Add constraints
        NSLayoutConstraint.activate([
            whiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            whiteView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.70)
        ])
        
        // Create UI elements for the first survey question
        let boldLabel1 = UILabel()
        boldLabel1.text = "Any places you're interested in visting?"
        boldLabel1.font = UIFont.boldSystemFont(ofSize: 18)
        boldLabel1.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(boldLabel1)
        
        let detailLabel1 = UILabel()
        detailLabel1.text = "E.g. museums, historical sites, art galleries, landmarks, theme parks, local markets, neighborhoods, etc."
        detailLabel1.textColor = .gray
        detailLabel1.font = UIFont.systemFont(ofSize: 12.0)
        detailLabel1.numberOfLines = 0 // Make it multiline
        detailLabel1.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(detailLabel1)
        
        let textField1 = UITextView()
        textField1.translatesAutoresizingMaskIntoConstraints = false
        textField1.layer.borderColor = UIColor.gray.cgColor // Set border color
        textField1.layer.borderWidth = 1.0 // Set border width
        textField1.layer.cornerRadius = 10 // Set corner radius for rounded corners
        whiteView.addSubview(textField1)
        
        // Add constraints for the first pair of UI elements
        NSLayoutConstraint.activate([
            boldLabel1.topAnchor.constraint(equalTo: whiteView.topAnchor, constant: 20),
            boldLabel1.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor, constant: 20),
            
            detailLabel1.topAnchor.constraint(equalTo: boldLabel1.bottomAnchor, constant: 8),
            detailLabel1.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor, constant: 20),
            detailLabel1.widthAnchor.constraint(equalTo: whiteView.widthAnchor, multiplier: 0.80),
            
            textField1.topAnchor.constraint(equalTo: detailLabel1.bottomAnchor, constant: 8),
            textField1.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor, constant: 20),
            textField1.trailingAnchor.constraint(equalTo: whiteView.trailingAnchor, constant: -20),
            textField1.heightAnchor.constraint(equalToConstant: 120), // Adjust height as needed
        ])
        
        // Create UI elements for the second pair (similar to the first pair)
        // Add constraints for the second pair of UI elements
        // ...
        // Create UI elements for the first survey question
        let boldLabel2 = UILabel()
        boldLabel2.text = "Any types of activities you're interested in?"
        boldLabel2.font = UIFont.boldSystemFont(ofSize: 18)
        boldLabel2.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(boldLabel2)
        
        let detailLabel2 = UILabel()
        detailLabel2.text = "E.g. sightseeing, shopping, hiking, attending shows or concerts, relaxation/spa days, boat rides, etc."
        detailLabel2.textColor = .gray
        detailLabel2.font = UIFont.systemFont(ofSize: 12.0)
        detailLabel2.numberOfLines = 0 // Make it multiline
        detailLabel2.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(detailLabel2)
        
        let textField2 = UITextView()
        textField2.translatesAutoresizingMaskIntoConstraints = false
        textField2.layer.borderColor = UIColor.gray.cgColor // Set border color
        textField2.layer.borderWidth = 1.0 // Set border width
        textField2.layer.cornerRadius = 10 // Set corner radius for rounded corners
        whiteView.addSubview(textField2)
        
        NSLayoutConstraint.activate([
            boldLabel2.topAnchor.constraint(equalTo: textField1.bottomAnchor, constant: 30),
            boldLabel2.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor, constant: 20),
            
            detailLabel2.topAnchor.constraint(equalTo: boldLabel2.bottomAnchor, constant: 8),
            detailLabel2.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor, constant: 20),
            detailLabel2.widthAnchor.constraint(equalTo: whiteView.widthAnchor, multiplier: 0.80),
            
            textField2.topAnchor.constraint(equalTo: detailLabel2.bottomAnchor, constant: 8),
            textField2.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor, constant: 20),
            textField2.trailingAnchor.constraint(equalTo: whiteView.trailingAnchor, constant: -20),
            textField2.heightAnchor.constraint(equalTo: textField1.heightAnchor), // Adjust height as needed
        ])
        
        
        // Add the 'Submit' button
        // Create Submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.backgroundColor = .lightGray
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.black.cgColor
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(submitButton)
        
        // Add constraints for the Submit button
        NSLayoutConstraint.activate([
            submitButton.centerXAnchor.constraint(equalTo: whiteView.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 100), // Adjust width as needed
            submitButton.heightAnchor.constraint(equalToConstant: 50), // Adjust height as needed
            submitButton.topAnchor.constraint(equalTo: textField2.bottomAnchor, constant: 20)
        ])
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.size.width * 0.5, y: inputImage.extent.size.height * 0.5)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: CIVector(cgRect: inputImage.extent)]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        let context = CIContext(options: nil)
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: 1.0)
    }
}

extension UIColor {
    var isLight: Bool {
        guard let components = cgColor.components, components.count >= 3 else { return false }
        let brightness = (components[0] * 299 + components[1] * 587 + components[2] * 114) / 1000
        return brightness > 0.5
    }
}
