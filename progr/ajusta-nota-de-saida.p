for each plani where plani.etbcod = 7
                 and plani.numero = 1207
                 and plani.serie = "1" no-lock.


    display plani.icms plani.bicms platot frete descprod.
             /*
    update /*plani except placod movtdc opccod*/ with frame f01 no-validate.
               */
               
               
    for each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movdat = plani.pladat
                     and movim.movtdc = plani.movtdc no-lock.
                     
        find first produ of movim no-lock no-error.             
        
        find first clafis of produ no-lock no-error.

        display movim.procod movim.movpc movim.movqtm (movim.movpc * movim.movqtm)(total) movim.movalic (total) /*(((movim.movpc * movim.movqtm) + (movim.movdev * movim.movqtm~ )) * movim.movalic / 100) (total)   perred pronom clafis.desfis*/ /*movicms  movdev plani.opccod format  ">>>9" movtdc format ">9" */ movdes movim.movalipi.                                                             
                      
    end.

end.


