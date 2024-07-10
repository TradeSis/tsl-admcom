def buffer bplani for plani.

form 
   plani.numero
   bplani.numero
     with frame f01.


for each tipmov no-lock.

    for each estab no-lock.

        for each plani where plani.etbcod = estab.etbcod
                         and plani.movtdc = tipmov.movtdc
                         and plani.pladat >= 01/01/2012
                                no-lock,
                                
            first bplani where bplani.etbcod = plani.etbcod
                           and bplani.placod = plani.placod
                        /* and bplani.numero */
                           and bplani.pladat >= 01/01/2012
                           and bplani.pladat <> plani.pladat
                                        no-lock:

            display  plani.numero  format ">>>>>>>>>>>>>>9"
                    bplani.numero  format ">>>>>>>>>>>>>>9"  when avail bplani
                        with frame f01 down.

            pause.
    
        end.

    end.

end.




