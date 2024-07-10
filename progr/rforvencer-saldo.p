/*----------------------------------------------------------------------------*/
/* finan/pag.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var varquivo as char.
def var vtot like titulo.titvlcob.
def temp-table wpag
    field wcod  like titulo.clifor
    field wnome like forne.fornom
    field wcnp  as char format "x(20)" label "CNPJ/CPF"
    field wven1 like titulo.titvlcob
    field wven2 like titulo.titvlcob
    field wven3 like titulo.titvlcob
    field wtot  like titulo.titvlcob
    index i1 wcod
    index i2 wnome.
def var vcob like titulo.titvlpag.
def var vpag like titulo.titvlpag.
def var vdes like titulo.titvlpag.
def var vjur like titulo.titvlpag.
def var vacum like titulo.titvlpag.
def var vlog as log.
def var vdt as date.
def var vmodcod like modal.modcod.
def temp-table wmodal like modal.
def var wtotger like titulo.titvlcob.
def var vnome like clien.clinom.
def var recatu2 as recid.
def var vtitrel     as char format "x(50)".
def var wetbcod like titulo.etbcod initial 0.
def var wmodcod like titulo.modcod initial "".
def var wtitnat like titulo.titnat initial yes.
def var wclifor like titulo.clifor initial 0.
def var wclicod like clien.clicod initial 0.
def var vdata1    like titulo.titdtven.
def var vdata2    like titulo.titdtven.
def var vdata3    like titulo.titdtven.
def var wtitvlcob like titulo.titvlcob.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wseq as i extent 2.
def var i as i.
def var wbar as c label "/" initial "/" format "x".
def var wclfnom as char format "x(30)" label "clfnom".
def var wforcli as i format "999999" label "For/Cli".
wtotger = 0.
def temp-table tt-titulo no-undo like titulo.
def var vcnp like wpag.wcnp.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
    /***
    disp "" @ wetbcod colon 12.
    update wetbcod label "Estabelec." .
    if  wetbcod <> 0
       then do:
               find estab where
                          estab.etbcod =  wetbcod.
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
    ***/
    repeat:
        clear frame ff.
        clear frame fc.
        /*
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
        **/
        
        update vdata1 label "Venc1."
               vdata2 label "Venc2."
               vdata3 label "Venc3." with frame fdat width 80 side-label.
        for each wmodal:
            delete wmodal.
        end.
        if wmodcod = ""
        then do:
            for each modal no-lock:
                create wmodal.
                assign wmodal.modcod = modal.modcod
                       wmodal.modnom = modal.modnom.
            end.
            vlog = no.
            /**
            repeat:
                update vmodcod with frame f-modal centered side-label.
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
            **/
        end.
        else do:
            create wmodal.
            assign wmodal.modcod = wmodcod.
            vlog = yes.
        end.
        wtot = 0.
        {confir.i 1 "RELATORIO"}

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .

        for each wpag:
            delete wpag.
        end.
        
        for each modal no-lock:
            disp "Aguarde processamento... " modal.modcod 
                with frame f-cb no-label 1 down row 10.
            pause 0.

            if  modal.modcod = "BON" or
                            modal.modcod = "DEV" or
                            modal.modcod = "CHP" then next.

            for each estab no-lock:
                disp estab.etbcod with frame f-cb.
                pause 0.
                for each titulo use-index titdtven where titulo.empcod = 19 and
                                      titulo.titnat = yes and
                                      titulo.modcod = modal.modcod and
                                      titulo.etbcod = estab.etbcod and
                                      (titulo.titsit = "LIB" or 
                                       titulo.titsit = "CON")
                                      no-lock:


                        create tt-titulo.
                        buffer-copy titulo to tt-titulo.
                end.
            end.
        end.

        if opsys = "UNIX"
        then varquivo = "../relat/lib3." + string(time).
        else varquivo = "..\relat\lib3." + string(time).
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "158"
            &Page-Line = "66"
            &Nom-Rel   = ""LIB3""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """         SALDO - TITULOS PENDENTES  "" +
                          string(vdata1,""99/99/9999"") + ""       "" +
                          string(vdata2,""99/99/9999"") + ""       "" +
                          string(vdata3,""99/99/9999"")"
            &Width     = "158"
            &Form      = "frame f-cabcab"}

        if vlog = no
        then put skip "TODAS MODALIDADES" skip.
        else do:
            put skip
                "MODALIDADES: ".

            for each wmodal:
                put wmodal.modcod ", ".
            end.
            put skip(1).
        end.
        vacum = 0.
        vcob  =  0.
        vjur  =  0.
        vdes  =  0.
        vpag  =  0.

        for each wmodal,
            each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat   =   wtitnat          and
                              tt-titulo.modcod = wmodal.modcod 
                                        no-lock break by tt-titulo.clifor:

            if wtitnat
            then do:
                find forne where 
                    forne.forcod = tt-titulo.clifor no-lock no-error.
                if avail forne
                then assign
                        vnome = forne.fornom
                        vcnp = forne.forcgc.
                else assign
                        vnome = ""
                        vcnp = "".
            end.
            else do:
                find clien where clien.clicod = tt-titulo.clifor no-lock.
                vnome = clien.clinom.
                vcnp = clien.ciccgc.
            end.
            find first wpag where wpag.wcod = tt-titulo.clifor no-error.
            if not avail wpag
            then do:
                create wpag.
                assign wpag.wcod = tt-titulo.clifor
                       wpag.wnome = vnome
                       wpag.wcnp = vcnp.
            end.
            if tt-titulo.titdtven <= vdata1
            then assign wpag.wven1 = wpag.wven1 + (tt-titulo.titvlcob +
                                                   tt-titulo.titvljur)
                        wpag.wtot = wpag.wtot + (tt-titulo.titvlcob +
                                                 tt-titulo.titvljur).

            if tt-titulo.titdtven > vdata1 and
               tt-titulo.titdtven <= vdata2
            then assign wpag.wven2 = wpag.wven2 +
                           (tt-titulo.titvlcob + tt-titulo.titvljur)
                        wpag.wtot = wpag.wtot +
                           (tt-titulo.titvlcob + tt-titulo.titvljur).

            if tt-titulo.titdtven > vdata2 and
               tt-titulo.titdtven <= vdata3
            then assign wpag.wven3  = wpag.wven3  +
                               (tt-titulo.titvlcob + tt-titulo.titvljur)
                        wpag.wtot   = wpag.wtot +
                               (tt-titulo.titvlcob + tt-titulo.titvljur).

            if tt-titulo.titdtven > vdata3
            then wpag.wtot = wpag.wtot + 
                    (tt-titulo.titvlcob + tt-titulo.titvljur).
        end.
        for each wpag where
                 wpag.wcod > 0 break by wpag.wnome:
            display wpag.wnome  format "x(37)"
                    wpag.wcod   format ">>>>>>>>>9"
                    wpag.wcnp
                    wpag.wven1(total) no-label
                    wpag.wven2(total) no-label
                    wpag.wven3(total) no-label
                    wpag.wtot(total)  column-label "TOTAL GERAL"
                            with frame f-pag width 160 down.
        end.
        output close.
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i}
        end.
        leave.
    end.
    leave.
end.
