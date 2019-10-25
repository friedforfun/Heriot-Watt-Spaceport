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
    Key Plasma PlanetScan AsteriodScan - Collectable
    Region
    Mission
  )

  (:constants Computer - Computer)                      

  (:predicates
    ; ------------ Space predicates -------------------------
    (In-region ?sp - Region ?s2 - Subregion)          	; inside this region is this subregion
    (Ion-rads ?sr - Planet)								              ; Ionising radiation is present on planet surface

    ; ------------ Personnel predicates ---------------------
    (Personnel-occupied ?p - Personnel)               	; Personnel is engaged, cannot move room
    (holding ?p - Personnel ?obj - Collectable)			     ; Personnel is holding an object

    ; ------------ Ship interior predicates ------------------
    (Personnel-Loc ?p - Personnel ?sr - Room)         	; location of Personnel on ship
    (door-connects ?d - Door ?ra - Room ?rb - Room)   	; door joins these rooms
    (Obj-in ?obj - Collectable ?r - Room)				        ; object is inside a room
  
    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - Region)                      	; ship is located in region
    (Ship-at-Subregion ?pn - Subregion)               	; ship is located at a subregion of region
    (Ship-damaged)                                    	; ship is damaged
    (Ship-clear)                         				        ; ship is outside of a subregeion 
    (Depart-OK)                                       	; ship cannot leave region until vehicles are back on board

    ; ------------- Engineering predicates -----------------
    (monitor-repair ?en - Engineer)                   	; this engineer is monitoring repair

    ;--------------- Vehicle predicates ----------------------
    (Vehicle-docked ?v - Vehicle ?room - LaunchBay)
    (Vehicle-deployed ?pr - Vehicle ?sr - Subregion)	  ; Vehicle has been deployed
    (On-board ?vh - Vehicle ?ps - Personnel)
    (Surface-Scan ?sc - Collectable ?sr - Subregion) 	  ; Scan that must be completed on the planet surface
    (Vehicle-destroyed ?pr - Vehicle)					          ; Vehicle has been destroyed
    (Vehicle-disabled ?ma - Vehicle)                          	; MAV has been disabled by a nebula
    (Lander-on-surface ?la - Lander ?sr - Planet)			    ; Lander on surface of planet
    (Launchbay-controls ?p - Engineer ?room - LaunchBay)

    ; ------------- Item predicates ------------------------
    (Scan-loc ?sc - Collectable ?sr - Subregion)        ; There is scan data at this location
    (Scan-stored ?sc - Collectable ?pr - Vehicle)       ; vehicle holds an object
    (On-ship ?sc - Collectable ?r - Room)             ; Collectible is on ship, in room


    ; ------------- Mission predicates ---------------------
    (Mission-complete ?m - Mission)								             ; Mission has been completed
    (Objective-scan-subregion ?m - Mission ?sr - Subregion)		 ; Mission has objective in location
    (Objective-visit-subregion ?m - Mission ?sr - Subregion)
    (Objective-scan-planet ?m - Mission ?p - Planet)
    (Objective-retrieve-plasma ?m - Mission ?n - Nebula)
    (Objective-visit-region ?m - Mission ?r - Region)
    (Objective-identify-touchdown ?m - Mission ?p - Planet)
    (Objective-deploy-MAV ?m - Mission ?sr - Subregion)
    (Objective-deploy-prove ?m - Mission ?sr - Subregion)
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
        (not(door-locked ?door))                   
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
    :parameters (?room - Room ?person - Personnel ?obj - Collectable)
    :precondition 
      (and 
        (not (Personnel-occupied ?person))
        (Personnel-Loc ?person ?room)
        (Obj-in ?obj ?room)
        (or 
          (exists (?x - Plasma ?y - ScienceOfficer) (and(= ?x ?obj) (= ?y ?person)))
          (exists (?x - Plasma)(not(= ?x ?obj)))
        )
      )
    :effect 
      (and 
        (holding ?person ?obj) 
        (not (Obj-in ?obj ?room))
      )
  )

  ; drop object
  (:action drop-object
    :parameters (?person - Personnel ?obj - Collectable ?room - Room)
    :precondition 
      (and 
        (Personnel-Loc ?person ?room)
        (not (exists (?x - Room) (Obj-in ?obj ?x)))
        
      )
    :effect 
    	(and 
        (not (holding ?person ?obj))
    		(Obj-in ?obj ?room)
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
  (:action deploy-vehicle
    :parameters (?veh - Vehicle ?room - LaunchBay ?subr - Subregion)
    :precondition 
      (and 
        (exists (?y - Engineer) (Launchbay-controls ?y ?room) )
        (Vehicle-docked ?veh ?room)
      )
    :effect 
      (and 
        (Vehicle-deployed ?veh ?subr)
        
        ;when probe in asteriodbelt destroy
        (when (and(exists (?x - AstroidBelt ?y - Probe) (and(= ?x ?subr) (= ?y ?veh)))) (Vehicle-destroyed ?veh))
        
        ;when mav is in nebula disable
        (when (and (exists (?z - Nebula ?a - MAV) (and (= ?z ?subr) (= ?a ?veh)))) (Vehicle-disabled ?veh))
      )
  )

  (:action recall-vehicle
    :parameters (?x - object)
    :precondition (and ())
    :effect (and ()))

  (:action operate-controls
    :parameters (?x - object)
    :precondition (and ())
    :effect (and ()))



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
  (:action repair-ship
    :parameters (?engineer - Engineer ?mav - MAV ?subregion - Subregion)
    :precondition 
      (and 
        (Ship-damaged)
        (exists (?x - Engineer) (monitor-repair ?x))
        (Vehicle-deployed ?mav ?subregion)
        (On-board ?mav ?engineer)
        (not (or (Vehicle-destroyed ?mav) (MAV-disabled ?mav)))
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



; REMOVE ---------------------------------------------------------
  ; deploy the mav from the launch bay
  (:action deploy-mav
    :parameters (?engineer - Engineer ?mav - MAV ?launchbay - LaunchBay ?subregion - Subregion)
    :precondition 
      (and 
        (exists (?x - Engineer) (and(not(= ?x ?engineer)) (Personnel-Loc ?x ?launchbay)))
        (MAV-docked ?mav)
        (Personnel-Loc ?engineer ?launchbay)
        (not (Vehicle-destroyed ?mav))
      )
    :effect 
      (and 
        (not (Personnel-Loc ?engineer ?launchbay))
        (MAV-EVA ?engineer ?mav)
        (Personnel-occupied ?engineer)
        (not (Depart-OK))
        (not (MAV-docked ?mav))
        (when (and (exists (?x - Nebula) (= ?x ?subregion))) (MAV-disabled ?mav))
      )
  )



  ; Recall MAV from EVA
  (:action recall-mav
    :parameters (?mav - MAV ?engineer - Engineer ?launchbay - LaunchBay)
    :precondition 
      (and 
        (not (MAV-docked ?mav))
        (MAV-EVA ?engineer ?mav)
        (exists (?x - Engineer) (Personnel-Loc ?x ?launchbay))
        (not (Vehicle-destroyed ?mav))
      )
    :effect 
      (and 
        (not (MAV-EVA ?engineer ?mav))
        (not (Personnel-occupied ?engineer))
        (MAV-docked ?mav)
        (Personnel-Loc ?engineer ?launchbay)
      )
  )

   ; deploy probe
  (:action deploy-probe
    :parameters (?probe - Probe ?subregion - Subregion)
    :precondition 
      (and 
        (exists (?x - Engineer ?y - LaunchBay) (Personnel-Loc ?x ?y))
        (not (exists (?x - Subregion) (Vehicle-deployed ?probe ?x)))
        (Ship-at-Subregion ?subregion)
        (not (Vehicle-destroyed ?probe))
      )
    :effect 
      (and 
        (Vehicle-deployed ?probe ?subregion)
        (when (and (exists (?x - AstroidBelt) (= ?x ?subregion))) (Vehicle-destroyed ?probe))
      )
  )

    ; recall probe
  (:action recall-probe
    :parameters (?probe - Probe ?subregion - Subregion ?launchbay - LaunchBay)
    :precondition 
      (and 
        (not (Vehicle-destroyed ?probe))
        (Vehicle-deployed ?probe ?subregion)
        (Ship-Location ?subregion)
      )
    :effect 
      (and 
        (not (Vehicle-deployed ?probe ?subregion))
        (forall (?x - Collectable)
          (when (and (Scan-stored ?x ?probe)) 
            (On-ship ?x ?launchbay)
          )
        )
      )
  )

    (:action deploy-lander
    :parameters (?lander - Lander ?subregion - Subregion)
    :precondition 
      (and 
        (Ship-at-Subregion ?subregion)
        (not (Vehicle-destroyed ?lander))
        (not (exists (?y - Subregion) (Vehicle-deployed ?lander ?y)))
        (exists (?x - Engineer) (Personnel-Loc ?x ?launchbay))
      )
    :effect 
      (and 
        (when (and(exists (?x - PlanetScan) (and (Scan-loc ?x ?subregion) ()))) (Scan-stored ?x ?lander))
        (Vehicle-deployed ?lander ?subregion)
      )
    )

  ; -------------------------------------------------------------


  ; -------------- Departure clearance -------------------

  ; Ship ready to depart, all MAV are docked
  (:action prep-departure
    :parameters (?bridge - Bridge)
    :precondition 
      (and 
        (exists (?x - Captain) (Personnel-Loc ?x ?bridge))
        (exists (?y - Navigator) (Personnel-Loc ?y ?bridge))
        (forall (?m - MAV) (MAV-docked ?m)) 
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
    :parameters (?probe - Probe ?subregion - Subregion ?obj - Collectable)
    :precondition 
      (and 
        (not (Vehicle-destroyed ?probe))
        (Vehicle-deployed ?probe ?subregion)
        (Scan-loc ?obj ?subregion)
      )
    :effect 
      (and 
        (Scan-stored ?obj ?probe)
        
        (when (and (exists (?x - PlanetScan) (= ?x ?obj) )) (TouchDown-Location ?obj ?subregion))
      )
  )



  (:action upload-scan
    :parameters (?scan - PlanetScan)
    :precondition 
      (and 
        (exists (?x - room)  (On-ship ?scan ?x))
        (not(On-ship ?scan Computer))
      )
    :effect 
      (and 
        (On-ship ?scan Computer)
      )
  )

  ; ------------ Lander ---------------------------------


  (:action lander-touchdown
    :parameters (?lander - Lander ?subregion - Planet)
    :precondition 
    	(and 
    		(Vehicle-deployed ?lander ?subregion)
    		(not (Lander-surface ?lander ?subregion))
    	)
    :effect 
    	(and 
    		(when (and (not (exists (?y - PlanetScan) (TouchDown-Location ?y ?subregion)))) (Vehicle-destroyed ?lander))
    		(Lander-surface ?lander ?subregion)
    	)
    )

  (:action Deploy-antenna
    :parameters (?lander - Lander ?subregion - Planet)
    :precondition 
    	(and 
    		(Lander-surface ?lander ?subregion)
    		(not (Vehicle-destroyed ?lander))
    	)
    :effect 
    	(and 
    		(Antenna-deployed ?subregion)
        (when (and (Ion-rads ?subregion)) (2-Antenna-deployed ?subregion))
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

)