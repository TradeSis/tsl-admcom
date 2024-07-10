/*
atuest.p
*/
def input parameter vrecmov as recid.
def input parameter vtipo   as char.
def input parameter vqtd    as i.

def var vano  as int.
def var vmes  as int.
def var vdata as date.

def buffer bhimov for himov.
DEF BUFFER Bpackestoq FOR packestoq.
DEF BUFFER xpackestoq FOR packestoq.

find movimpack where recid(movimpack) = vrecmov  no-error.
if not avail movimpack
then do:
    display "ENTRE EM CONTATO COM CPD URGENTE   movimPack"
            with frame f-aviso1 color white/red centered row 10.
    PAUSE.
    next.
end.

find pack of movimpack no-lock.
find tipmov of movimpack no-lock.

assign
    vano  = year(movimpack.movdat) + if month(movimpack.movdat) = 12 
            then 1
            else 0
    vmes  = if month(movimpack.movdat) = 12 
            then 1
            else month(movimpack.movdat) + 1
    vdata = date(vmes,01,vano) - 1.

/*** 
    if month(movimpack.datexp) <> month(today)
    then do:
        output to errodata.log append.
            put movimpack.placod format "9999999999" space(1)
                movimpack.etbcod space(1)
                movimpack.movdat space(1)
                movimpack.datexp format "99/99/9999" space(1)
                today format "99/99/9999"        space(1)
                movimpack.paccod skip.
        output close.
        find movdat where movdat.etbcod = movimpack.etbcod and
                          movdat.placod = movimpack.placod and
                          movdat.procod = movimpack.paccod no-error.
        if not avail movdat
        then do:
            create movdat.
            assign movdat.procod = movimpack.paccod
                   movdat.etbcod = movimpack.etbcod
                   movdat.placod = movimpack.placod
                   movdat.datent = today.
        end.
    
    end. 
***/

if tipmov.movttra /* movimpack.movtdc = 6 or movimpack.movtdc = 3 */
then do:
    find first plani where plani.etbcod = movimpack.etbcod and
                           plani.placod = movimpack.placod and
                           plani.movtdc = movimpack.movtdc and
                           plani.pladat = movimpack.movdat
                     no-lock no-error.
    if not avail plani
    then do:    
        display "ENTRE EM CONTATO COM LUIZ DO CPD URGENTE   Plani"  
                movimpack.placod format "9999999999"
                with frame f-aviso2
                        color white/red centered row 10.
        PAUSE.
        next.
    end.

    /**************  TRANSFERENCIA - SAIDA ******************/
    find packestoq where packestoq.etbcod = plani.emite and
                         packestoq.paccod = movimpack.paccod no-error.
    if not avail packestoq
    then do:
/***
        find first xpackestoq where xpackestoq.paccod = movimpack.paccod no-lock.
***/
        create packestoq.
        assign packestoq.etbcod = plani.emite
               packestoq.paccod = movimpack.paccod
               /***packestoq.estcusto = xpackestoq.estcusto
               packestoq.estvenda = xpackestoq.estvenda***/.
    end.

    if plani.emite <> 22
    then do:
        if vtipo = "I"
        then packestoq.estatual = packestoq.estatual - movimpack.movqtm.
        if vtipo = "E"
        then packestoq.estatual = packestoq.estatual + movimpack.movqtm.
        if vtipo = "A"
        then packestoq.estatual = packestoq.estatual + vqtd - movimpack.movqtm.
        if packestoq.estatual = 0
        then packestoq.estinvdat = movimpack.movdat.
    end.
    
    find packhiest where packhiest.etbcod = plani.emite      and
                         packhiest.paccod = movimpack.paccod and
                         packhiest.hiedt  = vdata
                   no-error.
    if not avail packhiest
    then do:
        create packhiest.
        assign packhiest.etbcod = plani.emite
               packhiest.paccod = movimpack.paccod
               packhiest.hiedt  = vdata.
    end.

    packhiest.hiestf = packestoq.estatual.
/***
    packhiest.hiepcf = packestoq.estcusto.
    packhiest.hiepvf = packestoq.estvenda.
***/    

    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/

    find bpackestoq where bpackestoq.etbcod = plani.desti and
                          bpackestoq.paccod = movimpack.paccod
                    no-error.
    if not avail bpackestoq
    then do:
