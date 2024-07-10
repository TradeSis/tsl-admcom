
{admcab.i}

def var vindex as int.
def var wsetcod as int.

def var vsetcod like setaut.setcod.
update vsetcod label "Setor" with frame f-sel
    side-label 1 down width 80 no-box color message.

if vsetcod <> 0
then do:
    find setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label with frame f-sel.
end.
else disp "Relatorio geral" @ setaut.setnom with frame f-sel.


def var vtipo as char extent 3 format "x(20)"
init ["SOMENTE CREDITOS","SOMENTE DEBITOS","CREDITOS E DEBITOS"].

def var vpdoc as log format "Sim/Nao".
def var vfornom like forne.fornom.
def var vesc as log init yes.
def var varquivo as char format "x(20)".
def var vv as char.
def var vtot    like fin.titulo.titvlcob.
def var vtotrec like fin.titulo.titvlcob.
def buffer bmodgru for modgru.
def var vperc as dec.
def temp-table wpag no-undo
    field setcod    like vsetcod
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wmogsup like modgru.mogsup
    field wdes  as dec format "->>>>,>>>,>>9.99"
    field wjur  as dec format "->>>>,>>>,>>9.99"
    field wcob  as dec format "->>>>,>>>,>>9.99"
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wcre  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wven  like fin.titulo.titvlcob
    index wmodcod is unique primary setcod asc wmodcod asc.

def temp-table wgru no-undo
    field setcod    like vsetcod
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wdes  as dec format "->>>>,>>>,>>9.99"
    field wjur  as dec format "->>>>,>>>,>>9.99"
    field wcob  as dec format "->>>>,>>>,>>9.99"
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wcre  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wven  like fin.titulo.titvlcob
    index wwgru is unique primary setcod asc wmodcod asc.

def temp-table wfor no-undo
    field setcod    like vsetcod
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wdes  as dec format "->>>>,>>>,>>9.99"
    field wjur  as dec format "->>>>,>>>,>>9.99"
    field wcob  as dec format "->>>>,>>>,>>9.99"
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wcre  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wven  like fin.titulo.titvlcob
    index wfor is unique primary setcod asc wcod asc wmodcod asc.
    
def temp-table wdoc no-undo
    field setcod like vsetcod
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wdes  as dec format "->>>>,>>>,>>9.99"
    field wjur  as dec format "->>>>,>>>,>>9.99"
    field wcob  as dec format "->>>>,>>>,>>9.99"
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wcre  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wven  like fin.titulo.titvlcob
    index wdoc is unique primary setcod asc wcod asc wnome asc wmodcod asc.
    

def var vcob as dec format "->>>>,>>>,>>9.99".
def var vpag as dec format "->>>>,>>>,>>9.99".
def var vrec as dec format "->>>>,>>>,>>9.99".
def var vdes as dec format "->>>>,>>>,>>9.99".
def var vjur as dec format "->>>>,>>>,>>9.99".
def var vacum as dec format "->>>>,>>>,>>9.99".
def var vlog as log.
def var vdt as date.
def var vmodcod like fin.modal.modcod.
def temp-table wmodal no-undo
    like fin.modal.
