func day7(part: Int, testMode: Bool) -> String {
	let input = testMode ? day7TestInput : day7Input

	// Parse input to get list of steps - a tuple of two steps where the first
	// in the tuple must be completed before the second.
	let steps = parseDay7Input(input)

	// convert list of steps to a map of step to step requirements
	let stepRequirements = steps.reduce(into: [String:Set<String>]()) { reqs, stepTuple in
		// Indicate that .1 depends on .0
		reqs[stepTuple.1, default: Set<String>()].insert(stepTuple.0)
		// Ensure .0 is in the map so we reccord any steps that have no dependencies
		if reqs[stepTuple.0] == nil {
			reqs[stepTuple.0] = Set<String>()
		}
	}

	if part == 1 {
		return part1(reqs: stepRequirements)
	}
	return part2(testMode, reqs: stepRequirements)

}

func part1(reqs stepRequirements: [String:Set<String>]) -> String {

	var reqs = stepRequirements

	var stepExecutionSequence = [String]()
	repeat {

		var potentialJobs = [String]()

		for (step, stepReqs) in reqs {
			if stepReqs.isEmpty {
				potentialJobs.append(step)
			}
		}

		if potentialJobs.isEmpty {
			break
		}

		let nextStep = potentialJobs.min()!
		reqs.removeValue(forKey: nextStep)
		stepExecutionSequence.append(nextStep)

		for (step, _) in reqs {
			reqs[step]!.remove(nextStep)
		}

	} while true



	return stepExecutionSequence.joined()

}


func part2(_ testMode: Bool, reqs stepRequirements: [String:Set<String>]) -> String {

	var workers: [Int:Int]
	if testMode {
		workers = [1:0, 2:0]
	} else {
		workers = [1:0, 2:0, 3:0, 4:0, 5:0]
	}

	var reqs = stepRequirements
	var inprogressJobs = [String:Int]()
	var second = 0

	var stepExecutionSequence = [String]()
	repeat {

		var availableWorkers = [Int]()
		for (workerId, secondBecameAvailable) in workers {
			if secondBecameAvailable <= second {
				availableWorkers.append(workerId)
			}
		}
		// check for available workers
		if availableWorkers.count > 0 {

			var potentialJobs = [String]()

			for (step, stepReqs) in reqs {
				if stepReqs.isEmpty {
					potentialJobs.append(step)
				}
			}

			if potentialJobs.isEmpty && inprogressJobs.isEmpty {
				// we must have finished
				break
			}

			// sort jobs so next one is last in list - so we can use pop
			potentialJobs.sort(by: >)
			repeat {
				guard let nextStep = potentialJobs.popLast() else {
					break
				}
				guard let nextWorker = availableWorkers.popLast() else {
					break
				}
				// set the worker to be next available at the appropriate time
				workers[nextWorker] = second + timeForStep(nextStep, inTestMode:testMode)
				// mark job as in progress with appropriate number of seconds
				inprogressJobs[nextStep] = timeForStep(nextStep, inTestMode:testMode)
				// remove job from the requirements map so it isn't considered again
				reqs.removeValue(forKey: nextStep)
			} while true

		}


		// now consider the second to have elapsed
		// loop over inprogress jobs and decrement remaining count.
		// if any are considered finished then remove from in progress and remove
		// from requirements
		// and mark in the execution sequence
		for (inProgressStep, remaining) in inprogressJobs {
			inprogressJobs[inProgressStep] = remaining - 1
			if remaining == 1 {
				for (step, _) in reqs {
					reqs[step]!.remove(inProgressStep)
				}
				// append job to execution sequence
				stepExecutionSequence.append(inProgressStep)
			}
		}
		inprogressJobs = inprogressJobs.filter({ $1 > 0 })

		// finally increment the second
		second += 1

	} while true

	if testMode {
		print("Execution sequence is:", stepExecutionSequence.joined(), "in:", second, "seconds")
	}

	return "\(second)"
}





func parseDay7Input(_ input: String) -> [(String,String)] {
	let regex = Regex(pattern: "^Step ([A-Z]) must be finished before step ([A-Z]) can begin.$")

	return input
			.split(separator: "\n")
			.map({ instruction in
				let steps = regex.FindSubmatch(in: instruction)
				return (steps[1], steps[2])
			})

}

func timeForStep(_ step: String, inTestMode testMode: Bool) -> Int {
	let ascii = Int(UInt8(ascii: step.first!.unicodeScalars.first!))
	return testMode ? ascii - 64 : ascii - 4
}