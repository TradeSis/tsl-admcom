/*
#1 junho/2018 - Projeto entrega em outra loja
*/
def buffer bhimov for himov.
DEF BUFFER BESTOQ FOR ESTOQ.
DEF BUFFER xESTOQ FOR ESTOQ.

def new shared temp-table tt-plani no-undo like plani.
def new shared temp-table tt-movim no-undo like movim.

def input parameter vrecmov as recid.
def input parameter vtipo   as char.
def input parameter vqtd    as i.
def var vi as int.

find movim where recid(movim) = vrecmov  no-error.
if not avail movim
then do:
    display "ENTRE EM CONTATO COM CPD URGENTE   Movim" 
            with frame f-aviso1
                    color white/red centered row 10.
    PAUSE.
    next.
end.
 
    if month(movim.datexp) <> month(today)
    then do:
        output to errodata.log append.
            put movim.placod format "9999999999" space(1)
                movim.etbcod space(1)
                movim.movdat space(1)
                movim.datexp format "99/99/9999" space(1)
                today format "99/99/9999"        space(1)
                movim.procod skip.
        output close.
        find movdat where movdat.etbcod = movim.etbcod and
                          movdat.placod = movim.placod and
                          movdat.procod = movim.procod NO-LOCK no-error.
        if not avail movdat
        then do:
            create movdat.
            assign movdat.procod = movim.procod
                   movdat.etbcod = movim.etbcod
                   movdat.placod = movim.placod
                   movdat.datent = today.
        end.    
    end. 
                       
    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ
    then do:
        output to erropro.log append.
        put movim.procod space(1)
            movim.etbcod space(1)
            movim.placod format "9999999999" space(1)
            movim.movdat space(1)
            movim.movtdc format "99" space(1) skip.
        output close.
    end.


if movim.movtdc = 6 or movim.movtdc = 3 /* Transferencia */
then do:

    find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat no-lock no-error.
    if not avail plani
    then do:    
        display "ENTRE EM CONTATO COM LUIZ DO CPD URGENTE   Plani"  
                movim.placod format "9999999999"
                with frame f-aviso2 color white/red centered row 10.
        PAUSE.
        next.
    end.


    /**************  TRANSFERENCIA - SAIDA ******************/
    find estoq where estoq.etbcod = plani.emite and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = plani.emite
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.

    if plani.emite <> 22
    then do:
        if vtipo = "I"
        then estoq.estatual = estoq.estatual - movim.movqtm.
        if vtipo = "E"
        then estoq.estatual = estoq.estatual + movim.movqtm.
        if vtipo = "A"
        then estoq.estatual = estoq.estatual + vqtd - movim.movqtm.

        /*** PONTO DE ATENCAO: VIRADA P2K ***/
        if estoq.estatual = 0
        then estoq.estinvdat = movim.movdat.
    end.

    find hiest where hiest.etbcod = plani.emite         and
                     hiest.procod = movim.procod        and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = plani.emite
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.

    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/

    find bestoq where bestoq.etbcod = plani.desti and
                      bestoq.procod = movim.procod no-error.
    if not avail bestoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create bestoq.
        assign bestoq.etbcod = plani.desti
               bestoq.procod = movim.procod
               bestoq.estcusto = xestoq.estcusto
               bestoq.estvenda = xestoq.estvenda.
    end.