def var wtotger as dec format "->>>>,>>>,>>9.99".
def var vnome like clien.clinom.
def var recatu2 as recid.
def var vtitrel     as char format "x(50)".
def var wetbcod like fin.titulo.etbcod initial 0.
def var wmodcod like fin.titulo.modcod initial "".
def var wtitnat like fin.titulo.titnat.
def var wclifor like fin.titulo.clifor initial 0.
def var wclicod like clien.clicod initial 0.
def var wdti    like fin.titulo.titdtven label "Periodo" initial today.
def var wdtf    like fin.titulo.titdtven.
def var wtitvlcob as dec format "->>>>,>>>,>>9.99".
def var wtot      as dec format "->>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wbar as c label "/" initial "/" format "x".
def var wclfnom as char format "x(30)" label "clfnom".
def var wforcli as i format "999999" label "For/Cli".
wdtf = wdti + 30.
wtotger = 0.
def var vven as dec.
form with frame f-pag.
form with frame f-pag1.
form with frame f-pag2.
def var vpfor as log format "Sim/Nao".
def var vana as log format "Sim/Nao".
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:

    wtitnat = yes.
    repeat:
        
       for each wpag:
            delete wpag.
       end.
       for each wfor:
        delete wfor.
       end. 
       for each wdoc: delete wdoc. end.
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        update wdti
               wdtf with frame fdat.
        
        disp vtipo with frame f-tipo no-label side-label centered.
        choose field vtipo with frame f-tipo.
        vindex = frame-index.
       
        for each wmodal:
            delete wmodal.
        end.
        if wmodcod = ""
        then do:
            for each fin.modal where fin.modal.modcod <> "DEV"
                                 and fin.modal.modcod <> "BON"
                                 and fin.modal.modcod <> "CHP" no-lock:
                create wmodal.
                assign wmodal.modcod = fin.modal.modcod
                       wmodal.modnom = fin.modal.modnom.
            end.
            vlog = no.
            repeat:
                vmodcod = "DUP".
                find first wmodal where wmodal.modcod = vmodcod
                                                            no-lock no-error.
                if avail wmodal
                then do:
                    delete wmodal.
                end.
                vlog = yes.
                leave.
            end.
        end.
        else do:
        
            find first modgru where modgru.mogsup = 0 and
                              modgru.modcod = wmodcod
                              no-lock no-error.
            if avail modgru
            then do:
                for each bmodgru where 
                         bmodgru.mogsup = modgru.mogcod
                         no-lock:
                    find fin.modal where
                        fin.modal.modcod = bmodgru.modcod no-lock.
                    
                    create wmodal.
                    assign wmodal.modcod = fin.modal.modcod
                           wmodal.modnom = fin.modal.modnom.
                end.             
            end.
            else do:
                find fin.modal where fin.modal.modcod = wmodcod no-lock.
                create wmodal.
                assign wmodal.modcod = wmodcod
                   wmodal.modnom = fin.modal.modnom.
            end.
            vlog = yes.
        end.
        wtot = 0.
        vana = no.
        message "Relatorio Analitico?" update vana.
        vpfor = no.
        vpdoc = no.
        if vana = yes
        then do:
            message "Por Fornecedor ? " update vpfor.
            message "Por Documento  ? " update vpdoc.
        end.
        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        if wclifor = 0
        then vv = "GERAL".
        else vv = "".
        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/pag4-" + string(time).
        else varquivo = "l:~\relat~\pag4-" + string(time).
        
        vacum =  0.
        vcob  =  0.
        vjur  =  0.
        vdes  =  0.
        vpag  =  0.
        vrec  =  0.
        def var vok as log. 
        for each wmodal:
                disp  "Processando... Aguarde! "  wmodal.modcod with frame f-proc.
                pause 0.

                vok = no. 
                find first fin.titluc where 
                        fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   no          and
                                      fin.titluc.modcod = wmodal.modcod 
                                      no-lock no-error.
                if avail fin.titluc then vok = yes.                      
                else do:
                    find first fin.titluc where 
                            fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   yes          and
                                      fin.titluc.modcod = wmodal.modcod 
                                      no-lock no-error.
                    if avail fin.titluc
                    then vok = yes.
                end.
                        
            if vok = no then next.                        
                        
                
            for each estab no-lock.
                disp estab.etbcod 
                with frame f-proc.
                pause 0.
                vok = no. 
                find first  fin.titluc where
                        fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   no          and
                                      fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.etbcod   = estab.etbcod 
                                  no-lock no-error.

                if avail fin.titluc then vok = yes.                      
                else do:
                    find first  fin.titluc where
                        fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   no          and
                                      fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.etbcod   = estab.etbcod 
                                  no-lock no-error.

                    if avail fin.titluc
                    then vok = yes.
                end.
                        
            if vok = no then next.                        
            
        
            do vdt = wdti to wdtf:
                disp vdt wmodal.modcod
                    estab.etbcod
                     with frame f-proc 1 down centered no-box color message
                        row 10 no-label.
                pause 0.        
                
                for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   no          and
                                      fin.titluc.modcod = wmodal.modcod and
                                      fin.titluc.titdtemi =  vdt 
                                      and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.etbcod   = estab.etbcod and
                                  fin.titluc.evecod = 8 no-lock:
                    if fin.titluc.titbanpag = 0 then next.
                            
                    if vsetcod > 0 
                    then do:
                        if fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> vsetcod
                        then do:
                            next.
                        end.    
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                    end.    
                    
                        wsetcod = fin.titluc.titbanpag.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                wsetcod = foraut.setcod.
                            end.
                        end.    
                    
                    find first wpag where 
                            wpag.setcod  = wsetcod and
                            wpag.wmodcod = fin.titluc.modcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        wpag.setcod  = wsetcod.
                        wpag.wmodcod = fin.titluc.modcod.
                    end.
                    find modal where modal.modcod = fin.titluc.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    find first wfor where
                               wfor.setcod = wsetcod and 
                               wfor.wcod = fin.titluc.clifor and
                               wfor.wmodcod = fin.titluc.modcod
                                no-error.
                    if not avail wfor
                    then do:
                        create wfor.
                        assign
                            wfor.setcod = wsetcod    
                            wfor.wcod = fin.titluc.clifor
                            wfor.wmodcod = fin.titluc.modcod
                            .
                    end.
                    find first wdoc where
                               wdoc.setcod = wsetcod and 
                               wdoc.wcod  = fin.titluc.clifor and
                               wdoc.wmod  = fin.titluc.modcod and
                               wdoc.wnome = if fin.titluc.titobs[1] <> ""
                                then fin.titluc.titobs[1]
                                else  (fin.titluc.titnum + "/" +
                                           string(fin.titluc.titpar)) 
                               no-error.
                    if not avail wdoc
                    then do:
                        create wdoc.
                        assign
                            wdoc.setcod = wsetcod    
                            wdoc.wcod = fin.titluc.clifor 
                            wdoc.wmod = fin.titluc.modcod
                            wdoc.wnome = if fin.titluc.titobs[1] <> ""
                                then fin.titluc.titobs[1]
                                else  (fin.titluc.titnum + "/" +
                                    string(fin.titluc.titpar))
                            .
                    end. 
                    assign            
                    wpag.wcre  = wpag.wcre  + fin.titluc.titvlcob
                    wfor.wcre  = wfor.wcre  + fin.titluc.titvlcob
                    wdoc.wcre  = wdoc.wcre  + fin.titluc.titvlcob.

                end.
                for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   yes          and
                                      fin.titluc.modcod = wmodal.modcod and
                                      fin.titluc.titdtemi =  vdt   and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.etbcod   = estab.etbcod and
                                  fin.titluc.evecod = 9 no-lock:
                    if fin.titluc.titbanpag = 0 then next.
                    if vsetcod > 0 
                    then do:
                        if fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> vsetcod
                        then do:
                            next.
                        end.    
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                    end.    
                    
                        wsetcod = fin.titluc.titbanpag.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                wsetcod = foraut.setcod.
                            end.
                        end.    
                    
                    find first wpag where 
                            wpag.setcod = wsetcod and
                            wpag.wmodcod = fin.titluc.modcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        wpag.setcod = wsetcod.
                        wpag.wmodcod = fin.titluc.modcod.
                    end.
                    find modal where modal.modcod = fin.titluc.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    find first wfor where
                               wfor.setcod = wsetcod and 
                               wfor.wcod = fin.titluc.clifor and
                               wfor.wmodcod = fin.titluc.modcod
                                no-error.
                    if not avail wfor
                    then do:
                        create wfor.
                        assign
                            wfor.setcod = wsetcod
                            wfor.wcod = fin.titluc.clifor
                            wfor.wmodcod = fin.titluc.modcod
                            .
                    end.
                    find first wdoc where
                               wdoc.setcod = wsetcod and 
                               wdoc.wcod  = fin.titluc.clifor and
                               wdoc.wmod  = fin.titluc.modcod and
                               wdoc.wnome = if fin.titluc.titobs[1] <> ""
                                then fin.titluc.titobs[1]
                                else  (fin.titluc.titnum + "/" +
                                           string(fin.titluc.titpar)) 
                               no-error.
                    if not avail wdoc
                    then do:
                        create wdoc.
                        assign
                            wdoc.setcod = wsetcod    
                            wdoc.wcod = fin.titluc.clifor 
                            wdoc.wmod = fin.titluc.modcod
                            wdoc.wnome = if fin.titluc.titobs[1] <> ""
                                then fin.titluc.titobs[1]
                                else  (fin.titluc.titnum + "/" +
                                    string(fin.titluc.titpar))
                            .
                    end. 
                    assign            
                    wpag.wdeb  = wpag.wdeb  + fin.titluc.titvlcob
                    wfor.wdeb  = wfor.wdeb  + fin.titluc.titvlcob
                    wdoc.wdeb  = wdoc.wdeb  + fin.titluc.titvlcob.

                end.
            end. /* estab */
            end.
        end.
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "0"
            &Nom-Rel   = ""EMIcredebdesp""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = " vtipo[vindex] + 
                            "" - POR EMISSAO DE "" +
                                  string(wdti,""99/99/99"") + "" A "" +
                                  string(wdtf,""99/99/99"") + ""  "" 
                                  "
            &Width     = "100"
            &Form      = "frame f-cabcab"}
 
        disp with frame f-sel.
        
        for each wgru:
            delete wgru.
        end.
        for each wpag :
            find modgru where 
                 modgru.modcod = wpag.wmodcod and
                 modgru.mogsup > 0
                 no-lock no-error.
            if avail modgru
            then do:
                find first bmodgru where 
                     bmodgru.mogcod = modgru.mogsup
                     and bmodgru.mogsup = 0 no-lock no-error.
                if not avail bmodgru
                then do:
                    message modgru.mogsup wpag.wmodcod.
                    pause.
                end.     
                find first wgru where
                     wgru.setcod  = wpag.setcod and
                     wgru.wmodcod = bmodgru.modcod no-error.
                if not avail wgru
                then do:
                    create wgru.
                    assign
                    wgru.setcod  = wpag.setcod 
                    wgru.wmodcod = bmodgru.modcod 
                    wgru.wnome   = bmodgru.mognom
                     .
                end.    
                assign
                    wgru.wdes = wgru.wdes + wpag.wdes
                    wgru.wjur = wgru.wjur + wpag.wjur
                    wgru.wcob = wgru.wcob + wpag.wcob
                    wgru.wpag = wgru.wpag + wpag.wpag
                    wgru.wrec = wgru.wrec + wpag.wrec
                    wgru.wven = wgru.wven + wpag.wven
                    wgru.wcre = wgru.wcre + wpag.wcre
                    wgru.wdeb = wgru.wdeb + wpag.wdeb
                wpag.wmogsup = bmodgru.mogcod.
            end.
        end.
        vtot = 0. 
        vven = 0.
        vtotrec = 0.
        if vindex = 3
        then run rel-index3.
        else if vindex = 2
            then run rel-index2.
            else if vindex = 1
                then run rel-index1.
        
        output close.
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i} .
        end.
        leave.
    end.
    leave.
