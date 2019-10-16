;
; Spaceport domain
; Sam Fay-Hunt SF52
;

(define (domain spaceport-domain_macromove)
  (:requirements
    :strips
    :typing
    :equality
  )

  (:types Captain Navigator - Personell 
    Bridge Engineering Scilab Laubay Hallway - Room
    Door 
    Region Planet)

  (:predicates
    ; ------------ Space predicates -------------------------
    (Space-region ?sp - Region)                       ; space regions exist
    (region-nebula ?sp - Region)                      ; space region contains nebula
    (region-planet ?sp - Region ?pn - Planet)         ; space region contains planet with name
    (region-astroid-belt ?sp - Region)                ; space region contains astroid belt

    ; ------------ Personell predicates ---------------------
    (has-key ?p - Personell)                          ; personell has a door key
    (key-location ?sr - Room)                         ; location of key on ship 

    ; ------------ Ship interior predicates ------------------
    (Room-Adjacent ?ra - Room ?rb - Room)
    (door-locked ?d - Door)                           ; is the door locked
    (Personell-Loc ?p - Personell ?sr - Room)         ; location of personell on ship
    (door ?d - Door)                                  ; is a door
    (door-connects ?d - Door ?ra - Room ?rb - Room)   ; door joins these rooms
  
    ; ------------- Ship exterior predicates ----------------
    (Ship-Location ?sp - Region)                      ; ship is located in region
    (Ship-at-planet ?pn - Planet)
    (Ship-damaged)                                    ; ship is damaged
    (Ship-offworld)
  )

    ; ------------- Moving around ship actions ----------------
    (:action change-room
      :parameters (?human - Personell ?startroom - Room ?endroom - Room ?door - Door)
      :precondition (and 
                      (Personell-Loc ?human ?startroom)                   ; Person moving is inside ?startroom                        
                      (Room-Adjacent ?startroom ?endroom)         ; ?startroom has a door to ?endroom
                      (door-connects ?door ?startroom ?endroom)     ; door connects the 2 rooms
                      (not(door-locked ?door))                      ; the door is unlocked  
                    )
        
      :effect (and  
                (not(Personell-Loc ?human ?startroom))        ; Personell in new location
                (Personell-Loc ?human ?endroom)
              )
    )

    (:action unlock-door
      :parameters (?human - Personell ?door - Door ?room - Room ?room-to-open - Room)
      :precondition (and 
                      (has-key ?human)
                      (door-locked ?door)
                      (or
                        (Personell-Loc ?human ?room)
                        (Personell-Loc ?human ?room-to-open)
                      )
                      (or
                        (door-connects ?door ?room ?room-to-open)
                        (door-connects ?door ?room-to-open ?room)
                      )

                    )

      :effect (and (not(door-locked ?door))
              )
    )

    ; -------------- Moving ship actions ------------------
    (:action ship-move
      :parameters (?captain - Captain ?navigator - Navigator ?origin - Region ?destination - Region ?bridge - Room)
      :precondition (and  
                      (Personell-Loc ?captain ?bridge)
                      (Personell-Loc ?navigator ?bridge)
                      (Ship-Location ?origin)
                      (Ship-offworld)
                      (not(Ship-damaged))
                    )
      :effect (and 
                (not(Ship-Location ?origin))
                (Ship-Location ?destination)
              )
    )

  (:action visit-planet
    :parameters (?captain - Captain ?navigator - Navigator ?solar-system - Region ?bridge - Room ?planet - Planet)
    :precondition (and 
                    (Personell-Loc ?captain ?bridge)
                    (Personell-Loc ?navigator ?bridge)
                    (Ship-offworld)
                    (not(Ship-damaged))
                    (Ship-Location ?solar-system)
                    (region-planet ?solar-system ?planet)
                  )
    :effect (and 
              (not(Ship-offworld))
              (Ship-at-planet ?planet)
            )
  )

  (:action leave-planet
    :parameters (?captain - Captain ?navigator - Navigator ?bridge - Room ?planet - planet)
    :precondition (and 
                    (Personell-Loc ?captain ?bridge)
                    (Personell-Loc ?navigator ?bridge)
                    (Ship-at-planet ?planet)
                    (not(Ship-offworld))
                    (not(Ship-damaged))
                  )
    :effect (and 
              (Ship-offworld)
              (not(Ship-at-planet ?planet))
            )
  )
)