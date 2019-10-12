(define (problem problem-1-1)
  (:domain spaceport-domain_micromove)

	(:objects
		Captain
		Navigator
		Picard
		La-Forge
		Bridge
		Engineering
		Science-Lab
		Launch-Bay
		Hallway-A
		Door-Engi
		Door-Bridge
		Door-Science-Lab
		Door-Launch-Bay
	)

	(:init
		; init Personell
		(Personell Picard)
		(Personell La-Forge)
		(has-rank Picard Captain)
		(has-rank La-Forge Navigator)
		(has-key Picard)
		(Personell-Loc Picard Science-Lab)
		(Personell-Loc La-Forge Launch-Bay)

		; init rooms
		(Spacecraft-has-room Bridge)
		(Spacecraft-has-room Engineering)
		(Spacecraft-has-room Science-Lab)
		(Spacecraft-has-room Launch-Bay)
		(Spacecraft-has-room Hallway-A)
		(Room-door-North Hallway-A Bridge)
		(Room-door-South Bridge Hallway-A)
		(door Door-Bridge)
		(Room-door-East Hallway-A Engineering)
		(Room-door-West Engineering Hallway-A)
		(door Door-Engi)
		(Room-door-South Hallway-A Science-Lab)
		(Room-door-North Science-Lab Hallway-A)
		(door Door-Science-Lab)
		(door-locked Door-Science-Lab)
		(Room-door-West Hallway-A Launch-Bay)
		(Room-door-East Launch-Bay Hallway-A)
		(door Door-Launch-Bay)

	)

	(:goal
		(and 
			(Personell-Loc Picard Bridge)
			(Personell-Loc La-Forge Bridge)
		)
	)


)

