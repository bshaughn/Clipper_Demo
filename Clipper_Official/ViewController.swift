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
    
    var visibleWaves = [UIImageView]()
    
    @IBOutlet weak var chair_1_customer: UILabel!
    @IBOutlet weak var chair_2_customer: UILabel!
    @IBOutlet weak var chair_3_customer: UILabel!
    @IBOutlet weak var chair_4_customer: UILabel!
    
    @IBOutlet weak var chair_1_barber: UILabel!
    @IBOutlet weak var chair_2_barber: UILabel!
    @IBOutlet weak var chair_3_barber: UILabel!
    @IBOutlet weak var chair_4_barber: UILabel!
    
    @IBOutlet weak var wallClock: WallClock!
    
    @IBOutlet weak var timescaleSlider: UISlider!
    
    @IBAction func timescaleSliderMoved(_ sender: Any) {
        let sliderValue = (sender as! UISlider).value
        
        barberShop.timeUISlider = Double(sliderValue)
    }
    
    var currentTime = -1
    
    let barberShop = BarberShop()
    
    var viewCustomers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        timescaleSlider.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
    
        let pauseImage = UIImage(systemName: "forward.fill")
        let ffImage = UIImage(systemName: "pause.fill")
        
        barberShop.barberShopDelegate = self
        
        wallClock.setTime(st: barberShop.currentTime)
        
        timescaleSlider.value = Float(barberShop.timeUISlider)
        
        waves_1.alpha = 0
        waves_2.alpha = 0
        waves_3.alpha = 0
        waves_4.alpha = 0
        waves_5.alpha = 0
        waves_6.alpha = 0
        waves_7.alpha = 0
        waves_8.alpha = 0
        waves_9.alpha = 0
    }

    func moveWaves() {
       let wavesArray = [waves_1, waves_2, waves_3, waves_4, waves_5, waves_6, waves_7, waves_8, waves_9]
        
        let alphas = [0.0, 0.1, 0.4, 1.0, 0.5, 0.3, 0.05]
        
        
        if visibleWaves.count < 2 {
            var numWaves = Int.random(in: 1...3)
            
            while numWaves > 0 {
                let waveIndex = wavesArray.indices.randomElement()
                let visibleWave:UIImageView = wavesArray[waveIndex!]!
                visibleWave.alpha = 0.0
                visibleWaves.append(visibleWave)
                numWaves -= 1
            }
        }
        
        for wave in visibleWaves {
            
            let waveAlpha = Double(round(100 * wave.alpha) / 100)
            
            let alphaIndex = alphas.firstIndex(of: waveAlpha)
            
            if alphaIndex == alphas.count-1 {
                visibleWaves.remove(at: visibleWaves.firstIndex(of: wave)!)
            }
            else {
                
                wave.alpha = alphas[alphaIndex!+1]
            }
            
        }
    }
}

extension ViewController: BarberShopDelegate {
    func didUpdateCurrentTime() {
        wallClock.incrementTime()
        
        moveWaves()
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
    
    func shopOpenStatus(isOpen: Bool) {
        if isOpen {
            rightDoor.image = UIImage(named: "Door_Open")
            leftDoor.image = UIImage(named: "Door_Open")
        }
        else {
            rightDoor.image = UIImage(named: "Door_Closed")
            leftDoor.image = UIImage(named: "Door_Clsoed")
        }
    }
    
    
}

