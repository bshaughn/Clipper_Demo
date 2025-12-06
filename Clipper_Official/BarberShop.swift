//
//  BarberShop.swift
//  Clipper
//
//  Created by Bart Shaughnessy on 11/21/25.
//

import Foundation

protocol BarberShopDelegate {
    func didUpdateCurrentTime()
    func barberDidArrive(barber:Barber, barberChairNumber: Int)
    func barberWentHome(barber: Barber, chairIndex: Int)
    func customerDidArrive(customer:Customer)
    func customerMovedtoWaitingRoom(customer:Customer, waitingRoomSlot:Int)
    func customerMovedtoBarberChair(customer:Customer, barberChairNumber:Int)
//    func customerMovedFromWatingRoomToChair(customer: Customer, waitingRoomSlot:Int, barberChairNumber:Int)
    func customerFinishedHaircut(customer:Customer, barberChairNumber: Int)
    func customerFrustrated(customer:Customer)
    func customerUnfulfilled(customer: Customer)
    func customerDisappointed(customer: Customer)
    func customerSatisfied(customer:Customer)
    func customerCursing(customer:Customer)
    func customerDeparted(customer:Customer)
    func shopOpenStatus(isOpen:Bool)
    func updateWaitingRoom(waitingCustomers: [Customer])
    func sendMessage(message:String)
    
}

let READ_EVENTS_FROM_FILE = false  // Id rather do this with Swift flags; for demo we'll just use a const

struct Barber: Identifiable {
    let id: UUID
    let name: String
    let avatar: String
}

struct Customer {
    let id: UUID 
    let name: String
    var arrivalTime: Int
    public var frustrateTime: Int
    public var haircutDuration: Int
    public var haircutFinish: Int
}

struct BarberChair {
    public let id: Int
    public var barber: Barber?
    public var customer: Customer?
    
    init(id: Int, barber: Barber? = nil, customer: Customer? = nil) {
        self.id = id
        self.barber = barber
        self.customer = customer
    }
    
    mutating func assignBarber(newBarber: Barber) {
        barber = newBarber
    }
    
    mutating func takeCustomer(newCustomer: Customer) {
        customer = newCustomer
        customer!.frustrateTime = -1
        if !READ_EVENTS_FROM_FILE {
            customer?.haircutDuration = Int.random(in: 20...40) // generate number between 20 and 40
        }
    }
    
    mutating func releaseCustomer() {
        customer = nil
    }
}

struct ShiftOne {
    public var shiftBarbers = [Barber]()
    
    init() {
        var uuid = UUID()
        let barber_1 = Barber(id: uuid, name: "Matt Andis", avatar: "🧟‍♂️")
        uuid = UUID()
        let barber_2 = Barber(id: uuid, name: "Sam Bentham", avatar: "🧛🏼")
        uuid = UUID()
        let barber_3 = Barber(id: uuid, name: "Warren Flynn", avatar: "👷🏾")
        uuid = UUID()
        let barber_4 = Barber(id: uuid, name: "Vic Fontanez", avatar: "👨🏻‍⚕️")
        shiftBarbers = [barber_1, barber_2, barber_3, barber_4]
    }
}

struct ShiftTwo {
    public var shiftBarbers = [Barber]()
    
    init() {
        var uuid = UUID()
        let barber_1 = Barber(id: uuid, name: "JC Barber", avatar: "👨🏻‍🎤")
        uuid = UUID()
        let barber_2 = Barber(id: uuid, name: "Matt Conrad", avatar: "🧑‍🏭")
        uuid = UUID()
        let barber_3 = Barber(id: uuid, name: "Ramesh Babu", avatar: "👨🏻‍🎨")
        uuid = UUID()
        let barber_4 = Barber(id: uuid, name: "Diego d'Ambrosio", avatar: "💁🏽")
        shiftBarbers = [barber_1, barber_2, barber_3, barber_4]
    }
}

class BarberShop: ObservableObject {
    let MAX_TIMESCALE = 22 // we'll try a 1-10 timescale, with 10 being the fastest. 0 is pause
    let MIN_TIMESCALE = 0
//    let MIN_TIMEBUFFER = 4
    var MIN_TIMEBUFFER = 80
    
