def input parameter vrecmov as recid.

find movim where recid(movim) = vrecmov no-lock.

if movim.movtdc = 6
then do:

    find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat no-lock no-error.
    if not avail plani
    then next.
    /**************  TRANSFERENCIA - SAIDA ******************/

    find hiest where hiest.etbcod = plani.emite         and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = 09                  and
                     hiest.hieano = 1999 no-error.
    if not avail hiest
    then do transaction:
        create hiest.
        assign hiest.etbcod = plani.emite
               hiest.procod = movim.procod
               hiest.hiemes = 09
               hiest.hieano = 1999.
    end.
    do transaction:
    
        hiest.hiestf = hiest.hiestf + movim.movqtm.
    end.
    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/

   
    find hiest where hiest.etbcod = plani.desti         and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = 09                  and
                     hiest.hieano = 1999 no-error.
    if not avail hiest
    then do transaction:
        create hiest.
        assign hiest.etbcod = plani.desti
               hiest.procod = movim.procod
               hiest.hiemes = 09
               hiest.hieano = 1999.
    end.

    do transaction:
        hiest.hiestf = hiest.hiestf - movim.movqtm.
    end.
end.

    
    /********************** INICIO ENTRADA **********************/
if movim.movtdc = 4 or
   movim.movtdc = 1 or
   movim.movtdc = 7 or
   movim.movtdc = 12 or
   movim.movtdc = 15 or
   movim.movtdc = 17
then do:
    find hiest where hiest.etbcod = movim.etbcod        and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = 09                  and
                     hiest.hieano = 1999 no-error.
    if not avail hiest
    then do transaction:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = 09
               hiest.hieano = 1999.
    end.
    do transaction:
    
        hiest.hiestf = hiest.hiestf - movim.movqtm.
    end.
end.
    /**************************  FIM ENTRADA ************************/


    /*********************** INICIO SAIDA ***********************/
if movim.movtdc = 5 or
   movim.movtdc = 13 or
   movim.movtdc = 14 or
   movim.movtdc = 16 or
   movim.movtdc = 8  or
   movim.movtdc = 18
then do:


    find hiest where hiest.etbcod = movim.etbcod        and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = 09                  and
                     hiest.hieano = 1999 no-error.
    if not avail hiest
    then do transaction:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = 09
               hiest.hieano = 1999.
    end.
    do transaction:
        hiest.hiestf = hiest.hiestf + movim.movqtm.
    end.
end.

    /**************************** FIM SAIDA *************************/



