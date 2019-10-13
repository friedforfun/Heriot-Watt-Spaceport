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

  (:types personell rank room door)

  (:predicates
    ; ------------ Space predicates -------------------------
    (Space-regions ?sp)                               ; space regions exist
    (region-nebula ?sp)                               ; space region contains nebula
    (region-planet ?sp ?pn)                           ; space region contains planet with name
    (region-astroid-belt ?sp)                         ; space region contains astroid belt

    ; ------------ Personell predicates ---------------------
    (Personell ?p - personell)                        ; is a member of personell
    (has-rank ?p - personell ?rk - rank)              ; personell has a rank
    (has-key ?p - personell)                          ; personell has a door key
    (key-location ?sr - room)                         ; location of key on ship 

    ; ------------ Ship interior predicates ------------------
    (Spacecraft-has-room ?sr - room)                  ; ship contains this room
    (Room-door-North ?ra - room ?rb - room)           ; room connects to other room (north)
    (Room-door-East ?ra - room ?rb - room)            ; room connects to other room (east)
    (Room-door-South ?ra - room ?rb - room)           ; room connects to other room (south)
    (Room-door-West ?ra - room ?rb - room)            ; room connects to other room (west)
    (door-locked ?d - door)                           ; is the door locked
    (Personell-Loc ?p - personell ?sr - room)         ; location of personell on ship
    (door ?d - door)                                  ; is a door
    (door-connects ?d - door ?ra - room ?rb - room)   ; door joins these rooms
  
    ; ------------- Ship Location predicates ----------------
    (Ship-Location ?sp)                               ; ship is located in region
    (Ship-damaged)                                    ; ship is damaged
  )

    ; ------------- Moving around ship actions ----------------
    (:action change-room
      :parameters (?human - personell ?startroom - room ?endroom - room ?door - door)
      :precondition (and (Personell-Loc ?human ?startroom)          ; Person moving is inside ?startroom
                (or (and  (Room-door-North ?startroom ?endroom)     ; ?startroom has a door to ?endroom
                      (door-connects ?door ?startroom ?endroom)     ; door connects the 2 rooms
                      (not(door-locked ?door))                      ; the door is unlocked
                  )
                  (and  (Room-door-East ?startroom ?endroom)
                      (door-connects ?door ?startroom ?endroom)
                      (not(door-locked ?door))
                  )
                  (and  (Room-door-South ?startroom ?endroom)
                      (door-connects ?door ?startroom ?endroom)
                      (not(door-locked ?door))
                  )
                  (and  (Room-door-West ?startroom ?endroom)
                      (door-connects ?door ?startroom ?endroom)
                      (not(door-locked ?door))
                  )
                )
              )
        
      :effect (and  (not(Personell-Loc ?human ?startroom))        ; Personell in new location
              (Personell-Loc ?human ?endroom)

            )
    )

    (:action unlock-door
      :parameters (?human - personell ?door - door)
      :precondition (and (has-key ?human)
                (door-locked ?door)
              )

      :effect (and (not(door-locked ?door))
            )
    )

    ; -------------- Moving ship actions ------------------

    ()
)