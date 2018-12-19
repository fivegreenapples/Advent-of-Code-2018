import Darwin
import CommandLineKit

let cli = CommandLineKit.CommandLine()
let day = IntOption(shortFlag: "d", longFlag: "day", required: true, helpMessage: "Which day of advent")
let part = IntOption(shortFlag: "p", longFlag: "part", required: true, helpMessage: "Which part of the puzzle")
let testMode = BoolOption(shortFlag: "t", longFlag: "test", helpMessage: "Run test input")
let verboseMode = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Run with verbose output")
cli.addOptions(day, part, testMode, verboseMode)

do {
	try cli.parse()
} catch {
	cli.printUsage(error)
	exit(1)
}

let theDay = day.value!
let thePart = part.value!
let isTestMode = testMode.value
let isVerboseMode = verboseMode.value

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
	case 6:
	result = day6(part: thePart, testMode: isTestMode)
	case 7:
	result = day7(part: thePart, testMode: isTestMode)
	case 8:
	result = day8(part: thePart, testMode: isTestMode)
	case 9:
	result = day9(part: thePart, testMode: isTestMode)
	case 10:
	result = day10(part: thePart, testMode: isTestMode)
	case 11:
	result = day11(part: thePart, testMode: isTestMode)
	case 12:
	result = day12(part: thePart, testMode: isTestMode)
	case 13:
	result = day13(part: thePart, testMode: isTestMode)
	case 14:
	result = day14(part: thePart, testMode: isTestMode)
	case 15:
	result = day15(part: thePart, testMode: isTestMode, verboseMode: isVerboseMode)
	case 16:
	result = day16(part: thePart, testMode: isTestMode)
	case 17:
	result = day17(part: thePart, testMode: isTestMode, verboseMode: isVerboseMode)
	case 18:
	result = day18(part: thePart, testMode: isTestMode)
	case 19:
	result = day19(part: thePart, testMode: isTestMode)
	case 20:
	result = day20(part: thePart, testMode: isTestMode)
	case 21:
	result = day21(part: thePart, testMode: isTestMode)
	case 22:
	result = day22(part: thePart, testMode: isTestMode)
	case 23:
	result = day23(part: thePart, testMode: isTestMode)
	case 24:
	result = day24(part: thePart, testMode: isTestMode)
	case 25:
	result = day25(part: thePart, testMode: isTestMode)


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
