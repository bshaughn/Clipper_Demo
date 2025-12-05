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
    
    @IBOutlet weak var scissor_1: UILabel!
    @IBOutlet weak var scissor_2: UILabel!
    @IBOutlet weak var scissor_3: UILabel!
    @IBOutlet weak var scissor_4: UILabel!
    
    @IBOutlet weak var waitingRoom1: UILabel!
    @IBOutlet weak var waitingRoom2: UILabel!
    @IBOutlet weak var waitingRoom3: UILabel!
    @IBOutlet weak var waitingRoom4: UILabel!
    
    @IBOutlet weak var arrivalSpot: UILabel!
    @IBOutlet weak var departureSpot: UILabel!
    
    @IBOutlet weak var wallClock: WallClock!
    
    @IBOutlet weak var timescaleSlider: UISlider!
    
    var customerImageViews = [String: UILabel]()
    var barberLabels = [String: UILabel]()
    
    @IBAction func timescaleSliderMoved(_ sender: Any) {
        let sliderValue = (sender as! UISlider).value
        
        barberShop.timeUISlider = Double(sliderValue)
    }
    
    var currentTime = -1
    
    let barberShop = BarberShop()
    
    var allowableDrift = [CGPoint]()
    
//    var viewCustomers = [Customer]()
    
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
        
        let shopFrame = shopView.frame
    
        allowableDrift.append(CGPoint(x: shopFrame.origin.x+5, y: shopFrame.origin.y))
        allowableDrift.append(CGPoint(x: shopFrame.origin.x-5, y: shopFrame.origin.y))
        allowableDrift.append(CGPoint(x: shopFrame.origin.x, y: shopFrame.origin.y+5))
        allowableDrift.append(CGPoint(x: shopFrame.origin.x, y: shopFrame.origin.y-5))
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
    
    func moveScissors() {
        let scissors = [scissor_1, scissor_2, scissor_3, scissor_4]
        
        for scissor in scissors {
            let currentTime = wallClock.clockTime
            if currentTime%2 == 0 {
                scissor?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/5)
            }
            else {
                scissor?.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/5)
            }
        }
    }
    
    func moveShop() {
        
        let moveOdds = Float.random(in: 0.0...1.0)
        
        if moveOdds < 0.6 {return}
        
        let direction = Int.random(in: 0...3)
        
        switch direction {
        case 0:
            if shopView.frame.origin.x + 1 <= allowableDrift[0].x {
                shopView.frame.origin.x += 1
            }
            
        case 1:
            if shopView.frame.origin.x - 1 >= allowableDrift[1].x {
                shopView.frame.origin.x -= 1
            }
        case 2:
            if shopView.frame.origin.y + 1 <= allowableDrift[2].y {
                shopView.frame.origin.y += 1
            }
            
        case 3:
            if shopView.frame.origin.y - 1 >= allowableDrift[3].y {
                shopView.frame.origin.y -= 1
            }
            
        default:
            debugPrint("????")
        }
    }
}

extension ViewController: BarberShopDelegate {

    
    func barberWentHome(barber: Barber, chairIndex: Int) {
        
        let barberList = [chair_1_barber, chair_2_barber, chair_3_barber, chair_4_barber]
        
        let departingBarberLabel = barberLabels[barber.id.uuidString]
        
        UIView.transition(with: departingBarberLabel!, duration: 0.2) { [self] in
            departingBarberLabel!.frame = departureSpot.frame
        } completion: { _ in
            departingBarberLabel!.removeFromSuperview()
        }
    }
    
    
    func updateWaitingRoom(waitingCustomers: [Customer]) {
        let waitingRoomSlots = [waitingRoom1, waitingRoom2, waitingRoom3, waitingRoom4]
        
        
        var i = 0
        
        while i < waitingCustomers.count {
            let customerLabel = customerImageViews[waitingCustomers[i].id.uuidString]
            UIView.transition(with: customerLabel!, duration: 0.2) {
                customerLabel?.frame = waitingRoomSlots[i]!.frame
            }
            
            i += 1
        }
    }
    
    func customerMovedFromWatingRoomToChair(customer: Customer, waitingRoomSlot: Int, barberChairNumber: Int) {
        let waitingRoomSlots = [waitingRoom1, waitingRoom2, waitingRoom3, waitingRoom4]
        waitingRoomSlots[waitingRoomSlot]?.text = ""
        
        let chairs = [chair_1_customer, chair_2_customer, chair_3_customer, chair_4_customer]
        chairs[barberChairNumber]!.text = normalCustomer
        
//        if waitingRoomSlot < waitingRoomSlots.count-1 {
//            var i = waitingRoomSlot + 1
//            while i < waitingRoomSlots.count {
//                waitingRoomSlots[i-1]?.text = waitingRoomSlots[i]?.text
//                i += 1
//            }
//        }
        
        let customerLabel = customerImageViews[customer.id.uuidString]
        
        UIView.animate(withDuration: 0.1) {
            customerLabel?.frame.origin =  (waitingRoomSlots[waitingRoomSlot-1]?.frame.origin)!
        }
        
    }
    