/***
        find first xpackestoq where xpackestoq.paccod = movimpack.paccod no-lock.
**/
        create bpackestoq.
        assign bpackestoq.etbcod = plani.desti
               bpackestoq.paccod = movimpack.paccod
/***               bpackestoq.estcusto = xpackestoq.estcusto
               bpackestoq.estvenda = xpackestoq.estvenda***/.
    end.
    if vtipo = "I"
    then bpackestoq.estatual = bpackestoq.estatual + movimpack.movqtm.
    if vtipo = "E"
    then bpackestoq.estatual = bpackestoq.estatual - movimpack.movqtm.
    if vtipo = "A"
    then  bpackestoq.estatual = bpackestoq.estatual - vqtd + movimpack.movqtm.

    find packhiest where packhiest.etbcod = plani.desti  and
                         packhiest.paccod = movimpack.paccod and
                         packhiest.hiedt  = vdata
                   no-lock.
    if not avail packhiest
    then do:
        create packhiest.
        assign packhiest.etbcod = plani.desti
               packhiest.paccod = movimpack.paccod
               packhiest.hiedt  = vdata.
    end.
    packhiest.hiestf = bpackestoq.estatual.
/***
    packhiest.hiepcf = bpackestoq.estcusto.
    packhiest.hiepvf = bpackestoq.estvenda.

    find bhimov where bhimov.etbcod = plani.emite         and
                      bhimov.movtdc = 6                   and
                      bhimov.procod = movimpack.paccod        and
                      bhimov.himmes = month(today) and
                      bhimov.himano =  year(today) no-error.
    if not avail bhimov 
    then do:
        create bhimov.
        assign bhimov.etbcod = plani.emite
               bhimov.movtdc = 6
               bhimov.procod = movimpack.paccod
               bhimov.himmes = month(today)
               bhimov.himano =  year(today).
    end.
    if vtipo = "I"
    then bhimov.himqtm = bhimov.himqtm + movimpack.movqtm.
    if vtipo = "E"
    then bhimov.himqtm = bhimov.himqtm - movimpack.movqtm.
    if vtipo = "A"
    then bhimov.himqtm = bhimov.himqtm - vqtd + movimpack.movqtm.

    if vtipo = "I"
    then do:
        find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) and
                       ctbhie.ctbmes <= month(movimpack.movdat) and
                       ctbhie.procod = movimpack.paccod
                       no-lock no-error.
        if not avail ctbhie
        then do vi = 1 to 10:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) - vi and
                       ctbhie.procod = movimpack.paccod
                       no-lock no-error.
            if avail ctbhie
            then leave.    
        end.
        if avail ctbhie
        then movimpack.movctm = ctbhie.ctbcus.
    end.
    
    /******************************************************/
    
    find himov where himov.etbcod = plani.desti         and
                     himov.movtdc = 7                   and
                     himov.procod = movimpack.paccod        and
                     himov.himmes = month(today) and
                     himov.himano =  year(today) no-error.
    if not avail himov
    then do:
        create himov.
        assign himov.etbcod = plani.desti
               himov.movtdc = 7
               himov.procod = movimpack.paccod
               himov.himmes = month(today)
               himov.himano =  year(today).
    end.
    if vtipo = "I"
    then himov.himqtm = himov.himqtm + movimpack.movqtm.
    if vtipo = "E"
    then himov.himqtm = himov.himqtm - movimpack.movqtm.
    if vtipo = "A"
    then  himov.himqtm = himov.himqtm - vqtd + movimpack.movqtm.
***/

    /****************** FIM TRANSFERENCIA - ENTRADA *****************/

end.

    
    /********************** INICIO ENTRADA **********************/
def var vqtdest-ant as dec.
def var vctomed-ant as dec.
def var vqtdest-atu as dec.
def var vctomed-atu as dec.
def var vpis as dec.
def var vcofins as dec.

if movimpack.movtdc = 4 or
   movimpack.movtdc = 1 or
   movimpack.movtdc = 7 or
   movimpack.movtdc = 11 or
   movimpack.movtdc = 12 or
   movimpack.movtdc = 15 or
   movimpack.movtdc = 17 or
   movimpack.movtdc = 60 or
   movimpack.movtdc = 62
