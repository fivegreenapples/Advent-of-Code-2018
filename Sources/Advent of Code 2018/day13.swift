func day13(part: Int, testMode: Bool) -> String {
	let input = testMode ? (part == 1 ? day13TestInput : day13Part2TestInput ) : day13Input


	var (map, carts) = parseDay13Input(input)

	if testMode {
		renderMap(map, withCarts: carts)
	}

	var hasCollided = false
	var answerPosition = ""
	repeat {
		let sortedCartPositions = carts.keys.sorted(by: { A, B in
			return A.y == B.y ? A.x < B.x : A.y < B.y
		})
		for cartPos in sortedCartPositions {
			guard var cart = carts[cartPos] else {
				// we might have removed a collision
				continue
			}
			var newCartPos = cartPos
			var newCartDir = cart.direction
			var newCartNextTurn = cart.nextTurn

			switch cart.direction {
				case .North:
				newCartPos = Coord(cartPos.x, cartPos.y-1)
				case .South:
				newCartPos = Coord(cartPos.x, cartPos.y+1)
				case .East:
				newCartPos = Coord(cartPos.x+1, cartPos.y)
				case .West:
				newCartPos = Coord(cartPos.x-1, cartPos.y)
			}

			let newTrack = map[newCartPos]!
			var rotate = 0
			switch newTrack {
				case .EastWest, .NorthSouth:
				break
				case .UpLeft:
				switch cart.direction {
					case .North, .South:
						rotate = 2 // anti-clockwise
					case .East, .West:
						rotate = 1 // clockwise
				}
				case .UpRight:
				switch cart.direction {
					case .North, .South:
						rotate = 1 // clockwise
					case .East, .West:
						rotate = 2 // anti-clockwise
				}
				case .Intersection:
				switch cart.nextTurn {
					case .Left:
						rotate = 2 // anti-clockwise
						newCartNextTurn = .Straight
					case .Straight:
						newCartNextTurn = .Right
					case .Right:
						rotate = 1 // clockwise
						newCartNextTurn = .Left
				}
			}

			if rotate == 1 { // clockwise
				switch cart.direction {
					case .North:
						newCartDir = .East
					case .South:
						newCartDir = .West
					case .East:
						newCartDir = .South
					case .West:
						newCartDir = .North
				}
			} else if rotate == 2 { // anticlockwise
				switch cart.direction {
					case .North:
						newCartDir = .West
					case .South:
						newCartDir = .East
					case .East:
						newCartDir = .North
					case .West:
						newCartDir = .South
				}
			}

			carts.removeValue(forKey: cartPos)
			cart.direction = newCartDir
			cart.nextTurn = newCartNextTurn

			// check for collisions
			if carts[newCartPos] != nil {
				// boom
				if part == 1 {
					hasCollided = true
					cart.collision = true
					answerPosition = "\(newCartPos.x),\(newCartPos.y)"
					carts[newCartPos] = cart
					break
				} else {
					// clear up collided carts
					carts.removeValue(forKey: newCartPos)
					continue
				}
			}


			carts[newCartPos] = cart


		}
		if testMode {
			renderMap(map, withCarts: carts)
		}
		// At end of tick check if we have only one cart remaming
		if carts.count <= 1 {
			break
		}
	} while !hasCollided

	if part == 2 {
		// our answer is the coord of the one remaining cart
		if carts.count == 0 {
			preconditionFailure("No carts left?!")
		}
		let remainingCartPos = carts.first!.key
		answerPosition = "\(remainingCartPos.x),\(remainingCartPos.y)"
	}

	return "\(answerPosition)"
}


enum TrackType: Character {
	case EastWest = "-"
	case NorthSouth = "|"
	case UpLeft = "\\"
	case UpRight = "/"
	case Intersection = "+"
}
enum Direction: Character {
	case North = "^"
	case South = "v"
	case East = ">"
	case West = "<"
}
enum TurnType {
	case Left
	case Straight
	case Right
}

struct Cart {
	var direction: Direction
	var nextTurn = TurnType.Left
	var collision = false
	init(withDirection d: Direction) {
		direction = d
	}
}

func renderMap(_ map: [Coord:TrackType], withCarts carts: [Coord:Cart]) {

	for y in 0..<8 {
		for x in 0..<15 {
			let thisCoord = Coord(x,y)
			let toPrint: Character
			if let cart = carts[thisCoord] {
				if cart.collision {
					toPrint = "X"
				} else {
					toPrint = cart.direction.rawValue
				}
			} else if let track = map[thisCoord] {
				toPrint = track.rawValue
			} else {
				toPrint = " "
			}
			print(toPrint, terminator:"")
		}
		print()
	}
}
func renderMap(_ map: [Coord:TrackType]) {

	renderMap(map, withCarts: [Coord:Cart]())

}


func parseDay13Input(_ input: String) -> (map:[Coord:TrackType], carts:[Coord:Cart]) {

	let rows = input.split(separator: "\n")
	var map = [Coord:TrackType]()
	var carts = [Coord:Cart]()

	for (y,row) in rows.enumerated() {
		for (x,char) in row.enumerated() {
			if char == " " {
				continue;
			}

			if let cart = Direction(rawValue: char) {
				carts[Coord(x,y)] = Cart(withDirection: cart)
				map[Coord(x,y)] = (cart == .North || cart == .South) ? .NorthSouth : .EastWest
			} else if let track = TrackType(rawValue: char) {
				map[Coord(x,y)] = track
			} else {
				preconditionFailure("Character \(char) not understood in input")
			}
 		}
	}

	return (map,carts)
}