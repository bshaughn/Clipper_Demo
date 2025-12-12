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

class CustomerLabel: UILabel {
    let customerInfo: Customer
    
    init(customerInfo: Customer, frame: CGRect) {
        self.customerInfo = customerInfo
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BarberLabel: UILabel {
    let barberInfo: Barber
    
    init(barberInfo: Barber, frame: CGRect) {
        self.barberInfo = barberInfo
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    var messageList = [String]()
    var messageAlphas = [CGFloat]()
    
    let normalCustomer = "🙂"
    let cursingCustomer = "🤬"
    let frustratedCustomer = "😤"
    let satisfiedCustomer = "🤩"
    let disappointedCustomer = "😫"
    let unfulfilledCustomer = "😞"
    
    @IBOutlet weak var shopView: UIView!
    
    @IBOutlet weak var clipperPoster: UIImageView!
    
    @IBOutlet weak var clipperSign: UILabel!
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
    
    @IBOutlet weak var barber_label_1: UILabel!
    @IBOutlet weak var barber_label_2: UILabel!
    @IBOutlet weak var barber_label_3: UILabel!
    @IBOutlet weak var barber_label_4: UILabel!
    
    @IBOutlet weak var scissor_1: UILabel!
    @IBOutlet weak var scissor_2: UILabel!
    @IBOutlet weak var scissor_3: UILabel!
    @IBOutlet weak var scissor_4: UILabel!
    
    @IBOutlet weak var waitingRoom1: UILabel!
    @IBOutlet weak var waitingRoom2: UILabel!
    @IBOutlet weak var waitingRoom3: UILabel!
    @IBOutlet weak var waitingRoom4: UILabel!
    
    @IBOutlet weak var waitingRoom4LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var waitingRoom3LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var waitingRoom2LeadingConstraint: NSLayoutConstraint!
    
    var waitingOffsetSize:Int? = nil
    
    @IBOutlet weak var waitingBench: UIImageView!
    @IBOutlet weak var benchWidthConstraint: NSLayoutConstraint!
   
    @IBOutlet weak var leftBarberPole: UIImageView!
    @IBOutlet weak var rightBarberPole: UIImageView!
    
    @IBOutlet weak var arrivalSpot: UILabel!
    @IBOutlet weak var departureSpot: UILabel!
    
    @IBOutlet weak var wallClock: WallClock!
    
    @IBOutlet weak var timescaleSlider: UISlider!
    var transportView: UIImageView?
    
    var customerImageViews = [String: UILabel]()
    var barberLabels = [String: UILabel]()
    
    @IBAction func timescaleSliderMoved(_ sender: Any) {
        let sliderValue = (sender as! UISlider).value
        
        barberShop.timeUISlider = Double(sliderValue)
        
        transportView?.isHidden = true
        
        if sliderValue < (1/22) {
            
            if transportView?.isHidden == true {
                transportView?.isHidden = false
                transportView?.image = pauseImage
                transportView?.backgroundColor = .white
            }
            
            //maybe add haptic? 
        }
        
        if sliderValue > 0.7 {
            
            if transportView?.isHidden == true {
                transportView?.image = ffImage
                transportView?.backgroundColor = .black
                transportView?.isHidden = false
                transportView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                timescaleSlider.minimumTrackTintColor = .black
            }
        }
        
        if sliderValue > 0.95 {
            transportView?.backgroundColor = .yellow
            transportView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            transportView?.contentMode = .scaleToFill
            timescaleSlider.minimumTrackTintColor = .yellow
        }
    }
    
    var currentTime = -1
    
    let barberShop = BarberShop()
    
    var allowableDrift = [CGPoint]()
    
    let pauseImage = UIImage(systemName: "pause.fill")
    let ffImage = UIImage(systemName: "forward")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        timescaleSlider.transform = CGAffineTransform.init(rotationAngle: -CGFloat.pi/2)
        timescaleSlider.frame.origin.y = shopView.frame.origin.y
        timescaleSlider.frame.origin.x = shopView.frame.origin.x - 45.0
        
        timescaleSlider.translatesAutoresizingMaskIntoConstraints = true
        
        transportView = UIImageView(frame: CGRect(x: shopView.frame.origin.x - 50.0, y: timescaleSlider.frame.height + 50, width: 40.0, height: 40.0))
        transportView?.backgroundColor = .clear
        transportView?.contentMode = .scaleAspectFit
        timescaleSlider.superview?.addSubview(transportView!)
    
        barberShop.barberShopDelegate = self
        
        wallClock.setTime(st: barberShop.currentTime)
        wallClock.layer.cornerRadius = 15.0
        
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        messagesTableView.separatorStyle = .none
        messagesTableView.rowHeight = UITableView.automaticDimension
        
        timescaleSlider.value = Float(barberShop.timeUISlider)
        
        clipperPoster.layer.borderColor = UIColor.brown.cgColor
        clipperPoster.layer.borderWidth = 5
        
        clipperSign.adjustsFontSizeToFitWidth = true
        clipperSign.clipsToBounds = true
        
        waves_1.alpha = 0
        waves_2.alpha = 0
        waves_3.alpha = 0
        waves_4.alpha = 0
        waves_5.alpha = 0
        waves_6.alpha = 0
        waves_7.alpha = 0
        waves_8.alpha = 0
        waves_9.alpha = 0
        
        leftBarberPole.layer.cornerRadius = 15
        rightBarberPole.layer.cornerRadius = 15
        
        barber_label_1.adjustsFontSizeToFitWidth = true
        barber_label_1.clipsToBounds = true
        barber_label_2.adjustsFontSizeToFitWidth = true
        barber_label_2.clipsToBounds = true
        barber_label_3.adjustsFontSizeToFitWidth = true
        barber_label_3.clipsToBounds = true
        barber_label_4.adjustsFontSizeToFitWidth = true
        barber_label_4.clipsToBounds = true
        
        // we're using 50x50 squares for the customer and barber avatars; hopefully screen sizes will always allow the bench to be at least 50 wide
        
        let shopFrame = shopView.frame
        allowableDrift.append(CGPoint(x: shopFrame.origin.x+5, y: shopFrame.origin.y))
        allowableDrift.append(CGPoint(x: shopFrame.origin.x-5, y: shopFrame.origin.y))
        allowableDrift.append(CGPoint(x: shopFrame.origin.x, y: shopFrame.origin.y+5))
        allowableDrift.append(CGPoint(x: shopFrame.origin.x, y: shopFrame.origin.y-5))
    }

    override func viewDidLayoutSubviews() {
        if waitingOffsetSize == nil && waitingBench.frame.width > 50  {  // wait until autolayout has chosen the final length for the bench
            waitingOffsetSize = (Int(waitingBench.frame.width)-200)/4
            
            waitingRoom2LeadingConstraint.constant = CGFloat(waitingOffsetSize!)
            waitingRoom3LeadingConstraint.constant = CGFloat(waitingOffsetSize!)
            waitingRoom4LeadingConstraint.constant = CGFloat(waitingOffsetSize!)
        }
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
                scissor?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/7)
            }
            else {
                scissor?.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/7)
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
    
    func updateMessageTable() {
        var i = messageAlphas.count - 1
        
        while i >= 0 {
            messageAlphas[i] -= 0.1
            if messageAlphas[i] <= 0 {
                messageList.remove(at: i)
                messageAlphas.remove(at: i)
            }
            i -= 1
        }
        
        DispatchQueue.main.async { [self] in
            messagesTableView.reloadData()
        }
    }
}

extension ViewController: BarberShopDelegate {
    func barberWentHome(barber: Barber, chairIndex: Int) {
        
        let barberNameLabels = [barber_label_1, barber_label_2, barber_label_3, barber_label_4]
        
        var departingBarberLabel = barberLabels[barber.id.uuidString]
        
        UIView.transition(with: departingBarberLabel!, duration: 0.2) { [self] in
            departingBarberLabel!.frame = departureSpot.frame
            barberNameLabels[chairIndex]?.text = ""
        } completion: { _ in
            departingBarberLabel!.removeFromSuperview()
            departingBarberLabel = nil
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
        
        let customerLabel = customerImageViews[customer.id.uuidString]
        
        UIView.animate(withDuration: 0.1) {
            customerLabel?.frame.origin =  (waitingRoomSlots[waitingRoomSlot-1]?.frame.origin)!
        }
    }
    
    func barberDidArrive(barber: Barber, barberChairNumber: Int) {
        let barberSlots = [chair_1_barber, chair_2_barber, chair_3_barber, chair_4_barber]
        let barberNameLabels = [barber_label_1, barber_label_2, barber_label_3, barber_label_4]
        
        let barberLabel = BarberLabel(barberInfo: barber, frame: departureSpot.frame)
        barberLabel.clipsToBounds = true
        barberLabel.layer.cornerRadius = 25.0
        barberLabel.textAlignment = .center
        barberLabel.font = UIFont.systemFont(ofSize: 38.0)
        barberLabel.text = barber.avatar
        
        if wallClock.clockTime < 780 {
            barberLabel.backgroundColor = .lightGray
        }
        else {
            barberLabel.backgroundColor = .darkGray
        }
        
        barberLabels[barber.id.uuidString] = barberLabel
        
        self.shopView.addSubview(barberLabel)
        sendMessage(message: "\(barber.name) started shift")
        
        UIView.transition(with: barberLabel, duration: 0.2) {
            barberLabel.frame = barberSlots[barberChairNumber]!.frame
        } completion: { _ in
            DispatchQueue.main.async {
                barberNameLabels[barberChairNumber]?.text = barber.name
            }
        }
    }
    
    func customerDidArrive(customer: Customer) {
        let customerLabel = CustomerLabel(customerInfo: customer, frame: arrivalSpot.frame)
        customerImageViews[customer.id.uuidString] = customerLabel
        customerLabel.font = UIFont.systemFont(ofSize: 38.0)
        customerLabel.textAlignment = .center
        customerLabel.text = normalCustomer
        customerLabel.isUserInteractionEnabled = true
        self.shopView.addSubview(customerLabel)
    }
    
    func customerMovedtoWaitingRoom(customer: Customer, waitingRoomSlot: Int) {
        let waitingRoomSlots = [waitingRoom1, waitingRoom2, waitingRoom3, waitingRoom4]
        
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = normalCustomer
        
        UIView.animate(withDuration: 0.1) {
            customerLabel?.frame.origin =  (waitingRoomSlots[waitingRoomSlot-1]?.frame.origin)!
        }
    }
    
    func customerMovedtoBarberChair(customer: Customer, barberChairNumber: Int) {
        let chairs = [chair_1_customer, chair_2_customer, chair_3_customer, chair_4_customer]
        
        let scissors = [scissor_1, scissor_2, scissor_3, scissor_4]
        
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.text = normalCustomer
        
        
        
        UIView.animate(withDuration: 1.1 - Double(timescaleSlider.value)) {
            customerLabel?.frame = chairs[barberChairNumber]!.frame
        } completion: { [self] _ in
            scissors[barberChairNumber]?.isHidden = false
            self.sendMessage(message: "\(self.barberShop.chairs[barberChairNumber].barber!.name) started cutting \(barberShop.chairs[barberChairNumber].customer!.name)'s hair")
        }
    }
    
    func customerFinishedHaircut(customer: Customer, barberChairNumber: Int) {
        let scissors = [scissor_1, scissor_2, scissor_3, scissor_4]
        
        sendMessage(message: "\(String(describing: barberShop.chairs[barberChairNumber].barber!.name)) finished cutting \(String(describing: barberShop.chairs[barberChairNumber].customer!.name))'s hair")
        
        scissors[barberChairNumber]?.isHidden = true
    }
    
    func customerFrustrated(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.clipsToBounds = true
        customerLabel?.layer.cornerRadius = 25.0
        customerLabel?.backgroundColor = .red
        customerLabel?.text = frustratedCustomer
    }
    
    func customerSatisfied(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.clipsToBounds = true
        customerLabel?.layer.cornerRadius = 25.0
        customerLabel?.backgroundColor = .green
        customerLabel?.text = satisfiedCustomer
    }
    
    func customerCursing(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.clipsToBounds = true
        customerLabel?.layer.cornerRadius = 25.0
        customerLabel?.backgroundColor = .black
        customerLabel?.text = cursingCustomer
    }
    
    func customerUnfulfilled(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.clipsToBounds = true
        customerLabel?.layer.cornerRadius = 25.0
        customerLabel?.backgroundColor = .yellow
        customerLabel?.text = unfulfilledCustomer
    }
    
    func customerDisappointed(customer: Customer) {
        let customerLabel = customerImageViews[customer.id.uuidString]
        customerLabel?.clipsToBounds = true
        customerLabel?.layer.cornerRadius = 25.0
        customerLabel?.backgroundColor = .purple
        customerLabel?.text = disappointedCustomer
    }
    
    func customerDeparted(customer: Customer) {
        var customerLabel = customerImageViews[customer.id.uuidString]
        
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
                customerLabel = nil
                self.customerImageViews.removeValue(forKey: customer.id.uuidString)
                self.updateWaitingRoom(waitingCustomers: self.barberShop.waitingRoom)
            }
        }
    }
    
    func didUpdateCurrentTime() {
        wallClock.incrementTime()
        
        moveWaves()
        moveScissors()
//        moveShop()  this works, but I'll comment it out in case the user doesnt like the shop drifting
        updateMessageTable()
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
    
    func sendMessage(message: String) {
        messageList.insert(message, at: 0)
        messageAlphas.insert(1.0, at: 0)
        if messageList.count > 7 {
            messageList.remove(at: messageList.count - 1)
            messageAlphas.remove(at: messageList.count - 1)
        }
        
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()

        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        
        UIView.animate(withDuration: 0.2) { [self] in
            messageCell.messageLabel.text = messageList[indexPath.row]
        }
        
        let row = indexPath.row
        messageCell.messageLabel.alpha = messageAlphas[row]
        if row == 0 {
           
            messageCell.messageLabel.font = UIFont(name: "Arial Bold", size: 15.0)
            messageCell.messageLabel.adjustsFontSizeToFitWidth = true
        }
        else {
            messageCell.messageLabel.font = UIFont(name: "Arial Bold", size: 10.0)
        }
        
        return messageCell
    }
    
    
}

