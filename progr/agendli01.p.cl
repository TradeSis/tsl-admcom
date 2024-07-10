/*----------------------------------------------------------------------------*/
/* finan/agendli01.p                                        Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/

{admcab.i}

def var p-catcod like produ.catcod.
def var varquivo as char format "x(20)".
def var vevecod like titulo.evecod.
def temp-table wevent like event.
def var vlog as log.
def var vdt as date.
def var vmodcod like modal.modcod.
def WORKFILE wmodal like modal.
def var wtotger like titulo.titvlcob.
def var vnome like clien.clinom.
def var recatu2 as recid.
def var vtitrel     as char format "x(50)".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat initial yes.
def var wclifor like titulo.clifor initial 0.
def var wclicod like clien.clicod initial 0.
def var wdti    like titulo.titdtven label "Periodo" initial today.
def var wdtf    like titulo.titdtven.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var vtitvlcob like titulo.titvlcob.
def var wseq as i extent 2.
def var i as i.
def var wbar as c label "/" initial "/" format "x".
def var wclfnom as char format "x(30)" label "clfnom".
def var wforcli as i format "999999" label "For/Cli".
def var vimp-setor as int format ">>9".

def temp-table tt-titlb
    field titdtven like titulo.titdtven
    field vimp-setor as int
    field clifor like titulo.clifor 
    field vnome as char
    field modcod like titulo.modcod 
    field titnum like titulo.titnum 
    field titpar like titulo.titpar
    field cobnom like cobra.cobnom
    field etbcod like titulo.etbcod 
    field titvlcob like titulo.titvlcob
    field titvljur like titulo.titvljur
    field titvldes like titulo.titvldes
    field valcob   like titulo.titvlcob
    field evecod   like titulo.evecod 
    field titsit   like titulo.titsit
    field i-subst  as dec
    field titobs   like  titulo.titobs
    .

def var i-subst as dec.
def var b-subst as dec.

form with frame f2 width 250 down.

wdtf = wdti + 30.
wtotger = 0.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    wtot = 0.
    vtitvlcob = 0.
    wtotger = 0.
    disp "" @ wetbcod colon 12.
    update wetbcod label "Estabelec." .
    if  wetbcod <> 0
       then do:
               find estab where
                          estab.etbcod =  wetbcod no-lock.
               display etbnom no-label format "x(10)".
       end.
       else disp "TODOS" @ etbnom.

    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.
    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    update wtitnat no-label.
    repeat:

        wtot = 0.
        vtitvlcob = 0.
        wtotger = 0.
        clear frame ff.
        clear frame fc.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wclifor.
             update wclifor label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
             if input wclifor <> "" and wclifor <> 0
                then do:
                        find forne where forne.forcod = input wclifor.
                        display fornom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
           end.
           else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             disp "" @ wclicod.
             prompt-for wclicod label "Cliente"
                help "Informe o codigo do Cliente ou <ENTER> para todos".
             if input wclicod <> ""
                then do:
                        find clien where clien.clicod = input wclicod.
                        display clinom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
           end.
        if not wtitnat
        then wclifor = wclicod.
        else wclifor = wclifor.
        clear frame f-sel all. 
        def var vsetcod like setaut.setcod.
        update vsetcod label "Setor" with frame f-sel
            side-label 1 down width 80 no-box color message.

        if vsetcod <> 0
        then do:
            find setaut where setaut.setcod = vsetcod no-lock.
            disp setaut.setnom no-label with frame f-sel.
        end.
        else disp "Relatorio geral" @ setaut.setnom with frame f-sel.

        def var vcatcod as int format ">>9".
        
        update vcatcod label "Depto" 
            help "Informe o codigo do Departamento."
            with frame f-sel.
        if vcatcod <> 0
        then do:
            find categoria where categoria.catcod = vcatcod no-lock.
            disp categoria.catnom no-label with frame f-sel.
        end.
        else disp "Todos os Departamentos" @ categoria.catnom with frame f-sel.
        
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        update wdti
               wdtf with frame fdat.


        for each wevent:
            delete wevent.
        end.
        for each event no-lock:
            create wevent.
            assign wevent.evecod = event.evecod
                   wevent.evenom = event.evenom.
        end.
        bl_evento:
        repeat:
            update vevecod go-on("end-error")
                        with frame f-event centered side-label.
            
            if keyfunction(lastkey) = "end-error"
            then leave bl_evento.

            find first wevent where wevent.evecod = vevecod no-lock no-error.
            if not avail wevent
            then do:
                
                message "EVENTO NAO CADASTRADO".
                undo, retry.
                
            end.
            display wevent.evenom no-label with frame f-event.
            delete wevent. 
            
        end.
        for each wmodal:
            delete wmodal.
        end.
        if wmodcod = ""
        then do:
            for each modal where modal.modcod <> "DEV" 
                             and modal.modcod <> "BON" 
                             and modal.modcod <> "CHP" no-lock:
                create wmodal.
                assign wmodal.modcod = modal.modcod
                       wmodal.modnom = modal.modnom.
            end.
            bl_modal:
            repeat:
                vlog = no.
                update vmodcod go-on("end-error")
                          with frame f-modal centered side-label.
                        
                if keyfunction(lastkey) = "end-error"           
                then leave bl_modal.                           
                
                find first wmodal where wmodal.modcod = vmodcod
                                                  no-lock no-error.
                if not avail wmodal
                then do:
                    message "Modalidade Invalida".
                    undo, retry.
                end.
                display wmodal.modnom no-label with frame f-modal.
                delete wmodal.
                vlog = yes.
            
            end.
            
        end.
        else do:
            create wmodal.
            assign wmodal.modcod = wmodcod.
        end.
        wtot = 0.

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .

    sresp = yes.
    message "Deseja imprimir a agenda?" update sresp.
    if not sresp
    then undo, retry.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/agenda" + string(time).
    else varquivo = "..\relat\agenda" + string(time).
        
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "190"  
        &Page-Line = "66"
        &Nom-Rel   = ""AGENDLI""  
        &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
        &Tit-Rel   = """AGENDA FINANCEIRA - PERIODO DE ""
                   + string(wdti,""99/99/9999"") 
                   + "" A "" 
                   + string(wdtf,""99/99/9999"") "
        &Width     = "190"
        &Form      = "frame f-cabcab"}

        disp with frame f1.
        disp with frame f-sel.
        /*
        if vlog = no
        then put skip "TODAS MODALIDADES" skip.
        else do:
            put skip.
            for each wmodal:
                put wmodal.modcod ", ".
            end.
            put skip(1).
        end.
        */


        if wetbcod = 0
        then do:
            for each wmodal where wmodal.modcod <> "CHP"
                              and wmodal.modcod <> "BON",
                each estab no-lock,
                each titulo where titulo.empcod = wempre.empcod and
                                  titnat   =   wtitnat          and
                                  titulo.modcod = wmodal.modcod and
                                  titulo.titdtven >= wdti      and
                                  titulo.titdtven <= wdtf      and
                                  titulo.etbcod = estab.etbcod  and
                               ( if wclifor = 0
                                 then true
                                  else titulo.clifor = wclifor ) and
                                  (titsit   =   "LIB" or
                                   titsit   =   "CON") no-lock
                                     /*break by titulo.titdtven
                                           /* by titulo.etbcod */
                                           by titulo.modcod
                                           by titulo.titnum */:
                /*
                find first titudesp where
                               titudesp.empcod = fin.titulo.empcod and
                               titudesp.titnat = fin.titulo.titnat and
                               titudesp.modcod = fin.titulo.modcod and
                               titudesp.etbcod = fin.titulo.etbcod and
                               titudesp.clifor = fin.titulo.clifor and
                               titudesp.titnum = fin.titulo.titnum and
                               titudesp.titdtemi = fin.titulo.titdtemi
                               no-lock no-error.
                if avail titudesp 
                then do:
                    run fin-titudesp.
                    next. 
                end.
                */
                    
                if vcatcod > 0
                then do:
                    run pega-categoria-titulo.p(recid(titulo),
                                                output p-catcod).
                    if p-catcod <> vcatcod
                    then next.                            
                end.
                if wtitnat
                then do:
                    find forne where forne.forcod = titulo.clifor
                                no-lock no-error.
                    if avail forne
                    then vnome = forne.fornom.
                    else vnome = "".
                
                    if vsetcod > 0 
                    then do:
                        if  fin.titulo.titbanpag > 0 and
                            fin.titulo.titbanpag <> vsetcod
                        then do:
                            next.
                        end.    
                        if fin.titulo.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                    end. 
                end.
                else do:
                    find clien where clien.clicod = titulo.clifor no-lock.
                    vnome = clien.clinom.
                end.

                vimp-setor = fin.titulo.titbanpag.
                if vimp-setor = 0
                then do:
                    find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                    if avail foraut 
                    then vimp-setor = foraut.setcod.
                end.
                find first wevent where wevent.evecod = titulo.evecod no-error.
                if not avail wevent
                then next.

                find cobra of titulo no-lock no-error.
                              wtot = wtot + (titulo.titvlcob + titulo.titvljur).
                vtitvlcob = (titulo.titvlcob + titulo.titvljur - 
                             titulo.titvldes).

                /*
                if first-of(titulo.titdtven)
                then display titulo.titdtven 
                    with frame ff2 side-label.
                */
                i-subst = 0.
                b-subst = 0.
                if titulo.modcod = "DUP"
                then run icms-subst.
 
                create tt-titlb.
                assign
                    tt-titlb.titdtven = titulo.titdtven
                    tt-titlb.vimp-setor = vimp-setor
                    tt-titlb.clifor     = titulo.clifor 
                    tt-titlb.vnome      = vnome
                    tt-titlb.modcod     = titulo.modcod 
                    tt-titlb.titnum     = titulo.titnum 
                    tt-titlb.titpar     = titulo.titpar
                    tt-titlb.cobnom     = cobra.cobnom
                    tt-titlb.etbcod     = titulo.etbcod 
                    tt-titlb.titvlcob   = titulo.titvlcob
                    tt-titlb.titvljur   = titulo.titvljur
                    tt-titlb.titvldes   = titulo.titvldes
                    tt-titlb.valcob     = (titulo.titvlcob + titulo.titvljur - 
                                             titulo.titvldes)
                    tt-titlb.evecod     = titulo.evecod 
                    tt-titlb.titsit     = titulo.titsit
                    tt-titlb.i-subst    = i-subst
                    tt-titlb.titobs     =  titulo.titobs
                    .
                
                /*****************
                display 
                        titulo.titdtven format "99/99/99"
                                column-label "Dt.Venc."
                        vimp-setor when vimp-setor <> 0 column-label "Set"
                        titulo.clifor 
                        column-label "Forne" format "999999" 
                        vnome         column-label "Ag.Comercial"
                                      format "x(30)"
                        titulo.modcod column-label "Mod"
                        titulo.titnum 
                        titulo.titpar
                        cobra.cobnom  when avail cobra
                            column-label "Cobranca" format "x(08)"
                        titulo.etbcod column-label "Fl." format ">99" 
                        titulo.titvlcob(total by titulo.titdtven) 
                                column-label "Valor!Total" 
                                        format ">>,>>>,>>9.99"
                        titulo.titvljur(total by titulo.titdtven)
                         format ">>>,>>9.99" 
                                column-label "Vl.Juros"
                        titulo.titvldes(total by titulo.titdtven)
                         format ">>>,>>9.99" 
                                column-label "Vl.Desc"
                        (titulo.titvlcob + titulo.titvljur - 
                         titulo.titvldes)(total by titulo.titdtven) 
                         format ">>,>>>,>>9.99"  column-label "Valor!Cobrado"
                        titulo.evecod column-label "Ev." format ">9"
                        titulo.titsit
                        i-subst(total by titulo.titdtven) format ">>>,>>9.99" 
                                column-label "ICMS!SUBST"
                        titulo.titobs[1] +
                        titulo.titobs[2]
                         format "x(80)"
                                    column-label "Obs"
                          with frame f2 width 250 down.
                down with frame f2.
                *************/
            end.
        end.
        else do:
            for each wmodal where wmodal.modcod <> "CHP"
                              and wmodal.modcod <> "BON",
                each titulo where titulo.empcod = wempre.empcod and
                                  titnat   =   wtitnat          and
                                  titulo.modcod = wmodal.modcod and
                                  titulo.titdtven >= wdti      and
                                  titulo.titdtven <= wdtf      and
                                  titulo.etbcod = wetbcod       and
                               ( if wclifor = 0
                                 then true
                                  else titulo.clifor = wclifor ) and
                                  (titsit   =   "LIB" or
                                   titsit   =   "CON") no-lock
                                     /*break by titulo.titdtven
                                           /* by titulo.etbcod */
                                           by titulo.modcod
                                           by titulo.titnum*/:
        
                find first titudesp where
                               titudesp.empcod = fin.titulo.empcod and
                               titudesp.titnat = fin.titulo.titnat and
                               titudesp.modcod = fin.titulo.modcod and
                               titudesp.etbcod = fin.titulo.etbcod and
                               titudesp.clifor = fin.titulo.clifor and
                               titudesp.titnum = fin.titulo.titnum and
                               titudesp.titdtemi = fin.titulo.titdtemi
                               no-lock no-error.
                if avail titudesp 
                then do:
                    run fin-titudesp.
                    next. 
                end.
                
                if vcatcod > 0
                then do:
                    run pega-categoria-titulo.p(recid(titulo),
                                                output p-catcod).
                    if p-catcod <> vcatcod
                    then next.                            
                end.
                if wtitnat
                then do:
                    find forne where forne.forcod = titulo.clifor
                                no-lock no-error.
                    if avail forne
                    then vnome = forne.fornom.
                    else vnome = "".
                    if vsetcod > 0 
                    then do:
                        if  fin.titulo.titbanpag > 0 and
                            fin.titulo.titbanpag <> vsetcod
                        then do:
                            next.
                        end.    
                        if fin.titulo.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                    end. 
                end.
                else do:
                    find clien where clien.clicod = titulo.clifor no-lock.
                    vnome = clien.clinom.
                end.

                vimp-setor = fin.titulo.titbanpag.
                if vimp-setor = 0
                then do:
                    find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                    if avail foraut 
                    then vimp-setor = foraut.setcod.
                end.

                find first wevent where wevent.evecod = titulo.evecod no-error.
                if not avail wevent
                then next.
                    
                find cobra of titulo no-lock no-error.
            
                /*
                              wtot = wtot + (titulo.titvlcob + titulo.titvljur).
                vtitvlcob = (titulo.titvlcob + titulo.titvljur - 
                             titulo.titvldes).
                */
                /*
                if first-of(titulo.titdtven)
                then display titulo.titdtven 
                        with frame ff3 side-label.
                */                   
                i-subst = 0.
                b-subst = 0.
                if titulo.modcod = "DUP"
                then run icms-subst.
                
                create tt-titlb.
                assign
                    tt-titlb.titdtven = titulo.titdtven
                    tt-titlb.vimp-setor = vimp-setor
                    tt-titlb.clifor     = titulo.clifor 
                    tt-titlb.vnome      = vnome
                    tt-titlb.modcod     = titulo.modcod 
                    tt-titlb.titnum     = titulo.titnum 
                    tt-titlb.titpar     = titulo.titpar
                    tt-titlb.cobnom     = cobra.cobnom
                    tt-titlb.etbcod     = titulo.etbcod 
                    tt-titlb.titvlcob   = titulo.titvlcob
                    tt-titlb.titvljur   = titulo.titvljur
                    tt-titlb.titvldes   = titulo.titvldes
                    tt-titlb.valcob     = (titulo.titvlcob + titulo.titvljur - 
                                             titulo.titvldes)
                    tt-titlb.evecod     = titulo.evecod 
                    tt-titlb.titsit     = titulo.titsit
                    tt-titlb.i-subst    = i-subst
                    tt-titlb.titobs     =  titulo.titobs
                    .
                /*********
                display 
                        titulo.titdtven format "99/99/99"
                                column-label "Dt.Venc."
                        vimp-setor when vimp-setor <> 0 column-label "Set"
                        titulo.clifor 
                        column-label "Forne" format "999999" 
                        vnome         column-label "Ag.Comercial"
                                      format "x(30)"
                        titulo.modcod column-label "Mod"
                        titulo.titnum 
                        titulo.titpar
                        cobra.cobnom when avail cobra
                            column-label "Cobranca"
                                      format "x(8)"
                        titulo.etbcod column-label "Fl." format ">99" 
                        titulo.titvlcob(total by titulo.titdtven) 
                             column-label "Valor!Total" format ">>,>>>,>>9.99"
                        titulo.titvljur(total by titulo.titdtven)
                         format ">>,>>9.99" 
                             column-label "Vl.Juros"
                        titulo.titvldes(total by titulo.titdtven)
                         format ">>,>>9.99" 
                             column-label "Vl.Desc"
                        (titulo.titvlcob + titulo.titvljur - 
                         titulo.titvldes)(total by titulo.titdtven) 
                         format ">>,>>>,>>9.99"  column-label "Valor!Cobrado"
                        titulo.evecod column-label "Ev." format ">9"
                        titulo.titsit 
                        i-subst (total by titulo.titdtven)
                            format ">>>,>>9.99" 
                                column-label "ICMS!SUBST"
                        titulo.titobs[1] +
                        titulo.titobs[2] 
                         format "x(80)"
                                column-label "Obs"
                        with frame f3 width 250 down.

                down with frame f3.
                 *********/
            end.
        end. 

        for each tt-titlb no-lock 
                        break by tt-titlb.titdtven
                              by tt-titlb.modcod
                              by tt-titlb.titnum
                        :
            
            disp tt-titlb.titdtven format "99/99/99"
                                column-label "Dt.Venc."
                 tt-titlb.vimp-setor when vimp-setor <> 0 column-label "Set"
                 tt-titlb.clifor 
                        column-label "Forne" format "999999" 
                 tt-titlb.vnome         column-label "Ag.Comercial"
                                      format "x(30)"
                 tt-titlb.modcod column-label "Mod"
                 tt-titlb.titnum 
                 tt-titlb.titpar
                 tt-titlb.cobnom when avail cobra
                            column-label "Cobranca"
                                      format "x(8)"
                 tt-titlb.etbcod column-label "Fl." format ">99" 
                 tt-titlb.titvlcob(total by tt-titlb.titdtven) 
                             column-label "Valor!Total" format ">>,>>>,>>9.99"
                 tt-titlb.titvljur(total by tt-titlb.titdtven)
                         format ">>,>>9.99" 
                             column-label "Vl.Juros"
                 tt-titlb.titvldes(total by tt-titlb.titdtven)
                         format ">>,>>9.99" 
                             column-label "Vl.Desc"
                 tt-titlb.valcob (total by tt-titlb.titdtven) 
                         format ">>,>>>,>>9.99"  column-label "Valor!Cobrado"
                 tt-titlb.evecod column-label "Ev." format ">9"
                 tt-titlb.titsit 
                 tt-titlb.i-subst (total by tt-titlb.titdtven)
                            format ">>>,>>9.99" 
                                column-label "ICMS!SUBST"
                 tt-titlb.titobs[1] +
                 tt-titlb.titobs[2] 
                         format "x(80)"
                                column-label "Obs"
                        with frame f3 width 250 down.

                down with frame f3.
        end.
        
        output close.
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i}
        end.
    end.
