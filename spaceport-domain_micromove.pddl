;
; Spaceport domain
; Sam Fay-Hunt SF52
;

(define (domain domain1)
    (:requirements
        :strips
        :typing
    )

    (:types personell room )

    (:predicates
    	(Personell ?p)
    	(Captain ?p)
        (Navigator ?p)


        (Spacecraft-has-room ?sr - room)
        (Room-door-North ?ra - room ?rb - room)
        (Room-door-East ?ra - room ?rb - room)
        (Room-door-South ?ra - room ?rb - room)
        (Room-door-West ?ra - room ?rb - room)
        (door-locked ?ra - room ?rb - room)
        (Personell-Loc ?p - personell ?sr - room)
        (has-key ?p)
    )

    (:action change-room
      :parameters (?human - personell ?startroom - room ?endroom - room)
      :precondition (and (Personell-Loc ?human ?startroom) 					; Person moving is inside ?startroom
      					(or (and	(Room-door-North ?startroom ?endroom) 		; ?startroom has a door to ?endroom
      								(not(door-locked ?startroom ?endroom))
      						)
      						(and 	(Room-door-East ?startroom ?endroom)
      								(not(door-locked ?startroom ?endroom))
      						)
      						(and 	(Room-door-South ?startroom ?endroom)
      								(not(door-locked ?startroom ?endroom))
      						)
      						(and 	(Room-door-West ?startroom ?endroom)
      								(not(door-locked ?startroom ?endroom))
      						)
      					)
      				)
      	
      :effect (and 	(Personell-Loc ?human ?endroom)

      		  )
    )

    (:action unlock-door
      :parameters (?human - personell ?startroom - room ?endroom - room)
      :precondition (and (has-key ?human)
      					(door-locked ?startroom ?endroom)
      				)

      :effect (and (not(door-locked ?startroom ?endroom))
      		  )
    )


)