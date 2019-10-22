(define (problem problem-1-2)
  (:domain spaceport-domain)

	(:objects
		Tretter - Captain
		Bunte Meachum - Navigator
		Hagarty Zayicek Penley - Engineer
		Bridge - Bridge 
		Engineering - Engineering 
		Science-Lab - Scilab 
		Launch-Bay - LaunchBay 
		Hallway-A  Hallway-B - Hallway
		No-Door Door-Engi Door-Bridge Door-Science-Lab Door-Launch-Bay - Door
		Sol Proxima-Centauri Alpha-Centauri - Region
		Mercury Venus Earth Mars b - Planet
		Ceres - AstroidBelt
		Mav-a Mav-b - MAV
		Probe-a - Probe
	)

	(:init
		; init Personell
		(has-key Tretter)
		(Personell-Loc Tretter Science-Lab)
		(Personell-Loc Meachum Launch-Bay)
		(Personell-Loc Bunte Launch-Bay)
		(MAV-EVA Hagarty Mav-a)
		(MAV-EVA Zayicek Mav-b)
		(Personell-Loc Penley Engineering)

		; init ship interior rooms
		(door-connects Door-Bridge Hallway-B Bridge)

		(door-connects Door-Engi Hallway-A Engineering)

		(door-connects Door-Science-Lab Hallway-B Science-Lab)
		(door-locked Door-Science-Lab)

		(door-connects Door-Launch-Bay Hallway-A Launch-Bay)
		(door-locked Door-Launch-Bay)

		(door-connects No-Door Hallway-A Hallway-B)

		; init space
		(In-region Sol Mercury)
		(In-region Sol Venus)
		(In-region Sol Earth)
		(In-region Sol Mars)
		(In-region Sol Ceres)

		(In-region Proxima-Centauri b)


		; init ship location
		(Ship-Location Sol)
		(Ship-at-Subregion Earth)

		;init ship vehicles

		(Ship-damaged)

	)

	(:goal
		(and 
			(Probe-destroyed Probe-a)
			(Ship-at-Subregion b)
		)
	)


)

