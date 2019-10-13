;
; Spaceport domain
; Sam Fay-Hunt SF52
;

(define (domain spaceport-domain_micromove)
  (:requirements
    :strips
    :typing
    :equality
  )

  (:types personell rank room door region planet)

  (:predicates
    ; ------------ Space predicates -------------------------
    (Space-region ?sp - region)                       ; space regions exist
    (region-nebula ?sp - region)                      ; space region contains nebula
    (region-planet ?sp - region ?pn - planet)         ; space region contains planet with name
    (region-astroid-belt ?sp - region)                ; space region contains astroid belt

    ; ------------ Personell predicates ---------------------
    (Personell ?p - personell)                        ; is a member of personell
    ;-(has-rank ?p - personell ?rk - rank)              ; personell has a rank
    (has-key ?p - personell)                          ; personell has a door key
    (key-location ?sr - room)                         ; location of key on ship 
    (is-captain ?p - personell)
    (is-navigator ?p - personell)

    ; ------------ Ship interior predicates ------------------
    (Spacecraft-has-room ?sr - room)                  ; ship contains this room
    (is-bridge ?sr - room)
    (Room-door-North ?ra - room ?rb - room)           ; room connects to other room (north)
    (Room-door-East ?ra - room ?rb - room)            ; room connects to other room (east)
    (Room-door-South ?ra - room ?rb - room)           ; room connects to other room (south)
    (Room-door-West ?ra - room ?rb - room)            ; room connects to other room (west)
    (door-locked ?d - door)                           ; is the door locked
    (Personell-Loc ?p - personell ?sr - room)         ; location of personell on ship
    (door ?d - door)                                  ; is a door
    (door-connects ?d - door ?ra - room ?rb - room)   ; door joins these rooms
  
    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - region)                      ; ship is located in region
    (Ship-at-planet ?pn - planet)
    (Ship-damaged)                                    ; ship is damaged
    (Ship-offworld)
  )

    ; ------------- Moving around ship actions ----------------
    (:action change-room
      :parameters (?human - personell ?startroom - room ?endroom - room ?door - door)
      :precondition (and 
                      (Personell-Loc ?human ?startroom)                   ; Person moving is inside ?startroom
                      (or (and  
                            (Room-door-North ?startroom ?endroom)         ; ?startroom has a door to ?endroom
                            (door-connects ?door ?startroom ?endroom)     ; door connects the 2 rooms
                            (not(door-locked ?door))                      ; the door is unlocked
                          )
                          (and  
                            (Room-door-East ?startroom ?endroom)
                            (door-connects ?door ?startroom ?endroom)
                            (not(door-locked ?door))
                          )
                          (and  
                            (Room-door-South ?startroom ?endroom)
                            (door-connects ?door ?startroom ?endroom)
                            (not(door-locked ?door))
                          )
                          (and  
                            (Room-door-West ?startroom ?endroom)
                            (door-connects ?door ?startroom ?endroom)
                            (not(door-locked ?door))
                          )
                      )
                    )
        
      :effect (and  
                (not(Personell-Loc ?human ?startroom))        ; Personell in new location
                (Personell-Loc ?human ?endroom)
              )
    )

    (:action unlock-door
      :parameters (?human - personell ?door - door)
      :precondition (and 
                      (has-key ?human)
                      (door-locked ?door)
                    )

      :effect (and (not(door-locked ?door))
              )
    )

    ; -------------- Moving ship actions ------------------
    (:action ship-move
      :parameters (?captain - personell ?navigator - personell ?origin - region ?destination - region ?bridge - room)
      :precondition (and  
                      (is-captain ?captain)
                      (is-navigator ?navigator)
                      (is-bridge ?bridge)
                      (Personell-Loc ?captain ?bridge)
                      (Personell-Loc ?navigator ?bridge)
                      (not(Ship-damaged))
                    )
      :effect (and 
                (not(Ship-Location ?origin))
                (Ship-Location ?destination)
                (Ship-offworld)
              )
    )

  (:action visit-planet
    :parameters (?captain - personell ?navigator - personell ?solar-system - region ?bridge - room ?planet - planet)
    :precondition (and 
                    (is-captain ?captain)
                    (is-navigator ?navigator)
                    (is-bridge ?bridge)
                    (Personell-Loc ?captain ?bridge)
                    (Personell-Loc ?navigator ?bridge)
                    (Ship-offworld)
                    (not(Ship-damaged))
                  )
    :effect (and 
              (not(Ship-offworld))
              (Ship-at-planet ?planet)
            )
  )

  (:action leave-planet
    :parameters (?captain - personell ?navigator - personell ?solar-system - region ?bridge - room ?planet - planet)
    :precondition (and 
                    (is-captain ?captain)
                    (is-navigator ?navigator)
                    (is-bridge ?bridge)
                    (Personell-Loc ?captain ?bridge)
                    (Personell-Loc ?navigator ?bridge)
                    (not(Ship-offworld))
                    (not(Ship-damaged))
                  )
    :effect (and 
              (Ship-offworld)
              (not(Ship-at-planet ?planet))
            )
  )


)