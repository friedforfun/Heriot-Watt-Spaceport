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
		EdenScan bScan - PlanetScan
		Ant-a Ant-b - Antenna


	)

	(:init
		; init Personnel
		(Personnel-Loc Tretter Science-Lab)
		(Personnel-Loc Meachum Launch-Bay)
		(Personnel-Loc Bunte Launch-Bay)
		(Personnel-Loc Elba Bridge)
		(On-board Hagarty Mav-a)
		(Personnel-occupied Hagarty)
		(On-board Zayicek Mav-b)
		(Personnel-occupied Zayicek)
		(Personnel-Loc Penley Engineering)

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
		(Scan-Loc bScan b)

		(In-region Alpha-Centauri Eden)

		(In-region Alpha-Centauri Pleiades)
		(In-region Alpha-Centauri Eden)
		(Probe-scan EdenScan Eden)
		
		; init ship location
		(Ship-Location Sol)
		(Ship-at-Subregion Earth)

		;init ship vehicles
		;(Vehicle-deployed mav-a Earth)
		(Vehicle-docked mav-a Launch-Bay)
		(Vehicle-docked mav-b Launch-Bay)
		(Vehicle-docked Probe-a Launch-Bay)
		(Vehicle-docked lander-a Launch-Bay)
		(On-vehicle Ant-a lander-a)
		(On-vehicle Ant-b lander-a)
		(Ship-damaged)

	)

	(:goal
		(and 
			(Vehicle-destroyed Probe-a)
			(Vehicle-disabled Mav-b)
			(Lander-on-surface lander-a Eden)
			(Ship-at-Subregion b)
			
		)
	)


)

