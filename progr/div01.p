/* #1 21.02.19 helio.neto ajustes para ficar igual ao plaped.p */  
/* #2 26.02.19 helio.neto ajustes para so mostrar as notas com produtos com divergencia */
{admcab.i}


def var fila as char.
def var recimp as recid.
/*
#1def var frete_unitario like plani.platot.
#1 def var qtd_total as int.*/

def temp-table tt-estab like estab .
def var vcatcod like produ.catcod.
def var vok as l.
def var varquivo as char format "x(30)".
def var vdata like plani.dtincl.
def var vmes as i.
def var vpla like crepl.crenom format "x(25)".
def var vped like crepl.crenom.
def var i     as i.
def var vdia  as i.
def var vpar  as i.
def var despla like plani.descprod.
def var desped like plani.descprod.
def var dpla like plani.pladat.
def var dini like pedid.peddti.
def var dfin like pedid.peddtf.
def var totpla  like plani.platot.
def var totped  like plani.platot.
def var vforcod like forne.forcod.
def var vnumero like plani.numero format ">>>>>>9".
def var vetbcod like estab.etbcod format ">>9".
def var vfrete  like plani.frete.
def var vemite  like plani.emite.

def var sresp-aux  as logical format "Visualizar/Imprimir".

def temp-table wprodu
    field wcod like produ.procod
    field qent like movim.movqtm
    field qped like movim.movqtm
    field pent like movim.movpc  format ">>,>>9.99"
    field pped like movim.movpc  format ">>,>>9.99".
    
