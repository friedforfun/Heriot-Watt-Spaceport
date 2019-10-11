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
        (Space-Region ?sreg)
        (Navigator ?n)
        (Captain ?c)
        (Spacecraft-room ?sr - room)
        (Spacecraft-Damaged ?sts)
        (Region-Contains ?rc)

        
        (Navigator-Loc  ?n ?sr - room)
        (Captain-Loc ?c ?sr - room)
    )

    (:action move
      :parameters (?sregion ?cap ?nav ?status ?bridge )
      :precondition (and 	(Navigator-Loc ?nav ?bridge)
      						(Captain-Loc ?cap ?bridge)
      						(not(Spacecraft-Damaged ?status))
      	)
      :effect (and (
      		)
      	)
    )

)