end.
procedure rel-index3:
    
    /**
    for each bwgru
        break by bwgru.setcod.
    if first-of(bwgru.setcod)
    then do:
        down with frame f-pag.
        find setaut where setaut.setcod = bwgru.setcod no-lock.
        
        disp bwgru.setcod  @ wgru.setcod
             setaut.setnom @ wgru.wnome 
             with frame f-pag.    
        down 1 with frame f-pag. 
    **/
            
    for each wgru /**where wgru.setcod = bwgru.setcod**/ no-lock,
            first modgru where modgru.mogsup = 0 and
                               modgru.modcod = wgru.wmodcod
                               no-lock break 
                                by wgru.setcod 
                                by modgru.mognom:

            find setaut where setaut.setcod = wgru.setcod no-lock no-error.

            vperc = ((wgru.wpag / wgru.wven) * 100). 
            if vperc = ? then vperc = 0.
            display wgru.setcod
                    setaut.setnom when avail setaut
                    wgru.wmodcod
                    wgru.wnome column-label "MODALIDADE"
                    wgru.wcre  
                        format "->>>,>>>,>>>,>>9.99" column-label "Creditos"
                    wgru.wdeb  
                        format "->>>,>>>,>>>,>>9.99" column-label "Debitos"    
                with frame f-pag down width 120.

            down with frame f-pag.
            if vana
            then do:
            for each wpag where 
                     wpag.setcod  = wgru.setcod and
                     wpag.wmogsup = modgru.mogcod
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod + " " + wpag.wnome  @ wgru.wnome
                    wpag.wcre      @ wgru.wcre 
                    wpag.wdeb      @ wgru.wdeb 
                    with frame f-pag.
                down with frame f-pag.
                if vpfor
                then
                for each wfor where 
                     wfor.setcod  = wpag.setcod and   
                     wfor.wmodcod = wpag.wmodcod
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock no-error.
                    if avail forne
                    then vfornom = "    " + forne.fornom.
                    else vfornom = "    " + string(wfor.wcod).            
                    display vfornom    @ wgru.wnome
                            wfor.wcre  @ wgru.wcre 
                            wfor.wdeb  @ wgru.wdeb
                        with frame f-pag .
                    down with frame f-pag.
                    if vpdoc
                    then for each wdoc where 
                                  wdoc.setcod = wfor.setcod  and
                                  wdoc.wcod = wfor.wcod and
                                  wdoc.wmodcod = wfor.wmodcod
                                  no-lock:
                          vfornom = "        " + wdoc.wnome.
                          display vfornom    @ wgru.wnome
                                  wdoc.wcre  @ wgru.wcre 
                                  wdoc.wdeb  @ wgru.wdeb
                            with frame f-pag .
                            down with frame f-pag.
                        end.                   
                end.
            end.
            end.
            vtotrec = vtotrec + wgru.wdeb.
            vtot = vtot + wgru.wcre.
        end.
    /**
    end.
    end.
    **/
    
        put fill("=",120) format "x(100)" skip.
        for each wpag where 
                     wpag.wmogsup = 0
                        break by wpag.setcod by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vtot  = vtot  + wpag.wcre.
                vtotrec = vtotrec + wpag.wdeb.
                vven  = vven  + wpag.wven.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                find setaut where setaut.setcod = wgru.setcod no-lock no-error.

                display wpag.setcod @ wgru.setcod
                        setaut.setnom when avail setaut
                
                    wpag.wmodcod  @ wgru.wmodcod
                    wpag.wnome     @ wgru.wnome
                    wpag.wcre      @ wgru.wcre 
                    wpag.wdeb      @ wgru.wdeb
                    with frame f-pag.
                down with frame f-pag.
                if vpfor
                then
                for each wfor where 
                     wfor.setcod  = wpag.setcod and
                     wfor.wmodcod = wpag.wmodcod
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock .       
                    display  forne.fornom  @ wgru.wnome
                             wfor.wcre     @ wgru.wcre 
                             wfor.wdeb     @ wgru.wdeb
                        with frame f-pag .
                    down with frame f-pag.
                    if vpdoc
                    then for each wdoc where
                                  wdoc.setcod = wfor.setcod and  
                                  wdoc.wcod = wfor.wcod and
                                  wdoc.wmodcod = wfor.wmodcod
                                  no-lock:
                          vfornom = "        " + wdoc.wnome.
                          display vfornom    @ wgru.wnome
                                  wdoc.wcre  @ wgru.wcre 
                                  wdoc.wdeb  @ wgru.wdeb
                            with frame f-pag .
                            down with frame f-pag.
                        end. 
                end.

        end.
    
        down(1) with frame f-pag.
        disp "Total Geral"  @ wgru.wnome
                vtot        @ wgru.wcre
                vtotrec     @ wgru.wdeb
                with frame f-pag.
 
