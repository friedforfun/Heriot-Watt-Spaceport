(define (problem problem-1-2)
  (:domain spaceport-domain_macromove)

	(:objects
		Picard - Captain
		La-Forge - Navigator
		Bridge - Bridge Engineering - Engineering Science-Lab - Scilab Launch-Bay - Laubay Hallway-A - Hallway
		Door-Engi Door-Bridge Door-Science-Lab Door-Launch-Bay - door
		Sol Proxima-Centauri Alpha-Centauri - region
		Mercury Venus Earth Mars b - planet
	)

	(:init
		; init Personell
		(has-key Picard)
		(Personell-Loc Picard Science-Lab)
		(Personell-Loc La-Forge Launch-Bay)

		; init ship interior rooms
		(Room-Adjacent  Hallway-A Bridge)
		(Room-Adjacent  Bridge Hallway-A)
		(door Door-Bridge)
		(door-connects Door-Bridge Hallway-A Bridge)
		(door-connects Door-Bridge Bridge Hallway-A)

		(Room-Adjacent Hallway-A Engineering)
		(Room-Adjacent Engineering Hallway-A)
		(door Door-Engi)
		(door-connects Door-Engi Hallway-A Engineering)
		(door-connects Door-Engi Engineering Hallway-A)

		(Room-Adjacent  Hallway-A Science-Lab)
		(Room-Adjacent  Science-Lab Hallway-A)
		(door Door-Science-Lab)
		(door-connects Door-Science-Lab Hallway-A Science-Lab)
		(door-connects Door-Science-Lab Science-Lab Hallway-A)
		(door-locked Door-Science-Lab)

		(Room-Adjacent Hallway-A Launch-Bay)
		(Room-Adjacent Launch-Bay Hallway-A)
		(door Door-Launch-Bay)
		(door-connects Door-Launch-Bay Hallway-A Launch-Bay)
		(door-connects Door-Launch-Bay Launch-Bay Hallway-A)
		(door-locked Door-Launch-Bay)

		; init space
		(Space-region Sol)
		(region-planet Sol Mercury)
		(region-planet Sol Venus)
		(region-planet Sol Earth)
		(region-planet Sol Mars)

		(Space-region Proxima-Centauri)
		(region-planet Proxima-Centauri b)

		(Space-region Alpha-Centauri)

		; init ship location
		(Ship-Location Sol)
		(Ship-at-planet Earth)

	)

	(:goal
		(and 
			(Ship-at-planet b)
		)
	)


)

