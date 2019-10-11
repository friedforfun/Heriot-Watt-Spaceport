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
        
        (Personell-Loc ?c ?sr - room)
    )

    (:action change-room
      :parameters (?Spacecraftroom ?personell ?startroom ?endroom )
      :precondition (and 	(Personell-Loc ?personell ?startroom)
      				)
      	
      :effect (and (
      		)
      	)
    )

)