import Foundation

class Regex {
	let regex: NSRegularExpression
	init(pattern: String) {
		self.regex = try! NSRegularExpression(pattern: pattern)
	}

	func FindSubmatch(in input: String) -> [String] {
		guard let firstMatch = self.regex.firstMatch(in: input, options: [], range: NSMakeRange(0, input.count)) else {
			return []
		}

		var submatches = [String]()
		for i in 0..<firstMatch.numberOfRanges {
			if let thisRange = Range(firstMatch.range(at: i), in:input) {
				submatches.append(String(input[thisRange]))
			} else {
				submatches.append("")
			}
		}

		return submatches
	}
}