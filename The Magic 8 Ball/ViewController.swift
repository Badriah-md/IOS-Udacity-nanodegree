//
//  ViewController.swift
//  The Magic 8 Ball
//
//  Created by Bdoor on 28/04/1440 AH.
//  Copyright © 1440 badriah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let ballArray = ["ball1","ball2","ball3","ball4","ball5"]
    var randomBall:Int = 0

    @IBOutlet weak var askingLabel: UILabel!
    
    @IBOutlet weak var answerImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatedAnswer()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func askButtonTapped(_ sender: UIButton) {
        updatedAnswer()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        updatedAnswer()
    }
    
    func updatedAnswer(){
        randomBall = Int.random(in: 0...4)
        
        answerImage.image = UIImage(named: ballArray[randomBall])
    }
}

