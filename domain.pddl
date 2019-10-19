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
    MAV
    Door 
    Empty Nebula AstroidBelt Planet - Subregion 
    Region)

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

  ; visit subregion (that is not an asteriod belt)

  (:action visit-subregion
    :parameters (?solar-system - Region ?subregion - Subregion)
    :precondition 
      (and 
        ()
      )
    :effect 
      (and 
        ()
      )
  )

  ; leave subregion (ready for hyperspace jump)

  ; enter orbit around a planet
  (:action orbit-planet
    :parameters (?solar-system - Region ?planet - Planet)
    :precondition 
      (and 
        (Ship-clear)
        (not(Ship-damaged))
        (Ship-Location ?solar-system)
        (In-region ?solar-system ?planet)
        (Depart-OK)
      )
    :effect 
      (and 
        (not(Ship-clear))
        (Ship-at-Subregion ?planet)
      )
  )

  ; leave planets orbit
  (:action leave-planet-orbit
    :parameters (?planet - planet)
    :precondition 
      (and 
        (Ship-at-Subregion ?planet)
        (not(Ship-clear))
        (not(Ship-damaged))
        (Depart-OK)
      )
    :effect 
      (and 
        (Ship-clear)
        (not(Ship-at-Subregion ?planet))
      )
  )

  ; visit asteroid belt inside region
  (:action visit-asteroid
    :parameters (?solar-system - Region ?asteroidbelt - AstroidBelt)
    :precondition 
      (and 
        (Ship-clear)
        (not(Ship-damaged))
        (Ship-Location ?solar-system)
        (In-region ?solar-system ?asteroidbelt)
        (Depart-OK)
      )
    :effect 
      (and 
        (Ship-at-Subregion ?asteroidbelt)
        (not (Ship-clear))
        (Ship-damaged)
      )
    )

  ; visit nebula
  (:action visit-nebula
    :parameters (?solar-system - Region ?nebula - Nebula)
    :precondition 
      (and 
        (Ship-clear)
        (not(Ship-damaged))
        (Ship-Location ?solar-system)
        (In-region ?solar-system ?nebula)
        (Depart-OK)
      )
    :effect 
      (and 
        (Ship-at-Subregion ?nebula)
        (not (Ship-clear))
      )
    )

  ; visit empty subregion
  (:action visit-empty
    :parameters (?solar-system - Region ?emptysr - empty)
    :precondition 
      (and 
        (Ship-clear)
        (not(Ship-damaged))
        (Ship-Location ?solar-system)
        (In-region ?solar-system ?emptysr)
        (Depart-OK)
      )
    :effect 
      (and 
        (Ship-at-Subregion ?emptysr)
        (not (Ship-clear))
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
    :parameters (?engineera - Engineer ?engineerb - Engineer ?mav - MAV ?launchbay - Laubay)
    :precondition 
      (and 
        (Personell-Loc ?engineera ?launchbay)
      )
    :effect 
      (and 
        (not (Personell-Loc ?engineera ?launchbay))
        (MAV-EVA ?engineera ?mav)
        (personell-occupied ?engineera)
        (not (Depart-OK))
        (not (MAV-docked ?mav))
      )
  )

  ; repair damage
  (:action repair-ship
    :parameters (?engineer - Engineer ?engineerb - Engineer ?subregion - Subregion ?mav - MAV)
    :precondition 
      (and 
        (Ship-damaged)
        (MAV-EVA ?engineer ?mav)
        (monitor-repair ?engineerb)
        (not (exists (?x - Nebula) (= ?x ?subregion))) 
      )
    :effect 
      (and 
        (not (Ship-damaged))
        (not (monitor-repair ?engineerb))
        (not (personell-occupied ?engineerb))
      )
  )

  ; Recall MAV from EVA
  (:action recall-mav
    :parameters (?mav - MAV ?engia - Engineer ?engib - Engineer)
    :precondition 
      (and 
        (not (MAV-docked ?mav))
        (MAV-EVA ?engia ?mav)
        (not (monitor-repair ?engib))
      )
    :effect 
      (and 
        (not (MAV-EVA ?engia ?mav))
        (not (personell-occupied ?engia))
        (MAV-docked ?mav)
      )
  )

  ; -------------- Departure clearance -------------------

  ; Ship ready to depart, all probes and MAV are docked
  (:action prep-departure
    :parameters (?captain - Captain ?navigator - Navigator ?bridge - Bridge)
    :precondition 
      (and 
        (Personell-Loc ?captain ?bridge)
        (Personell-Loc ?navigator ?bridge)
        (forall (?m - MAV) (MAV-docked ?m)) 
        (not (Depart-OK))
      )
    :effect 
      (and 
        (Depart-OK)
      )
    )

  ; ------------ Missions -------------------------------

  ; predicate ideas:
  ; mission has a destination
  ; mission requires lander to visit planet
  ; mission requires a scan
  ; mission requires plasma scans
  ; mission can be complete

  ; actions
  ; complete visit mission
  ; complete lander mission
  ; complete scan mission
  ; complete plasma mission

  ; ---------------- Question 2 ideas -----------------------

  ; weapons system to destroy asteroid
  ; weapons system disabled in nebula
  ; shield system to prevent ionicising radiation from nebula
  ; weapons cannot deploy when shield is in use vice versa
  ; mav/probes/lander cannot deploy when shield is up
  ; 

)