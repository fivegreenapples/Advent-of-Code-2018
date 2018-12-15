import Foundation

func day8(part: Int, testMode: Bool) -> String {
	let input = testMode ? day8TestInput : day8Input

	let numbers = input.split(separator:" ").map({ Int($0)! })

	let analysis: Int
	if part == 1 {
		analysis = analyseNodePart1(for: numbers, startingAt: 0).sum
	} else {
		analysis = analyseNodePart2(for: numbers, startingAt: 0).value
	}

	
	return "\(analysis)"

}


func analyseNodePart1(for input: [Int], startingAt offset: Int) -> (sum:Int, length:Int) {

	let children = input[offset]
	let metadataEntries = input[offset + 1]
	var nodeSum = 0

	var childOffset = 0
	for _ in 0..<children {
		let childAnalysis = analyseNodePart1(for: input, startingAt: offset+2+childOffset)
		nodeSum += childAnalysis.sum
		childOffset += childAnalysis.length
	}

	for m in 0..<metadataEntries {
		nodeSum += input[offset+2+childOffset+m]
	}

	return (nodeSum,2+childOffset+metadataEntries)
}

func analyseNodePart2(for input: [Int], startingAt offset: Int) -> (value:Int, length:Int) {

	let children = input[offset]
	let metadataEntries = input[offset + 1]
	var nodeValue = 0

	var childOffset = 0
	var childValues = [Int:Int]()
	if children > 0 {
		for c in 1...children {
			let childAnalysis = analyseNodePart2(for: input, startingAt: offset+2+childOffset)
			childValues[c] = childAnalysis.value
			childOffset += childAnalysis.length
		}
	}

	for m in 0..<metadataEntries {
		if children == 0 {
			nodeValue += input[offset+2+childOffset+m]
		} else {
			nodeValue += childValues[input[offset+2+childOffset+m], default:0]
		}
	}

	return (nodeValue,2+childOffset+metadataEntries)
}

