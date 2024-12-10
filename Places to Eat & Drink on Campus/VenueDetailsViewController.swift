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

        updateButtonStates()
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
    
    func updateButtonStates() {
        let isLiked = venue!.isLiked
        print("ISLIKED: ", isLiked)
        
        
        if isLiked {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)

        } else {
            likeButton.isSelected = false
            dislikeButton.isSelected = false
        }
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        updateLikeStatus(true)
        likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
    }

    @IBAction func dislikeButtonTapped(_ sender: UIButton) {
        updateLikeStatus(false)
    }

    func updateLikeStatus(_ isLiked: Bool) {
        //venue.isLiked = isLiked
        saveLikeStatusToCoreData(isLiked)
        updateButtonStates()
    }

    func saveLikeStatusToCoreData(_ isLiked: Bool) {
    //    guard let venueName = venue.venueName else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
      //  let fetchRequest: NSFetchRequest<Venues1> = Venues1.fetchRequest()
      //  fetchRequest.predicate = NSPredicate(format: "name == %@", venueName)
        venue!.isLiked = isLiked
        do {
           // let fetchedVenues = try context.fetch(fetchRequest)
           // if let coreDataVenue = fetchedVenues.first {
              //  coreDataVenue.isLiked = isLiked
                try context.save()
          //  }
        } catch {
            print("Error updating like status: \(error)")
        }
    }
    // MARK: - Navigation

}