/***
    else if avail bestoq and plani.emite = 22
    then do.
        find first xestoq where xestoq.procod = movim.procod no-lock.
        bestoq.estcusto = xestoq.estcusto.
    end.
***/
    
    if vtipo = "I"
    then bestoq.estatual = bestoq.estatual + movim.movqtm.
    if vtipo = "E"
    then bestoq.estatual = bestoq.estatual - movim.movqtm.
    if vtipo = "A"
    then bestoq.estatual = bestoq.estatual - vqtd + movim.movqtm.

    find hiest where hiest.etbcod = plani.desti  and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = plani.desti
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    hiest.hiestf = bestoq.estatual.
    hiest.hiepcf = bestoq.estcusto.
    hiest.hiepvf = bestoq.estvenda.

    find bhimov where bhimov.etbcod = plani.emite  and
                      bhimov.movtdc = 6            and
                      bhimov.procod = movim.procod and
                      bhimov.himmes = month(today) and
                      bhimov.himano = year(today) no-error.
    if not avail bhimov 
    then do:
        create bhimov.
        assign bhimov.etbcod = plani.emite
               bhimov.movtdc = 6
               bhimov.procod = movim.procod
               bhimov.himmes = month(today)
               bhimov.himano = year(today).
    end.
    if vtipo = "I"
    then bhimov.himqtm = bhimov.himqtm + movim.movqtm.
    if vtipo = "E"
    then bhimov.himqtm = bhimov.himqtm - movim.movqtm.
    if vtipo = "A"
    then bhimov.himqtm = bhimov.himqtm - vqtd + movim.movqtm.

    /*** PONTO DE ATENCAO: VIRADA P2K ***/
    if vtipo = "I"
    then do:
        find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) and
                       ctbhie.ctbmes <= month(movim.movdat) and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
        if not avail ctbhie
        then do vi = 1 to 10:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) - vi and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
            if avail ctbhie
            then leave.    
        end.
        if avail ctbhie
        then movim.movctm = ctbhie.ctbcus.
    end.
    
    /******************************************************/
    
    find himov where himov.etbcod = plani.desti         and
                     himov.movtdc = 7                   and
                     himov.procod = movim.procod        and
                     himov.himmes = month(today) and
                     himov.himano = year(today) no-error.
    if not avail himov
    then do:
        create himov.
        assign himov.etbcod = plani.desti
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
    then himov.himqtm = himov.himqtm - vqtd + movim.movqtm.

    /****************** FIM TRANSFERENCIA - ENTRADA *****************/
end.

if movim.movtdc = 79 /* Transferencia estorno */
then do:
    /************** INICIO TRANSFERENCIA - ESTORNO ******************/
    find estoq where estoq.etbcod = plani.emite and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = plani.emite
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.

    if plani.emite <> 22
    then do:
        if vtipo = "I"
        then estoq.estatual = estoq.estatual + movim.movqtm.
        if vtipo = "E"
        then estoq.estatual = estoq.estatual - movim.movqtm.
        if vtipo = "A"
        then estoq.estatual = estoq.estatual - (vqtd - movim.movqtm).

        /*** PONTO DE ATENCAO: VIRADA P2K ***/
        if estoq.estatual = 0
        then estoq.estinvdat = movim.movdat.    

    find hiest where hiest.etbcod = plani.emite  and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = plani.emite
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.
    end.
    
    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/
    find bestoq where bestoq.etbcod = plani.desti and
                      bestoq.procod = movim.procod no-error.
    if not avail bestoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create bestoq.
        assign bestoq.etbcod = plani.desti
               bestoq.procod = movim.procod
               bestoq.estcusto = xestoq.estcusto
               bestoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then bestoq.estatual = bestoq.estatual - movim.movqtm.
    if vtipo = "E"
    then bestoq.estatual = bestoq.estatual + movim.movqtm.
    if vtipo = "A"
    then bestoq.estatual = bestoq.estatual + (vqtd + movim.movqtm).

    find hiest where hiest.etbcod = plani.desti  and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = plani.desti
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    hiest.hiestf = bestoq.estatual.
    hiest.hiepcf = bestoq.estcusto.
    hiest.hiepvf = bestoq.estvenda.

    find bhimov where bhimov.etbcod = plani.emite  and
                      bhimov.movtdc = 6            and
                      bhimov.procod = movim.procod and
                      bhimov.himmes = month(today) and
                      bhimov.himano = year(today) no-error.
    if not avail bhimov 
    then do:
        create bhimov.
        assign bhimov.etbcod = plani.emite
               bhimov.movtdc = 6
               bhimov.procod = movim.procod
               bhimov.himmes = month(today)
               bhimov.himano = year(today).
    end.
    if vtipo = "I"
    then bhimov.himqtm = bhimov.himqtm - movim.movqtm.
    if vtipo = "E"
    then bhimov.himqtm = bhimov.himqtm + movim.movqtm.
    if vtipo = "A"
    then bhimov.himqtm = bhimov.himqtm + (vqtd + movim.movqtm).

    /*** PONTO DE ATENCAO: VIRADA P2K ***/
    if vtipo = "I"
    then do:
        find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) and
                       ctbhie.ctbmes <= month(movim.movdat) and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
        if not avail ctbhie
        then do vi = 1 to 10:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) - vi and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
            if avail ctbhie
            then leave.    
        end.
        if avail ctbhie
        then movim.movctm = ctbhie.ctbcus.
    end.
    
    /******************************************************/
    
    find himov where himov.etbcod = plani.desti  and
                     himov.movtdc = 7            and
                     himov.procod = movim.procod and
                     himov.himmes = month(today) and
                     himov.himano = year(today) no-error.
    if not avail himov
    then do:
        create himov.
        assign himov.etbcod = plani.desti
               himov.movtdc = 7
               himov.procod = movim.procod
               himov.himmes = month(today)
               himov.himano = year(today).
    end.
    if vtipo = "I"
    then himov.himqtm = himov.himqtm - movim.movqtm.
    if vtipo = "E"
    then himov.himqtm = himov.himqtm + movim.movqtm.
    if vtipo = "A"
    then himov.himqtm = himov.himqtm + (vqtd + movim.movqtm).

    /****************** FIM TRANSFERENCIA - ESTORNO *****************/
