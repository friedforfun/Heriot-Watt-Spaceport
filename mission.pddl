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
		Airlock - Airlock
		Hallway-A  Hallway-B - Hallway
		No-Door Door-Airlock Door-Engi Door-Bridge Door-Science-Lab Door-Launch-Bay - Door
		Sol Proxima-Centauri Alpha-Centauri - Region
		Earth b Eden - Planet
		Ceres - AstroidBelt
		Pleiades - Nebula
		Mav-a Mav-x - MAV
		Probe-a - Probe
		lander-a lander-x - Lander
		EdenScan bScan - ProbeScan
		EdenSurfaceScan bSurfaceScan - LanderScan
		Ant-a Ant-b Ant-x Ant-y - Antenna
		plasma-ple - Plasma
		plasmascan-ple - PlasmaScan

		Mission-1 - Mission
		objective-1 - Objective
		;objective-2 objective-3 objective-4 objective-5 - Objective

		Bernal-1 Island-2 - Starport
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

		; init ship interior rooms
		(door-connects Door-Bridge Hallway-B Bridge)

		(door-connects Door-Engi Hallway-A Engineering)
		(door-connects Door-Airlock Hallway-A Airlock)
		(door-connects Door-Science-Lab Hallway-B Science-Lab)

		(door-connects Door-Launch-Bay Hallway-A Launch-Bay)

		(door-connects No-Door Hallway-A Hallway-B)

		; init space

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

		;init ship vehicles
		(Vehicle-docked mav-a Launch-Bay)
		(Vehicle-docked Probe-a Launch-Bay)
		(Vehicle-docked lander-a Launch-Bay)
		(On-vehicle Ant-a lander-a)
		(On-vehicle Ant-b lander-a)

		;init objective
		(Objective-scan objective-1 EdenSurfaceScan)
		;(Objective-retrieve-plasmadata objective-2 plasmascan-ple)
		;(Objective-visit-subregion objective-3 b)
		;(Objective-deploy-vehicle objective-4 lander-x Pleiades)
		;(Objective-scan objective-5 bSurfaceScan)
	)

	(:goal
		(and 
			;(Vehicle-destroyed Probe-a)
			;(Vehicle-disabled Mav-b)
			;(On-ship plasma-ple Science-Lab)
			;(Antenna-deployed Ant-a Eden)
			;(On-vehicle EdenSurfaceScan lander-a)
			;(On-vehicle bSurfaceScan lander-x)
			;(On-ship EdenScan Computer)
			;(On-vehicle EdenScan lander-a)
			;(lander-on-surface lander-a Eden)
			;(On-ship Ant-x Airlock)
			;(On-ship Ant-y Airlock)

			;(On-ship EdenSurfaceScan Computer)
			;(On-ship plasmascan-ple Computer)
			;(Vehicle-destroyed lander-a)
			;(Objective-complete objective-1)
			;(Objective-complete objective-2)
			;(Objective-complete objective-3)
			;(Objective-complete objective-4)
			;(Objective-complete objective-5)

			(Mission-control EdenSurfaceScan)
		)
	)


)

