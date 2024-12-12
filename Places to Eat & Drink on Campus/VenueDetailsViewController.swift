//
//  VenueDetailsViewController.swift
//  Places to Eat & Drink on Campus
//
//  Created by Chockalingam, Nitya on 06/12/2024.
//

import UIKit
import CoreData

class VenueDetailsViewController: UIViewController {
    var venue: Venues1? = nil
    
   
    @IBOutlet weak var nameLabel: UITextView!
    @IBOutlet weak var buildingLabel: UITextView!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var openingTimesLabel: UITextView!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        nameLabel.text = venue!.venueName
        buildingLabel.text = venue!.building
        displayDesciption()
        openingTimesLabel.text = venue!.opening_times

        let isLiked = venue!.isLiked
        if isLiked == "1" {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        } else if isLiked == "-1" {
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        
        
        
    }
    
    func displayDesciption() {
        if venue!.descriptionText!.isEmpty {
            descriptionLabel.text = "No description available"
                return
        }
        let descriptionHTML = venue!.descriptionText?.data(using: .utf8)
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
    

    @IBAction func likeButtonTapped(_ sender: UIButton) {

        let beforeUpdate = venue!.isLiked
        if beforeUpdate == "1" {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
        dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        
        updateLikeStatus("1")
        
    }

    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
        let beforeUpdate = venue!.isLiked
        if beforeUpdate == "-1" {
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        } else {
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        
        
        updateLikeStatus("-1")
     //   dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
    }

    func updateLikeStatus(_ isLiked: String) {
        //venue.isLiked = isLiked
        saveLikeStatusToCoreData(isLiked)
       // updateButtonStates()
    }

    func saveLikeStatusToCoreData(_ isLiked: String) {
    //    guard let venueName = venue.venueName else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        //if neutral or disliked but like pressed, its got to be 1
        //but if its already liked, and like it pressed, it should be 0
        
    
        
        if venue!.isLiked == isLiked {
            venue!.isLiked = "0"
        } else {
            venue!.isLiked = isLiked
        }
        
        
        //venue!.isLiked = isLiked
        
        
        
        do {
                try context.save()
        } catch {
            print("Error updating like status: \(error)")
        }
    }
    // MARK: - Navigation

}