end procedure.

procedure rel-index1:
    for each wgru where wgru.wcre > 0 no-lock,
            first modgru where modgru.mogsup = 0 and
                               modgru.modcod = wgru.wmodcod
                               no-lock break by modgru.mognom:

            vperc = ((wgru.wpag / wgru.wven) * 100). 
            if vperc = ? then vperc = 0.
            display wgru.wmodcod
                    wgru.wnome column-label "MODALIDADE"
                    wgru.wcre  
                        format "->>>,>>>,>>>,>>9.99" column-label "Creditos"
                with frame f-pag1 down width 120.

            down with frame f-pag1.
            if vana
            then do:
            for each wpag where 
                     wpag.wmogsup = modgru.mogcod and
                     wpag.wcre > 0
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod + " " + wpag.wnome  @ wgru.wnome
                    wpag.wcre      @ wgru.wcre 
                    with frame f-pag1.
                down with frame f-pag1.
                if vpfor
                then
                for each wfor where 
                     wfor.wmodcod = wpag.wmodcod
                     and wfor.wcre > 0 
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock no-error.
                    if avail forne
                    then vfornom = "    " + forne.fornom.
                    else vfornom = "    " + string(wfor.wcod).            
                    display vfornom    @ wgru.wnome
                            wfor.wcre  @ wgru.wcre 
                        with frame f-pag1 .
                    down with frame f-pag1.
                    if vpdoc
                    then for each wdoc where
                                  wdoc.wcod = wfor.wcod and
                                  wdoc.wmodcod = wfor.wmodcod
                                  and wdoc.wcre > 0
                                  no-lock:
                          vfornom = "        " + wdoc.wnome.
                          display vfornom    @ wgru.wnome
                                  wdoc.wcre  @ wgru.wcre 
                            with frame f-pag1 .
                            down with frame f-pag1.
                        end.                   
                end.
            end.
            end.
            vtotrec = vtotrec + wgru.wdeb.
            vtot = vtot + wgru.wcre.
        end.
        put fill("=",120) format "x(100)" skip.
        for each wpag where 
                     wpag.wmogsup = 0
                     and wpag.wcre > 0
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vtot  = vtot  + wpag.wcre.
                vtotrec = vtotrec + wpag.wdeb.
                vven  = vven  + wpag.wven.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod  @ wgru.wmodcod
                    wpag.wnome     @ wgru.wnome
                    wpag.wcre      @ wgru.wcre 
                    with frame f-pag1.
                down with frame f-pag1.
                if vpfor
                then
                for each wfor where 
                     wfor.wmodcod = wpag.wmodcod
                        and wfor.wcre > 0
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock .       
                    display  forne.fornom  @ wgru.wnome
                             wfor.wcre     @ wgru.wcre 
                        with frame f-pag1 .
                    down with frame f-pag1.
                    if vpdoc
                    then for each wdoc where
                                  wdoc.wcod = wfor.wcod and
                                  wdoc.wmodcod = wfor.wmodcod
                                  and wdoc.wcre > 0
                                  no-lock:
                          vfornom = "        " + wdoc.wnome.
                          display vfornom    @ wgru.wnome
                                  wdoc.wcre  @ wgru.wcre 
                            with frame f-pag1 .
                            down with frame f-pag1.
                        end. 
                end.

        end.
        down(1) with frame f-pag1.
        disp "Total Geral"  @ wgru.wnome
                vtot        @ wgru.wcre
                with frame f-pag1.
 
