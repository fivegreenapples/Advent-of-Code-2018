
func day2(part: Int) -> String {

	let day2Ids = day2Input.split(separator: "\n")

	if part == 1 {
		let counts = day2Ids.reduce(into: (two:Int,three:Int)(0,0)) { counts, id in

			let letterCount = id.reduce(into: [:]) { counts, letter in
				counts[letter, default: 0] += 1
			}

			let (hasTwoCount, hasThreeCount) = letterCount.reduce((false, false)) { current, charAndCount in
				(
					current.0 || charAndCount.value == 2,
					current.1 || charAndCount.value == 3
				)
			}

			if hasTwoCount {
				counts.two += 1
			}
			if hasThreeCount {
				counts.three += 1
			}
		}

		return String(counts.two * counts.three)
	}


	for iA in 0..<(day2Ids.count-1) {
		
		for iB in (iA+1)..<day2Ids.count {

			let a = String(day2Ids[iA])
			let b = String(day2Ids[iB])

			if diffId(a, b) == 1 {
				return sharedId(a, b)
			}
		}
	}

	return "no result :("

}

func diffId(_ a: String, _ b: String) -> UInt {
	var diff: UInt = 0
	for i in a.indices {
		if a[i] != b[i] {
			diff += 1
		}
	}
	return diff
}

func sharedId(_ a: String, _ b: String) -> String {
	var str = ""
	for i in a.indices {
		if a[i] == b[i] {
			str += String(a[i])
		}
	}
	return str
}