    var shift_1 = ShiftOne()
    var shift_2 = ShiftTwo()
    
    var statusMessage = ""
    
    var barberShopDelegate: BarberShopDelegate?
    
    // default to 8am
    var currentTime = 530 { // timescale is in "minutes" using a counter that cycles through 0-1339 each day
        didSet {
            if currentTime > 1339 || currentTime < 0 {  //attempting to force an invalid time will reset the time counter
                currentTime = 0
                return
            }
            
            if currentTime < 540 || currentTime > 1020 {
                
                if !READ_EVENTS_FROM_FILE {
                    if currentTime == 535 {
                        bgQ.sync(flags: .barrier) { [self] in
                            let newCustomer = Customer(id: UUID(), name: "Customer-\(currentTime)", arrivalTime: currentTime + 5, frustrateTime: currentTime + 25, haircutDuration: -1, haircutFinish: -1)
                            
                            customers.append(newCustomer)
                            
//                            debugCustomers.append(newCustomer)
                            
                            let firstCustomerEvent = ClipperEvent(id: UUID(), ts: currentTime + 5, type: .customerArrive, owner: newCustomer.id)
                            eventQueue.addEvent(event: firstCustomerEvent)
                        }
                    }
                }
                
                self.isOpen = false
                
                if currentTime > 1020 {
                    let randomCustomerChance = Float.random(in: 0.0...1.0)
                    if randomCustomerChance <= 0.05 {
                        bgQ.sync(flags: .barrier) {
                            let newCustomer = Customer(id: UUID(), name: "Random Customer", arrivalTime: currentTime + 5, frustrateTime: currentTime + 25, haircutDuration: -1, haircutFinish: -1)
                            customerArrived(newCustomer: newCustomer)
                        }
                        
                    }
                }
                
                return
            }
            
            if !READ_EVENTS_FROM_FILE {
                if (currentTime >= 540) && (currentTime < 1020) && (currentTime%5 == 0) {
                    bgQ.sync(flags: .barrier) { [self] in
                        let newCustomer = Customer(id: UUID(), name: "Customer-\(currentTime)", arrivalTime: currentTime + 5, frustrateTime: currentTime+25, haircutDuration: -1, haircutFinish: -1)
                        
                        customers.append(newCustomer)
//                        debugCustomers.append(newCustomer)
                        
                        let newCustomerEvent = ClipperEvent(id: UUID(), ts: currentTime + 5, type: .customerArrive, owner: newCustomer.id)
                        eventQueue.addEvent(event: newCustomerEvent)
                    }
                }
            }
            
            self.isOpen = true
            
            if currentTime >= 540 && currentTime <= 780 {
                self.shift = 1
            }
            else {
                self.shift = 2
            }
            
        }
    }
    
    var timeUISlider = 0.1 {
        didSet {
            timeScale = 22 - Int(22.0*timeUISlider)
//            print("Timescale is now \(timeScale)")
            
            if timeUISlider >= 0 && timeUISlider <= 0.4 {
                MIN_TIMEBUFFER = 80
            }
            
            if timeUISlider > 0.4 && timeUISlider <= 0.8 {
                MIN_TIMEBUFFER = 15
            }
            
            if timeUISlider > 0.8 {
                MIN_TIMEBUFFER = 3
            }
            
        }
    }
    
    var timeSlider = 22.0 {
        didSet {
            timeScale = Int(22.0-(timeSlider))
        }
    }

    var timeScale = 22 {
        willSet {
            if newValue < MIN_TIMESCALE || newValue > MAX_TIMESCALE {
                debugPrint("Rejecting invalid timescale! \(newValue)")
                return
            }
            
            if newValue == 22 {
                timerEnabled(te: false)
            }
            
            if (timeScale == MAX_TIMESCALE) && (newValue < MAX_TIMESCALE) && (newValue > MIN_TIMESCALE) {
                if timer == nil {
                    timerEnabled(te: true)
                }
            }
        }
            
        didSet {
            if timeScale < MIN_TIMESCALE {timeScale = MIN_TIMESCALE}
            if timeScale > MAX_TIMESCALE {timeScale = MAX_TIMESCALE}
        }
    }
    
