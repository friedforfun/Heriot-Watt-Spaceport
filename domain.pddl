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

  (:types Captain Navigator Engineer ScienceOfficer - Personell 
    Bridge Engineering Scilab LaunchBay Hallway Computer - Room
    MAV Probe Lander - Vehicle
    Door 
    OnShip Empty Nebula AstroidBelt Planet - Subregion
    Key Plasma PlanetScan AsteriodScan - Collectable
    Region
    Mission
  )

  (:predicates
    ; ------------ Space predicates -------------------------
    (In-region ?sp - Region ?s2 - Subregion)          	; inside this region is this subregion
    (Ion-rads ?sr - Planet)								; Ionising radiation is present on planet surface

    ; ------------ Personell predicates ---------------------
    (key-location ?sr - Room)                         	; location of key on ship 
    (personell-occupied ?p - Personell)               	; personell is engaged, cannot move room
    (holding ?p - Personell ?obj - Collectable)			; personell is holding an object

    ; ------------ Ship interior predicates ------------------
    (door-locked ?d - Door)                           	; the door is locked
    (Personell-Loc ?p - Personell ?sr - Room)         	; location of personell on ship
    (door-connects ?d - Door ?ra - Room ?rb - Room)   	; door joins these rooms
    (Obj-in ?obj - Collectable ?r - Room)				; object is inside a room
  
    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - Region)                      	; ship is located in region
    (Ship-at-Subregion ?pn - Subregion)               	; ship is located at a subregion of region
    (Ship-damaged)                                    	; ship is damaged
    (Ship-clear)                         				; ship is outside of a subregeion 
    (Depart-OK)                                       	; ship cannot leave region until vehicles are back on board

    ; ------------- Engineering predicates -----------------
    (monitor-repair ?en - Engineer)                   	; this engineer is monitoring repair

    ;--------------- Vehicle predicates ----------------------
    (Vehicle-deployed ?pr - Vehicle ?sr - Subregion)	; Vehicle has been deployed
    (Scan-loc ?sc - Collectable ?sr - Subregion)		; There is scan data at this location
    (Surface-Scan ?sc - Collectable ?sr - Subregion) 	; Scan that must be completed on the planet surface
    (Scan-retrieved ?sc - Collectable ?pr - Probe)		; Probe has scan data
    (TouchDown-Location ?obj - Collectable ?p - Planet)	; scan has found a touchdown location
    (Vehicle-destroyed ?pr - Vehicle)					; Vehicle has been destroyed
    (Deliver-collectable ?sc - Collectable)				; Collectible is on ship
    (MAV-EVA ?en - Engineer ?ma - MAV)                	; MAV is in EVA state with an engineer
    (MAV-docked ?ma - MAV)                            	; the MAV is docked
    (MAV-disabled ?ma - MAV)                          	; MAV has been disabled by a nebula
    (Lander-surface ?la - Lander ?sr - Planet)			; Lander on surface of planet
    (Antenna-deployed ?p - Planet)
    (2-Antenna-deployed ?p - Planet)

    ; ------------- Mission predicates ---------------------
    (Mission-complete ?m - Mission)								; Mission has been completed
    (Objective-scan-subregion ?m - Mission ?sr - Subregion)		; Mission has objective in location
    (Objective-visit-subregion ?m - Mission ?sr - Subregion)
    (Objective-scan-planet ?m - Mission ?p - Planet)
    (Objective-retrieve-plasma ?m - Mission ?n - Nebula)
    (Objective-visit-region ?m - Mission ?r - Region)
    (Objective-identify-touchdown ?m - Mission ?p - Planet)
    (Objective-deploy-MAV ?m - Mission ?sr - Subregion)
    (Objective-deploy-prove ?m - Mission ?sr - Subregion)
  )

  ; ------------- Moving around ship actions ----------------
  ; personell can move between rooms inside the ship
  (:action change-room
    :parameters (?person - Personell ?startroom - Room ?endroom - Room ?door - Door)
    :precondition 
      (and 
        (Personell-Loc ?person ?startroom)                                     
        (or 
          (door-connects ?door ?startroom ?endroom)
          (door-connects ?door ?endroom ?startroom)
        ) 
        (not(door-locked ?door))                   
        (not (personell-occupied ?person))
      )
      
    :effect 
      (and  
        (not(Personell-Loc ?person ?startroom))      
        (Personell-Loc ?person ?endroom)
      )
  )

  ; keyholder to unlock doors
  (:action unlock-door
    :parameters (?person - Personell ?door - Door ?room - Room ?room-to-open - Room ?key - Key)
    :precondition 
      (and 
        (holding ?person ?key)
        (not (personell-occupied ?person))
        (door-locked ?door)
        (Personell-Loc ?person ?room)
        (or
          (door-connects ?door ?room ?room-to-open)
          (door-connects ?door ?room-to-open ?room)
        )
      )

    :effect 
      (and 
        (not(door-locked ?door))
      )
  )

  ; collect pickup object when person is in room
  (:action pickup-object
    :parameters (?room - Room ?person - Personell ?obj - Collectable)
    :precondition 
      (and 
        (not (personell-occupied ?person))
        (Personell-Loc ?person ?room)
        (Obj-in ?obj ?room)
        (exists (?x - Plasma) (not(= ?x ?obj)))
      )
    :effect 
      (and 
        (holding ?person ?obj) 
        (not (Obj-in ?obj ?room))
      )
  )

  ; pickup plasma
  (:action collect-plasma
    :parameters (?person - ScienceOfficer ?obj - Plasma ?room - Room)
    :precondition 
      (and 
        (not (personell-occupied ?person))
        (Personell-Loc ?person ?room)
        (Obj-in ?obj ?room)
      )
    :effect 
      (and 
        (not (Obj-in ?onj ?room))
        (holding ?person ?obj)
      )
  )

  ; drop object
  (:action drop-object
    :parameters (?person - Personell ?obj - Collectable ?room - Room)
    :precondition 
      (and 
        (Personell-Loc ?person ?room)
        (not (exists (?x - Room) (Obj-in ?obj ?x)))
        
      )
    :effect 
    	(and 
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

  ; -------------- Engineering Actions -------------------
  ; Instruct an engineer to begin monitoring repairs
  (:action monitor-repair
    :parameters (?engineer - Engineer ?room - Engineering)
    :precondition 
      (and 
        (Personell-Loc ?engineer ?room)
      )
    :effect 
      (and 
        (monitor-repair ?engineer)
        (personell-occupied ?engineer)
      )
  )

  ; deploy the mav from the launch bay
  (:action deploy-mav
    :parameters (?engineer - Engineer ?mav - MAV ?launchbay - LaunchBay ?subregion - Subregion)
    :precondition 
      (and 
        (exists (?x - Engineer) (and(not(= ?x ?engineer)) (Personell-Loc ?x ?launchbay)))
        (MAV-docked ?mav)
        (Personell-Loc ?engineer ?launchbay)
        (not (Vehicle-destroyed ?mav))
      )
    :effect 
      (and 
        (not (Personell-Loc ?engineer ?launchbay))
        (MAV-EVA ?engineer ?mav)
        (personell-occupied ?engineer)
        (not (Depart-OK))
        (not (MAV-docked ?mav))
        (when (and (exists (?x - Nebula) (= ?x ?subregion))) (MAV-disabled ?mav))
      )
  )

  ; repair damage
  (:action repair-ship
    :parameters (?engineer - Engineer ?mav - MAV)
    :precondition 
      (and 
        (Ship-damaged)
        (exists (?x - Engineer) (monitor-repair ?x))
        (MAV-EVA ?engineer ?mav)
        (not (or (Vehicle-destroyed ?mav) (MAV-disabled ?mav)))
      )

    :effect 
      (and 
        (not (Ship-damaged))
        (forall (?x - Engineer)
          (when (and (monitor-repair ?x))
            (and (not(monitor-repair ?x)) (not(personell-occupied ?x)) )
          )
        )
      )
  )

  ; Recall MAV from EVA
  (:action recall-mav
    :parameters (?mav - MAV ?engineer - Engineer ?launchbay - LaunchBay)
    :precondition 
      (and 
        (not (MAV-docked ?mav))
        (MAV-EVA ?engineer ?mav)
        (exists (?x - Engineer) (Personell-Loc ?x ?launchbay))
        (not (Vehicle-destroyed ?mav))
      )
    :effect 
      (and 
        (not (MAV-EVA ?engineer ?mav))
        (not (personell-occupied ?engineer))
        (MAV-docked ?mav)
        (Personell-Loc ?engineer ?launchbay)
      )
  )

  ; -------------- Departure clearance -------------------

  ; Ship ready to depart, all MAV are docked
  (:action prep-departure
    :parameters (?bridge - Bridge)
    :precondition 
      (and 
        (exists (?x - Captain) (Personell-Loc ?x ?bridge))
        (exists (?y - Navigator) (Personell-Loc ?y ?bridge))
        (forall (?m - MAV) (MAV-docked ?m)) 
        (not (Depart-OK))
      )
    :effect 
      (and 
        (Depart-OK)
      )
    )

  ; ------------ Probes ---------------------------------

  ; deploy probe
  (:action deploy-probe
    :parameters (?probe - Probe ?subregion - Subregion)
    :precondition 
      (and 
        (exists (?x - Engineer ?y - LaunchBay) (Personell-Loc ?x ?y))
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

  ; recall probe
  (:action recall-probe
    :parameters (?probe - Probe ?subregion - Subregion)
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
            (Deliver-collectable ?x)
          )
        )
      )
  )

  ; ------------ Lander ---------------------------------
  (:action deploy-lander
    :parameters (?lander - Lander ?subregion - Subregion)
    :precondition 
    	(and 
    		(not (Vehicle-destroyed ?lander))
    		(not (Vehicle-deployed ?lander))
    		(exists (?x - Engineer) (Personell-Loc ?x ?launchbay))
    	)
    :effect 
    	(and 
    		(Vehicle-deployed ?lander ?subregion)
    	)
    )

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
    		(when (and (not (Ion-rads ?subregion))) (Antenna-deployed ?subregion))
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