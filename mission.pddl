(define (problem problem-1-2)
  (:domain spaceport-domain)

	(:objects
		Tretter - Captain
		Bunte Meachum - Navigator
		Hagarty Zayicek Penley - Engineer
		Elba - ScienceOfficer
		Bridge - Bridge 
		Engineering - Engineering 
		Science-Lab - Sciencelab 
		Launch-Bay - LaunchBay 
		Hallway-A  Hallway-B - Hallway
		No-Door Door-Engi Door-Bridge Door-Science-Lab Door-Launch-Bay - Door
		Sol Proxima-Centauri Alpha-Centauri - Region
		Mercury Venus Earth Mars b Eden - Planet
		Ceres - AstroidBelt
		Pleiades - Nebula
		Mav-a Mav-b - MAV
		Probe-a - Probe
		lander-a - Lander
		EdenScan - PlanetScan

	)

	(:init
		; init Personell
		(Personell-Loc Tretter Science-Lab)
		(Personell-Loc Meachum Launch-Bay)
		(Personell-Loc Bunte Launch-Bay)
		(personell-Loc Elba Bridge)
		(On-board Mav-a Hagarty)
		(On-board Mav-b Zayicek)
		(Personell-Loc Penley Engineering)

		; init ship interior rooms
		(door-connects Door-Bridge Hallway-B Bridge)

		(door-connects Door-Engi Hallway-A Engineering)

		(door-connects Door-Science-Lab Hallway-B Science-Lab)

		(door-connects Door-Launch-Bay Hallway-A Launch-Bay)

		(door-connects No-Door Hallway-A Hallway-B)

		; init space
		(In-region Sol Mercury)
		(In-region Sol Venus)
		(In-region Sol Earth)
		(In-region Sol Mars)
		(In-region Sol Ceres)

		(In-region Proxima-Centauri b)

		(In-region Alpha-Centauri Eden)

		(In-region Alpha-Centauri Pleiades)
		(Scan-Loc EdenScan Eden)
		
		; init ship location
		(Ship-Location Sol)
		(Ship-at-Subregion Earth)

		;init ship vehicles
		(Vehicle-deployed mav-a Earth)
		(Vehicle-docked mav-b Launch-Bay)
		(Vehicle-docked Probe-a Launch-Bay)
		(Vehicle-docked lander-a Launch-Bay)
		(Ship-damaged)

	)

	(:goal
		(and 
			(Vehicle-destroyed Probe-a)
			(Ship-at-Subregion b)
			
		)
	)


)

