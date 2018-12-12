import Darwin
import CommandLineKit

let cli = CommandLineKit.CommandLine()
let day = IntOption(shortFlag: "d", longFlag: "day", required: true, helpMessage: "Which day of advent")
let part = IntOption(shortFlag: "p", longFlag: "part", required: true, helpMessage: "Which part of the puzzle")
let testMode = BoolOption(shortFlag: "t", longFlag: "test", helpMessage: "Run test input")
cli.addOptions(day, part, testMode)

do {
	try cli.parse()
} catch {
	cli.printUsage(error)
	exit(1)
}

let theDay = day.value!
let thePart = part.value!
let isTestMode = testMode.value

if thePart != 1 && thePart != 2 {
	print("Part \(thePart) is not a valid part number for Advent of Code")
	exit(1)
}

let result: String

switch theDay {
	case 1:
	result = day1(part: thePart)
	case 2:
	result = day2(part: thePart)
	case 3:
	result = day3(part: thePart, testMode: isTestMode)
	case 4:
	result = day4(part: thePart, testMode: isTestMode)
	case 5:
	result = day5(part: thePart, testMode: isTestMode)

	default:
	print("No implementation for day \(theDay)")
	exit(1)
}

print("")
print("Advent of Code 2018")
print("Day \(theDay), Part \(thePart)")
print("")
print(result)
print("")
print("")
