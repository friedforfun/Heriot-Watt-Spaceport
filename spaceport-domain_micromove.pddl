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
        (Navigator ?n)
        (Personell ?p)

        (Spacecraft-has-room ?sr - room)
        (Room-door-North ?ra - room ?rb - room)
        (Room-door-East ?ra - room ?rb - room)
        (Room-door-South ?ra - room ?rb - room)
        (Room-door-West ?ra - room ?rb - room)
        (door-unlocked ?ra - room ?rb - room)
        (Personell-Loc ?c - personell ?sr - room)
    )

    (:action change-room
      :parameters (?human - personell ?startroom - room ?endroom - room)
      :precondition (and 	(Personell-Loc ?human ?startroom) ; Person moving is inside ?startroom
      					(or (and	(Room-door-North ?startroom ?endroom) ; ?startroom has a door to ?endroom
      								(door-unlocked ?startroom ?endroom) 
      						)
      						(and 	(Room-door-East ?startroom ?endroom)
      								(door-unlocked ?startroom ?endroom)
      						)
      						(and 	(Room-door-South ?startroom ?endroom)
      								(door-unlocked ?startroom ?endroom)
      						)
      						(and 	(Room-door-West ?startroom ?endroom)
      								(door-unlocked ?startroom ?endroom)
      						)
      					)
      				)
      	
      :effect (and (
      		)
      	)
    )

)