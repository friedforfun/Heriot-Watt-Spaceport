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
    Bridge Engineering Sciencelab LaunchBay Hallway Computer - Room
    MAV Probe Lander - Vehicle
    Door
    OnShip Empty Nebula AstroidBelt Planet - Subregion
    Plasma Antenna Scan - Object
    ProbeScan LanderScan PlasmaScan - Scan ; can upload scans
    Region
    Objective - Mission
  )

  (:constants Computer - Computer)                      

  (:predicates
    ; ------------ Space predicates -------------------------
    (In-region ?sp - Region ?s2 - Subregion)          	  ; inside this region is this subregion
    (Ion-rads ?sr - Planet)								                ; Ionising radiation is present on planet surface

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
    (Mission-objective ?ob - Objective ?mi - Mission)
    (Objective-complete ?ob - Objective)
    (Mission-complete ?m - Mission)								             ; Mission has been completed
    
    (Objective-scan ?m - Objective ?scan - Scan)		 ; Mission has objective in location
    (Objective-visit-subregion ?m - Objective ?sr - Subregion)
    (Objective-retrieve-plasmadata ?m - Objective ?p - Plasma)
    (Objective-deploy-vehcle ?m - Objective ?v - Vehicle ?sr - Subregion)
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

  ; Ship ready to depart, all MAV are docked
  (:action prep-departure
    :parameters (?bridge - Bridge ?launchbay - LaunchBay)
    :precondition 
      (and 
        (exists (?x - Captain) (Personnel-Loc ?x ?bridge))
        (exists (?y - Navigator) (Personnel-Loc ?y ?bridge))
        ;(not (exists (?m - MAV ?l - LaunchBay) (not(Vehicle-docked ?m ?l))))
        ;(forall (?m - MAV) (Vehicle-docked ?m ?launchbay)) 
        ;(not (exists (?z - Engineer ?l - LaunchBay) (Launchbay-controls ?z ?l)))
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
        (not (Ion-rads ?subregion))
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
        (Ion-rads ?subregion)
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

  ; predicate ideas:
  ; mission has a destination
  ; mission requires lander to visit planet
  ; mission requires a scan
  ; mission requires plasma scans
  ; mission can be complete

  ; for each mission describe precontions as goals, then set mission to true as effect
  ; actions
  ; complete visit mission
  ; complete lander mission
  ; complete scan mission
  ; complete plasma mission

  (:action complete-objective-scan
    :parameters (?objective - Objective ?scan - Scan)
    :precondition 
      (and 
        (Objective-scan ?objective ?scan)
        (not (Object-complete ?objective))
        (On-ship ?scan Computer)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  (:action complete-objective-visit-subregion
    :parameters (?objective - Objective ?subregion - Subregion)
    :precondition 
      (and 
        (Objective-visit-subregion ?objective ?subregion)
        (not (Object-complete ?objective))
        (Ship-Location ?subregion)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  (:action complete-objective-retrieve-plasmadata
    :parameters (?objective - Objective ?plasma - Plasma)
    :precondition 
      (and 
        (Objective-retrieve-plasmadata ?objective ?plasma)
        (not (Object-complete ?objective))
        (exists (?x - PlasmaScan) (and (Plasma-data ?x ?plasma) (On-ship ?x Computer)))
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )

  (:action complete-objective-deploy-vehicle
    :parameters (?objective - Objective ?subregion - Subregion ?vehicle - Vehicle)
    :precondition 
      (and 
        (Objective-deploy-MAV ?objective ?subregion)
        (not (Objective-complete ?objective))
        (Vehicle-deployed ?vehicle ?subregion)
      )
    :effect 
      (and 
        (Objective-complete ?objective)
      )
  )




  ;(:action complete-mission
  ; :parameters (?mission - Mission)
  ;  :precondition 
  ;    (and 
  ;      ()
  ;    )
  ;  :effect 
  ;    (and 
  ;      ()
  ;    )
  ;)

  ; hand in mission
  
  ; ---------------- Question 2 ideas -----------------------

  ; weapons system to destroy asteroid
  ; weapons system disabled in nebula
  ; shield system to prevent ionicising radiation from nebula
  ; weapons cannot deploy when shield is in use vice versa
  ; mav/probes/lander cannot deploy when shield is up
  ; 

  ; ---------------------------------------------------------

  ; equipment stored in spaceport
  ; ship can fly back and restock probes, landers ect

)