end procedure.

procedure rel-index2:
    for each wgru where wgru.wdeb > 0 no-lock,
            first modgru where modgru.mogsup = 0 and
                               modgru.modcod = wgru.wmodcod
                               no-lock break by modgru.mognom:

            vperc = ((wgru.wpag / wgru.wven) * 100). 
            if vperc = ? then vperc = 0.
            display wgru.wmodcod
                    wgru.wnome column-label "MODALIDADE"
                    wgru.wdeb  
                        format "->>>,>>>,>>>,>>9.99" column-label "Debitos"    
                with frame f-pag2 down width 120.

            down with frame f-pag2.
            if vana
            then do:
            for each wpag where 
                     wpag.wmogsup = modgru.mogcod
                     and wpag.wdeb > 0
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod + " " + wpag.wnome  @ wgru.wnome
                    wpag.wdeb      @ wgru.wdeb 
                    with frame f-pag2.
                down with frame f-pag2.
                if vpfor
                then
                for each wfor where 
                     wfor.wmodcod = wpag.wmodcod
                     and wfor.wdeb > 0
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock no-error.
                    if avail forne
                    then vfornom = "    " + forne.fornom.
                    else vfornom = "    " + string(wfor.wcod).            
                    display vfornom    @ wgru.wnome
                            wfor.wdeb  @ wgru.wdeb
                        with frame f-pag2 .
                    down with frame f-pag2.
                    if vpdoc
                    then for each wdoc where
                                  wdoc.wcod = wfor.wcod and
                                  wdoc.wmodcod = wfor.wmodcod
                                  and wdoc.wdeb > 0
                                  no-lock:
                          vfornom = "        " + wdoc.wnome.
                          display vfornom    @ wgru.wnome
                                  wdoc.wdeb  @ wgru.wdeb
                            with frame f-pag2 .
                            down with frame f-pag2.
                        end.                   
                end.
            end.
            end.
            vtotrec = vtotrec + wgru.wdeb.
            vtot = vtot + wgru.wcre.
        end.
        put fill("=",120) format "x(100)" skip.
        for each wpag where 
                     wpag.wmogsup = 0
                     and wpag.wdeb > 0
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vtot  = vtot  + wpag.wcre.
                vtotrec = vtotrec + wpag.wdeb.
                vven  = vven  + wpag.wven.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod  @ wgru.wmodcod
                    wpag.wnome     @ wgru.wnome
                    wpag.wdeb      @ wgru.wdeb
                    with frame f-pag2.
                down with frame f-pag2.
                if vpfor
                then
                for each wfor where 
                     wfor.wmodcod = wpag.wmodcod
                     and wfor.wdeb > 0
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock .       
                    display  forne.fornom  @ wgru.wnome
                             wfor.wdeb     @ wgru.wdeb
                        with frame f-pag2 .
                    down with frame f-pag2.
                    if vpdoc
                    then for each wdoc where
                                  wdoc.wcod = wfor.wcod and
                                  wdoc.wmodcod = wfor.wmodcod
                                  and wdoc.wdeb > 0  
                                  no-lock:
                          vfornom = "        " + wdoc.wnome.
                          display vfornom    @ wgru.wnome
                                  wdoc.wdeb  @ wgru.wdeb
                            with frame f-pag2 .
                            down with frame f-pag2.
                        end. 
                end.

        end.
        down(1) with frame f-pag2.
        disp "Total Geral"  @ wgru.wnome
                vtotrec     @ wgru.wdeb
                with frame f-pag2.
 
end procedure.


       
