//
//  EventPriorityQueue.swift
//  Clipper
//
//  Created by Bart Shaughnessy on 11/20/25.
//

/*
   Traditional min-heap priority queue
   Based heavily upon pseudocode from Chapter 6 of Cormen/Lieserson/Rivest/Stein/s Introduction to Algorithms textbook
 
   Implemented using structs for better performance and concurrency safety
 */

import Foundation

enum EventType: CaseIterable {
    case shopOpen
    case shopClose
    
    case barberStartShift
    case barberGoHome
    
    case customerArrive
    case customerFrustrated
    case customerSatisfied
    case customerFinishedHaircut
    case customerUnfulfilled
    case customerCursing
}

enum EventOwner: CaseIterable {
    case barber
    case customer
}

struct ClipperEvent {
    public var id: UUID
    public var ts: Int
    public var type: EventType
    public var owner: UUID
    
    init(id:UUID, ts:Int, type:EventType, owner:UUID) {
        self.id = id
        self.ts = ts
        self.type = type
        self.owner = owner
    }
}

struct EventHeap {
    enum SiftDirection {
        case up
        case down
    }
    var heapArray: [ClipperEvent]
    
    init(heapArray: [ClipperEvent]) {
        self.heapArray = heapArray
        buildHeap()
    }
    
    init() {
        self.heapArray = [ClipperEvent]()
    }
    
    mutating func buildHeap() {
        if heapArray.count == 0 {return}
        
        var i = Int(floor(Double(heapArray.count)/2))
        
        while (i > 0) {
            heapify(idx: i, direction: .down)
            i -= 1
        }
    }
    
    mutating func swap(idx1: Int, idx2: Int) {
        let tmpEvent = heapArray[idx1]
        heapArray[idx1] = heapArray[idx2]
        heapArray[idx2] = tmpEvent
    }
    
    mutating func heapify(idx: Int, direction: SiftDirection) {
        if heapArray.count == 0 {return}
        // at each node compare timestamps with both child nodes
        
        let parentNode = heapArray[idx]
        var swapNode = parentNode
        var swapIndex = idx
        
        let c1_idx = (idx * 2) + 1
        if c1_idx >= heapArray.count {
            return
        }
        
        let childNode_1 = heapArray[c1_idx]
        if (childNode_1.ts < swapNode.ts) {
            swapNode = childNode_1
            swapIndex = c1_idx
        }
        
        let c2_idx = (idx * 2) + 2
        if c2_idx >= heapArray.count {
            if idx != swapIndex {
                swap(idx1: idx, idx2: swapIndex)
                if direction == .up {
                    let parentIndex = Int(floor(Double(idx - 1) / 2))
                    if parentIndex >= 0 {
                        heapify(idx: parentIndex, direction: .up)
                    }
                }
                else {
                    heapify(idx: swapIndex, direction: .down)
                }
            }
            return
        }
        
        let childNode_2 = heapArray[c2_idx]
        if (childNode_2.ts < swapNode.ts) {
            swapIndex = c2_idx
        }
        
        if idx == swapIndex {return}
        
        swap(idx1: idx, idx2: swapIndex)
        
        if direction == .up {
            let parentIndex = Int(floor(Double(idx - 1) / 2))
            if parentIndex >= 0 {
                heapify(idx: parentIndex, direction: .up)
            }
        }
        else {
            heapify(idx: swapIndex, direction: .down)
        }
        
    }
    
    mutating func addEvent(event: ClipperEvent) {
        heapArray.append(event)
        
        if heapArray.count <= 1 {
            return
        }
        
        let newElementIndex = heapArray.count - 1
        
        let parentIndex = Int(floor(Double(newElementIndex - 1) / 2))
        
        heapify(idx: parentIndex, direction: .up)
    }
    
    func peek() -> ClipperEvent? {
        if heapArray.count > 0 {
            return heapArray[0]
        }
        
        return nil
    }
    
    mutating func dequeueEvent() -> ClipperEvent? {
        if heapArray.count == 0 {
            return nil
        }
        
        let nextEvent = heapArray[0]
        heapArray[0] = heapArray.last!
        heapArray.removeLast()
        heapify(idx: 0, direction: .down)
        return nextEvent
        
    }
        
}
