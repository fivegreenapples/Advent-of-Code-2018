import Foundation

func day4(part: Int, testMode: Bool) -> String {
	let input = testMode ? day4TestInput : day4Input

	// parse the input and get a sorted list of guard logs
	let guardLogs = getSortedGuardLogs(fromPuzzleInput: input)

	// next loop over these logs, arranging the info logs for each day
	// this gives us the behaviour of the guard on that day,

	var dayDetails = [DayDetail]()
	var currentDay = DayDetail()
	var napStart = 0
	let calendar = Calendar.current

	guardLogs.forEach { log in 
		switch log.logType {
			case let .beginsShift(guardId):
			if currentDay.sleepLog.totalMinsAsleep() > 0 {
				dayDetails.append(currentDay)
			}
			currentDay = DayDetail()
			currentDay.guardId = guardId
			
			case .fallsAsleep:
			currentDay.datestamp = log.datestamp
			let minutes = calendar.component(.minute, from: log.datestamp)
			napStart = minutes

			case .wakesUp:
			let minutes = calendar.component(.minute, from: log.datestamp)
			currentDay.sleepLog = currentDay.sleepLog + (napStart..<minutes)
		}
	}
	if currentDay.sleepLog.totalMinsAsleep() > 0 {
		dayDetails.append(currentDay)
	}

	if testMode {
		// Date   ID   Minute
		//             000000000011111111112222222222333333333344444444445555555555
		//             012345678901234567890123456789012345678901234567890123456789
		// 11-01  #10  .....####################.....#########################.....
		// 11-02  #99  ........................................##########..........

		let formatter = DateFormatter()
		formatter.dateFormat = "MM-dd"
		print("Date   ID   Minute")
		print("            000000000011111111112222222222333333333344444444445555555555")
		print("            012345678901234567890123456789012345678901234567890123456789")

		for d in dayDetails {
			print(formatter.string(from: d.datestamp), "  #", d.guardId, "  ", d.sleepLog, separator:"")
		}
	}

	// Now aggregate all the days so we have aggregate records for each guard.
	var guardSleepLogs = [Int:HourSleepLog]()
	for d in dayDetails {
		guardSleepLogs[d.guardId] = guardSleepLogs[d.guardId, default: HourSleepLog()] + d.sleepLog
	}


	if part == 1 {
		return doStrategy1(guardSleepLogs, testMode)
	}

	return doStrategy2(guardSleepLogs, testMode)

}

func doStrategy1(_ guardSleepLogs: [Int:HourSleepLog], _ testMode: Bool) -> String {

	// Strategy 1 - most sleepy guard

	// reduce the sleep totals to find sleepiest guard
	var mostSleepyGuardId = -1, mostSleepyGuardSleepTotal = 0
	guardSleepLogs.forEach() { (guardId, sleepLog) in
		let thisTotal = sleepLog.totalMinsAsleep()
		if thisTotal > mostSleepyGuardSleepTotal {
			mostSleepyGuardId = guardId
			mostSleepyGuardSleepTotal = thisTotal
		}
	}

	// now find which minute this guard was asleep most often
	let sleepiestMinute = guardSleepLogs[mostSleepyGuardId]!.mostAsleepMinute()

	if testMode {
		print("guard:", mostSleepyGuardId, sleepiestMinute)
	}

	return "\(mostSleepyGuardId * sleepiestMinute)"

}

func doStrategy2(_ guardSleepLogs: [Int:HourSleepLog], _ testMode: Bool) -> String {

	// Strategy 2 - most asleep minute for a guard

	// convert guardlogs to sleepiest minute logs
	var sleepiestMinute = 0, amountOfSleep = 0, guardId = 0
	guardSleepLogs.forEach() { (_guardId, sleepLog) in
		let _sleepiestMinute = sleepLog.mostAsleepMinute()
		let _amountOfSleep = sleepLog.minutes[_sleepiestMinute]
		if _amountOfSleep > amountOfSleep {
			sleepiestMinute = _sleepiestMinute
			amountOfSleep = _amountOfSleep
			guardId = _guardId
		}
	}

	if testMode {
		print("guard:", guardId, sleepiestMinute)
	}

	return "\(guardId * sleepiestMinute)"
}

func getSortedGuardLogs(fromPuzzleInput input: String) -> [GuardLog] {

	let rawLogs = input.split(separator: "\n").map() { String($0) }

	// [1518-11-01 00:00] Guard #10 begins shift
	// [1518-11-01 00:05] falls asleep
	// [1518-11-01 00:25] wakes up
	let logRegex = Regex(pattern: "^\\[1518-([0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2})\\] ((Guard #([0-9]+) begins shift)|(falls asleep)|(wakes up))$")
	let formatter = DateFormatter()
	formatter.dateFormat = "MM-dd HH:mm"

	var guardLogs = [GuardLog]()
	for l in rawLogs {
		let matches = logRegex.FindSubmatch(in: l)
		if matches.count == 0 {
			 preconditionFailure("Log didn't match regex: \(l)")
		}
		guard let logDate = formatter.date(from: matches[1]) else {
			preconditionFailure("Couldn't parse date from \(matches[1])")
		}

		let logType: LogType
		if matches[3] != "" {
			logType = .beginsShift(guardId: Int(matches[4])!)
		} else if matches[5] != "" {
			logType = .fallsAsleep
		} else {
			logType = .wakesUp
		}

		guardLogs.append(
			GuardLog(date: logDate, type: logType)
		)
	}
	// Sort the logs by date
	guardLogs.sort()
	return guardLogs
}
struct DayDetail {
	var datestamp = Date()
	var guardId = 0
	var sleepLog = HourSleepLog()
}

struct GuardLog : Comparable {
	let datestamp: Date
	let logType: LogType 
	init(date ds: Date, type lt: LogType) {
		self.datestamp = ds
		self.logType = lt
	}

	static func < (lhs: GuardLog, rhs: GuardLog) -> Bool {
		return lhs.datestamp < rhs.datestamp
	}
}

enum LogType : Equatable {
	case beginsShift(guardId: Int)
	case fallsAsleep
	case wakesUp
}

struct HourSleepLog: CustomStringConvertible {
	// minutes tracks the number of times spent sleeping during the particular minute
	var minutes = [Int](repeating:0, count:60)

	init() {}

	init(withRange  r: Range<Int>) {
		if r.lowerBound < 0 || r.upperBound > 60 {
			preconditionFailure("range is not right")
		}
		for i in r {
			self.minutes[i] = 1
		}
	}

	static func + (lhs: HourSleepLog, rhs: HourSleepLog) -> HourSleepLog {
		var lhs = lhs
		for i in 0..<lhs.minutes.count {
			lhs.minutes[i] += rhs.minutes[i]
		}
		return lhs
	}
	static func + (lhs: HourSleepLog, rhs: Range<Int>) -> HourSleepLog {
		return lhs + HourSleepLog(withRange: rhs)
	}

	func totalMinsAsleep() -> Int {
		return self.minutes.reduce(0) { $0 + $1 }
	}
	func mostAsleepMinute() -> Int {
		var sleepiestMinute = 0, sleepiestAmount = 0
		for (m, sleep) in self.minutes.enumerated() {
			if sleep > sleepiestAmount {
				sleepiestMinute = m
				sleepiestAmount = sleep
			}
		}
		return sleepiestMinute
	}

	var description: String {
		var desc = ""
		for v in self.minutes {
			desc += (v == 0 ? "." : "#")
		}
		return desc
	}
}