end.

procedure icms-subst:
    find first plani where
                                   plani.etbcod = titulo.etbcod and 
                                   plani.emite = titulo.clifor and
                                   plani.desti = titulo.etbcod and
                                   plani.movtdc = 4 and
                                   plani.numero = int(titulo.titnum) 
                                   no-lock no-error.
                        if avail plani
                        then assign
                                b-subst = plani.bsubst
                                i-subst = plani.icmssubst
                                . 
end.                                

procedure fin-titudesp:
    for each titudesp where titudesp.empcod = wempre.empcod and
                                      titudesp.titnat =   wtitnat   and
                                      /*titudesp.modcod = wmodal.modcod and*/
                                      titudesp.etbcod = titulo.etbcod and
                                      titudesp.clifor = titulo.clifor and
                                      titudesp.titnum = titulo.titnum and
                                      titudesp.titdtven >= wdti      and
                                      titudesp.titdtven <= wdtf 
                                      no-lock:
                    
            if wmodcod <> "" and titudesp.modcod <> wmodcod
            then next.
            if vsetcod > 0 and titudesp.titbanpag <> vsetcod    
            then next.
                 
                            
                    find forne where forne.forcod = titulo.clifor
                                no-lock no-error.
                    if avail forne
                    then vnome = forne.fornom.
                    else vnome = "".
 
                    vimp-setor = titudesp.titbanpag.
                    if vimp-setor = 0
                    then do:
                        find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                        if avail foraut 
                        then vimp-setor = foraut.setcod.
                    end.
                    
                    if vsetcod > 0 
                    then do:
                        if  titudesp.titbanpag > 0 and
                            titudesp.titbanpag <> vsetcod
                        then do:
                            next.
                        end.    
                        if titudesp.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = titudesp.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                    end.    
                find first wevent where wevent.evecod = titulo.evecod no-error.
                if not avail wevent
                then next.
                    
                find cobra of titulo no-lock no-error.

                create tt-titlb.
                assign
                    tt-titlb.titdtven   = titulo.titdtven
                    tt-titlb.vimp-setor = vimp-setor
                    tt-titlb.clifor     = titulo.clifor 
                    tt-titlb.vnome      = vnome
                    tt-titlb.modcod     = titudesp.modcod 
                    tt-titlb.titnum     = titudesp.titnum 
                    tt-titlb.titpar     = titudesp.titpar
                    tt-titlb.cobnom     = cobra.cobnom
                    tt-titlb.etbcod     = titudesp.etbcod 
                    tt-titlb.titvlcob   = titudesp.titvlcob
                    tt-titlb.titvljur   = titudesp.titvljur
                    tt-titlb.titvldes   = titudesp.titvldes
                    tt-titlb.valcob     = (titudesp.titvlcob + 
                                           titudesp.titvljur - 
                                           titudesp.titvldes)
                    tt-titlb.evecod     = titulo.evecod 
                    tt-titlb.titsit     = titulo.titsit
                    tt-titlb.i-subst    = i-subst
                    tt-titlb.titobs     =  titulo.titobs
                    .
 
                 
    end.            
end.