    var timeBuffer = 2
    var eventQueue = EventHeap()
//    let bgQ = DispatchQueue(label: "default bg", qos: .background , attributes: .concurrent)
    let bgQ = DispatchQueue.global(qos: .background)
    
    var barbers = [Barber]()
    var chairs = [BarberChair(id: 0), BarberChair(id:1), BarberChair(id:2), BarberChair(id:3)]

    var waitingBarbers = [Barber]()
    var customers = [Customer]()
    
//    var debugCustomers = [Customer]()
//    var departedCustomers = [Customer]()
//    var satisfiedCustomers = [Customer]()
//    var frustratedCustomers = [Customer]()
    
    var occupancy = 0 //max occupancy is 8
    var waitingRoom = [Customer]() //array of size 4; LIFO queue
    
    var timer: Timer? = nil
    
    var isOpen = false {
        didSet {
            if isOpen == oldValue {return}
            
            if isOpen {
//                statusMessage = "Barbershop is OPEN"
                if barberShopDelegate != nil {
                    barberShopDelegate?.sendMessage(message: "Clipper is open for business!")
                }
                // bring in shift 1
                shift = 1
            }
            else {
//                statusMessage = "Barbershop is CLOSED"
                
                if barberShopDelegate != nil {
                    barberShopDelegate?.sendMessage(message: "Clipper is closed")
                }
                
                // send home shift 2
                bgQ.sync(flags: .barrier) {
                    for barber in barbers {
                        var timeToExit = currentTime
                        let activeCustomer = chairs.filter{$0.barber!.id == barber.id}[0].customer
                        
                        if activeCustomer != nil {
                            timeToExit = activeCustomer!.haircutFinish+1
                        }
                        
                        let endShiftEvent = ClipperEvent(id: UUID(), ts: timeToExit, type: .barberGoHome, owner: barber.id)
                        eventQueue.addEvent(event: endShiftEvent)
                        
                        for wc in waitingRoom {
                            if barberShopDelegate != nil {
                                barberShopDelegate?.customerCursing(customer: wc)
                                barberShopDelegate?.customerDeparted(customer: wc)
                            }
                        }
                        
                        waitingRoom.removeAll()
                        
                        let waitingCustomers = customers.filter{$0.haircutFinish < 0}
                        
                        for wc in waitingCustomers {
                            let c_idx = customers.firstIndex { c in
                                c.id == wc.id
                            }
                            
                            if c_idx != nil {
                                customers.remove(at: c_idx!)
//                                debugPrint("customers count after removal (closed): \(customers.count)")
                            }
                        }
                    }
                }

            }
            if barberShopDelegate != nil {
                barberShopDelegate?.shopOpenStatus(isOpen: isOpen)
            }
        }
    }
    
    var shift = -1 {
        didSet {
            if shift == oldValue {return}
            if shift == 1 {
                // bring in shift 1 barbers
                for barber in shift_1.shiftBarbers {
//                    let clipperEvent = ClipperEvent(id: UUID(), ts: currentTime, type: .barberStartShift, owner: barber.id)
//                    eventQueue.addEvent(event: clipperEvent)
                    barberStartShift(barberID: barber.id)
                    
                }
            }
            
            if shift == 2 {
                // send home shift 1
                for barber in barbers {
                    var timeToExit = currentTime
                    
                    let activeCustomer = chairs.filter{$0.barber!.id == barber.id}[0].customer
                    
                    if activeCustomer != nil {
                        timeToExit = activeCustomer!.haircutFinish
                    }
                    
                    let endShiftEvent = ClipperEvent(id: UUID(), ts: timeToExit, type: .barberGoHome, owner: barber.id)
                    eventQueue.addEvent(event: endShiftEvent)
                }
                // bring in shift 2 barbers
                for barber in shift_2.shiftBarbers {
                    let startShiftEvent = ClipperEvent(id: UUID(), ts: currentTime, type: .barberStartShift, owner: barber.id)
                    eventQueue.addEvent(event: startShiftEvent)
                }
            }
        }
    }
    