then do:
    if vtipo = "I"
    then do:
        vqtdest-ant = 0.
        for each packestoq where packestoq.paccod = movimpack.paccod no-lock:
            vqtdest-ant = vqtdest-ant + packestoq.estatual.
        end.
    end.    
    
    find packestoq where packestoq.etbcod = movimpack.etbcod and
                         packestoq.paccod = movimpack.paccod
                   no-error.
    if not avail packestoq
    then do:
/***
        find first xpackestoq where xpackestoq.paccod = movimpack.paccod no-lock.
***/
        create packestoq.
        assign packestoq.etbcod = movimpack.etbcod
               packestoq.paccod = movimpack.paccod
/***               packestoq.estcusto = xpackestoq.estcusto
               packestoq.estvenda = xpackestoq.estvenda***/.
    end.
    if vtipo = "I"
    then packestoq.estatual = packestoq.estatual + movimpack.movqtm.
    if vtipo = "E"
    then packestoq.estatual = packestoq.estatual - movimpack.movqtm.
    if vtipo = "A"
    then  packestoq.estatual = packestoq.estatual - vqtd + movimpack.movqtm.
    
    find packhiest where packhiest.etbcod = movimpack.etbcod and
                         packhiest.paccod = movimpack.paccod and
                         packhiest.hiedt  = vdata
                   no-error.
    if not avail packhiest
    then do:
        create packhiest.
        assign packhiest.etbcod = movimpack.etbcod
               packhiest.paccod = movimpack.paccod
               packhiest.hiedt  = vdata.
    end.
    packhiest.hiestf = packestoq.estatual.
/***
    packhiest.hiepcf = packestoq.estcusto.
    packhiest.hiepvf = packestoq.estvenda.
   
    if movimpack.movtdc = 4 or
       movimpack.movtdc = 1
    then do:
    
        find himov where himov.etbcod = movimpack.etbcod        and
                         himov.movtdc = 4                   and
                         himov.procod = movimpack.paccod        and
                         himov.himmes = month(today) and
                         himov.himano = year(today) no-error.
        if not avail himov
        then do:
            create himov.
            assign himov.etbcod = movimpack.etbcod
                   himov.movtdc = 4
                   himov.procod = movimpack.paccod
                   himov.himmes = month(today)
                   himov.himano =  year(today).
        end.
        if vtipo = "I"
        then himov.himqtm = himov.himqtm + movimpack.movqtm.
        if vtipo = "E"
        then himov.himqtm = himov.himqtm - movimpack.movqtm.
        if vtipo = "A"
        then  himov.himqtm = himov.himqtm - vqtd + movimpack.movqtm.
        
        if vtipo = "I"
        then do:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) and
                       ctbhie.ctbmes <= month(movimpack.movdat) and
                       ctbhie.procod = movimpack.paccod
                       no-lock no-error.
            if not avail ctbhie
            then do vi = 1 to 10:
                find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) - vi and
                       ctbhie.procod = movimpack.paccod
                       no-lock no-error.
                if avail ctbhie
                then leave.    
            end.
            vctomed-ant = 0.
            if avail ctbhie
            then vctomed-ant = ctbhie.ctbcus.
            vpis = 0.
            vcofins = 0.
            run piscofal.p( input no, 
                        input movimpack.movtdc, 
                        input movimpack.paccod, 
                        output vpis,
                        output vcofins).
        
            if vpis > 0
            then vpis = (movimpack.movpc * movimpack.movqtm) * (vpis / 100).
            if vcofins > 0
            then vcofins = (movimpack.movpc * movimpack.movqtm) * 
                        (vcofins / 100).
            if vqtdest-ant = ? or vqtdest-ant < 0
            then vqtdest-ant = 0.            
            if vctomed-ant = ? or vctomed-ant < 0
            then vctomed-ant = 0.
            vqtdest-atu = vqtdest-ant + movimpack.movqtm.
                                 
            vctomed-atu =  
                ((movimpack.movpc - (movimpack.movpc * (movimpack.movalicms / 100))) *
                             movimpack.movqtm) - (movimpack.movdes * movimpack.movqtm)
                             + movimpack.movipi - vpis - vcofins.
            if vqtdest-ant > 0 and
               vctomed-ant > 0
            then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
            vctomed-atu = vctomed-atu / vqtdest-atu.
            
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) and
                       ctbhie.ctbmes = month(movimpack.movdat) and
                       ctbhie.procod = movimpack.paccod
                       no-error.
            if not avail ctbhie
            then do:
                create ctbhie.
                assign
                    ctbhie.etbcod = 0 
                    ctbhie.procod = movimpack.paccod
                    ctbhie.ctbano = year(movimpack.movdat)
                    ctbhie.ctbmes = month(movimpack.movdat)
                    .
            end.
            assign
                ctbhie.ctbcus = vctomed-atu
                ctbhie.ctbest = vctomed-ant
                ctbhie.ctbven = vqtdest-ant
                movimpack.movctm = vctomed-atu.

        end.
    end.
***/

