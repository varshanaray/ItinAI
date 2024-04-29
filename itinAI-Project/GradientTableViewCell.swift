// Project: itinAI-Final
// EID: ezy78, gkk298, esa549, vn4597
// Course: CS371L
import UIKit

class GradientTableViewCell: UITableViewCell {
    
    private let gradientLayer = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.orange.withAlphaComponent(0.6).cgColor,
            UIColor.orange.withAlphaComponent(0.4).cgColor,
            UIColor.orange.withAlphaComponent(0.2).cgColor,
            UIColor.orange.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
}