repeat:
    for each wprodu.
        delete wprodu.
    end.

    for each tt-estab:
        delete tt-estab.
    end.

    update vetbcod with frame f00 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f00.
    find tt-estab where tt-estab.etbcod = estab.etbcod no-error.
    if not avail tt-estab
    then do:
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.
    end.
    
    if vetbcod = 996
    then do:
        create tt-estab.
        assign tt-estab.etbcod = 22.
    end.
    
    update vdata with frame f0 side-label width 80.

    totpla = 0.
    totped = 0.
    despla = 0.
    desped = 0.
    dpla = ?.
    dini = ?.
    dfin = ?.

    if opsys = "UNIX"
    then varquivo = "../relat/diverg" + string(time).
    else varquivo = "..\relat\diverg" + string(day(today)).

    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "130" 
        &Page-Line = "66" 
        &Nom-Rel   = ""div01"" 
        &Nom-Sis   = """SISTEMA DE ESTOQUE""" 
        &Tit-Rel   = """DIVERGENCIAS DE PEDIDOS DIA "" +
                        string(vdata,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}
                
                
    for each tt-estab,
        each tipmov where tipmov.movtdc = 4 or
                          tipmov.movtdc = 6,  
        each plani where plani.datexp = vdata and
                         plani.movtdc = tipmov.movtdc  and
                         plani.etbcod = tt-estab.etbcod no-lock:
        if tipmov.movtdc = 6
        then do:
            if plani.etbcod = 22 and
               plani.desti  = 996
            then.
            else next.
        end.
        if plani.movtdc = 6
        then vemite = 5027.
        else vemite = plani.emite. 
        
            
        vfrete = 0.
        for each titulo where titulo.empcod = 19    and
                              titulo.titnat = yes   and
                              titulo.etbcod = tt-estab.etbcod and
                              titulo.modcod = "NEC" and
                              titulo.clifor = plani.cxacod            and
                              titulo.titnumger = string(plani.numero) and
                              titulo.titpar = 1 no-lock:
            vfrete = vfrete + titulo.titvlcob.               
        end.
        vfrete = vfrete + plani.frete.

        
        for each wprodu.
            delete wprodu.
        end.
        totpla = 0.
        totped = 0.
        despla = 0.
        desped = 0.
        dpla = ?.
        dini = ?.
        dfin = ?.

        if plani.platot <> 0
        then totpla = plani.platot.
        else totpla = plani.protot.
        

        for each plaped where plaped.forcod = vemite  and
                              plaped.plaetb = vetbcod and
                              plaped.serie  = plani.serie  and
                              plaped.placod = plani.placod and
                              plaped.numero = plani.numero no-lock.

            find pedid where pedid.etbcod = plaped.pedetb and
                         pedid.pedtdc = plaped.pedtdc and
                         pedid.pednum = plaped.pednum no-lock no-error.
            if not avail pedid
            then next.
        
        
            if plani.movtdc = 6
            then find forne where forne.forcod = 5027 no-lock.
            else find forne where forne.forcod = plani.emite no-lock.

            find crepl where crepl.crecod = pedid.crecod no-lock.

            vpar = 0.
            vdia = 0.
            vpla = "".
            vmes = 0.
            for each titulo where titulo.empcod = wempre.empcod and
                              titulo.etbcod = plani.etbcod  and
                              titulo.titnat = yes           and
                              titulo.modcod = "DUP"         and
                              titulo.clifor = plani.emite   and
                              titulo.titnum = string(plani.numero) no-lock:
                vpar  = vpar + 1.
                vmes  = titulo.titdtven - titulo.titdtemi.
                vpla  = vpla + string(vmes) + ", ".
                vdia  = titulo.titdtven - pedid.peddat.
            end.
            vped = crepl.crenom.

            vpla = vpla + " DIAS".

            if plani.pladat <= pedid.peddti or
               plani.pladat >= pedid.peddtf
            then assign dpla = plani.pladat
        
            dini = pedid.peddti
            dfin = pedid.peddtf.
            if plani.descprod = 0
            then if pedid.nfdes <> 0
                 then assign despla = plani.descprod
                             desped = pedid.nfdes.

            if plani.descprod <> 0
            then if pedid.nfdes = 0
                 then assign despla = plani.descprod
                             desped = pedid.nfdes.

            /*#1
            qtd_total = 0.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and 
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:
                             
                qtd_total = qtd_total + movim.movqtm.
            
            end.    */
                             


            for each liped where liped.etbcod = plaped.pedetb and
                                 liped.pedtdc = plaped.pedtdc and
                                 liped.pednum = plaped.pednum no-lock:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.procod = liped.procod no-lock:
                    find first wprodu where wprodu.wcod = movim.procod no-error.
                    if not avail wprodu
                    then do:
                        create wprodu.
                        assign wprodu.wcod = movim.procod.
                    end.
                    wprodu.qent = movim.movqtm.
                
    
                    /*#1 frete_unitario = plani.frete / qtd_total.*/  
    
    
                    if movim.movdev > 0 
                    then wprodu.pent = (movim.movpc + (movim.movdev / movim.movqtm)
                                            - movim.movdes). 
                    else wprodu.pent = (movim.movpc /* #1+ frete_unitario*/ - movim.movdes
                                    ).
                    if movim.movipi > 0
                    then wprodu.pent = wprodu.pent + (movim.movipi / movim.movqtm) .
                    else wprodu.pent = wprodu.pent +
                        ( (movim.movpc /*+ frete_unitario*/ - movim.movdes) *
                                    (movim.movalipi / 100)).
                   
                
                    find first wprodu where wprodu.wcod = liped.procod no-error.
                    wprodu.qped = wprodu.qped + liped.lipqtd.
               
                    
                    wprodu.pped = (liped.lippreco - 
                                  (liped.lippreco * (pedid.nfdes / 100))).

                    wprodu.pped = (wprodu.pped + 
                                  (wprodu.pped * (pedid.ipides / 100))).

                    wprodu.pped = (wprodu.pped + 
                                  (wprodu.pped * (pedid.acrfin / 100))).
                    
                    
                    totped = totped + (wprodu.pped * liped.lipqtd).
                end.
            end.

            vok = no.
            for each wprodu:
                if (wprodu.qent = wprodu.qped) and
                   (wprodu.pent = wprodu.pped)
                then delete wprodu.
                /*#2*/ else do:
                    vok = yes.    
                end.
            end.

            /*#2*/
            if vok = no
            then do:
                next.
            end.
            
            put skip(4) fill("_",83) format "x(83)" at 1 skip
                 "| DEP: "  plaped.plaetb format ">>9"
                 "   PE : " pedid.pednum
                 "   NF: "  plani.numero format ">>>>>>9"
                 "   Forne: "    forne.fornom
              " | " at 83 skip
                    fill("-",83) format "x(83)" skip.

                         display "TOTAIS....    " totpla label "NF"
                                 totped label "PE" at 45
                                           with frame f2 side-label no-box.
            if dpla <> ?
            then display "DATAS.....    " dpla label "NF"
                         dini label "PE"  format "99/99/9999" at 45
                         "A " dfin no-label format "99/99/9999"
                            with frame f3 side-label no-box.

            if despla <> 0 or
               desped <> 0
            then display "DESC......    " despla label "NF"
                         desped label "PE" at 45 with frame f4 side-label no-box.

            display "VENC......    " vpla label "NF"
                     vped label "PE" at 45 with frame f5 side-label no-box.

            if vfrete <> 0
            then
            display "FRETE.....    " vfrete label "NF"
                    " = " ((vfrete / totpla) * 100) format ">>.99 %"
                     pedid.fobcif  label "PE" at 45 with frame f6 side-label no-box.

             
            put skip fill("_",83) format "x(83)" skip
                "| Produto Nome Produto                         Qtd.Nf   Qtd.PE     Pr.NF"
                "     Pr.PE | " skip
                "| ------- ------------                         ------   ------     -----"
                "     ----- | "    skip.
            vok = no.
            for each wprodu:
                find produ where produ.procod = wprodu.wcod no-lock.
                put "| " wprodu.wcod
                         produ.pronom format "x(35)" at 11
                         wprodu.qent at 47
                         wprodu.qped at 56
                         wprodu.pent format ">,>>9.99" at 66
                         wprodu.pped format ">,>>9.99" at 75
                         " |" at 83 skip.
                vok = yes.
            end.
            if vok
            then put skip "|" fill("_",82) format "x(82)" "|" at 84.
    
            hide frame f5 no-pause.
            hide frame f4 no-pause.
            hide frame f3 no-pause.
            hide frame f2 no-pause.
            for each wprodu.
                delete wprodu.
            end.
        end.
    end.     

    output close.  
    if opsys = "UNIX"
    then do:

        assign sresp-aux = yes. 
        message "Deseja Visualizar ou Imprimir o relatório?" update sresp-aux.
        
        if sresp-aux
        then run visurel.p (input varquivo, input "").
        else do:                       

            find first impress where impress.codimp = setbcod
                                    no-lock no-error. 
            if avail impress
            then do: 
                run acha_imp.p (input recid(impress),  
                                output recimp). 
                find impress where recid(impress) = recimp no-lock no-error.
                assign fila = string(impress.dfimp).
            end.    
      
            os-command silent lpr value(fila + " " + varquivo).
        end.
    end.
    else do:
                            
        {mrod.i} 
    end.
end.
