{admcab.i}
def input parameter vesc as log.
def var varquivo as char format "x(20)".
def var vv as char.
def var vtot like fin.titulo.titvlcob.
def temp-table tt-mod
    field modcod as char
    field pos    as int.
    
def var ii as int.
def temp-table wpag
    field etbcod like estab.etbcod
    field wnome  like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wdes  like fin.titulo.titvlcob
    field wjur  like fin.titulo.titvlcob
    field wcob  like fin.titulo.titvlcob
    field wpag  like fin.titulo.titvlcob
    field wven  like fin.titulo.titvlcob.
def var vcob like fin.titulo.titvlpag.
def var vpag like fin.titulo.titvlpag.
def var vdes like fin.titulo.titvlpag.
def var vjur like fin.titulo.titvlpag.
def var vacum like fin.titulo.titvlpag.
def var vlog as log.
def var vdt as date.
def var vmodcod like fin.modal.modcod.
def temp-table wmodal like fin.modal.
def var wtotger like fin.titulo.titvlcob.
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
def var wtitvlcob like fin.titulo.titvlcob.
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
        find estab where estab.etbcod =  wetbcod no-lock.
        display etbnom no-label format "x(10)".
    end. 
    
    else disp "TODOS" @ etbnom.
    update wmodcod validate(wmodcod = "" or
                            can-find(fin.modal where 
                                     fin.modal.modcod = wmodcod),
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
            for each fin.modal no-lock:
                create wmodal.
                assign wmodal.modcod = fin.modal.modcod
                       wmodal.modnom = fin.modal.modnom.
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

            find fin.modal where fin.modal.modcod = wmodcod no-lock.
            create wmodal.
            assign wmodal.modcod = wmodcod
                   wmodal.modnom = fin.modal.modnom.
            vlog = yes.
        end.
        wtot = 0.
        {confir.i 1 "impressao de Agenda Financeira"}

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        if wclifor = 0
        then vv = "GERAL".
        else vv = forne.fornom.
            varquivo = "l:\relat\pag4-" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "147"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """PAGAMENTOS FINANCEIRA - PERIODO DE "" +
                                  string(wdti,""99/99/9999"") + "" A "" +
                                  string(wdtf,""99/99/9999"") + ""  "" +
                                  string(wclifor,"">>>>>9"")  + ""  "" + 
                                  string(vv,""x(30)"")"
            &Width     = "147"
            &Form      = "frame f-cabcab"}
        vacum = 0.
        vcob  =  0.
        vjur  =  0.
        vdes  =  0.
        vpag  =  0.

        do vdt = wdti to wdtf:
            for each wmodal:
                
                
                for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                      fin.titulo.titnat =   wtitnat   and
                                      fin.titulo.modcod = wmodal.modcod and
                                      fin.titulo.titdtpag =  vdt        and
                                ( if wetbcod = 0
                                     then true
                                     else fin.titulo.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                     then true
                                     else fin.titulo.clifor = wclifor ) and
                                  fin.titulo.titsit   =   "PAG" 
                                        no-lock:

                    find first wpag where wpag.wmodcod = fin.titulo.modcod and
                                          wpag.etbcod  = fin.titulo.etbcod
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        assign wpag.etbcod  = fin.titulo.etbcod
                               wpag.wmodcod = fin.titulo.modcod.
                    end.
                    find modal where modal.modcod = fin.titulo.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    wpag.wcob  = wpag.wcob  + fin.titulo.titvlcob.
                    wpag.wjur  = wpag.wjur  + fin.titulo.titvljur.
                    wpag.wdes  = wpag.wdes  + fin.titulo.titvldes.
                    wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag.
                end.

                
                if vesc
                then do:
                    for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = wtitnat   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt        and
                                ( if wetbcod = 0
                                  then true
                                  else banfin.titulo.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                  then true
                                  else banfin.titulo.clifor = wclifor ) and
                                       banfin.titulo.titsit =   "PAG" no-lock:

                        find first wpag 
                             where wpag.wmodcod = banfin.titulo.modcod and
                                   wpag.etbcod  = banfin.titulo.etbcod 
                                            no-error.
                        if not avail wpag
                        then do:
                            create wpag.
                            assign wpag.etbcod  = banfin.titulo.etbcod
                                   wpag.wmodcod = banfin.titulo.modcod.
                        end.
                        find modal where modal.modcod = banfin.titulo.modcod 
                                                            no-lock no-error.
                        if not avail modal
                        then wpag.wnome = "".
                        else wpag.wnome = modal.modnom.
                    
                        wpag.wcob  = wpag.wcob  + banfin.titulo.titvlcob.
                        wpag.wjur  = wpag.wjur  + banfin.titulo.titvljur.
                        wpag.wdes  = wpag.wdes  + banfin.titulo.titvldes.
                        wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag.
                    end.
                
                end.
                 
                
                
                
                
                if substring(wmodal.modnom,1,6) = "Filial" 
                then do:
                    for each plani where plani.etbcod = 
                                         int(substring(wmodal.modnom,8,2)) and
                                         plani.movtdc = 5 and
                                         plani.pladat = vdt no-lock:
                        find first wpag 
                             where wpag.wmodcod = wmodal.modcod and
                                   wpag.etbcod  = plani.etbcod no-error.
                        if not avail wpag
                        then do:
                            find modal where modal.modcod = wmodal.modcod 
                                                        no-lock no-error.
                            create wpag.
                            assign wpag.etbcod = plani.etbcod
                                   wpag.wnome = wmodal.modnom
                                   wpag.wmodcod = wmodal.modcod.
                        end.
            
                        if plani.crecod = 1
                        then wpag.wven = wpag.wven + 
                                         (plani.platot - plani.vlserv).
                        else wpag.wven = wpag.wven + plani.biss.           
                    end.
                end.
            end.
        end.
        
        for each wpag break by wpag.wmodcod
                            by wpag.etbcod:
                            
            find first tt-mod where tt-mod.modcod = wpag.wmodcod no-error.
            if not avail tt-mod
            then do:
                create tt-mod.
                assign tt-mod.modcod = wpag.wmodcod.
            end.
        end.                             
           

        for each estab no-lock:
            for each tt-mod:
                find first wpag where wpag.wmodcod = tt-mod.modcod and
                                      wpag.etbcod  = estab.etbcod no-error.
                if not avail wpag
                then do:
                    create wpag.
                    assign wpag.wmodcod = tt-mod.modcod
                           wpag.etbcod  = estab.etbcod
                           wpag.wpag    = 0.
                end.           
            end.
        end.
                           
                                      
    

        
        for each wpag break by wpag.wmodcod
                            by wpag.etbcod:
        
            if first-of(wpag.wmodcod)
            then display wpag.wmodcod label "Modalidade"
                         wpag.wnome no-label 
                                    with frame f-fil side-label.
            display wpag.etbcod column-label "Filial"
                    wpag.wpag(total by wpag.wmodcod) 
                        format "->,>>>,>>9.99" column-label "Vl.Pago"
                        with frame f-pag width 150 down.
        end.
        
        output close.
        {mrod.i}

    end.
end.
