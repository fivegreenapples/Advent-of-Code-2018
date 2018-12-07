import Darwin
import CommandLineKit

let cli = CommandLineKit.CommandLine()
let day = IntOption(shortFlag: "d", longFlag: "day", required: true, helpMessage: "Which day of advent")
let part = IntOption(shortFlag: "p", longFlag: "part", required: true, helpMessage: "Which partof the puzzle")
cli.addOptions(day, part)

do {
  try cli.parse()
} catch {
  cli.printUsage(error)
  exit(1)
}

let theDay = day.value!
let thePart = part.value!

if thePart != 1 && thePart != 2 {
  print("Part \(thePart) is not a valid part number for Advent of Code")
  exit(1)
}

switch theDay {
  case 1:
  day1(part: thePart)

  default:
  print("No implementation for day \(theDay)")
  exit(1)
}
