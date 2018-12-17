func day14(part: Int, testMode: Bool) -> String {
	let input = testMode ? (part == 1 ? day14TestInput : day14Part2TestInput) : day14Input

	var recipes = [Int]()
	recipes.append(3)
	recipes.append(7)
	var elf1Idx = 0
	var elf2Idx = 1

	if part == 1 {

		repeat {
			let newRecipe = recipes[elf1Idx] + recipes[elf2Idx]
			if newRecipe < 10 {
				recipes.append(newRecipe)
			} else {
				recipes.append(1)
				recipes.append(newRecipe-10)
			}

			elf1Idx = (elf1Idx + 1 + recipes[elf1Idx]) % recipes.count
			elf2Idx = (elf2Idx + 1 + recipes[elf2Idx]) % recipes.count
		} while recipes.count < (input + 10)

		return recipes[input..<input+10].map({ String($0) }).joined()
	}

	// convert input to array of ints
	let compare = String(input).map({ Int(String($0))! })
	repeat {
		let newRecipe = recipes[elf1Idx] + recipes[elf2Idx]
		if newRecipe < 10 {
			recipes.append(newRecipe)
			if recipes.count > compare.count && recipes[(recipes.count-compare.count)...].elementsEqual(compare) {
				break
			}
		} else {
			recipes.append(1)
			if recipes.count > compare.count && recipes[(recipes.count-compare.count)...].elementsEqual(compare) {
				break
			}
			recipes.append(newRecipe-10)
			if recipes.count > compare.count && recipes[(recipes.count-compare.count)...].elementsEqual(compare) {
				break
			}
		}

		elf1Idx = (elf1Idx + 1 + recipes[elf1Idx]) % recipes.count
		elf2Idx = (elf2Idx + 1 + recipes[elf2Idx]) % recipes.count

	} while true

	return "\(recipes.count - compare.count)"

}