end.
    /**************************  FIM ENTRADA ************************/


    /*********************** INICIO SAIDA ***********************/
if movimpack.movtdc = 5 or
   movimpack.movtdc = 13 or
   movimpack.movtdc = 14 or
   movimpack.movtdc = 16 or
   movimpack.movtdc = 8  or
   movimpack.movtdc = 18 or
   movimpack.movtdc = 26 or
   movimpack.movtdc = 59
then do:
    find packestoq where packestoq.etbcod = movimpack.etbcod and
                         packestoq.paccod = movimpack.paccod
                   no-error.
    if not avail packestoq
    then do:
/***
        find first xpackestoq where xpackestoq.paccod = movimpack.paccod no-lock.
***/
        create packestoq.
        assign packestoq.etbcod = movimpack.etbcod
               packestoq.paccod = movimpack.paccod
/***
               packestoq.estcusto = xpackestoq.estcusto
               packestoq.estvenda = xpackestoq.estvenda.
***/.
    end.

    if plani.emite <> 22
    then do:
        if vtipo = "I"
        then packestoq.estatual = packestoq.estatual - movimpack.movqtm.
        if vtipo = "E"
        then packestoq.estatual = packestoq.estatual + movimpack.movqtm.
        if vtipo = "A"
        then  packestoq.estatual = packestoq.estatual + vqtd - movimpack.movqtm.
        if packestoq.estatual = 0
        then packestoq.estinvdat = movimpack.movdat.
    end.

    find packhiest where packhiest.etbcod = movimpack.etbcod and
                         packhiest.paccod = movimpack.paccod and
                         packhiest.hiedt  = vdata
                   no-error.
    if not avail packhiest
    then do:
        create packhiest.
        assign packhiest.etbcod = movimpack.etbcod
               packhiest.paccod = movimpack.paccod
               packhiest.hiedt  = vdata.
    end.
    packhiest.hiestf = packestoq.estatual.
/***
    packhiest.hiepcf = packestoq.estcusto.
    packhiest.hiepvf = packestoq.estvenda.

    if movimpack.movtdc = 5
    then do:
        find himov where himov.etbcod = movimpack.etbcod        and
                         himov.movtdc = movimpack.movtdc        and
                         himov.procod = movimpack.paccod        and
                         himov.himmes = month(today) and
                         himov.himano =  year(today) no-error.
        if not avail himov
        then do:
            create himov.
            assign himov.etbcod = movimpack.etbcod
                   himov.movtdc = 5
                   himov.procod = movimpack.paccod
                   himov.himmes = month(today)
                   himov.himano =  year(today).
        end.
        if vtipo = "I"
        then himov.himqtm = himov.himqtm + movimpack.movqtm.
        if vtipo = "E"
        then himov.himqtm = himov.himqtm - movimpack.movqtm.
        if vtipo = "A"
        then  himov.himqtm = himov.himqtm - vqtd + movimpack.movqtm.
    end.
    
    if vtipo = "I"
    then do:
        find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) and
                       ctbhie.ctbmes <= month(movimpack.movdat) and
                       ctbhie.procod = movimpack.paccod
                       no-lock no-error.
        if not avail ctbhie
        then do vi = 1 to 10:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movimpack.movdat) - vi  and
                       ctbhie.procod = movimpack.paccod
                       no-lock no-error.
            if avail ctbhie
            then leave.    
        end.
        if avail ctbhie
        then movimpack.movctm = ctbhie.ctbcus.
    end.
***/
end.

    /**************************** FIM SAIDA *************************/