end.

    
    /********************** INICIO ENTRADA **********************/
def var vqtdest-ant as dec.
def var vctomed-ant as dec.
def var vqtdest-atu as dec.
def var vctomed-atu as dec.
def var vpis as dec.
def var vcofins as dec.
def var vmovsubst as dec.

if movim.movtdc = 4 or
   movim.movtdc = 1 or
   movim.movtdc = 7 or
   movim.movtdc = 11 or
   movim.movtdc = 12 or
   movim.movtdc = 15 or
   movim.movtdc = 17 or
   movim.movtdc = 51 or
   movim.movtdc = 53 or
   movim.movtdc = 60 or
   movim.movtdc = 62 or
   movim.movtdc = 82 /* #1 */
then do:
    find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat no-lock no-error.
    if not avail plani
    then do:    
        display "ENTRE EM CONTATO COM LUIZ DO CPD URGENTE   Plani"  
                movim.placod format "9999999999"
                with frame f-aviso2 color white/red centered row 10.
        PAUSE.
        next.
    end.

    if vtipo = "I"
    then do:
        vqtdest-ant = 0.
        for each estoq where estoq.procod = movim.procod no-lock:
            vqtdest-ant = vqtdest-ant + estoq.estatual.
        end.
    end.    
    
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
    then estoq.estatual = estoq.estatual - vqtd + movim.movqtm.
    
    find hiest where hiest.etbcod = movim.etbcod and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.
       
    if movim.movtdc = 4 or
       movim.movtdc = 1
    then do:
        find himov where himov.etbcod = movim.etbcod and
                         himov.movtdc = 4            and
                         himov.procod = movim.procod and
                         himov.himmes = month(today) and
                         himov.himano = year(today) no-error.
        if not avail himov
        then do:
            create himov.
            assign himov.etbcod = movim.etbcod
                   himov.movtdc = 4
                   himov.procod = movim.procod
                   himov.himmes = month(today)
                   himov.himano = year(today).
        end.
        if vtipo = "I"
        then himov.himqtm = himov.himqtm + movim.movqtm.
        if vtipo = "E"
        then himov.himqtm = himov.himqtm - movim.movqtm.
        if vtipo = "A"
        then himov.himqtm = himov.himqtm - vqtd + movim.movqtm.
        
        if vtipo = "I"
        then do:
            
            run calctom-movim.p(input recid(movim), input "").

            /****
            run /admcom/progr/calctom-pro.p(movim.procod, 
                                            input today ,
                                            input today ,
                                            input "").

            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) and
                       ctbhie.ctbmes <= month(movim.movdat) and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
            if not avail ctbhie
            then do vi = 1 to 10:
                find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) - vi and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
                if avail ctbhie
                then leave.    
            end.
            vctomed-ant = 0.
            if avail ctbhie
            then vctomed-ant = ctbhie.ctbcus.
            
            vpis = 0.
            vcofins = 0.

            for each tt-movim: delete tt-movim. end.
            for each tt-plani: delete tt-plani. end.
        
            if movim.movpis > 0 or movim.movcofins > 0
            then assign
                vpis = movim.movpis
                vcofins = movim.movcofins.
            else do:        
                create tt-plani.
                buffer-copy plani to tt-plani.
                create tt-movim.
                buffer-copy movim to tt-movim.
        
                run piscofins-ae.p   .

                find first tt-movim where tt-movim.procod = movim.procod 
                     no-error.
                if avail tt-movim 
                then assign
                    vpis = tt-movim.movpis  
                    vcofins = tt-movim.movcofins
                    vmovsubst = tt-movim.movsubst.
            end.

            /*****************
            vpis = 0.
            vcofins = 0.

            run piscofal.p( input no, 
                        input movim.movtdc, 
                        input movim.procod, 
                        output vpis,
                        output vcofins).
        
            if vpis > 0
            then vpis = (movim.movpc * movim.movqtm) * (vpis / 100).
            if vcofins > 0
            then vcofins = (movim.movpc * movim.movqtm) * 
                        (vcofins / 100).
            *******************/
            
            if vqtdest-ant = ? or vqtdest-ant < 0
            then vqtdest-ant = 0.            
            if vctomed-ant = ? or vctomed-ant < 0
            then vctomed-ant = 0.
            vqtdest-atu = vqtdest-ant + movim.movqtm.
                                 
            vctomed-atu =  
                ((movim.movpc - (movim.movpc * (movim.movalicms / 100))) *
                             movim.movqtm) - (movim.movdes * movim.movqtm)
                             + movim.movipi - vpis - vcofins.
                              
            if vmovsubst > ((movim.movpc * movim.movqtm) *
                                (movim.movalicms / 100))
            then vctomed-atu = vctomed-atu +                    
                    (vmovsubst - ((movim.movpc * movim.movqtm) * 
                                (movim.movalicms / 100))).

            if vqtdest-ant > 0 and
               vctomed-ant > 0
            then vctomed-atu = vctomed-atu +
                      (vctomed-ant * vqtdest-ant).
            vctomed-atu = vctomed-atu / vqtdest-atu.
            
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(plani.dtinclu) and
                       ctbhie.ctbmes = month(plani.dtinclu) and
                       ctbhie.procod = movim.procod
                       no-error.
            if not avail ctbhie
            then do:
                create ctbhie.
                assign
                    ctbhie.etbcod = 0 
                    ctbhie.procod = movim.procod
                    ctbhie.ctbano = year(plani.dtinclu)
                    ctbhie.ctbmes = month(plani.dtinclu).
            end.
            assign
                ctbhie.ctbcus = vctomed-atu
                ctbhie.ctbest = vctomed-ant
                ctbhie.ctbven = vqtdest-ant
                movim.movctm = vctomed-atu.
    
            find first mvcusto where 
                   mvcusto.procod = movim.procod and
                   mvcusto.dativig = plani.dtinclu and
                   mvcusto.horivig = plani.horincl
                   no-error.
            if not avail mvcusto
            then  do:
                create mvcusto.
                assign
                    mvcusto.procod = movim.procod
                    mvcusto.dativig = plani.dtinclu
                    mvcusto.horivig = plani.horincl
                    .
            end.        
            assign
                mvcusto.etbcod = plani.etbcod
                mvcusto.placod = plani.placod
                mvcusto.serie  = plani.serie
                mvcusto.valctonotaf = estoq.estcusto
                mvcusto.valctomedio = vctomed-atu
                mvcusto.estoque = vqtdest-ant
                mvcusto.custo1 = vctomed-ant
                mvcusto.datinclu = plani.dtinclu
                mvcusto.char1 = "QTDESTANT=" + string(vqtdest-ant) + "|" +
                            "QTDESTATU=" + string(vqtdest-atu) + "|" +
                            "CTOMEDANT=" + string(vctomed-ant) + "|" +
                            "CTOMEDATU=" + string(vctomed-atu) + "|"
                 . 
            *******************/         
        end.
    end.
