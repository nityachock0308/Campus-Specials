//
//  VenueDetailsViewController.swift
//  Places to Eat & Drink on Campus
//
//  Created by Chockalingam, Nitya on 06/12/2024.
//

import UIKit

class VenueDetailsViewController: UIViewController {
    var venue: Venue_Info?
    
   
    @IBOutlet weak var nameLabel: UITextView!
    @IBOutlet weak var buildingLabel: UITextView!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var openingTimesLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let venue = venue {
              nameLabel.text = venue.name
              buildingLabel.text = venue.building
            displayDesciption()
              openingTimesLabel.text = venue.opening_times.joined(separator: ", ")
          }
        
    }
    
    func displayDesciption() {
        if venue!.description.isEmpty {
            descriptionLabel.text = "No description available"
                return
        }
        let descriptionHTML = venue!.description.data(using: .utf8)
        let attributedString = try? NSAttributedString(
            data: descriptionHTML!,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
        descriptionLabel.attributedText = attributedString
    }
    
    // MARK: - Navigation

}
