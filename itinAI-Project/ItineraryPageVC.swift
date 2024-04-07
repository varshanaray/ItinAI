//
//  itineraryPageVC.swift
//  itinAI-Project
//
//  Created by Eric Yang on 4/1/24.
//

import UIKit
import FirebaseFirestore

class ItineraryPageVC: UIViewController {

    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainContentView: UIView!
    
    var itineraryDays: [ItineraryDay] = [] // Populate this array from Firestore
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchItineraryData { [weak self] in
            self?.populateScrollView()
        }
    }
    
    
    func fetchItineraryData(completion: @escaping () -> Void) {
        // Fetch your itinerary data from Firestore and populate the itineraryDays array
        // Call completion() after data is fetched and array is populated
    }
    
    func populateScrollView() {
        var yOffset: CGFloat = 10
        for day in itineraryDays {
            let block = createItineraryBlock(for: day, yOffset: yOffset)
            scrollView.addSubview(block)
            yOffset += block.frame.height + 10 // Adjust spacing between blocks
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yOffset)
    }
    
    func createItineraryBlock(for day: ItineraryDay, yOffset: CGFloat) -> UIView {
        let blockView = UIView(frame: CGRect(x: 0, y: yOffset, width: scrollView.frame.width, height: 200)) // Adjust height as needed
        
        let dayLabel = UILabel(frame: CGRect(x: 10, y: 10, width: blockView.frame.width - 20, height: 20))
        dayLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dayLabel.text = "Day \(day.dayNumber)"
        blockView.addSubview(dayLabel)
        
        let dateLabel = UILabel(frame: CGRect(x: 10, y: 40, width: blockView.frame.width - 20, height: 20))
        dateLabel.text = day.date
        blockView.addSubview(dateLabel)
        
        let contentView = UITextView(frame: CGRect(x: 10, y: 70, width: blockView.frame.width - 20, height: 120))
        contentView.text = day.content.joined(separator: "\n")
        contentView.isEditable = true // Adjust based on your requirements
        blockView.addSubview(contentView)
        
        return blockView
    }
    
}