    func barberDidArrive(barber: Barber, barberChairNumber: Int) {
        let barberSlots = [chair_1_barber, chair_2_barber, chair_3_barber, chair_4_barber]
        
        let barberLabel = UILabel(frame: departureSpot.frame)
        barberLabel.font = UIFont.systemFont(ofSize: 38.0)
        barberLabel.text = barber.avatar
        
        barberLabels[barber.id.uuidString] = barberLabel
        
        self.shopView.addSubview(barberLabel)
//        barberSlots[barberChairNumber]?.text = barber.avatar
        
        UIView.transition(with: barberLabel, duration: 0.2) {
            barberLabel.frame = barberSlots[barberChairNumber]!.frame
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                barberLabel.backgroundColor = .green
            } completion: { _ in
                barberLabel.backgroundColor = .clear
            }
        }
        
    }
    
    func customerDidArrive(customer: Customer) {
        var customerLabel = UILabel(frame: arrivalSpot.frame)
        
        customerImageViews[customer.id.uuidString] = customerLabel
        customerLabel.font = UIFont.systemFont(ofSize: 38.0)
        customerLabel.text = normalCustomer
        self.shopView.addSubview(customerLabel)
    }
    
    func customerMovedtoWaitingRoom(customer: Customer, waitingRoomSlot: Int) {
        let waitingRoomSlots = [waitingRoom1, waitingRoom2, waitingRoom3, waitingRoom4]
        
//        waitingRoomSlots[waitingRoomSlot-1]?.text = normalCustomer
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = normalCustomer
        
        UIView.animate(withDuration: 0.1) {
            customerLabel?.frame.origin =  (waitingRoomSlots[waitingRoomSlot-1]?.frame.origin)!
        }
    }
    
    func customerMovedtoBarberChair(customer: Customer, barberChairNumber: Int) {
        let chairs = [chair_1_customer, chair_2_customer, chair_3_customer, chair_4_customer]
        
        let scissors = [scissor_1, scissor_2, scissor_3, scissor_4]
        
//        chairs[barberChairNumber]!.text = normalCustomer
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = normalCustomer
        
        UIView.animate(withDuration: 1.1 - Double(timescaleSlider.value)) {
            customerLabel?.frame = chairs[barberChairNumber]!.frame
        } completion: { _ in
            scissors[barberChairNumber]?.isHidden = false
        }
    }
    
    func customerFinishedHaircut(customer: Customer, barberChairNumber: Int) {
        let scissors = [scissor_1, scissor_2, scissor_3, scissor_4]
        
        scissors[barberChairNumber]?.isHidden = true
    }
    
    func customerFrustrated(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = frustratedCustomer
    }
    
    func customerSatisfied(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = satisfiedCustomer
    }
    
    func customerCursing(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = cursingCustomer
    }
    
    func customerDeparted(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
//        customerLabel?.text = cursingCustomer
        
        if customerLabel == nil {
            return
        }
        
        UIView.animate(withDuration: 1.1 - Double(timescaleSlider.value)) { [self] in
            customerLabel?.frame = departureSpot.frame
        } completion: { _ in
            UIView.transition(with: customerLabel!, duration: 0.3) {
                customerLabel?.alpha = 0

                
            } completion: { _ in
                customerLabel?.removeFromSuperview()
                self.customerImageViews.removeValue(forKey: customer.id.uuidString)
                // look here
                self.updateWaitingRoom(waitingCustomers: self.barberShop.waitingRoom)
            }
        }
    }
    
    func didUpdateCurrentTime() {
        wallClock.incrementTime()
        
        moveWaves()
        moveScissors()
//        moveShop()  this works, but I'll comment it out in case the user doesnt like the shop drifting
    }
    
    func shopOpenStatus(isOpen: Bool) {
        if isOpen {
            rightDoor.image = UIImage(named: "Door_Open")
            leftDoor.image = UIImage(named: "Door_Open")
        }
        else {
            rightDoor.image = UIImage(named: "Door_Closed")
            leftDoor.image = UIImage(named: "Door_Closed")
        }
    }
}

