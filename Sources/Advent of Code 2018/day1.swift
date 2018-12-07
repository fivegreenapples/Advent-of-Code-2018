func day1(part: Int) {

	if part == 1 {
		print(day1Input.reduce(0, { 
			cur, next
			in 
			cur + next
		}))
	}

	if part == 2 {

		var curFreq = 0
		var seenFreqs = Set<Int>()
		var foundDupe = false

		while !foundDupe {
			for delta in day1Input {
				if seenFreqs.contains(curFreq) {
					foundDupe = true
					break
				}
				seenFreqs.insert(curFreq)
				curFreq += delta
			}
		}

		print(curFreq)
	}
}


