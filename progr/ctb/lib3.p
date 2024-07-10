/*----------------------------------------------------------------------------*/
/* finan/pag.p                                              Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/

{admcab.i}

def var varquivo as char.
def var vtot like titulo.titvlcob.
def temp-table wpag
    field wcod  like titulo.clifor
    field wnome like forne.fornom
    field wven1 like titulo.titvlcob
    field wven2 like titulo.titvlcob
    field wven3 like titulo.titvlcob
    field wtot  like titulo.titvlcob
    index i1 wcod.
    
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
def var p-catcod like produ.catcod.
wtotger = 0.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
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
    repeat:
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
        
        def var vcatcod as int format ">>9".
        
        update vcatcod label "Departamento" 
            help "Informe o codigo do Departamento."
            with side-LABEL WIDTH 80.
        if vcatcod <> 0
        then do:
            find categoria where categoria.catcod = vcatcod no-lock.
            disp categoria.catnom no-label .
        end.
        else disp "Todos os Departamentos" @ categoria.catnom.
        
        update vdata1 label "Venc."
               vdata2 label "Venc."
               vdata3 label "Venc." with frame fdat width 80 side-label.
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
        end.
        else do:
            create wmodal.
            assign wmodal.modcod = wmodcod.
            vlog = yes.
        end.
        wtot = 0.
        {confir.i 1 "impressao de Agenda Financeira"}

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .

        for each wpag:
            delete wpag.
        end.

        if opsys = "UNIX"
        then varquivo = "../relat/lib3." + string(time).
        else varquivo = "..\relat\lib3." + string(time).
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "119"
            &Page-Line = "66"
            &Nom-Rel   = ""LIB3""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """PAGAMENTOS FINANCEIRA          "" +
                          string(vdata1,""99/99/9999"") + ""        "" +
                          string(vdata2,""99/99/9999"") + ""        "" +
                          string(vdata3,""99/99/9999"")"
            &Width     = "119"
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
            each titulo where titulo.empcod = wempre.empcod and
                              titnat   =   wtitnat          and
                              titulo.modcod = wmodal.modcod and
                              (titsit   =   "LIB" or
                               titsit   =   "CON") and
                            ( if wetbcod = 0
                                 then true
                                 else titulo.etbcod = wetbcod ) and
                            ( if wclifor = 0
                              then true
                              else titulo.clifor = wclifor ) 
                                        no-lock:
                                        
            if vcatcod > 0
            then do:
                    run pega-categoria-titulo.p(recid(titulo),
                                                output p-catcod).
                    if p-catcod <> vcatcod
                    then next.                            
            end.

            if wtitnat
            then do:
                find forne where forne.forcod = titulo.clifor no-lock no-error.
                if avail forne
                then vnome = forne.fornom.
                else vnome = "".
            end.
            else do:
                find clien where clien.clicod = titulo.clifor no-lock.
                vnome = clien.clinom.
            end.
            find first wpag where wpag.wcod = titulo.clifor no-error.
            if not avail wpag
            then do:
                create wpag.
                assign wpag.wcod = titulo.clifor
                       wpag.wnome = vnome.
            end.
            if titulo.titdtven <= vdata1
            then assign wpag.wven1 = wpag.wven1 + (titulo.titvlcob +
                                                   titulo.titvljur)
                        wpag.wtot = wpag.wtot + (titulo.titvlcob +
                                                 titulo.titvljur).

            if titulo.titdtven > vdata1 and
               titulo.titdtven <= vdata2
            then assign wpag.wven2 = wpag.wven2 +
                                     (titulo.titvlcob + titulo.titvljur)
                        wpag.wtot = wpag.wtot +
                                     (titulo.titvlcob + titulo.titvljur).

            if titulo.titdtven > vdata2 and
               titulo.titdtven <= vdata3
            then assign wpag.wven3  = wpag.wven3  +
                                      (titulo.titvlcob + titulo.titvljur)
                        wpag.wtot   = wpag.wtot +
                                      (titulo.titvlcob + titulo.titvljur).

            if titulo.titdtven > vdata3
            then wpag.wtot = wpag.wtot + (titulo.titvlcob + titulo.titvljur).
        end.
        for each wpag break by wpag.wnome:
            display wpag.wnome
                    wpag.wcod
                    wpag.wven1(total) no-label
                    wpag.wven2(total) no-label
                    wpag.wven3(total) no-label
                    wpag.wtot(total)  column-label "TOTAL GERAL"
                            with frame f-pag width 150 down.
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
