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
			submatches.append(String(input[Range(firstMatch.range(at: i), in:input)!]))
		}

		return submatches
	}
}