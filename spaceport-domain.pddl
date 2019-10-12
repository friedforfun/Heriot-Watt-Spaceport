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
    (Personell ?p - personell)
    (has-rank ?p - personell ?rk - rank)
    (Spacecraft-has-room ?sr - room)
    (Room-door-North ?ra - room ?rb - room)
    (Room-door-East ?ra - room ?rb - room)
    (Room-door-South ?ra - room ?rb - room)
    (Room-door-West ?ra - room ?rb - room)
    (door-locked ?d - door)
    (Personell-Loc ?p - personell ?sr - room)
    (has-key ?p - personell)
    (key-location ?sr - room)
    (door ?d - door)
    (door-connects ?d - door ?ra - room ?rb - room)
  )

    (:action change-room
      :parameters (?human - personell ?startroom - room ?endroom - room ?door - door)
      :precondition (and (Personell-Loc ?human ?startroom)          ; Person moving is inside ?startroom
                (or (and  (Room-door-North ?startroom ?endroom)     ; ?startroom has a door to ?endroom
                      (door-connects ?door ?startroom ?endroom)
                      (not(door-locked ?door))    ; the door is unlocked
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
        
      :effect (and  (not(Personell-Loc ?human ?startroom))
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
)