(define (problem problem-1-1)
  (:domain spaceport-domain)

	(:objects
		Picard La-Forge - personell
		Bridge Engineering Science-Lab Launch-Bay Hallway-A - room
		Door-Engi Door-Bridge Door-Science-Lab Door-Launch-Bay - door
	)

	(:init
		; init Personell
		(Personell Picard)
		(Personell La-Forge)
		(is-captain Picard)
		(is-navigator La-Forge)
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
		(door-connects Door-Bridge Hallway-A Bridge)
		(door-connects Door-Bridge Bridge Hallway-A)
		(Room-door-East Hallway-A Engineering)
		(Room-door-West Engineering Hallway-A)
		(door Door-Engi)
		(door-connects Door-Engi Hallway-A Engineering)
		(door-connects Door-Engi Engineering Hallway-A)
		(Room-door-South Hallway-A Science-Lab)
		(Room-door-North Science-Lab Hallway-A)
		(door Door-Science-Lab)
		(door-connects Door-Science-Lab Hallway-A Science-Lab)
		(door-connects Door-Science-Lab Science-Lab Hallway-A)
		(door-locked Door-Science-Lab)
		(Room-door-West Hallway-A Launch-Bay)
		(Room-door-East Launch-Bay Hallway-A)
		(door Door-Launch-Bay)
		(door-connects Door-Launch-Bay Hallway-A Launch-Bay)
		(door-connects Door-Launch-Bay Launch-Bay Hallway-A)

	)

	(:goal
		(and 
			(Personell-Loc Picard Bridge)
			(Personell-Loc La-Forge Bridge)
		)
	)


)

