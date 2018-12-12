func day5(part: Int, testMode: Bool) -> String {
	let input = testMode ? day5TestInput : day5Input

	if input.count <= 1 {
		return input
	}

	let reactedPolymer: String
	if part == 1 {
		reactedPolymer = reactPolymer(input, ignoring: "*")
	} else {
		reactedPolymer = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map {
			reactPolymer(input, ignoring:$0)
		}.min(by: { $0.count < $1.count} )!
	}

	if testMode {
		print("\nResulting string is:")
		print(reactedPolymer)
	}

	return "\(reactedPolymer.count)"
}

func reactPolymer(_ polymer: String, ignoring ignoreChar: Character) -> String {

	var bytes = [UInt8](polymer.utf8)
	let ignoreByte = UInt8(ascii: ignoreChar.unicodeScalars.first!)
	var editPos = -1
	var currentPos = 0

	repeat {
		if bytes[currentPos] != ignoreByte && bytes[currentPos] != (ignoreByte+32) {
			if editPos >= 0 && abs(Int(bytes[editPos]) - Int(bytes[currentPos])) == 32 {
				editPos -= 1
			} else {
				editPos += 1
				bytes[editPos] = bytes[currentPos]
			}
		}
		currentPos += 1
	} while currentPos < bytes.count

	return String(bytes: bytes[0...editPos], encoding: .utf8)!
}