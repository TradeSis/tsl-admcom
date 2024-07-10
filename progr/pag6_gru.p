/*----------------------------------------------------------------------------*/
/* finan/pag.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/

{admcab.i}

def buffer bmodgru for modgru.
def var varquivo as char.
def stream sterm.
def var vv as char.
def var vtot like titulo.titvlcob.
def temp-table wpag
    field wcod    like titulo.clifor
    field wnome   like forne.fornom
    field wetbcod like titulo.etbcod
    field wdes  like titulo.titvlcob
    field wjur  like titulo.titvlcob
    field wcob  like titulo.titvlcob
    field wpag  like titulo.titvlcob
    field wven  like titulo.titvlcob.
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
def var wtitnat like titulo.titnat.
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
wdtf = wdti + 30.
wtotger = 0.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
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
        
       for each wpag:
            delete wpag.
       end.

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
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        update wdti
               wdtf with frame fdat.
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

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        if wclifor = 0
        then vv = "GERAL".
        else vv = forne.fornom.
        if opsys = "UNIX"
        then varquivo = "../relat/pag06g" + string(time).
        else varquivo = "l:\relat\pag06g" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "119"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG6_GRU""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """PAGAMENTOS FINANCEIRA - PERIODO DE "" +
                                  string(wdti,""99/99/9999"") + "" A "" +
                                  string(wdtf,""99/99/9999"") + ""  "" +
                                  string(wclifor,"">>>>>9"")  + ""  "" + 
                                  string(vv,""x(30)"")"
            &Width     = "119"
            &Form      = "frame f-cabcab"}
        vacum = 0.
        vcob  =  0.
        vjur  =  0.
        vdes  =  0.
        vpag  =  0.

        do vdt = wdti to wdtf:
            for each wmodal where wmodal.modcod <> "BON" :
                for each titulo where titulo.empcod = wempre.empcod and
                                  titnat   =   wtitnat          and
                                  titulo.modcod = wmodal.modcod and
                                  titdtpag =  vdt        and
                                ( if wetbcod = 0
                                     then true
                                     else titulo.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                     then true
                                     else titulo.clifor = wclifor ) and
                                  titsit   =   "PAG" no-lock:

                    find first wpag where wpag.wetbcod = titulo.etbcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        assign wpag.wcod = titulo.clifor
                               wpag.wetbcod = titulo.etbcod.
                    end.
                    find estab where estab.etbcod = titulo.etbcod 
                                                        no-lock no-error.
                    if not avail estab
                    then wpag.wnome = "".
                    else wpag.wnome = estab.etbnom.
                    
                    wpag.wcob  = wpag.wcob  + titulo.titvlcob.
                    wpag.wjur  = wpag.wjur  + titulo.titvljur.
                    wpag.wdes  = wpag.wdes  + titulo.titvldes.
                    wpag.wpag  = wpag.wpag  + titulo.titvlpag.
                end.
                
                if substring(wmodal.modnom,1,6) = "Filial" 
                then do:
                    for each plani where plani.etbcod = 
                                         int(substring(wmodal.modnom,8,2)) and
                                         plani.movtdc = 5 and
                                         plani.pladat = vdt no-lock:
                        find first wpag where wpag.wetbcod = plani.etbcod                                                                       no-error.
                        if not avail wpag
                        then do:
                            find estab where estab.etbcod = plani.etbcod
                                    no-lock.
                            create wpag.
                            assign wpag.wcod    = wclifor
                                   wpag.wnome   = estab.etbnom
                                   wpag.wetbcod = estab.etbcod.
                        end.
            
                        if plani.crecod = 1
                        then wpag.wven = wpag.wven + 
                                         (plani.platot - plani.vlserv).
                        else wpag.wven = wpag.wven + plani.biss.           
                    end.
                end.
            end.
        end.
        output stream sterm to terminal.
        for each wpag break by wpag.wnome:
            vacum = vacum + wpag.wpag.
            vtot  = vtot  + wpag.wpag.

            
            display stream sterm 
                    wpag.wetbcod
                    wpag.wpag(total) 
                        format "->,>>>,>>9.99" column-label "Vl.Pago"
                    vacum column-label "Acumulado" format "->,>>>,>>9.99"
                    wpag.wven(total) 
                        format "->,>>>,>>9.99" column-label "Vl.Venda"
                    ((wpag.wpag / wpag.wven) * 100) format "->>9.99 %"
                             column-label "Perc." when wpag.wven > 0
                        with frame f-term width 80 down.


        
            
            display wpag.wetbcod
                    wpag.wnome column-label "Filial"
                    wpag.wpag(total) 
                        format "->,>>>,>>9.99" column-label "Vl.Pago"
                    vacum column-label "Acumulado" format "->,>>>,>>9.99"
                    wpag.wven(total) 
                        format "->,>>>,>>9.99" column-label "Vl.Venda"
                    ((wpag.wpag / wpag.wven) * 100) format "->>9.99 %"
                             column-label "Perc." when wpag.wven > 0
                        with frame f-pag width 150 down.
            if line-counter = 61
            then page.
        end.
        output close.
        output stream sterm close.
        /*message "Deseja imprimir listagem" update sresp.
        if sresp
        then dos silent value("type " + varquivo + " > prn").*/
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:    
            {mrod.i}
        end.

    end.
end.
