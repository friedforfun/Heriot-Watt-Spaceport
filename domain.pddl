;
; Spaceport domain
; Sam Fay-Hunt SF52
;

(define (domain spaceport-domain)
  (:requirements
    :strips
    :typing
    :equality
    :conditional-effects
    :adl
  )

  (:types Captain Navigator Engineer ScienceOfficer - Personnel 
    Bridge Engineering Sciencelab LaunchBay Hallway Airlock Computer - Room
    MAV Probe Lander - Vehicle
    Door
    OnShip Empty Nebula AstroidBelt Planet - Subregion
    Plasma Antenna Scan - Object
    ProbeScan LanderScan PlasmaScan - Scan ; can upload scans
    Region
    Objective
    Mission
    Starport
  )

  (:constants Computer - Computer)                      

  (:predicates
    ; ------------ Space predicates -------------------------
    (In-region ?sp - Region ?s2 - Subregion)          	  ; inside this region is this subregion
    (Rads ?sr - Planet)								                ; radiation is present on planet surface
    (Starport-location ?sp - Starport ?sb - Subregion)    ; Location of the spaceport
    (Ship-docked ?sp - Starport)
    (Starport-vehicles ?ve - vehicle ?sp - Starport)
    (Starport-crew ?p - Personnel ?sp - Starport)
    (Starport-item ?obj - Object ?sp - Starport)
    (Home-starport ?st - Starport)
    (Mission-control ?S - Scan)


    ; ------------ Personnel predicates ---------------------
    (Personnel-occupied ?p - Personnel)               	  ; Personnel is engaged, cannot move room
    (holding ?p - Personnel ?obj - Object)			          ; Personnel is holding an object
    (Personnel-Loc ?p - Personnel ?sr - Room)             ; location of Personnel on ship

    ; ------------ Ship interior predicates ------------------
    (door-connects ?d - Door ?ra - Room ?rb - Room)   	  ; door joins these rooms

    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - Region)                      	  ; ship is located in region
    (Ship-at-Subregion ?pn - Subregion)               	  ; ship is located at a subregion of region
    (Ship-damaged)                                    	  ; ship is damaged
    (Ship-clear)                         				          ; ship is outside of a subregeion 
    (Depart-OK)                                       	  ; ship cannot leave region until vehicles are back on board

    ; ------------- Engineering predicates -----------------
    (monitor-repair ?en - Engineer)                   	  ; this engineer is monitoring repair

    ;--------------- Vehicle predicates ----------------------
    (Vehicle-docked ?v - Vehicle ?room - LaunchBay)       ; vehicle is docked in this launchbay
    (Vehicle-deployed ?pr - Vehicle ?sr - Subregion)	    ; Vehicle has been deployed in this subregion
    (On-board ?ps - Personnel ?vh - Vehicle)              ; this person is on board this vehicle
    (Vehicle-destroyed ?pr - Vehicle)					            ; Vehicle has been destroyed
    (Vehicle-disabled ?ma - Vehicle)                      ; vehicle has been disabled

    ; type of lander on surface changed for testing online planner: ?la - Lander -> Vehicle ?sr - Planet -> Subregion
    (Lander-on-surface ?la - Lander ?sr - Planet)			    ; Lander on surface of planet
    (Launchbay-controls ?p - Engineer ?room - LaunchBay)  ; an engineer is at the controls of this launchbay

    ; ------------- Item predicates ------------------------
    (Obj-subregion ?sc - Object ?sr - Subregion)          ; There is an object for the probe to collect at this location
    (On-vehicle ?sc - Object ?pr - Vehicle)               ; vehicle holds an object
    (On-ship ?sc - Object ?r - Room)                      ; Collectible is on ship, in room
    (Antenna-deployed ?an - Antenna ?p - Planet)          ; Antenna is deployed on planet surface
    (Plasma-data ?data - PlasmaScan ?obj - Plasma)        ; PlasmaScan is data from plasma

    ; ------------- Mission predicates ---------------------
    (Objective-complete ?ob - Objective)
    (Mission-complete ?m - Mission)								             ; Mission has been completed
    (Objective-scan ?m - Objective ?scan - Scan)		 ; Mission has objective in location
    (Objective-visit-subregion ?m - Objective ?sr - Subregion)
    (Objective-retrieve-plasmadata ?m - Objective ?p - PlasmaScan)
    (Objective-deploy-vehicle ?m - Objective ?v - Vehicle ?sr - Subregion)
  )

  ; ------------- Moving around ship actions ----------------
  ; Personnel can move between rooms inside the ship
  (:action change-room
    :parameters (?person - Personnel ?startroom - Room ?endroom - Room ?door - Door)
    :precondition 
      (and 
        (Personnel-Loc ?person ?startroom)                                     
        (or 
          (door-connects ?door ?startroom ?endroom)
          (door-connects ?door ?endroom ?startroom)
        ) 
        (not (Personnel-occupied ?person))
      )
      
    :effect 
      (and  
        (not(Personnel-Loc ?person ?startroom))      
        (Personnel-Loc ?person ?endroom)
      )
  )


  ; collect pickup object when person is in room
  (:action pickup-object
    :parameters (?room - Room ?person - Personnel ?obj - Object)
    :precondition 
      (and 
        (not (Personnel-occupied ?person))
        (Personnel-Loc ?person ?room)
        (On-ship ?obj ?room)
        (or 
          (exists (?x - Plasma ?y - ScienceOfficer) (and(= ?x ?obj) (= ?y ?person)))
          (exists (?x - Plasma)(not(= ?x ?obj)))
        )
      )
    :effect 
      (and 
        (holding ?person ?obj) 
        (not (On-ship ?obj ?room))
      )
  )

  ; drop object
  (:action drop-object
    :parameters (?person - Personnel ?obj - Object ?room - Room)
    :precondition 
      (and 
        (Personnel-Loc ?person ?room)
        (not (exists (?x - Room) (On-ship ?obj ?x)))
        (holding ?person ?obj)
      )
    :effect 
    	(and 
        (not (holding ?person ?obj))
    		(On-ship ?obj ?room)
    	)
    )


  ; -------------- Moving ship actions ------------------
  ; move the ship from one region to another
  (:action hyperspace-move
    :parameters (?origin - Region ?destination - Region)
    :precondition 
      (and  
        (Ship-Location ?origin)
        (Ship-clear)
        (not(Ship-damaged))
        (Depart-OK)
      )
    :effect 
      (and 
        (not(Ship-Location ?origin))
        (Ship-Location ?destination)
      )
  )

  ; visit subregion, if asteroid belt is visited ship gets damaged
  (:action visit-subregion
    :parameters (?solar-system - Region ?subregion - Subregion)
    :precondition 
      (and 
        (Ship-clear)
        (not(Ship-damaged))
        (Ship-Location ?solar-system)
        (In-region ?solar-system ?subregion)
        (Depart-OK)
      )
    :effect 
      (and 
        (not(Ship-clear))
        (Ship-at-Subregion ?subregion)
        (when (and (exists (?x - AstroidBelt) (= ?x ?subregion))) (Ship-damaged))
      )
  )

  ; leave subregion (ready for hyperspace jump)
  (:action leave-subregion
    :parameters (?subregion - Subregion)
    :precondition 
      (and 
        (Ship-at-Subregion ?subregion)
        (not(Ship-clear))
        (not(Ship-damaged))
        (Depart-OK)
      )
    :effect 
      (and 
        (Ship-clear)
        (not(Ship-at-Subregion ?subregion))
      )
  )

  ; -------------- Launch/recall vehicles ----------------
  ; deploys vehicle, probes destroyed when deployed in asteriod belt & MAV disabled in nebula
  (:action deploy-vehicle
    :parameters (?veh - Vehicle ?room - LaunchBay ?subr - Subregion)
    :precondition 
      (and 
        (Ship-at-Subregion ?subr)
        (exists (?y - Engineer) (Launchbay-controls ?y ?room) )
        (Vehicle-docked ?veh ?room)
        (not(Vehicle-deployed ?veh ?subr))
      )
    :effect 
      (and 
        (Vehicle-deployed ?veh ?subr)
        (not(Vehicle-docked ?veh ?room))
        (not (Depart-OK))
        (when (and(exists (?x - AstroidBelt ?y - Probe) (and(= ?x ?subr) (= ?y ?veh)))) (Vehicle-destroyed ?veh))
        (when (and (exists (?z - Nebula ?a - MAV) (and (= ?z ?subr) (= ?a ?veh)))) (Vehicle-disabled ?veh))
      )
  )

  ; Dock vehicles in a ship launchbay
  (:action dock-vehicle
    :parameters (?veh - Vehicle ?room - LaunchBay ?subr - Subregion)
    :precondition 
      (and 
        (Ship-at-Subregion ?subr)
        (Vehicle-deployed ?veh ?subr)
        (exists (?y - Engineer) (Launchbay-controls ?y ?room) )
        (not (Vehicle-docked ?veh ?room))
        (not (or (Vehicle-destroyed ?veh) (Vehicle-disabled ?veh) ) )
        (not (Lander-on-surface ?veh ?subr))
      )
    :effect 
      (and 
        (not (Vehicle-deployed ?veh ?subr))
        (Vehicle-docked ?veh ?room)
      )
  )

  ; Engineer operate launchbay controls
  (:action operate-controls
    :parameters (?engineer - Engineer ?room - LaunchBay)
    :precondition 
      (and 
        (Personnel-Loc ?engineer ?room)
        (not (Personnel-occupied ?engineer))
      )
    :effect 
      (and 
        (Personnel-occupied ?engineer)
        (Launchbay-controls ?engineer ?room)
      )
  )

