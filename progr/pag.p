/*----------------------------------------------------------------------------*/
/* finan/pag.p                                              Agenda - Listagem */
/*                                                                            */
/*------------------  -------------------------------------------------------*/

{admcab.i}

def var ii as int.
def var varquivo as char format "x(20)". 
def var vevecod like titulo.evecod.
def temp-table wevent like event.
def var vlog as log.
def var vdt as date.
def var vmodcod like modal.modcod.
def workfile wmodal like modal.
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
def var wseq as i extent 2.
def var i as i.
def var wbar as c label "/" initial "/" format "x".
def var wclfnom as char format "x(30)" label "clfnom".
def var wforcli as i format "999999" label "For/Cli".
def var vtotcob like titulo.titvlcob.
def var vtotjur like titulo.titvljur.
def var vtotdes like titulo.titvldes.
def var vtotpag like titulo.titvlcob.
def var p-catcod like produ.catcod.
def var i-subst as dec.
def var b-subst as dec.

wdtf = wdti + 30.
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

     vtotcob  = 0.
     vtotjur  = 0.
     vtotdes  = 0.
     vtotpag  = 0.
     wtitvlcob = 0.
     wtot = 0.
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
        repeat:
            update vevecod with frame f-event centered side-label.
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
        end.
        wtot = 0.
        {confir.i 1 "impressao de Agenda Financeira"}

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .


        if opsys = "UNIX"
        then varquivo = "../relat/res" + string(time).
        else varquivo = "..\relat\res" + string(time).


        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""PAG""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A """
            &Tit-Rel   = """PAGAMENTOS - PERIODO DE "" +
                                  string(wdti,""99/99/9999"") + "" A "" +
                                  string(wdtf,""99/99/9999"") "
            &Width     = "140"
            &Form      = "frame f-cabcab"}

        if vlog = no
        then put skip "TODAS MODALIDADES" skip.
        else do:
            put skip.
            ii = 0.
            for each wmodal:
                put wmodal.modcod  ", ".
                ii = ii + 1.
                if ii = 10
                then do:
                    put skip.
                    ii = 0.
                end.    
            end.
            put skip(1).
        end.

        vtotcob = 0.
        vtotjur = 0.
        vtotdes = 0.
        vtotpag = 0.
        do vdt = wdti to wdtf:
        for each wmodal,
            each titulo where titulo.empcod = wempre.empcod and
                              titnat   =   wtitnat          and
                              titulo.modcod = wmodal.modcod and
                              titdtpag =  vdt        and
                            ( if wetbcod = 0
                                 then true
                                 else titulo.etbcod = wetbcod ) and
                            ( if wclifor = 0
                              then true
                              else titulo.clifor = wclifor ) and
                              titsit   =   "PAG"  no-lock
                                 break by titulo.titdtpag:
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
            find first wevent where wevent.evecod = titulo.evecod no-error.
            if not avail wevent
            then next.

            i-subst = 0.
                b-subst = 0.
                if titulo.modcod = "DUP"
                then run icms-subst.
 
            display titulo.titnum column-label "Numero"
                    titulo.titdtven column-label "Dt.Venc." 
                    titulo.titdtpag column-label "Dt.Pag." 
                    titulo.titdtemi column-label "Emissao."
                    titulo.clifor
                    forne.fornom when avail forne
                    titulo.modcod
                    titulo.titvlcob(total by titulo.titdtpag)
                            column-label "Vl.Cobrado" format "->,>>>,>>9.99"
                    titulo.titvljur(total by titulo.titdtpag)
                            column-label "Juros"      format "->,>>>,>>9.99"
                    titulo.titvldes(total by titulo.titdtpag)
                            column-label "Desconto"   format "->,>>>,>>9.99"
                    (titulo.titvlcob + titulo.titvljur - titulo.titvldes)
                        (total by titulo.titdtpag) column-label "Vl.Total"
                                format "->,>>>,>>9.99"
                    titulo.evecod column-label "Even"
                    i-subst (total by titulo.titdtpag)
                            format ">>>,>>9.99" 
                    titulo.titobs[1] + titulo.titobs[2] format "x(60)"
                            with frame f-pag width 260 down.
            vtotcob = vtotcob + titulo.titvlcob.
            vtotjur = vtotjur + titulo.titvljur.
            vtotdes = vtotdes + titulo.titvldes.
            vtotpag = vtotpag + (titulo.titvlpag +
                                 titulo.titvljur -
                                 titulo.titvldes).

        end.
        end.
        put "TOTAL COBRADO.......: " at 20 vtotcob
            "TOTAL JUROS.........: " at 20 vtotjur
            "TOTAL DESCONTO......: " at 20 vtotdes
            "TOTAL PAGO..........: " at 20 vtotpag.
        assign
         vtotcob = 0
         vtotjur = 0
         vtotdes = 0
         vtotpag = 0.
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
