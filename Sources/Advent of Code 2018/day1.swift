func day1(part: Int) -> String {

	let day1Deltas = day1Input.split(separator: "\n").map { Int($0)! }


	if part == 1 {
		//
		// Part 1
		//
		return String(day1Deltas.reduce(0, { $0 + $1 }))
	}


	//
	// Part 2
	//
	var curFreq = 0
	var seenFreqs = Set<Int>()
	var foundDupe = false

	while !foundDupe {
		for delta in day1Deltas {
			if seenFreqs.contains(curFreq) {
				foundDupe = true
				break
			}
			seenFreqs.insert(curFreq)
			curFreq += delta
		}
	}

	return String(curFreq)
}


