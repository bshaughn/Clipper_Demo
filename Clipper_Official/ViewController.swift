//
//  ViewController.swift
//  Clipper_Official
//
//  Created by Bart Shaughnessy on 12/2/25.
//

import UIKit

class WallClock: UIView {
    @IBOutlet weak var timeDisplay: UILabel!
    
    var clockTime = -1
    
    func setTime(st: Int) {
        clockTime = st
    }
    
    func incrementTime() {
        if clockTime == 1339 {
            clockTime = 0
            return
        }
        
        clockTime += 1
        updateTimeDisplay()
    }
    
    func updateTimeDisplay() {
        let hours = Int(clockTime/60)
        let minutes = Int(clockTime%60)
        let hourstring = hours < 10 ? "0\(hours)" : "\(hours)"
        let minuteString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        timeDisplay.text = hourstring + ":" + minuteString
    }
}

class ViewController: UIViewController {
    
    let normalCustomer = "🙂"
    let cursingCustomer = "🤬"
    let frustratedCustomer = "😤"
    let satisfiedCustomer = "🤩"
    let disappointedCustomer = "😫"
    
    @IBOutlet weak var shopView: UIView!
    
    @IBOutlet weak var timeScaleSlider: UISlider!
    
    @IBOutlet weak var leftDoor: UIImageView!
    @IBOutlet weak var rightDoor: UIImageView!
    
    @IBOutlet weak var waves_1: UIImageView!
    @IBOutlet weak var waves_2: UIImageView!
    @IBOutlet weak var waves_3: UIImageView!
    @IBOutlet weak var waves_4: UIImageView!
    @IBOutlet weak var waves_5: UIImageView!
    @IBOutlet weak var waves_6: UIImageView!
    @IBOutlet weak var waves_7: UIImageView!
    @IBOutlet weak var waves_8: UIImageView!
    @IBOutlet weak var waves_9: UIImageView!
    
    @IBOutlet weak var chair_1_customer: UILabel!
    @IBOutlet weak var chair_2_customer: UILabel!
    @IBOutlet weak var chair_3_customer: UILabel!
    @IBOutlet weak var chair_4_customer: UILabel!
    
    @IBOutlet weak var chair_1_barber: UILabel!
    @IBOutlet weak var chair_2_barber: UILabel!
    @IBOutlet weak var chair_3_barber: UILabel!
    @IBOutlet weak var chair_4_barber: UILabel!
    
    @IBOutlet weak var wallClock: WallClock!
    
    var currentTime = -1
    
    let barberShop = BarberShop()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        timeScaleSlider.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
        
        barberShop.barberShopDelegate = self
        
        wallClock.setTime(st: barberShop.currentTime)
    }


}

extension ViewController: BarberShopDelegate {
    func didUpdateCurrentTime() {
        wallClock.incrementTime()
    }
    
    func barberDidArrive() {
        //
    }
    
    func customerDidArrive() {
        //
    }
    
    func customerFrustrated() {
        //
    }
    
    func customerSatisfied() {
        //
    }
    
    func customerCursing() {
        //
    }
    
    
}

