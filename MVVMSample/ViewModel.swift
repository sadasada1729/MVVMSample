//
//  ViewModel.swift
//  MVVMSample
//
//  Created by 長田公喜 on 2024/03/25.
//

import Foundation

class ViewModel {
    enum RunningState {
        case running
        case stop
        case empty
    }
    
    private var model = Stopwatch()
    
    @Published private(set) var splitTime: String = "00:00:00"
    @Published private(set) var lapTime: String = "00:00:00"
    @Published private(set) var lapNumber: String = "0"
    @Published private(set) var name: String = "Name"
    @Published private(set) var leftBtnTitle: String = "RESET"
    @Published private(set) var rightBtnTitle: String = "START"
    
    private weak var timer: Timer?
    
    
    func leftBtnTapped() {
        let now = Date()
        switch runningState() {
        case .empty, .stop:
            resetTime()
        case .running:
            model.lapTimes.append(now)
        }
        judgeBtnTitle()
        judgeTimerState()
    }
    
    func rightBtnTapped() {
        let now = Date()
        switch runningState() {
        case .empty, .stop:
            model.startTimes.append(now)
        case .running:
            model.stopTimes.append(now)
        }
        judgeBtnTitle()
        judgeTimerState()
    }
}

private extension ViewModel {
    func runningState() -> RunningState {
        if model.startTimes.isEmpty { return .empty }
        if model.startTimes.count == model.stopTimes.count { return .stop }
        return .running
    }
    
    func resetTime() {
        model.startTimes.removeAll()
        model.stopTimes.removeAll()
        model.lapTimes.removeAll()
    }
    
    func resetName() {
        model.name = "Name"
    }
    
    func judgeBtnTitle() {
        switch runningState() {
        case .empty, .stop:
            rightBtnTitle = "START"
            leftBtnTitle = "RESET"
        case .running:
            rightBtnTitle = "STOP"
            leftBtnTitle = "LAP"
        }
    }
    
    func judgeTimerState() {
        switch runningState() {
        case .empty, .stop:
            stopTimer()
        case .running:
            startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            self.update()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func culcSplitTime(time: Date) -> Double {
        if let last = model.startTimes.last {
            if !model.stopTimes.isEmpty {
                var seconds: Double = 0
                for index in 0..<model.stopTimes.count {
                    seconds += model.stopTimes[index].timeIntervalSince(model.startTimes[index])
                }
                if model.startTimes.count == model.stopTimes.count {
                    return seconds
                }
                seconds += time.timeIntervalSince(model.startTimes.last!)
                return seconds
            }else{
                return time.timeIntervalSince(last) > 0 ? time.timeIntervalSince(last) : 0
            }
        }
        return 0
    }
    
    func culcLapTime(time: Date) -> Double {
        var time: Date = time
        if let last = model.lapTimes.last {
            if model.startTimes.count == model.stopTimes.count,!model.stopTimes.isEmpty{
                time = model.stopTimes.last!
            }
            if model.startTimes.last!.timeIntervalSince(last)>0{
                return time.timeIntervalSince(model.startTimes.last!)
            }else{
                return time.timeIntervalSince(last)
            }
        }else{
            return culcSplitTime(time: time)
        }
    }
    
    func update() {
        let now = Date()
        updateSplit(time: now)
        updateLap(time: now)
        updateLapNumber()
    }
    
    func updateSplit(time: Date) {
        splitTime = Utility.getTimeStringFromSeconds(sec: culcSplitTime(time: time), displayInSeconds: false)
    }
    
    func updateLap(time: Date) {
        lapTime = Utility.getTimeStringFromSeconds(sec: culcLapTime(time: time), displayInSeconds: false)
    }
    
    func updateLapNumber() {
        lapNumber = String(model.lapTimes.count)
    }
}
