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
    Nebula AstroidBelt Planet - Subregion Region)

  (:predicates
    ; ------------ Space predicates -------------------------
    (Space-region ?sp - Region)                       ; space regions exist
    (In-region ?sp - Region ?s2 - subregion)

    ; ------------ Personell predicates ---------------------
    (has-key ?p - Personell)                          ; personell has a door key
    (key-location ?sr - Room)                         ; location of key on ship 
    (personell-occupied ?p - Personell)               ; personell is engaged, cannot move room
    
    ; ------------ Ship interior predicates ------------------
    (Room-Adjacent ?ra - Room ?rb - Room)
    (door-locked ?d - Door)                           ; is the door locked
    (Personell-Loc ?p - Personell ?sr - Room)         ; location of personell on ship
    (door-connects ?d - Door ?ra - Room ?rb - Room)   ; door joins these rooms
  
    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - Region)                      ; ship is located in region
    (Ship-at-Subregion ?pn - Subregion)
    (Ship-damaged)                                    ; ship is damaged
    (Ship-at-Escape-velocity)                                   ; ship is Ship-at-Escape-velocity
    (Depart-OK)                                       ; ship cannot leave region until MAV is back on board

    ; ------------- Engineering predicates -----------------
    (MAV-EVA ?en - Engineer ?ma - MAV)                ; MAV is in EVA state
    (monitor-repair ?en - Engineer)
    (MAV-docked ?ma - MAV)
  )

    ; ------------- Moving around ship actions ----------------
    (:action change-room
      :parameters (?person - Personell ?startroom - Room ?endroom - Room ?door - Door)
      :precondition 
        (and 
          (Personell-Loc ?person ?startroom)             ; Person moving is inside ?startroom                        
          (Room-Adjacent ?startroom ?endroom)           ; ?startroom has a door to ?endroom
          (door-connects ?door ?startroom ?endroom)     ; door connects the 2 rooms
          (not(door-locked ?door))                      ; the door is unlocked  
          (not (personell-occupied ?person))
        )
        
      :effect 
        (and  
          (not(Personell-Loc ?person ?startroom))              ; Personell in new location
          (Personell-Loc ?person ?endroom)
        )
    )

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

    ; to implement pickup key

    ; -------------- Moving ship actions ------------------

    (:action ship-move
      :parameters (?origin - Region ?destination - Region)
      :precondition 
        (and  
          (Ship-Location ?origin)
          (Ship-at-Escape-velocity)
          (not(Ship-damaged))
          (Depart-OK)
        )
      :effect 
        (and 
          (not(Ship-Location ?origin))
          (Ship-Location ?destination)
        )
    )

  (:action orbit-planet
    :parameters (?solar-system - Region ?planet - Planet)
    :precondition 
      (and 
        (Ship-at-Escape-velocity)
        (not(Ship-damaged))
        (Ship-Location ?solar-system)
        (In-region ?solar-system ?planet)
        (Depart-OK)
      )
    :effect 
      (and 
        (not(Ship-at-Escape-velocity))
        (Ship-at-planet ?planet)
      )
  )

  (:action leave-planet-orbit
    :parameters (?planet - planet)
    :precondition 
      (and 
        (Ship-at-planet ?planet)
        (not(Ship-at-Escape-velocity))
        (not(Ship-damaged))
        (Depart-OK)
      )
    :effect 
      (and 
        (Ship-at-Escape-velocity)
        (not(Ship-at-planet ?planet))
      )
  )

  ; -------------- Engineering Actions -------------------

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

  (:action deploy-mav
    :parameters (?engineera - Engineer ?engineerb - Engineer ?mav - MAV ?launchbay - Laubay)
    :precondition 
      (and 
        (Personell-Loc ?engineera ?launchbay)
        (monitor-repair ?engineerb)
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

  (:action repair-ship
    :parameters (?engineer - Engineer ?Space-region - region ?mav - MAV)
    :precondition 
      (and 
        (Ship-damaged)
        (not (region-nebula ?Space-region))
        (Ship-Location ?Space-region)
        (MAV-EVA ?engineer ?mav)
      )
    :effect 
      (and 
        (not (Ship-damaged))
      )
  )

  (:action recall-mav
    :parameters (?mav - MAV ?engia - Engineer ?engib - Engineer)
    :precondition 
      (and 
        (MAV-EVA ?engia ?mav)
        (not (Ship-damaged))
      )
    :effect 
      (and 
        (not (MAV-EVA ?engia ?mav))
        (not (monitor-repair ?engib))
        (not (personell-occupied ?engia))
        (not (personell-occupied ?engib))
        (MAV-docked ?mav)
      )
  )

  ; -------------- Departure clearance -------------------
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

  ; weapons system to destroy asteroid
  ; weapons system disabled in nebula
  ; shield system to prevent ionicising radiation from nebula
  ; weapons cannot deploy when shield is in use vice versa
  ; mav/probes/lander cannot deploy when shield is up
  ; 

)