    //also we'll put a timer here that will count "minutes". Compare seconds to timescale+buffer to dequeue events
    
    init() {
        timeSlider = 1.0
        timeScale = 21
        
        if READ_EVENTS_FROM_FILE {
            bgQ.sync(flags: .barrier) {
                if let path = Bundle.main.path(forResource: "testfile", ofType: "txt") {
                    let fileURL = URL(fileURLWithPath: path)
                        do {
                            try readTextFileLines(from: fileURL)
                        }
                        catch let error{
                            debugPrint("GOT FILEREAD ERROR: \(error.localizedDescription)")
                        }
                } else {
                    print("File not found in bundle.")
                }
            }
        }
        
        timerEnabled(te: true)
    }
    
//    func updateDebugCustomers() {
//        for c in customers {
//            let dbc = debugCustomers.filter{$0.id == c.id}
//            if dbc.count == 0 {
//                debugPrint("Didnt find active customer record??")
//            } else {
//                let dbcIndex = debugCustomers.firstIndex { debugC in
//                    debugC.id == dbc[0].id
//                }
//
//                if dbcIndex != nil {
//                    debugCustomers[dbcIndex!] = c
//                }
//            }
//        }
//    }
    
    func readTextFileLines(from fileURL: URL) throws {
        do {
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
            let fileLines = fileContents.components(separatedBy: .newlines)

            for line in fileLines {
                // Process each line here
                let line_info = line.split(separator: ",")
                if line_info.count == 3 {  // textfile lines consist of CustomerName, ArrivalTime, Haircut duration. Anything that doesnt fit this format is not valid
                    let newCustomer = Customer(id: UUID(), name: String(line_info[0]), arrivalTime: Int(line_info[1].trimmingCharacters(in: .whitespacesAndNewlines))!, frustrateTime: -1, haircutDuration: Int(line_info[2].trimmingCharacters(in: .whitespacesAndNewlines))!, haircutFinish: -1)
                    customers.append(newCustomer)
//                    debugCustomers.append(newCustomer)
                    let newCustomerArrival = ClipperEvent(id: UUID(), ts: Int(line_info[1].trimmingCharacters(in: .whitespacesAndNewlines))!, type: .customerArrive, owner: newCustomer.id)
                    eventQueue.addEvent(event: newCustomerArrival)
                }
                
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    func customerArrived(newCustomer: Customer) {
        if barberShopDelegate != nil {
            barberShopDelegate?.customerDidArrive(customer: newCustomer)
            barberShopDelegate?.sendMessage(message: "\(newCustomer.name) arrived!")
        }
        
        
        if !isOpen {
            customerDisappointed(disappointedCustomer: newCustomer)
            return
            
        }
//        DispatchQueue.main.async {
//            self.statusMessage = "\(newCustomer.name) arrived!"
//        }
        
//        if barberShopDelegate != nil {
//            barberShopDelegate?.sendMessage(message: "\(newCustomer.name) arrived!")
//        }
        
        if waitingRoom.count == 4 {
            debugPrint("Customer arrive to full waiting room - leaves in frustration")
            customerFrustrated(madCustomer: newCustomer)
            return
        }
        
//        if barberShopDelegate != nil {
//            barberShopDelegate?.customerDidArrive(customer: newCustomer)
//        }
        
        let freeChairs = chairs.filter{$0.customer==nil && $0.barber != nil}
        if freeChairs.count > 0 {
            let freeChairIndex = chairs.firstIndex { bc in
                bc.id == freeChairs[0].id
            }
            if freeChairIndex == nil {
                debugPrint("Failed to find free chair for customer (?!?!?!?!?!)")
            }

            chairs[freeChairIndex!].takeCustomer(newCustomer: newCustomer)
            
            // update the copy of the customer in the customers array
            
            if (customers.first(where: { c in
                c.id == chairs[freeChairIndex!].customer!.id
            }) != nil) {
                let customerIndex = customers.firstIndex { ci in
                    ci.id == chairs[freeChairIndex!].customer!.id
                }
                
                customers[customerIndex!] = chairs[freeChairIndex!].customer!

            }
            
            let seatedCustomer = chairs[freeChairIndex!].customer
            let haircutFinish = currentTime+seatedCustomer!.haircutDuration
        
            chairs[freeChairIndex!].customer?.haircutFinish = haircutFinish
            
            if customers.filter({$0.id == newCustomer.id}).count > 0 {
                let customerIndex = customers.firstIndex { c in
                    c.id == newCustomer.id
                }
                
                customers[customerIndex!] = chairs[freeChairIndex!].customer!
            }
            
            let finishHaircutEvent = ClipperEvent(id: UUID(), ts: haircutFinish, type: .customerFinishedHaircut, owner: newCustomer.id)
            eventQueue.addEvent(event: finishHaircutEvent)
            barberShopDelegate?.customerMovedtoBarberChair(customer: newCustomer, barberChairNumber: freeChairIndex!)
        }
        else {
            let frustrationEvent = ClipperEvent(id: UUID(), ts: currentTime+20, type: .customerFrustrated, owner: newCustomer.id)
            eventQueue.addEvent(event: frustrationEvent)
                waitingRoom.append(newCustomer)
            barberShopDelegate?.customerMovedtoWaitingRoom(customer: newCustomer, waitingRoomSlot: waitingRoom.count)
        }
    }
    
    func customerDeparted(finishedCustomer: Customer) {
        if !isOpen {
            let customerIndex = customers.firstIndex { c in
                c.id == finishedCustomer.id
            }
            
            if barberShopDelegate != nil {
                barberShopDelegate?.customerDeparted(customer: finishedCustomer)
            }
            
            if customerIndex != nil {
//                departedCustomers.append(customers[customerIndex!])
                customers.remove(at: customerIndex!)
//                debugPrint("customers count after removal (departed-closed): \(customers.count)")
            }
        }
        
        let customerChair = chairs.filter{$0.customer?.id == finishedCustomer.id}

        if customerChair.count != 0 {
            chairs[customerChair[0].id].releaseCustomer()
        }
        
        let customerIndex = customers.firstIndex { c in
            c.id == finishedCustomer.id
        }
        
        if customerIndex != nil {
            customers.remove(at: customerIndex!)
//            debugPrint("customers count after removal (departed): \(customers.count)")
            
            
            if barberShopDelegate != nil {
                barberShopDelegate?.customerDeparted(customer: finishedCustomer)
//                barberShopDelegate?.updateWaitingRoom(waitingCustomers: waitingRoom)
//                departedCustomers.append(finishedCustomer)
            }
        }
        
        if (waitingRoom.first(where: { c in
            c.id == finishedCustomer.id
        }) != nil) {
            waitingRoom.removeAll { ci in
                ci.id == finishedCustomer.id
            }
        }
        
        for bc in chairs {
            if bc.barber == nil {
                return
            }
        }
            
        if waitingRoom.count > 0 {
//            debugPrint("Attempting to assign waiting room customer to chair")
            if customerChair.count > 0 {
                let nextCustomer = waitingRoom.remove(at: 0)
                
                chairs[customerChair[0].id].takeCustomer(newCustomer: nextCustomer)
                
                assert(chairs[customerChair[0].id].barber != nil)
                
                let seatedCustomer = chairs[customerChair[0].id].customer
                chairs[customerChair[0].id].customer?.haircutFinish = currentTime+seatedCustomer!.haircutDuration
            
                if (customers.first(where: { c in
                    c.id == chairs[customerChair[0].id].customer!.id
                }) != nil) {
                    let customerIndex = customers.firstIndex { ci in
                        ci.id == chairs[customerChair[0].id].customer!.id
                    }
                    customers[customerIndex!] = chairs[customerChair[0].id].customer!
                }
                
//                updateDebugCustomers()
                    
                let finishHaircutEvent = ClipperEvent(id: UUID(), ts: chairs[customerChair[0].id].customer!.haircutFinish, type: .customerFinishedHaircut, owner: seatedCustomer!.id)
                eventQueue.addEvent(event: finishHaircutEvent)
                
                if barberShopDelegate != nil {
//                    barberShopDelegate?.customerMovedFromWatingRoomToChair(customer: customers[customerIndex!], waitingRoomSlot: 0, barberChairNumber: customerChair[0].id)
                    barberShopDelegate?.customerMovedtoBarberChair(customer: nextCustomer, barberChairNumber: customerChair[0].id)
                    
                    barberShopDelegate?.updateWaitingRoom(waitingCustomers: waitingRoom)
                }
            }
        }
    }
    
    func customerSatisfied(happyCustomer: Customer) {
        if barberShopDelegate != nil {
            barberShopDelegate?.customerSatisfied(customer: happyCustomer)
        }
        
//        bgQ.sync(flags: .barrier) { [self] in
            self.customerDeparted(finishedCustomer: happyCustomer)
//            self.satisfiedCustomers.append(happyCustomer)
//        }
//        DispatchQueue.main.async { [self] in
////            debugPrint("PRinting customer satisfied")
//                self.statusMessage = "\(happyCustomer.name) is satisfied!"
            
            
            
            if barberShopDelegate != nil {
                barberShopDelegate?.sendMessage(message: "\(happyCustomer.name) leaves satisfied")
            }
//
//            bgQ.sync(flags: .barrier) { [self] in
//                self.customerDeparted(finishedCustomer: happyCustomer)
//                self.satisfiedCustomers.append(happyCustomer)
//            }
//        }
    }
    
    func customerFrustrated(madCustomer:Customer) {
        if madCustomer.haircutFinish > currentTime {
//            debugPrint("Received frustration event but customer is content")
            return
        }
        
        if barberShopDelegate != nil {
            barberShopDelegate?.customerFrustrated(customer: madCustomer)
        }
        
//        frustratedCustomers.append(madCustomer)
        
//        bgQ.sync(flags: .barrier) { [self] in
            self.customerDeparted(finishedCustomer: madCustomer)
//        }
        
//        DispatchQueue.main.async { [self] in
//            if madCustomer.haircutFinish >= currentTime {
//                debugPrint("Received frustration event but customer is content")
//                return
//            }
//            debugPrint("PRinting customer frustrated")

//            self.statusMessage = "\(madCustomer.name) is frustrated!"
            
//            if barberShopDelegate != nil {
//                barberShopDelegate?.customerFrustrated(customer: madCustomer)
//            }
//
//            frustratedCustomers.append(madCustomer)
//
//            bgQ.sync(flags: .barrier) { [self] in
//                self.customerDeparted(finishedCustomer: madCustomer)
//            }
//        }
        
        if barberShopDelegate != nil {
            barberShopDelegate?.sendMessage(message: "\(madCustomer.name) leaves frustrated")
        }
    }
    
    func customerUnfulfilled(unfulfilledCustomer: Customer) {
        if barberShopDelegate != nil {
            barberShopDelegate?.sendMessage(message: "\(unfulfilledCustomer.name) leaves unfulfilled")
            barberShopDelegate?.customerUnfulfilled(customer: unfulfilledCustomer)
        }
        self.customerDeparted(finishedCustomer: unfulfilledCustomer)
    }
    
    func customerDisappointed(disappointedCustomer: Customer) {
        if barberShopDelegate != nil {
            barberShopDelegate?.sendMessage(message: "\(disappointedCustomer.name) leaves disappointed")
            barberShopDelegate?.customerDisappointed(customer: disappointedCustomer)
        }
        self.customerDeparted(finishedCustomer: disappointedCustomer)
    }
    
    func customerLeavesCursing(cursingCustomer: Customer) {
        if barberShopDelegate != nil {
            barberShopDelegate?.customerCursing(customer: cursingCustomer)
        }
        
//        bgQ.sync(flags: .barrier) { [self] in
            self.customerDeparted(finishedCustomer: cursingCustomer)
//        }
//        DispatchQueue.main.async { [self] in

//            self.statusMessage = "\(cursingCustomer.name) leaves cursing!"
            
//            if barberShopDelegate != nil {
//                barberShopDelegate?.customerCursing(customer: cursingCustomer)
//            }
//
//            bgQ.sync(flags: .barrier) { [self] in
//                self.customerDeparted(finishedCustomer: cursingCustomer)
//            }
//        }
        
        if barberShopDelegate != nil {
            barberShopDelegate?.sendMessage(message: "\(cursingCustomer.name) leaves cursing")
        }
    }
    
    func findBarber(barberID: UUID) -> Barber? {
        let shift1_barber_list = shift_1.shiftBarbers.filter({$0.id == barberID})
        if shift1_barber_list.count > 0 {
            return shift1_barber_list[0]
        }
        
        let shift2_barber_list = shift_2.shiftBarbers.filter({$0.id == barberID})
        if shift2_barber_list.count > 0 {
            return shift2_barber_list[0]
        }
        return nil
    }
    
    func barberStartShift(barberID:UUID) {
        guard let barber = findBarber(barberID: barberID) else {
            statusMessage = "BARBER \(barberID) FAILED TO START SHIFT"
            return
        }
        
        // look for free chairs first
        if !barbers.contains(where: { b in
            b.id == barber.id
        }) {
            barbers.append(barber)
        }
        
        let freeChairs = chairs.filter{$0.barber == nil}
        if freeChairs.count > 0 {
            let freeChair = freeChairs[0]
            let freeChairIndex = chairs.firstIndex { chair in
                chair.id == freeChair.id
            }
            
            chairs[freeChairIndex!].assignBarber(newBarber: barber)
            
            if barberShopDelegate != nil {
                barberShopDelegate?.barberDidArrive(barber: barber, barberChairNumber: freeChairIndex!)
                barberShopDelegate?.sendMessage(message: "\(barber.name) started shift")
            }
            
        }
        else {
            waitingBarbers.append(barber)
        }
    }
    
    func handleEvent(evt: ClipperEvent) {
        let evtType = evt.type
        
        switch evtType {
            
            // MARK: barberGoHome case
        case .barberGoHome:
//            DispatchQueue.main.async { [self] in
                guard let barber = findBarber(barberID: evt.owner) else {
                    statusMessage = "BARBER \(evt.owner) FAILED TO START SHIFT"
                    return
                }
                
//                self.statusMessage = "\(barber.name) went home"
                
            if barberShopDelegate != nil {
                barberShopDelegate?.sendMessage(message: "\(barber.name) ended shift")
            }
                
                
                let barberChair = chairs.filter{$0.barber?.id == barber.id}[0]
                let barberChairIdx = chairs.firstIndex { bc in
                    bc.id == barberChair.id
                }
                
                chairs[barberChairIdx!].barber = nil

                if waitingBarbers.count > 0 {
                    let nextBarber = waitingBarbers.remove(at: 0)
                    chairs[barberChairIdx!].assignBarber(newBarber: nextBarber)
                    
                    if barberShopDelegate != nil {
                        barberShopDelegate?.barberDidArrive(barber: nextBarber, barberChairNumber: barberChairIdx!)
                    }

                }
                
                let barberInt = barbers.firstIndex { b in
                    b.id == barber.id
                }
                
                if barberShopDelegate != nil {
                    barberShopDelegate?.barberWentHome(barber: barbers[barberInt!], chairIndex: barberChairIdx!)
                }
                
                barbers.remove(at: barberInt!)
                

//            }
            
            // MARK: barberStartShift case
        case .barberStartShift:
            barberStartShift(barberID: evt.owner)
//            guard let barber = findBarber(barberID: evt.owner) else {
//                statusMessage = "BARBER \(evt.owner) FAILED TO START SHIFT"
//                return
//            }
//
//            // look for free chairs first
//            if !barbers.contains(where: { b in
//                b.id == barber.id
//            }) {
//                barbers.append(barber)
//            }
//
//            let freeChairs = chairs.filter{$0.barber == nil}
//            if freeChairs.count > 0 {
//                let freeChair = freeChairs[0]
//                let freeChairIndex = chairs.firstIndex { chair in
//                    chair.id == freeChair.id
//                }
//
//                chairs[freeChairIndex!].assignBarber(newBarber: barber)
//            }
//            else {
//                waitingBarbers.append(barber)
//            }
            
            // MARK: customerArrive case
        case .customerArrive:
            let customer: Customer = customers.filter{$0.id == evt.owner}[0]
            customerArrived(newCustomer: customer)
            
            // MARK: customerFrustrated case
        case .customerFrustrated:
            let customerList: [Customer] = customers.filter{$0.id == evt.owner}
        
            if customerList.count == 0 {
                return
            }
        
            let customer = customerList[0]
            customerFrustrated(madCustomer: customer)
            
            // MARK: customerSatisfied case
        case .customerSatisfied:
            let customer: Customer = customers.filter{$0.id == evt.owner}[0]
            customerSatisfied(happyCustomer: customer)
            // MARK: customerUnfulfilled case
        case .customerUnfulfilled:
            let customer: Customer = customers.filter{$0.id == evt.owner}[0]
            customerUnfulfilled(unfulfilledCustomer: customer)
            // MARK: customerFinishedHaircut case
        case .customerFinishedHaircut:

            let customerChairs: [BarberChair] = chairs.filter{$0.customer?.id == evt.owner}
            
//            if barberShopDelegate != nil {
//
//                barberShopDelegate?.customerFinishedHaircut(customer:customerChairs[0].customer!, barberChairNumber: chairs.firstIndex(where: { bc in
//                    bc.id == customerChairs[0].id
//                })!)
//
//            }
        
            if customerChairs.count == 0 {  // not even sure how this is possible. improve later
                return
            }
        
        let customer = customerChairs[0].customer!
            
                // works here but we're going to do some debugging
            if barberShopDelegate != nil {

                barberShopDelegate?.customerFinishedHaircut(customer: customer, barberChairNumber: chairs.firstIndex(where: { bc in
                    bc.id == customerChairs[0].id
                })!)

            }
            
            let satisfactionOdds = Float.random(in: 0.0...1.0)
            if satisfactionOdds <= 0.3 {
                customerFrustrated(madCustomer: customer)
            }
            else {
                customerSatisfied(happyCustomer: customer)
            }
            
        default:
            debugPrint("DEQUEUED AN UNRECOGNIZED EVENT!! \(evtType)")
        }
    }
    
    func timerEnabled(te: Bool) {
        DispatchQueue.main.async { [self] in
            timer?.invalidate()
            timer = nil
        }

        if te {
            DispatchQueue.main.async { [self] in
                timer = Timer.scheduledTimer(withTimeInterval: 0.0075 , repeats: true, block: { [weak self] timer in
                    guard let self = self else {
                                    timer.invalidate() // Invalidate if self is gone
                                    return
                                }
                    
                    if self.timeBuffer >= (self.timeScale + self.MIN_TIMEBUFFER) {
                        
                        var nextEvent = self.eventQueue.peek()
                        
                        while (nextEvent != nil) && (nextEvent!.ts <= self.currentTime) {
                            
                            let evt = self.eventQueue.dequeueEvent()
                            if evt != nil {
                                bgQ.sync(flags: .barrier) {
                                    self.handleEvent(evt: evt!)
//                                    debugPrint("DEQUEUED EVENT AT TIMESTAMP \(String(describing: evt?.ts))")
                                }
                                
                            }
                            
                            nextEvent = self.eventQueue.peek()
                        }
                        
                        self.timeBuffer = 0
                        self.currentTime += 1
                        
                        if barberShopDelegate != nil {
                            barberShopDelegate?.didUpdateCurrentTime()
                        }
//                        debugPrint("Current time: \(self.currentTime)")
                    } else {
                        self.timeBuffer += 1
                    }
                    
                })
            }

        }
    }
}
