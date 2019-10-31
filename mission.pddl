(define (problem problem-1-2)
  (:domain spaceport-domain)

	(:objects
		; Personnel
		Tretter - Captain
		Bunte Meachum - Navigator
		Hagarty Zayicek Penley - Engineer
		Elba - ScienceOfficer

		; Rooms + Doors
		Bridge - Bridge 
		Engineering - Engineering 
		Science-Lab - Sciencelab 
		Launch-Bay - LaunchBay 
		Airlock - Airlock
		Hallway-A  Hallway-B - Hallway
		No-Door Door-Airlock Door-Engi Door-Bridge Door-Science-Lab Door-Launch-Bay - Door
		
		; Regions of space
		Sol Proxima-Centauri Alpha-Centauri - Region
		Earth b Eden - Planet
		Ceres - AstroidBelt
		Pleiades - Nebula
		
		; Vehicles
		Mav-a Mav-x - MAV
		Probe-a Probe-x - Probe
		lander-a lander-x - Lander
		
		; physical objects and scan data
		EdenScan bScan - ProbeScan
		EdenSurfaceScan bSurfaceScan - LanderScan
		Ant-a Ant-b Ant-x Ant-y - Antenna
		plasma-ple - Plasma
		plasmascan-ple - PlasmaScan

		; mission and objectives
		Mission-1 - Mission
		objective-1 objective-2 objective-3 objective-4 - Objective

		; starports
		Bernal-1 Island-2 - Starport
	)

	(:init
		; init Personnel locations and busy status
		(Personnel-Loc Tretter Bridge)
		(Personnel-Loc Meachum Bridge)
		(Personnel-Loc Bunte Bridge)
		(Personnel-Loc Elba Science-Lab)
		(On-board Hagarty Mav-a)
		(Personnel-occupied Hagarty)
		(Personnel-Loc Zayicek Launch-Bay)

		; init ship interior rooms represent connections between rooms
		(door-connects Door-Bridge Hallway-B Bridge)
		(door-connects Door-Engi Hallway-A Engineering)
		(door-connects Door-Airlock Hallway-A Airlock)
		(door-connects Door-Science-Lab Hallway-B Science-Lab)
		(door-connects Door-Launch-Bay Hallway-A Launch-Bay)
		(door-connects No-Door Hallway-A Hallway-B)

		; init space, spaceports, and spaceport contents
		(In-region Sol Earth)
		(Home-starport Bernal-1)
		(Starport-location Bernal-1 Earth)
		(Starport-crew Penley Bernal-1)
		(Starport-vehicles mav-x Bernal-1)
		
		(In-region Sol Ceres)

		(In-region Proxima-Centauri b)
		(Obj-subregion bScan b)
		(Obj-subregion bSurfaceScan b)
		(Rads b)
		(Starport-location Island-2 b)
		(Starport-vehicles lander-x Island-2)
		(Starport-vehicles Probe-x Island-2)
		(Starport-item Ant-x Island-2)
		(Starport-item Ant-y Island-2)

		(In-region Alpha-Centauri Eden)

		(In-region Alpha-Centauri Pleiades)
		(Obj-subregion plasma-ple Pleiades)
		(Plasma-data plasmascan-ple plasma-ple)

		(In-region Alpha-Centauri Eden)
		(Obj-subregion EdenScan Eden)
		(Obj-subregion EdenSurfaceScan Eden)
		
		; init ship location
		(Ship-Location Sol)
		(Ship-docked Bernal-1)

		;init ship vehicles and the objects they carry
		(Vehicle-docked mav-a Launch-Bay)
		(Vehicle-docked Probe-a Launch-Bay)
		(Vehicle-docked lander-a Launch-Bay)
		(On-vehicle Ant-a lander-a)
		(On-vehicle Ant-b lander-a)

		;init objectives to satisfy the mission
		(Objective-deploy-vehicle objective-1 lander-x b)
		(Objective-scan objective-2 bScan)
		(Objective-scan objective-3 bSurfaceScan)
		(Objective-deploy-vehicle objective-4 lander-a Eden)
	)

	(:goal
		(and 
			(Mission-complete Mission-1)
		)
	)


)