end.
    /**************************  FIM ENTRADA ************************/


    /*********************** INICIO SAIDA ***********************/
if movim.movtdc = 5 or
   movim.movtdc = 13 or
   movim.movtdc = 14 or
   movim.movtdc = 16 or
   movim.movtdc = 8  or
   movim.movtdc = 18 or
   movim.movtdc = 26 or
   movim.movtdc = 46 or 
   movim.movtdc = 52 or
   movim.movtdc = 59 or
   movim.movtdc = 72 or
   movim.movtdc = 81 /* #1 */
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

    if movim.emite <> 22
    then do:
        if vtipo = "I"
        then estoq.estatual = estoq.estatual - movim.movqtm.
        if vtipo = "E"
        then estoq.estatual = estoq.estatual + movim.movqtm.
        if vtipo = "A"
        then estoq.estatual = estoq.estatual + vqtd - movim.movqtm.
        if estoq.estatual = 0
        then estoq.estinvdat = movim.movdat.
    end.                                       

    find hiest where hiest.etbcod = movim.etbcod and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.

    if movim.movtdc = 5
    then do:
        find himov where himov.etbcod = movim.etbcod and
                         himov.movtdc = movim.movtdc and
                         himov.procod = movim.procod and
                         himov.himmes = month(today) and
                         himov.himano = year(today) no-error.
        if not avail himov
        then do:
            create himov.
            assign himov.etbcod = movim.etbcod
                   himov.movtdc = 5
                   himov.procod = movim.procod
                   himov.himmes = month(today)
                   himov.himano = year(today).
        end.
        if vtipo = "I"
        then himov.himqtm = himov.himqtm + movim.movqtm.
        if vtipo = "E"
        then himov.himqtm = himov.himqtm - movim.movqtm.
        if vtipo = "A"
        then himov.himqtm = himov.himqtm - vqtd + movim.movqtm.
    end.
    
    if movim.movtdc <> 5 and /*** 26/01/2016 ***/
       vtipo = "I"
    then do:
        find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) and
                       ctbhie.ctbmes <= month(movim.movdat) and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
        if not avail ctbhie
        then do vi = 1 to 10:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) - vi  and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
            if avail ctbhie
            then leave.    
        end.
        if avail ctbhie
        then movim.movctm = ctbhie.ctbcus.
    end.
