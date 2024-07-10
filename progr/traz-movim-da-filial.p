/*
connect com -H value("filial95") -S sdrebcom -N tcp -ld comloja no-error.
*/

for each comloja.plani where comloja.plani.etbcod = 19
                      /* and comloja.plani.movtdc = 48 */
                         and comloja.plani.numero = 668
                         and month(comloja.plani.pladat) = 06 no-lock.

     find first com.plani where com.plani.etbcod = comloja.plani.etbcod
                            and com.plani.movtdc = comloja.plani.movtdc
                            and com.plani.numero = comloja.plani.numero
                            and com.plani.pladat = comloja.plani.pladat
                            and com.plani.placod = comloja.plani.placod 
                                        no-lock no-error.
                         
     if not avail com.plani
     then do:
     
         create com.plani.
         buffer-copy comloja.plani to com.plani.
     
     end.
     else display com.plani with 6 col.
     
     for each comloja.movim where comloja.movim.etbcod = comloja.plani.etbcod
                              and comloja.movim.movdat = comloja.plani.pladat
                              and comloja.movim.movtdc = comloja.plani.movtdc
                              and comloja.movim.placod = comloja.plani.placod
                                              no-lock.
                                  
         release com.movim.                                     
         find first com.movim
              where com.movim.etbcod = comloja.movim.etbcod
                and com.movim.movdat = comloja.movim.movdat
                and com.movim.movtdc = comloja.movim.movtdc
                and com.movim.placod = comloja.movim.placod
                and com.movim.procod = comloja.movim.procod
                              no-lock no-error.

         if not avail com.movim
         then do:
            message "copiando...".

          create com.movim.
          buffer-copy comloja.movim to com.movim.

         end.
         else display com.movim.movpc * com.movim.movqtm.
      end.
     

end.