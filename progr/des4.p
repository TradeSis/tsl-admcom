/*----------------------------------------------------------------------------*/
/* finan/pag.p                                          Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
def input parameter vesc as log.

def var varquivo as char format "x(20)".
def var vv as char.
def var vtot like fin.titluc.titvlcob.
def temp-table wpag
    field wcod like fin.titluc.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titluc.modcod
    field wdes  like fin.titluc.titvlcob
    field wjur  like fin.titluc.titvlcob
    field wcob  like fin.titluc.titvlcob
    field wpag  like fin.titluc.titvlcob
    field wven  like fin.titluc.titvlcob
    field mes   as int format "99".
def var vacum like fin.titluc.titvlpag.
def var vdt as date.
def var vmodcod like fin.modal.modcod init "".
def temp-table wmodal like fin.modal.
def var wtotger like fin.titluc.titvlcob.
def var vtitrel     as char format "x(50)".
def var wetbcod like fin.titluc.etbcod initial 0.
def var wmodcod like fin.titluc.modcod initial "".
def var wtitnat like fin.titluc.titnat.
def var wclifor like fin.titluc.clifor initial 0.
def var wclicod like clien.clicod initial 0.
def var wdti    like fin.titluc.titdtven label "Periodo" initial today.
def var wdtf    like fin.titluc.titdtven.
def var wtot      as dec format ">,>>>,>>>,>>9.99" label "Total".
def var wclfnom as char format "x(30)" label "clfnom".

form wdti colon 12
     " A"
     wdtf colon 29 no-label with frame fdat width 80 side-label.

wdtf = wdti + 30.
wtotger = 0.
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:

    disp "" @ wetbcod colon 12.
    update wetbcod label "Estabelec." .
    if wetbcod <> 0
    then do: 
        find estab where estab.etbcod =  wetbcod NO-LOCK.
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
        then do with column 1 side-labels 1 down width 48 row 6 frame ff:
            disp "" @ wclifor.
            update wclifor label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
            if input wclifor <> "" and wclifor <> 0
            then do:
                        find forne where forne.forcod = input wclifor NO-LOCK.
                        display fornom format "x(32)" no-label at 10.
            end.
            else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
        end.
        else do with column 1 side-labels 1 down width 48 row 6 frame fc:
            disp "" @ wclicod.
            prompt-for wclicod label "Cliente"
                  help "Informe o codigo do Cliente ou <ENTER> para todos".
            if input wclicod <> ""
            then do:
                        find clien where clien.clicod = input wclicod NO-LOCK.
                        display clinom format "x(32)" no-label at 10.
            end.
            else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
        end.
        if not wtitnat
        then wclifor = wclicod.
        else wclifor = wclifor.

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
            repeat:
                update vmodcod with frame f-modal centered side-label.
                if vmodcod = ""
                then leave.
                find first wmodal where wmodal.modcod = vmodcod
                                                            no-lock no-error.
                if not avail wmodal
                then do:
                    message "Modalidade Invalida".
                    undo, retry.
                end.
                display wmodal.modnom no-label with frame f-modal.
                delete wmodal.
            end.
        end.
        else do:
            find fin.modal where fin.modal.modcod = wmodcod no-lock.
            create wmodal.
            assign wmodal.modcod = wmodcod
                   wmodal.modnom = fin.modal.modnom.
        end.
        wtot = 0.
/***
        {confir.i 1 "impressao de Agenda Financeira"}
***/

        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        if wclifor = 0
        then vv = "GERAL".
        else vv = forne.fornom.

        if opsys = "UNIX"
        then varquivo = "/admcom/relat/des4." + string(time).
        else varquivo = "l:\relat\des4-" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "147"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """PAGAMENTOS FINANCEIRA - PERIODO DE "" +
                                  string(wdti) + "" A "" +
                                  string(wdtf) + ""  "" +
                                  string(wclifor)  + ""  "" + 
                                  string(vv,""x(30)"")"
            &Width     = "147"
            &Form      = "frame f-cabcab"}
        vacum = 0.

        do vdt = wdti to wdtf:
            for each wmodal:
                for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   wtitnat   and
                                      fin.titluc.modcod = wmodal.modcod and
                                      fin.titluc.titdtpag =  vdt        and
                                ( if wetbcod = 0
                                     then true
                                     else fin.titluc.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                     then true
                                     else fin.titluc.clifor = wclifor ) and
                                  fin.titluc.titsit   =   "PAG" no-lock:

                    find first wpag where 
                               wpag.wmodcod = fin.titluc.modcod and
                               wpag.mes     =  month(fin.titluc.titdtpag)
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        assign wpag.wcod    = fin.titluc.clifor
                               wpag.wmodcod = fin.titluc.modcod
                               wpag.mes     = month(fin.titluc.titdtpag).
                    end.
                    find modal where modal.modcod = fin.titluc.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    wpag.wcob  = wpag.wcob  + fin.titluc.titvlcob.
                    wpag.wjur  = wpag.wjur  + fin.titluc.titvljur.
                    wpag.wdes  = wpag.wdes  + fin.titluc.titvldes.
                    wpag.wpag  = wpag.wpag  + fin.titluc.titvlpag.
                end.
                
                if vesc
                then do:
                    for each banfin.titluc where 
                             banfin.titluc.empcod = wempre.empcod and
                             banfin.titluc.titnat = wtitnat   and
                             banfin.titluc.modcod = wmodal.modcod and
                             banfin.titluc.titdtpag =  vdt        and
                                ( if wetbcod = 0
                                  then true
                                  else banfin.titluc.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                  then true
                                  else banfin.titluc.clifor = wclifor ) and
                                       banfin.titluc.titsit =   "PAG" no-lock:

                        find first wpag where 
                                   wpag.wmodcod = banfin.titluc.modcod and
                                   wpag.mes     = month(banfin.titluc.titdtpag)
                                                                no-error.
                        if not avail wpag
                        then do:
                            create wpag.
                            assign wpag.wcod    = banfin.titluc.clifor
                                   wpag.wmodcod = banfin.titluc.modcod
                                   wpag.mes     = month(banfin.titluc.titdtpag).
                        end.
                        find modal where modal.modcod = banfin.titluc.modcod 
                                                            no-lock no-error.
                        if not avail modal
                        then wpag.wnome = "".
                        else wpag.wnome = modal.modnom.
                    
                        wpag.wcob  = wpag.wcob  + banfin.titluc.titvlcob.
                        wpag.wjur  = wpag.wjur  + banfin.titluc.titvljur.
                        wpag.wdes  = wpag.wdes  + banfin.titluc.titvldes.
                        wpag.wpag  = wpag.wpag  + banfin.titluc.titvlpag.
                    end.
                
                end.
                 
                /*
                if substring(wmodal.modnom,1,6) = "Filial" 
                then do:
                    for each plani where plani.etbcod = 
                                         int(substring(wmodal.modnom,8,2)) and
                                         plani.movtdc = 5 and
                                         plani.pladat = vdt no-lock:
                        find first wpag where 
                                   wpag.wmodcod = wmodal.modcod no-error.
                        if not avail wpag
                        then do:
                            find modal where modal.modcod = wmodal.modcod 
                                                        no-lock no-error.
                            create wpag.
                            assign wpag.wcod = wclifor
                                   wpag.wnome = wmodal.modnom
                                   wpag.wmodcod = wmodal.modcod
                                   wpag.mes     = month(plani.pladat).
                        end.
            
                        if plani.crecod = 1
                        then wpag.wven = wpag.wven + 
                                         (plani.platot - plani.vlserv).
                        else wpag.wven = wpag.wven + plani.biss.           
                    end.
                end.
                */
                
            end.
        end.
        for each wpag break by wpag.mes:
            vacum = vacum + wpag.wpag.
            vtot  = vtot  + wpag.wpag.
            display wpag.mes    column-label "Mes"
                    wpag.wmodcod
                    wpag.wnome column-label "MODALIDADE"
                    wpag.wpag(total by wpag.mes) 
                        format "->,>>>,>>9.99" column-label "Vl.Pago"
                    vacum column-label "Acumulado" format "->,>>>,>>9.99"
                        with frame f-pag width 150 down.
        end.
        output close.

        if opsys = "UNIX"
        then run visurel.p(varquivo,"").
        else do:
            {mrod.i}
        end.
    end.
end.

