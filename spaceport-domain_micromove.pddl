;
; Spaceport domain
; Sam Fay-Hunt SF52
;

(define (domain domain1)
    (:requirements
        :strips
        :typing
        :equality
    )

    (:types personell room )

    (:predicates
    	(Personell ?p - personell)
    	(has-rank ?p - personell ?rk)
        (Spacecraft-has-room ?sr - room)
        (Room-door-North ?ra - room ?rb - room)
        (Room-door-East ?ra - room ?rb - room)
        (Room-door-South ?ra - room ?rb - room)
        (Room-door-West ?ra - room ?rb - room)
        (door-locked ?ra - room ?rb - room)
        (Personell-Loc ?p - personell ?sr - room)
        (has-key ?p)
        (key-location ?sr - room)
    )

    (:action change-room
      :parameters (?human - personell ?startroom - room ?endroom - room)
      :precondition (and (Personell-Loc ?human ?startroom) 					; Person moving is inside ?startroom
      					(or (and	(Room-door-North ?startroom ?endroom) 		; ?startroom has a door to ?endroom
      								(not(door-locked ?startroom ?endroom))		; the door is unlocked
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
      	
      :effect (and 	(not(Personell-Loc ?human ?startroom))
      				(Personell-Loc ?human ?endroom)

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