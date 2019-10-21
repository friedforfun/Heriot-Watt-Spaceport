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

  (:types Captain Navigator Engineer - Personell 
    Bridge Engineering Scilab Laubay Hallway - Room
    MAV Probe
    Door 
    OnShip Empty Nebula AstroidBelt Planet - Subregion
    Plasma Scan - Collectable
    Region
    Mission
  )

  (:predicates
    ; ------------ Space predicates -------------------------
    (In-region ?sp - Region ?s2 - Subregion)          ; inside this region is this subregion

    ; ------------ Personell predicates ---------------------
    (has-key ?p - Personell)                          ; personell has a door key
    (key-location ?sr - Room)                         ; location of key on ship 
    (personell-occupied ?p - Personell)               ; personell is engaged, cannot move room
    
    ; ------------ Ship interior predicates ------------------
    (Room-Adjacent ?ra - Room ?rb - Room)             ; room a is adjacent to room b
    (door-locked ?d - Door)                           ; the door is locked
    (Personell-Loc ?p - Personell ?sr - Room)         ; location of personell on ship
    (door-connects ?d - Door ?ra - Room ?rb - Room)   ; door joins these rooms
  
    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - Region)                      ; ship is located in region
    (Ship-at-Subregion ?pn - Subregion)               ; ship is located at a subregion of region
    (Ship-damaged)                                    ; ship is damaged
    (Ship-clear)                         ; ship is outside of a subregeion 
    (Depart-OK)                                       ; ship cannot leave region until vehicles are back on board

    ; ------------- Engineering predicates -----------------
    (MAV-EVA ?en - Engineer ?ma - MAV)                ; MAV is in EVA state
    (monitor-repair ?en - Engineer)                   ; this engineer is monitoring repair
    (MAV-docked ?ma - MAV)                            ; the MAV is docked
    (MAV-disabled ?ma - MAV)

    ;--------------- Probe predicates ----------------------
    (Probe-deployed ?pr - Probe ?sr - Subregion)
    (Scan-loc ?sc - Collectable ?sr - Subregion)
    (Scan-retrieved ?sc - Collectable ?pr - Probe)
    (Probe-destroyed ?pr - Probe)

    ; ------------- Mission predicates ---------------------
    (Mission-complete ?m - Mission)
    (Objective-scan-subregion ?m - Mission ?sr - Subregion)
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
        (Room-Adjacent ?startroom ?endroom)           
        (door-connects ?door ?startroom ?endroom)     
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
    :parameters (?person - Personell ?door - Door ?room - Room ?room-to-open - Room)
    :precondition 
      (and 
        (has-key ?person)
        (not (personell-occupied ?person))
        (door-locked ?door)
        (or
          (Personell-Loc ?person ?room)
          (Personell-Loc ?person ?room-to-open)
        )
        (or
          (door-connects ?door ?room ?room-to-open)
          (door-connects ?door ?room-to-open ?room)
        )
      )

    :effect (and (not(door-locked ?door))
            )
  )

  ; collect key from room
  (:action pickup-key
    :parameters (?room - Room ?person - Personell)
    :precondition 
      (and 
        (not (personell-occupied ?person))
        (Personell-Loc ?person ?room)
        (key-location ?room)
      )
    :effect 
      (and 
        (not (key-location ?room))
        (has-key ?person)
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
    :parameters (?engineer - Engineer ?mav - MAV ?launchbay - Laubay ?subregion - Subregion)
    :precondition 
      (and 
        (MAV-docked ?mav)
        (Personell-Loc ?engineer ?launchbay)
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
        (exists (?x - Engineer) (MAV-EVA ?x ?mav))
        (monitor-repair ?engineer)
        (not (MAV-disabled ?mav))
      )
    :effect 
      (and 
        (not (Ship-damaged))
        (not (monitor-repair ?engineer))
        (not (personell-occupied ?engineer))
      )
  )

  ; Recall MAV from EVA
  (:action recall-mav
    :parameters (?mav - MAV ?engineer - Engineer ?launchbay - Laubay)
    :precondition 
      (and 
        (not (MAV-docked ?mav))
        (MAV-EVA ?engineer ?mav)
        (exists (?x - Engineer) (Personell-Loc ?x ?launchbay))
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

  ; Ship ready to depart, all probes and MAV are docked
  (:action prep-departure
    :parameters (?bridge - Bridge)
    :precondition 
      (and 
        (and 
          (exists (?x - Captain) (Personell-Loc ?x ?bridge))
          (exists (?y - Navigator) (Personell-Loc ?y ?bridge))
        )
        ;(Personell-Loc ?captain ?bridge)
        ;(Personell-Loc ?navigator ?bridge)
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
        (not (exists (?x - Subregion) (Probe-deployed ?probe ?x)))
        (Ship-at-Subregion ?subregion)
      )
    :effect 
      (and 
        (Probe-deployed ?probe ?subregion)
        (when (and (exists (?x - AstroidBelt) (= ?x ?subregion))) (Probe-destroyed ?probe))
      )
  )


  ; probe scan
  (:action probe-scan
    :parameters (?probe - Probe ?subregion - Subregion ?obj - Collectable)
    :precondition 
      (and 
        (Probe-deployed ?probe ?subregion)
        (Scan-loc ?obj ?subregion)
      )
    :effect 
      (and 
        (Scan-retrieved ?obj ?probe)
      )
  )

  ; recall probe

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

  (:action complete-mission
    :parameters (?mission - Mission)
    :precondition 
      (and 
        ()
      )
    :effect 
      (and 
        ()
      )
  )

  ; hand in mission
  
  ; ---------------- Question 2 ideas -----------------------

  ; weapons system to destroy asteroid
  ; weapons system disabled in nebula
  ; shield system to prevent ionicising radiation from nebula
  ; weapons cannot deploy when shield is in use vice versa
  ; mav/probes/lander cannot deploy when shield is up
  ; 

)