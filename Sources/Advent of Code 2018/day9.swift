func day9(part: Int, testMode: Bool) -> String {
	let input = testMode ? day9TestInput : day9Input
	
	let allGames = parseDay9Input(input)
	var highestScore = 0
	
	for (gameNum, game) in allGames.enumerated() {

		let numPlayers = game.players
		let finalMarble = part == 2 ? game.lastMarble * 100 : game.lastMarble

		// init game
		
		// create zero marble
		let zero = Marble(withValue: 0)

		// init game state
		var current = zero
		current.previous = current
		current.next = current
		var nextMarble = 1
		var currentPlayer = 1
		var playerScores = [Int:Int]()
		highestScore = 0

		// main game loop
		while nextMarble <= finalMarble {

			if testMode && gameNum == 0 && part == 1 {
				var curPrint = zero
				print("[\(currentPlayer)] ", terminator: "")
				repeat {
					if current.value == curPrint.value {
						print(" (\(curPrint.value))", terminator: "")
					} else {
						print("  \(curPrint.value)", terminator: "")
					}
					curPrint = curPrint.next!
				} while curPrint.value != 0
				print()
			}

			if nextMarble % 23 == 0 {
				// scoring round
				// give current player this marbles value
				playerScores[currentPlayer, default:0] += nextMarble
				// move current marble back 7
				for _ in 1...7 {
					current = current.previous!
				}
				// also give current player the value of the new current marble
				playerScores[currentPlayer, default:0] += current.value
				// set high score
				if playerScores[currentPlayer, default:0] > highestScore {
					highestScore = playerScores[currentPlayer, default:0]
				}
				// remove current
				current.previous!.next = current.next
				current = current.next!
			} else {
				// insertion round
				// move current to next insert pos
				current = current.next!
				// init new marble
				let thisMarble = Marble(withValue: nextMarble)
				thisMarble.previous = current
				thisMarble.next = current.next
				// insert
				current.next!.previous = thisMarble
				current.next = thisMarble

				current = thisMarble
			}

			nextMarble += 1
			currentPlayer = (currentPlayer % numPlayers) + 1
		}

		if testMode {
			print("High score is:", highestScore)
		}
	}



	return "\(highestScore)"


}

class Marble {
	let value: Int
	var previous: Marble? = nil
	var next: Marble? = nil
	init(withValue val:Int) {
		self.value = val
	}
}


typealias GameSetup = (players: Int, lastMarble: Int)

func parseDay9Input(_ input: String) -> [GameSetup] {

	// 9 players; last marble is worth 25 points
	let regex = Regex(pattern:"^([0-9]+) players; last marble is worth ([0-9]+) points$")

	return input.split(separator: "\n").map({ gameDesc in
		let matches = regex.FindSubmatch(in: gameDesc)
		return (players: Int(matches[1])!, lastMarble: Int(matches[2])!)
	})

}