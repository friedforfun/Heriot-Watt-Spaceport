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
		EdenScan bScan - ProbeScan
		EdenSurfaceScan - LanderScan
		Ant-a Ant-b - Antenna
		plasma-ple - Plasma
		plasmascan-ple - PlasmaScan

		objective-1 objective-2 - Objective


	)

	(:init
		; init Personnel
		(Personnel-Loc Tretter Bridge)
		(Personnel-Loc Meachum Bridge)
		(Personnel-Loc Bunte Bridge)
		(Personnel-Loc Elba Science-Lab)
		(On-board Hagarty Mav-a)
		(Personnel-occupied Hagarty)
		(Personnel-Loc Zayicek Launch-Bay)
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
		(Obj-subregion bScan b)

		(In-region Alpha-Centauri Eden)

		(In-region Alpha-Centauri Pleiades)
		(Obj-subregion plasma-ple Pleiades)
		(Plasma-data plasmascan-ple plasma-ple)

		(In-region Alpha-Centauri Eden)
		(Obj-subregion EdenScan Eden)
		(Obj-subregion EdenSurfaceScan Eden)
		
		; init ship location
		(Ship-Location Sol)
		(Ship-at-Subregion Earth)

		;init ship vehicles
		(Vehicle-docked mav-a Launch-Bay)
		(Vehicle-docked mav-b Launch-Bay)
		(Vehicle-docked Probe-a Launch-Bay)
		(Vehicle-docked lander-a Launch-Bay)
		(On-vehicle Ant-a lander-a)
		(On-vehicle Ant-b lander-a)

		;init objective
		(Objective-scan objective-1 EdenSurfaceScan)
		(Objective-retrieve-plasmadata objective-2 plasmascan-ple)
			
	)

	(:goal
		(and 
			;(Vehicle-destroyed Probe-a)
			;(Vehicle-disabled Mav-b)
			;(On-ship plasma-ple Science-Lab)
			;(Antenna-deployed Ant-a Eden)
			;(On-vehicle EdenSurfaceScan lander-a)
			;(On-ship EdenScan Computer)
			;(On-vehicle EdenScan lander-a)
			;(lander-on-surface lander-a Eden)

			;(On-ship EdenSurfaceScan Computer)
			;(On-ship plasmascan-ple Computer)
			;(Vehicle-destroyed lander-a)
			(Objective-complete objective-1)
			(Objective-complete objective-2)

			(Ship-at-Subregion Earth)
		)
	)


)