end.

/**************************** FIM SAIDA *************************/

/********** ARMAZEM GERAL *******************/

/********** EMISSAO ***********************/
if movim.movtdc = 73
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
        then estoq.estatual = estoq.estatual + vqtd - movim.movqtm.
        if estoq.estatual = 0
        then estoq.estinvdat = movim.movdat.

    find hiest where hiest.etbcod = movim.etbcod and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.

    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.

    if vtipo = "I"
    then do:
        find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) and
                       ctbhie.ctbmes <= month(movim.movdat) and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
        if not avail ctbhie
        then do vi = 1 to 10:
            find last ctbhie where ctbhie.etbcod = 0 and
                       ctbhie.ctbano = year(movim.movdat) - vi  and
                       ctbhie.procod = movim.procod
                       no-lock no-error.
            if avail ctbhie
            then leave.    
        end.
        if avail ctbhie
        then movim.movctm = ctbhie.ctbcus.
    end.

    find estoq where estoq.etbcod = 981 and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = 981
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.

    if vtipo = "I"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "A"
    then estoq.estatual = estoq.estatual - vqtd - movim.movqtm.
    
    if estoq.estatual = 0
    then estoq.estinvdat = movim.movdat.

    find hiest where hiest.etbcod = 981 and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = 981
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.

    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.
end.

/***** RETORNO *****/

if movim.movtdc = 74 or movim.movtdc = 78
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
    then estoq.estatual = estoq.estatual - vqtd + movim.movqtm.

    find hiest where hiest.etbcod = movim.etbcod and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = movim.etbcod
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.

    find estoq where estoq.etbcod = 981 and
                     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
        find first xestoq where xestoq.procod = movim.procod no-lock.
        create estoq.
        assign estoq.etbcod = 981
               estoq.procod = movim.procod
               estoq.estcusto = xestoq.estcusto
               estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "A"
    then estoq.estatual = estoq.estatual + vqtd + movim.movqtm.

    find hiest where hiest.etbcod = 981 and
                     hiest.procod = movim.procod and
                     hiest.hiemes = month(today) and
                     hiest.hieano = year(today) no-error.
    if not avail hiest
    then do:
        create hiest.
        assign hiest.etbcod = 981
               hiest.procod = movim.procod
               hiest.hiemes = month(today)
               hiest.hieano = year(today).
    end.
    
    hiest.hiestf = estoq.estatual.
    hiest.hiepcf = estoq.estcusto.
    hiest.hiepvf = estoq.estvenda.
end.

/********* FIM ARMAZEM GERAL ******/