; Engineer finished operating launchbay controls
(:action stop-operate-controls
  :parameters (?engineer - Engineer ?room - LaunchBay)
  :precondition 
    (and 
      (Launchbay-controls ?engineer ?room)
    )
  :effect 
    (and 
      (not (Launchbay-controls ?engineer ?room))
      (not (Personnel-occupied ?engineer))
    )
)

; Personnel board vehicle when needed
(:action board-vehicle
  :parameters (?person - Personnel ?vehicle - Vehicle ?launchbay - LaunchBay)
  :precondition 
    (and 
      (not(Personnel-occupied ?person))
      (Personnel-Loc ?person ?launchbay) 
      (Vehicle-docked ?vehicle ?launchbay)
    )
  :effect 
    (and 
      (not (Personnel-Loc ?person ?launchbay))
      (On-board ?person ?vehicle)
      (Personnel-occupied ?person)
    )
)

; Personnell disembark from vehicle
(:action disembark-vehicle
  :parameters (?person - Personnel ?vehicle - Vehicle ?launchbay - LaunchBay)
  :precondition 
    (and 
      (On-board ?person ?vehicle)
      (Vehicle-docked ?Vehicle ?launchbay)
    )
  :effect 
    (and 
      (not (Personnel-occupied ?person))
      (Personnel-Loc ?person ?launchbay)
      (not (On-board ?person ?vehicle))
    )
)


  ; -------------- Engineering Actions -------------------
  ; Instruct an engineer to begin monitoring repairs
  (:action monitor-repair
    :parameters (?engineer - Engineer ?room - Engineering)
    :precondition 
      (and 
        (Personnel-Loc ?engineer ?room)
      )
    :effect 
      (and 
        (monitor-repair ?engineer)
        (Personnel-occupied ?engineer)
      )
  )

  ; repair damage
  (:action repair-ship ; change ?mav - MAV -> Vehicle for online editor testing
    :parameters (?engineer - Engineer ?mav - MAV ?subregion - Subregion)
    :precondition 
      (and 
        (Ship-damaged)
        (exists (?x - Engineer) (monitor-repair ?x))
        (Vehicle-deployed ?mav ?subregion)
        (Ship-at-Subregion ?subregion)
        (On-board ?engineer ?mav)
        (not (or (Vehicle-destroyed ?mav) (Vehicle-disabled ?mav)))
      )

    :effect 
      (and 
        (not (Ship-damaged))
        (forall (?x - Engineer)
          (when (and (monitor-repair ?x))
            (and (not(monitor-repair ?x)) (not(Personnel-occupied ?x)) )
          )
        )
      )
  )

  ; -------------- Departure clearance -------------------

  ; Ship ready to depart, MAV behaviour not ideal
  (:action prep-departure
    :parameters (?bridge - Bridge ?launchbay - LaunchBay)
    :precondition 
      (and 
        (exists (?x - Captain) (Personnel-Loc ?x ?bridge))
        (exists (?y - Navigator) (Personnel-Loc ?y ?bridge))
        ;(forall (?m - MAV) (Vehicle-docked ?m ?launchbay)) 
        (not (Depart-OK))
      )
    :effect 
      (and 
        (Depart-OK)
      )
    )

  ; ------------ Probes ---------------------------------

  ; probe scan
  (:action probe-scan
    :parameters (?probe - Probe ?subregion - Subregion ?obj - ProbeScan)
    :precondition 
      (and 
        (not (Vehicle-destroyed ?probe))
        (Vehicle-deployed ?probe ?subregion)
        (Obj-subregion ?obj ?subregion)
      )
    :effect 
      (and 
        (On-vehicle ?obj ?probe)
      )
  )

  (:action probe-collect-plasma
    :parameters (?probe - Probe ?subregion - Subregion ?plasma - Plasma)
    :precondition 
      (and 
        (not(Vehicle-destroyed ?probe))
        (Vehicle-deployed ?probe ?subregion)
        (Obj-subregion ?plasma ?subregion)
      )
    :effect 
      (and 
        (On-vehicle ?plasma ?probe)
      )
  )

  ; Probe can deliver object (scan/plasma)
  (:action probe-deliver
    :parameters (?probe - Probe ?obj - Object ?launchbay - LaunchBay)
    :precondition 
      (and 
        (Vehicle-docked ?probe ?launchbay)
        (On-vehicle ?obj ?probe)
      )
    :effect 
      (and 
        (not (On-vehicle ?obj ?probe))
        (On-ship ?obj ?launchbay)
      )
  )

  ; Planetary scans are uploaded to the computer
  (:action upload-scan
    :parameters (?scan - Scan)
    :precondition 
      (and 
        (exists (?x - Room)  (On-ship ?scan ?x))
        (not(On-ship ?scan Computer))
      )
    :effect 
      (and 
        (On-ship ?scan Computer)
      )
  )

  ; ------------ Lander ---------------------------------

  (:action Store-antenna
    :parameters (?antenna - Antenna ?lander - Lander ?room - LaunchBay)
    :precondition 
      (and 
        (On-ship ?antenna ?room)
        (Vehicle-docked ?lander ?room)
        (exists (?x - Personnel) (Personnel-Loc ?x ?room))
      )
    :effect 
      (and 
        (On-vehicle ?antenna ?lander)
      )
  )

  ; Lander downloads data about touchdown from ships computer
  (:action load-touchdown-data
    :parameters (?lander - Lander ?touchdown - ProbeScan)
    :precondition 
      (and 
        (On-ship ?touchdown Computer)
        (exists (?x - LaunchBay) (Vehicle-docked ?lander ?x))
      )
    :effect 
      (and 
        (On-vehicle ?touchdown ?lander)
      )
  )

  ; Lander performs touchdown on planet surface
  (:action lander-touchdown
    :parameters (?lander - Lander ?subregion - Planet)
    :precondition 
    	(and 
        (exists (?x - ProbeScan) (On-vehicle ?x ?lander)) ; it is possible to load touchdown data for the wrong planet thus destroying the lander
    		(Vehicle-deployed ?lander ?subregion)
    		(not (Lander-on-surface ?lander ?subregion))
    	)
    :effect 
    	(and 
    		(when (and (not(exists (?y - ProbeScan) (and(On-vehicle ?y ?lander) (Obj-subregion ?y ?subregion)))) ) (Vehicle-destroyed ?lander))
    		(Lander-on-surface ?lander ?subregion)
        (not (Vehicle-deployed ?lander ?subregion))
    	)
    )

  ;lander scan surface
  (:action scan-surface
    :parameters (?lander - Lander ?planet - Planet ?scan - LanderScan)
    :precondition 
      (and 
        (Lander-on-surface ?lander ?planet)
        (not (Vehicle-destroyed ?lander))
        (Obj-subregion ?scan ?planet)
      )
    :effect 
      (and 
        (On-vehicle ?scan ?lander)
      )
  )


  ; Lander deploys an antenna
  (:action Deploy-antenna
    :parameters (?lander - Lander ?subregion - Planet ?antenna - Antenna)
    :precondition 
    	(and 
        (On-vehicle ?antenna ?lander)
    		(Lander-on-surface ?lander ?subregion)
    		(not (Vehicle-destroyed ?lander))
    	)
    :effect 
    	(and 
    		(Antenna-deployed ?antenna ?subregion)
        (not (On-vehicle ?antenna ?lander))
    	)
    )

  ;lander transmit scan to ship
  (:action transmit-from-surface
    :parameters (?lander - Lander ?subregion - Planet ?obj - LanderScan)
    :precondition 
      (and 
        (not (Rads ?subregion))
        (exists (?x - Antenna) (Antenna-deployed ?x ?subregion))
        (not (Vehicle-destroyed ?lander))
        (Lander-on-surface ?lander ?subregion)
        (Ship-at-Subregion ?subregion)
        (Obj-subregion ?obj ?subregion)
        (On-vehicle ?obj ?lander)      
      )
    :effect 
      (and 
        (On-ship ?obj Computer)
      )
  )

  ; transmit from irradiated surface
  (:action transmit-irradiated-surface
    :parameters (?lander - Lander ?subregion - Planet ?obj - LanderScan)
    :precondition 
      (and 
        (Rads ?subregion)
        (exists (?x - Antenna ?y - Antenna)
          (and
            (not (= ?x ?y)) (Antenna-deployed ?x ?subregion) (Antenna-deployed ?y ?subregion)
          )
        )
        (Lander-on-surface ?lander ?subregion)
        (not (Vehicle-destroyed ?lander))
        (Ship-at-Subregion ?subregion)
        (Obj-subregion ?obj ?subregion)
        (On-vehicle ?obj ?lander)
      )
    :effect 
      (and 
        (On-ship ?obj Computer)
      )
  )

  ; ------------ Science lab  -------------------------
  (:action analyse-plasma
    :parameters (?person - ScienceOfficer ?plasmascan - PlasmaScan ?plasma - Plasma ?room - Sciencelab)
    :precondition 
      (and 
        (On-ship ?plasma ?room)
        (Personnel-Loc ?person ?room)
        (Plasma-data ?plasmascan ?plasma)
      )
    :effect 
      (and 
        (On-ship ?plasmascan Computer)
      )
  )

  ; ------------ Missions -------------------------------

  ; set objective complete when scan is on ship computer
  (:action complete-objective-scan
    :parameters (?objective - Objective ?scan - Scan)
    :precondition 
      (and 
        (Objective-scan ?objective ?scan)
        (not (Objective-complete ?objective))
        (On-ship ?scan Computer)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  ; set objective complete when ship visits appropreate subregion
  (:action complete-objective-visit-subregion
    :parameters (?objective - Objective ?subregion - Subregion)
    :precondition 
      (and 
        (Objective-visit-subregion ?objective ?subregion)
        (not (Objective-complete ?objective))
        (Ship-at-Subregion ?subregion)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  ; set complete when plasma data is on computer
  (:action complete-objective-retrieve-plasmadata
    :parameters (?objective - Objective ?plasmascan - PlasmaScan)
    :precondition 
      (and 
        (Objective-retrieve-plasmadata ?objective ?plasmascan)
        (not (Objective-complete ?objective))
        (On-ship ?plasmascan Computer)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  ; set complete when defined vehicle is deployed in location
  (:action complete-objective-deploy-vehicle
    :parameters (?objective - Objective ?subregion - Subregion ?vehicle - Vehicle)
    :precondition 
      (and 
        (Objective-deploy-vehicle ?objective ?vehicle ?subregion)
        (not (Objective-complete ?objective))
        (Vehicle-deployed ?vehicle ?subregion)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  ; upload scans on ship to mission control when at home spaceport
  (:action upload-to-mission-control
    :parameters (?scan - Scan ?starport - Starport)
    :precondition 
      (and 
        (Ship-docked ?starport)
        (Home-starport ?starport)
        (On-ship ?scan Computer)
      )
    :effect 
      (and 
        (Mission-control ?scan)
      )
  )

  ; set mission complete when all objectives are achieved, no scan is on ship that has not been sent to mission control
  (:action complete-mission
    :parameters (?mission - Mission ?starport - Starport)
    :precondition 
      (and 
        (forall (?x - Objective) (Objective-complete ?x))
        (not (exists (?y - Scan ) (and (On-ship ?y Computer) (not (Mission-control ?y)))))
        (Ship-docked ?starport)
        (Home-starport ?starport)
      )
    :effect 
      (and 
        (Mission-complete ?mission)
      )
  )

  ; ----------------- Additional feature ----------------------------------;
  ; Ship can dock at a starport and aquire new vehicles and crew members   ;
  ; Starport with home flag will be used to hand in completed Missions     ;
  ; Crew and objects load into ship via new room: Airlock                  ;
  ; vehicles load into ship via launchbay                                  ;
  ;------------------------------------------------------------------------;

  ; Dock the ship at the starport
  (:action dock-starport
    :parameters (?starport - Starport ?subregion - Subregion)
    :precondition 
      (and 
        (Ship-at-Subregion ?subregion)
        (Starport-location ?starport ?subregion)
        (not (Ship-docked ?starport))
      )
    :effect 
      (and 
        (not (Ship-at-Subregion ?subregion))
        (Ship-docked ?starport)
      )
  )

  ; Ship departs starport
  (:action leave-starport
    :parameters (?starport - Starport ?subregion - Subregion)
    :precondition 
      (and 
        (not (Ship-at-Subregion ?subregion))
        (Starport-location ?starport ?subregion)
        (Ship-docked ?starport)
      )
    :effect 
      (and 
        (Ship-at-Subregion ?subregion)
        (not (Ship-docked ?starport))
      )
  )
  
  ; Starports have an infinate supply of identical vehicles
  ; only one starport vehicle can be loaded into each launchbay at a time
  (:action load-vehicle
    :parameters (?vehicle - Vehicle ?starport - Starport ?launchbay - LaunchBay)
    :precondition 
      (and 
        (Ship-docked ?starport)
        (Starport-vehicles ?vehicle ?starport)
        (not (Vehicle-docked ?vehicle ?launchbay))
      )
    :effect 
      (and 
        (Vehicle-docked ?vehicle ?launchbay)
      )
  )

  ; crew members are unique, no cloning
  (:action load-crew
    :parameters (?person - Personnel ?starport - Starport ?room - Airlock)
    :precondition 
      (and 
        (Ship-docked ?starport)
        (Starport-crew ?person ?starport)
      )
    :effect 
      (and 
        (not (Starport-crew ?person ?starport))
        (Personnel-Loc ?person ?room)

      )
  )

  ; objects must be removed from the ship before they can be loaded onto the ship again
  (:action load-object
    :parameters (?obj - object ?starport - Starport ?room - Airlock)
    :precondition 
      (and 
        (Ship-docked ?starport)
        (Starport-item ?obj ?starport)
        (forall (?x - Room) (not(On-ship ?obj ?x)))
      )
    :effect 
      (and 
        (On-ship ?obj ?room)
      )
  )

)