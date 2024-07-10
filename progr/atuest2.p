def buffer bhimov for himov.
DEF BUFFER BESTOQ FOR ESTOQ.
DEF BUFFER xESTOQ FOR ESTOQ.
def input parameter vrecmov as recid.
def input parameter vtipo   as char.
def input parameter vqtd    as i.
def input parameter vemite  like plani.emite.
def input parameter vdesti  like plani.desti.

find movim where recid(movim) = vrecmov no-lock no-error.
if not avail movim
then do:
    display "ENTRE EM CONTATO COM LUIZ DO CPD URGENTE   Movim" 
            with frame f-aviso1
                    color white/red centered row 10.
    PAUSE.
    next.
end.


    if vemite = 0 or vdesti = 0
    then do:    
        display "ENTRE EM CONTATO COM LUIZ DO CPD URGENTE   Plani"  
                with frame f-aviso2
                        color white/red centered row 10.
        PAUSE.
        next.
    end.






if movim.movtdc = 6
then do:

    /**************  TRANSFERENCIA - SAIDA ******************/
    find estoq where estoq.etbcod = vemite and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = vemite
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.

    if vemite <> 22
    then do:
        if vtipo = "I"
        then estoq.estatual = estoq.estatual - movim.movqtm.
        if vtipo = "E"
        then estoq.estatual = estoq.estatual + movim.movqtm.
        if vtipo = "A"
        then estoq.estatual = estoq.estatual + vqtd - movim.movqtm.
    end.

    find hiest where hiest.etbcod = vemite         and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = month(today) and
                     hiest.hieano =  year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = vemite
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano =  year(today).
    end.

    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.
    
    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/

    find bestoq where bestoq.etbcod = vdesti and
                      bestoq.procod = movim.procod no-error.
    if not avail bestoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create bestoq.
        assign bestoq.etbcod = vdesti
               bestoq.procod = movim.procod
               bestoq.estcusto = xestoq.estcusto
               bestoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then bestoq.estatual = bestoq.estatual + movim.movqtm.
    if vtipo = "E"
    then bestoq.estatual = bestoq.estatual - movim.movqtm.
    if vtipo = "A"
    then  bestoq.estatual = bestoq.estatual - vqtd + movim.movqtm.

    find hiest where hiest.etbcod = vdesti         and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = month(today) and
                     hiest.hieano =  year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = vdesti
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano =  year(today).
    end.

    hiest.hiestf = bestoq.estatual.
    hiest.hiepcf = bestoq.estcusto.
    hiest.hiepvf = bestoq.estvenda.

    
    find bhimov where bhimov.etbcod = vemite         and
                      bhimov.movtdc = 6                   and
                      bhimov.procod = movim.procod        and
                      bhimov.himmes = month(today) and
                      bhimov.himano =  year(today) no-error.
    if not avail bhimov 
    then do:
        create bhimov.
        assign bhimov.etbcod = vemite
               bhimov.movtdc = 6
               bhimov.procod = movim.procod
               bhimov.himmes = month(today)
               bhimov.himano =  year(today).
    end.
    if vtipo = "I"
    then bhimov.himqtm = bhimov.himqtm + movim.movqtm.
    if vtipo = "E"
    then bhimov.himqtm = bhimov.himqtm - movim.movqtm.
    if vtipo = "A"
    then  bhimov.himqtm = bhimov.himqtm - vqtd + movim.movqtm.

    
    /******************************************************/
    
    find himov where himov.etbcod = vdesti         and
                     himov.movtdc = 7                   and
                     himov.procod = movim.procod        and
                     himov.himmes = month(today) and
                     himov.himano =  year(today) no-error.
    if not avail himov
    then do:
        create himov.
        assign himov.etbcod = vdesti
               himov.movtdc = 7
               himov.procod = movim.procod
               himov.himmes = month(today)
               himov.himano =  year(today).
    end.
    if vtipo = "I"
    then himov.himqtm = himov.himqtm + movim.movqtm.
    if vtipo = "E"
    then himov.himqtm = himov.himqtm - movim.movqtm.
    if vtipo = "A"
    then  himov.himqtm = himov.himqtm - vqtd + movim.movqtm.


    /****************** FIM TRANSFERENCIA - ENTRADA *****************/

end.

    
    /********************** INICIO ENTRADA **********************/
if movim.movtdc = 4 or
   movim.movtdc = 1 or
   movim.movtdc = 7 or
   movim.movtdc = 12 or
   movim.movtdc = 15 or
   movim.movtdc = 17
then do:
    find estoq where estoq.etbcod = movim.etbcod and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = movim.etbcod
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "A"
    then  estoq.estatual = estoq.estatual - vqtd + movim.movqtm.

    /*
    if movim.movtdc = 4
    then estoq.estcusto = movim.movpc.
    */

    find hiest where hiest.etbcod = movim.etbcod        and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = month(today) and
                     hiest.hieano =  year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano =  year(today).
    end.
    
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.


    
    if movim.movtdc = 4 or
       movim.movtdc = 1
    then do:
    
        find himov where himov.etbcod = movim.etbcod        and
                         himov.movtdc = 4                   and
                         himov.procod = movim.procod        and
                         himov.himmes = month(today) and
                         himov.himano = year(today) no-error.
        if not avail himov
        then do:
            create himov.
            assign himov.etbcod = movim.etbcod
                   himov.movtdc = 4
                   himov.procod = movim.procod
                   himov.himmes = month(today)
                   himov.himano =  year(today).
        end.
        if vtipo = "I"
        then himov.himqtm = himov.himqtm + movim.movqtm.
        if vtipo = "E"
        then himov.himqtm = himov.himqtm - movim.movqtm.
        if vtipo = "A"
        then  himov.himqtm = himov.himqtm - vqtd + movim.movqtm.
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

    find estoq where estoq.etbcod = movim.etbcod and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = movim.etbcod
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "A"
    then  estoq.estatual = estoq.estatual + vqtd - movim.movqtm.

    find hiest where hiest.etbcod = movim.etbcod        and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = month(today) and
                     hiest.hieano =  year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano =  year(today).
    end.

    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.


    if movim.movtdc = 5
    then do:
        find himov where himov.etbcod = movim.etbcod        and
                         himov.movtdc = movim.movtdc        and
                         himov.procod = movim.procod        and
                         himov.himmes = month(today) and
                         himov.himano =  year(today) no-error.
        if not avail himov
        then do:
            create himov.
            assign himov.etbcod = movim.etbcod
                   himov.movtdc = 5
                   himov.procod = movim.procod
                   himov.himmes = month(today)
                   himov.himano =  year(today).
        end.
        if vtipo = "I"
        then himov.himqtm = himov.himqtm + movim.movqtm.
        if vtipo = "E"
        then himov.himqtm = himov.himqtm - movim.movqtm.
        if vtipo = "A"
        then  himov.himqtm = himov.himqtm - vqtd + movim.movqtm.
    end.
end.

    /**************************** FIM SAIDA *************************/



