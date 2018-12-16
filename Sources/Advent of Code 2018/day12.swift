func day12(part: Int, testMode: Bool) -> String {
	let input = testMode ? day12TestInput : day12Input

	// parsedInput provides the initial state and the set of plant states that
	// produce a plant on the next generation.
	let parsedInput = parseInput(input)
	let generations = part == 1 ? 20 : 50000000000
	var theTunnel = Tunnel(fromInitialState: parsedInput.initialState, andProducers: parsedInput.plantProducers)
	var currentPlantLayout = theTunnel.renderToString()
	for g in 1...generations {
		theTunnel.runOneGeneration()
		if part == 2 {
			print("\(g): ", terminator: "")
			theTunnel.render()
			let thisPlantLayout = theTunnel.renderToString()
			if thisPlantLayout[1...] == currentPlantLayout {

				// this means the plants have started a repeating sequence, 
				// shifted along one pot every generation.
				let currentSum = theTunnel.sumPots()
				let currentPlantCount = theTunnel.countPlants()
				let finalSum = currentSum + ( (generations - g) * currentPlantCount )
				return "\(finalSum)"
			}
			currentPlantLayout = thisPlantLayout
		} else if testMode {
			theTunnel.render(from: -3)
		}

	}

	return "\(theTunnel.sumPots())"
}

struct Tunnel {
	var pots: [Bool]
	var plantProducers: Set<Int>
	var zeroOffset = 0
	init(fromInitialState state: String, andProducers producers: Set<String>) {
		// init plant array with 20 entries to represent -20 to -1
		pots = [Bool]()
		plantProducers = Set<Int>()

		state.forEach({ char in
			pots.append(char == "#" ? true : false)
		})

		for p in producers {
			var prodVal = 0
			for (charIndex,char) in p.reversed().enumerated() {
				if char == "#" {
					prodVal += (1 << charIndex)
				}
			}
			plantProducers.insert(prodVal)
		}
		extendPotsAsNecessary()
	}

	mutating func extendPotsAsNecessary() {
		// make sure both ends of the pots array has sufficient empty pots
		if let firstPlant = pots.firstIndex(of: true), firstPlant < 4 {
			self.pots.insert(contentsOf: [Bool](repeating: false, count: 4 - firstPlant), at: 0)
			zeroOffset += (4 - firstPlant)
		}
		if let lastPlant = pots.lastIndex(of: true), lastPlant > pots.count-5 {
			self.pots.insert(contentsOf: [Bool](repeating: false, count: 5 - (pots.count - lastPlant)), at: pots.count)
		}
	}

	mutating func runOneGeneration() {
		var currentPots = pots
		for pIndex in 0..<(pots.count-4) {
			var testVal = 0
			if pots[pIndex] {
				testVal += 0b10000
			}
			if pots[pIndex + 1] {
				testVal += 0b1000
			}
			if pots[pIndex + 2] {
				testVal += 0b100
			}
			if pots[pIndex + 3] {
				testVal += 0b10
			}
			if pots[pIndex + 4] {
				testVal += 0b1
			}
			currentPots[pIndex+2] = plantProducers.contains(testVal)
		}
		pots = currentPots
		extendPotsAsNecessary()
	}

	func sumPots() -> Int {
		return pots.enumerated().reduce(0, { current, next in
			return current + ( next.element ? next.offset-zeroOffset : 0 )
		})
	}
	func countPlants() -> Int {
		return pots.count(where: { $0 })
	}


	func render(from potNumber: Int) {
		for p in pots[zeroOffset+potNumber..<pots.count] {
			print(p ? "#" : ".", terminator:"")
		}
		print()
	}
	func render() {
		print(renderToString())
	}
	func renderToString() -> String {
		var str = ""
		for p in pots[0..<pots.count] {
			str += (p ? "#" : ".")
		}
		return str
	}
}

func parseInput(_ input: String) -> (initialState:String, plantProducers:Set<String>) {

	// note: .split omits empty sequences by default
	let inputStrings = input.split(separator: "\n").map({ String($0) })
	let initialState = String(inputStrings[0][15...])

	var plantSet = Set<String>()
	for s in inputStrings[1...] {
		if s[9...9] == "#" {
			plantSet.insert(String(s[0...4]))
		}
	}

	return (initialState, plantSet)


}