
{admcab.i}

def var vindex as int.

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
def temp-table wpag
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
    field wven  like fin.titulo.titvlcob.

def temp-table wgru
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
    field wven  like fin.titulo.titvlcob.

def temp-table wfor
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
    field wven  like fin.titulo.titvlcob.
    
def temp-table wdoc
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
    field wven  like fin.titulo.titvlcob.
    

def var vcob as dec format "->>>>,>>>,>>9.99".
def var vpag as dec format "->>>>,>>>,>>9.99".
def var vrec as dec format "->>>>,>>>,>>9.99".
def var vdes as dec format "->>>>,>>>,>>9.99".
def var vjur as dec format "->>>>,>>>,>>9.99".
def var vacum as dec format "->>>>,>>>,>>9.99".
def var vlog as log.
def var vdt as date.
def var vmodcod like fin.modal.modcod.
def temp-table wmodal like fin.modal.
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
    /**
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
    wtitnat = yes.
    update wtitnat no-label.
    **/

    wtitnat = yes.
    repeat:
        
       for each wpag:
            delete wpag.
       end.
       for each wfor:
        delete wfor.
       end. 
       for each wdoc: delete wdoc. end.
       /**
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
        **/
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
                /*
                update vmodcod with frame f-modal centered side-label.
                */
                find first wmodal where wmodal.modcod = vmodcod
                                                            no-lock no-error.
                if avail wmodal
                then do:
                    delete wmodal.
                end.
                /*
                display wmodal.modnom no-label with frame f-modal.
                delete wmodal.
                */
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
        /*
        {confir.i 1 "impressao de Agenda Financeira"}
        */
        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        if wclifor = 0
        then vv = "GERAL".
        else vv = "".
        
        if opsys = "UNIX"
        then varquivo = "/admcom/relat/pag4-" + string(time).
        else varquivo = "l:~\relat~\pag4-" + string(time).
        
        /***
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = """PAGAMENTOS PERIODO DE "" +
                                  string(wdti,""99/99/99"") + "" A "" +
                                  string(wdtf,""99/99/99"") + ""  "" +
                                  string(wclifor,"">>>>>9"")  + ""  "" + 
                                  string(vv,""x(25)"")"
            &Width     = "80"
            &Form      = "frame f-cabcab"}
        ***/
        vacum =  0.
        vcob  =  0.
        vjur  =  0.
        vdes  =  0.
        vpag  =  0.
        vrec  =  0.
        do vdt = wdti to wdtf:
            disp "Processando... Aguarde! " vdt
                 with frame f-proc 1 down centered no-box color message
                    row 10 no-label.
            pause 0.        
            for each wmodal:
                disp wmodal.modcod with frame f-proc.
                pause 0.

                /***
                for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                      fin.titulo.titnat =   wtitnat   and
                                      fin.titulo.modcod = wmodal.modcod and
                                      fin.titulo.titdtpag =  vdt and
                                      fin.titulo.titsit   =   "PAG" no-lock:

                    find first titudesp where
                               titudesp.empcod = fin.titulo.empcod and
                               titudesp.titnat = fin.titulo.titnat and
                               titudesp.modcod = fin.titulo.modcod and
                               titudesp.etbcod = fin.titulo.etbcod and
                               titudesp.clifor = fin.titulo.clifor and
                               titudesp.titnum = fin.titulo.titnum and
                               titudesp.titdtemi = fin.titulo.titdtemi
                               no-lock no-error.
                    if avail titudesp and vdt > 06/30/13
                    then next. 

                    disp titulo.titnum with frame f-proc.
                    pause 0.
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
                    find first wpag where wpag.wmodcod = fin.titulo.modcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        wpag.wmodcod = fin.titulo.modcod.
                    end.
                    find modal where modal.modcod = fin.titulo.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    find first wfor where
                               wfor.wcod = fin.titulo.clifor and
                               wfor.wmodcod = fin.titulo.modcod
                                no-error.
                    if not avail wfor
                    then do:
                        create wfor.
                        assign
                            wfor.wcod = fin.titulo.clifor
                            wfor.wmodcod = fin.titulo.modcod
                            .
                    end.
                    find first wdoc where
                               wdoc.wcod  = fin.titulo.clifor and
                               wdoc.wmod  = fin.titulo.modcod and
                               wdoc.wnome = if fin.titulo.titobs[1] <> ""
                                then fin.titulo.titobs[1]
                                else  (fin.titulo.titnum + "/" +
                                           string(fin.titulo.titpar)) 
                               no-error.
                    if not avail wdoc
                    then do:
                        create wdoc.
                        assign
                            wdoc.wcod = fin.titulo.clifor 
                            wdoc.wmod = fin.titulo.modcod
                            wdoc.wnome = if fin.titulo.titobs[1] <> ""
                                then fin.titulo.titobs[1]
                                else  (fin.titulo.titnum + "/" +
                                    string(fin.titulo.titpar))
                            .
                    end.           
                    assign            
                    wpag.wcob  = wpag.wcob  + fin.titulo.titvlcob
                    wpag.wjur  = wpag.wjur  + fin.titulo.titvljur
                    wpag.wdes  = wpag.wdes  + fin.titulo.titvldes
                    wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag
                    wfor.wcob  = wfor.wcob  + fin.titulo.titvlcob
                    wfor.wjur  = wfor.wjur  + fin.titulo.titvljur
                    wfor.wdes  = wfor.wdes  + fin.titulo.titvldes
                    wfor.wpag  = wfor.wpag  + fin.titulo.titvlpag
                    wdoc.wcob  = wdoc.wcob  + fin.titulo.titvlcob
                    wdoc.wjur  = wdoc.wjur  + fin.titulo.titvljur
                    wdoc.wdes  = wdoc.wdes  + fin.titulo.titvldes
                    wdoc.wpag  = wdoc.wpag  + fin.titulo.titvlpag.
                    
                end.
                
                run fin-titudesp.
                ******/
                
                for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                      fin.titluc.titnat =   no          and
                                      fin.titluc.modcod = wmodal.modcod and
                                      fin.titluc.titdtpag =  vdt /*       and
                                ( if wetbcod = 0
                                     then true
                                     else fin.titluc.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                     then true
                                     else fin.titluc.clifor = wclifor )*/ and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.evecod = 8 no-lock:
                    if fin.titluc.titbanpag = 0 then next.
                    /* Diretores */
                    disp fin.titluc.titnum with frame f-proc.
                    pause 0.
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
                    find first wpag where wpag.wmodcod = fin.titluc.modcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        wpag.wmodcod = fin.titluc.modcod.
                    end.
                    find modal where modal.modcod = fin.titluc.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    find first wfor where
                               wfor.wcod = fin.titluc.clifor and
                               wfor.wmodcod = fin.titluc.modcod
                                no-error.
                    if not avail wfor
                    then do:
                        create wfor.
                        assign
                            wfor.wcod = fin.titluc.clifor
                            wfor.wmodcod = fin.titluc.modcod
                            .
                    end.
                    find first wdoc where
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
                                      fin.titluc.titdtpag =  vdt /*       and
                                ( if wetbcod = 0
                                     then true
                                     else fin.titluc.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                     then true
                                     else fin.titluc.clifor = wclifor )*/ and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.evecod = 9 no-lock:
                    if fin.titluc.titbanpag = 0 then next.
                    /* Diretores */
                    disp fin.titluc.titnum with frame f-proc.
                    pause 0.
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
                    find first wpag where wpag.wmodcod = fin.titluc.modcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        wpag.wmodcod = fin.titluc.modcod.
                    end.
                    find modal where modal.modcod = fin.titluc.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    find first wfor where
                               wfor.wcod = fin.titluc.clifor and
                               wfor.wmodcod = fin.titluc.modcod
                                no-error.
                    if not avail wfor
                    then do:
                        create wfor.
                        assign
                            wfor.wcod = fin.titluc.clifor
                            wfor.wmodcod = fin.titluc.modcod
                            .
                    end.
                    find first wdoc where
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

                /********************
                /**/
                    

                if vesc
                then do:
                
                    for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = wtitnat   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt  and
                             banfin.titulo.titsit =   "PAG" no-lock:
                        
                        find first titudesp where
                               titudesp.empcod = banfin.titulo.empcod and
                               titudesp.titnat = banfin.titulo.titnat and
                               titudesp.modcod = banfin.titulo.modcod and
                               titudesp.etbcod = banfin.titulo.etbcod and
                               titudesp.clifor = banfin.titulo.clifor and
                               titudesp.titnum = banfin.titulo.titnum and
                               titudesp.titdtemi = banfin.titulo.titdtemi
                               no-lock no-error.
                        if avail titudesp and vdt > 06/30/13
                        then  next. 
                        
                        disp titulo.titnum with frame f-proc.
                        pause 0.
                        if vsetcod > 0 
                        then do:
                            if  banfin.titulo.titbanpag > 0 and
                            banfin.titulo.titbanpag <> vsetcod
                            then next.
                            if banfin.titulo.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    if foraut.setcod <> vsetcod 
                                    then next.
                                end.
                                else next.
                            end.
                        end.

                        find first wpag where wpag.wmodcod = 
                                            banfin.titulo.modcod no-error.
                        if not avail wpag
                        then do:
                            create wpag.
                            assign wpag.wcod    = banfin.titulo.clifor
                                   wpag.wmodcod = banfin.titulo.modcod.
                        end.
                        find modal where modal.modcod = banfin.titulo.modcod 
                                                            no-lock no-error.
                        if not avail modal
                        then wpag.wnome = "".
                        else wpag.wnome = modal.modnom.
                        find first wfor where
                               wfor.wcod = banfin.titulo.clifor and
                               wfor.wmodcod = banfin.titulo.modcod
                                no-error.
                        if not avail wfor
                        then do:
                            create wfor.
                            assign
                                wfor.wcod = banfin.titulo.clifor
                                wfor.wmodcod = banfin.titulo.modcod
                                .
                        end.
                        find first wdoc where
                               wdoc.wcod  = banfin.titulo.clifor and
                               wdoc.wmod  = banfin.titulo.modcod and
                               wdoc.wnome = if banfin.titulo.titobs[1] <> ""
                                then banfin.titulo.titobs[1]
                                else  (banfin.titulo.titnum + "/" +
                                           string(banfin.titulo.titpar)) 
                               no-error.
                    if not avail wdoc
                    then do:
                        create wdoc.
                        assign
                            wdoc.wcod = banfin.titulo.clifor 
                            wdoc.wmod = banfin.titulo.modcod
                            wdoc.wnome = if banfin.titulo.titobs[1] <> ""
                                then banfin.titulo.titobs[1]
                                else  (banfin.titulo.titnum + "/" +
                                    string(banfin.titulo.titpar))
                            .
                    end. 

                        assign            
                        wpag.wcob  = wpag.wcob  + banfin.titulo.titvlcob
                        wpag.wjur  = wpag.wjur  + banfin.titulo.titvljur
                        wpag.wdes  = wpag.wdes  + banfin.titulo.titvldes
                        wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag
                        wfor.wcob  = wfor.wcob  + banfin.titulo.titvlcob
                        wfor.wjur  = wfor.wjur  + banfin.titulo.titvljur
                        wfor.wdes  = wfor.wdes  + banfin.titulo.titvldes
                        wfor.wpag  = wfor.wpag  + banfin.titulo.titvlpag
                        wdoc.wcob  = wdoc.wcob  + banfin.titulo.titvlcob
                        wdoc.wjur  = wdoc.wjur  + banfin.titulo.titvljur
                        wdoc.wdes  = wdoc.wdes  + banfin.titulo.titvldes
                        wdoc.wpag  = wdoc.wpag  + banfin.titulo.titvlpag

                        .
                    end.
                   /** Antonio **/
                   for each  banfin.titluc where 
                             banfin.titluc.empcod = wempre.empcod and
                             banfin.titluc.titnat = no            and
                             banfin.titluc.modcod = wmodal.modcod and
                             banfin.titluc.titdtpag =  vdt        and
                                ( if wetbcod = 0
                                  then true
                                  else banfin.titluc.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                  then true
                                  else banfin.titluc.clifor = wclifor ) and
                                       banfin.titluc.titsit = "PAG" and
                                       banfin.titluc.evecod = 8 no-lock:
                                       
                        if banfin.titluc.titbanpag = 0 then next.
                        /* diretores */               
                        disp banfin.titluc.titnum with frame f-proc.
                        pause 0.
                        if vsetcod > 0 
                        then do:
                            if  banfin.titluc.titbanpag > 0 and
                            banfin.titluc.titbanpag <> vsetcod
                            then next.
                            if banfin.titluc.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    if foraut.setcod <> vsetcod 
                                    then next.
                                end.
                                else next.
                            end.
                        end.

                        find first wpag where wpag.wmodcod = 
                                            banfin.titluc.modcod no-error.
                        if not avail wpag
                        then do:
                            create wpag.
                            assign wpag.wcod    = banfin.titluc.clifor
                                   wpag.wmodcod = banfin.titluc.modcod.
                        end.
                        find modal where modal.modcod = banfin.titluc.modcod 
                                                            no-lock no-error.
                        if not avail modal
                        then wpag.wnome = "".
                        else wpag.wnome = modal.modnom.
                        find first wfor where
                               wfor.wcod = banfin.titluc.clifor and
                               wfor.wmodcod = banfin.titluc.modcod
                                no-error.
                        if not avail wfor
                        then do:
                            create wfor.
                            assign
                                wfor.wcod = banfin.titluc.clifor
                                wfor.wmodcod = banfin.titluc.modcod
                                .
                        end.
                        find first wdoc where
                               wdoc.wcod  = banfin.titluc.clifor and
                               wdoc.wmod  = banfin.titluc.modcod and
                               wdoc.wnome = if banfin.titluc.titobs[1] <> ""
                                then banfin.titluc.titobs[1]
                                else  (banfin.titluc.titnum + "/" +
                                           string(banfin.titluc.titpar)) 
                               no-error.
                        if not avail wdoc
                        then do:
                            create wdoc.
                            assign
                            wdoc.wcod = banfin.titluc.clifor 
                            wdoc.wmod = banfin.titluc.modcod
                            wdoc.wnome = if banfin.titluc.titobs[1] <> ""
                                then banfin.titluc.titobs[1]
                                else  (banfin.titluc.titnum + "/" +
                                    string(banfin.titluc.titpar))
                            .
                        end. 

                        assign            
                        wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob
                        wfor.wrec  = wfor.wpag  + banfin.titluc.titvlcob
                        wdoc.wrec  = wdoc.wpag  + banfin.titluc.titvlcob
                        .
                   end.

                   for each  banfin.titluc where 
                             banfin.titluc.empcod = wempre.empcod and
                             banfin.titluc.titnat = no            and
                             banfin.titluc.modcod = wmodal.modcod and
                             banfin.titluc.titdtpag =  vdt        and
                                ( if wetbcod = 0
                                  then true
                                  else banfin.titluc.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                  then true
                                  else banfin.titluc.clifor = wclifor ) and
                                       banfin.titluc.titsit = "PAG" and
                                       banfin.titluc.evecod = 9 no-lock:
                                       
                        if banfin.titluc.titbanpag = 0 then next.
                        /* diretores */               
                        disp banfin.titluc.titnum with frame f-proc.
                        pause 0.
                        if vsetcod > 0 
                        then do:
                            if  banfin.titluc.titbanpag > 0 and
                            banfin.titluc.titbanpag <> vsetcod
                            then next.
                            if banfin.titluc.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    if foraut.setcod <> vsetcod 
                                    then next.
                                end.
                                else next.
                            end.
                        end.

                        find first wpag where wpag.wmodcod = 
                                            banfin.titluc.modcod no-error.
                        if not avail wpag
                        then do:
                            create wpag.
                            assign wpag.wcod    = banfin.titluc.clifor
                                   wpag.wmodcod = banfin.titluc.modcod.
                        end.
                        find modal where modal.modcod = banfin.titluc.modcod 
                                                            no-lock no-error.
                        if not avail modal
                        then wpag.wnome = "".
                        else wpag.wnome = modal.modnom.
                        find first wfor where
                               wfor.wcod = banfin.titluc.clifor and
                               wfor.wmodcod = banfin.titluc.modcod
                                no-error.
                        if not avail wfor
                        then do:
                            create wfor.
                            assign
                                wfor.wcod = banfin.titluc.clifor
                                wfor.wmodcod = banfin.titluc.modcod
                                .
                        end.
                        find first wdoc where
                               wdoc.wcod  = banfin.titluc.clifor and
                               wdoc.wmod  = banfin.titluc.modcod and
                               wdoc.wnome = if banfin.titluc.titobs[1] <> ""
                                then banfin.titluc.titobs[1]
                                else  (banfin.titluc.titnum + "/" +
                                           string(banfin.titluc.titpar)) 
                               no-error.
                        if not avail wdoc
                        then do:
                            create wdoc.
                            assign
                            wdoc.wcod = banfin.titluc.clifor 
                            wdoc.wmod = banfin.titluc.modcod
                            wdoc.wnome = if banfin.titluc.titobs[1] <> ""
                                then banfin.titluc.titobs[1]
                                else  (banfin.titluc.titnum + "/" +
                                    string(banfin.titluc.titpar))
                            .
                        end. 

                        assign            
                        wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob
                        wfor.wrec  = wfor.wpag  + banfin.titluc.titvlcob
                        wdoc.wrec  = wdoc.wpag  + banfin.titluc.titvlcob
                        .
                   end.

                end.
                 
                /***
                
                if substring(wmodal.modnom,1,6) = "Filial" 
                then do:
                    for each plani where plani.etbcod = 
                                         int(substring(wmodal.modnom,8,2)) and
                                         plani.movtdc = 5 and
                                         plani.pladat = vdt no-lock:
                        find first wpag where wpag.wmodcod = wmodal.modcod                                                                 no-error.
                        if not avail wpag
                        then do:
                            find modal where modal.modcod = wmodal.modcod 
                                                        no-lock no-error.
                            create wpag.
                            assign wpag.wcod = wclifor
                                   wpag.wnome = wmodal.modnom
                                   wpag.wmodcod = wmodal.modcod.
                        end.
            
                        if plani.crecod = 1
                        then wpag.wven = wpag.wven + 
                                         (plani.platot - plani.vlserv).
                        else wpag.wven = wpag.wven + plani.biss.           
                    end.
                end.
                ***/
                ************************/
                
            end.
        end.
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "100"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" + vtitrel "
            &Tit-Rel   = " vtipo[vindex] + 
                            "" DO PERIODO DE "" +
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
                     wgru.wmodcod = bmodgru.modcod no-error.
                if not avail wgru
                then do:
                    create wgru.
                    assign
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
        /***        
        for each wgru no-lock,
            first modgru where modgru.mogsup = 0 and
                               modgru.modcod = wgru.wmodcod
                               no-lock break by modgru.mognom:

            vperc = ((wgru.wpag / wgru.wven) * 100). 
            if vperc = ? then vperc = 0.
            display wgru.wmodcod
                    wgru.wnome column-label "MODALIDADE"
                    wgru.wcre  
                        format "->>>,>>>,>>>,>>9.99" column-label "Creditos"
                    wgru.wdeb  
                        format "->>>,>>>,>>>,>>9.99" column-label "Debitos"    
                with frame f-pag down width 120.

            down with frame f-pag.
            if vana
            then do:
            /*put fill("-",100) format "x(80)" skip.*/
            for each wpag where 
                     wpag.wmogsup = modgru.mogcod
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                /*vtot  = vtot  + wpag.wpag.*/
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
            /*put fill("=",100) format "x(80)" skip.*/
            end.
            /*else do:
                for each wpag where 
                     wpag.wmogsup = modgru.mogcod
                        break by wpag.wnome:
                    /*vtot  = vtot  + wpag.wpag.*/
                end.
            end.*/
            vtotrec = vtotrec + wgru.wdeb.
            vtot = vtot + wgru.wcre.
        end.
        put fill("=",120) format "x(100)" skip.
        for each wpag where 
                     wpag.wmogsup = 0
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                vtot  = vtot  + wpag.wpag.
                vtotrec = vtotrec + wpag.wrec.
                vven  = vven  + wpag.wven.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod  @ wgru.wmodcod
                    wpag.wnome     @ wgru.wnome
                    wpag.wcre      @ wgru.wcre 
                    wpag.wdeb      @ wgru.wdeb
                    with frame f-pag.
                down with frame f-pag.
                if vpfor
                then
                for each wfor where 
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
         
        ***/
        
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
    for each wgru no-lock,
            first modgru where modgru.mogsup = 0 and
                               modgru.modcod = wgru.wmodcod
                               no-lock break by modgru.mognom:

            vperc = ((wgru.wpag / wgru.wven) * 100). 
            if vperc = ? then vperc = 0.
            display wgru.wmodcod
                    wgru.wnome column-label "MODALIDADE"
                    wgru.wcre  
                        format "->>>,>>>,>>>,>>9.99" column-label "Creditos"
                    wgru.wdeb  
                        format "->>>,>>>,>>>,>>9.99" column-label "Debitos"    
                with frame f-pag down width 120.

            down with frame f-pag.
            if vana
            then do:
            /*put fill("-",100) format "x(80)" skip.*/
            for each wpag where 
                     wpag.wmogsup = modgru.mogcod
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                /*vtot  = vtot  + wpag.wpag.*/
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
            /*put fill("=",100) format "x(80)" skip.*/
            end.
            /*else do:
                for each wpag where 
                     wpag.wmogsup = modgru.mogcod
                        break by wpag.wnome:
                    /*vtot  = vtot  + wpag.wpag.*/
                end.
            end.*/
            vtotrec = vtotrec + wgru.wdeb.
            vtot = vtot + wgru.wcre.
        end.
        put fill("=",120) format "x(100)" skip.
        for each wpag where 
                     wpag.wmogsup = 0
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
                    wpag.wdeb      @ wgru.wdeb
                    with frame f-pag.
                down with frame f-pag.
                if vpfor
                then
                for each wfor where 
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


procedure fin-titudesp:
    for each titudesp where titudesp.empcod = wempre.empcod and
                                      titudesp.titnat =   wtitnat   and
                                      titudesp.modcod = wmodal.modcod and
                                      titudesp.titdtpag =  vdt /*       and
                                ( if wetbcod = 0
                                     then true
                                     else titudesp.etbcod = wetbcod ) and
                                ( if wclifor = 0
                                     then true
                                     else titudesp.clifor = wclifor )*/ and
                                  titudesp.titsit   =   "PAG" no-lock:
                    
                    disp titudesp.titnum with frame f-proc.
                    pause 0.
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
                    find first wpag where wpag.wmodcod = titudesp.modcod 
                                                                    no-error.
                    if not avail wpag
                    then do:
                        create wpag.
                        wpag.wmodcod = titudesp.modcod.
                    end.
                    find fin.modal where modal.modcod = titudesp.modcod 
                                                        no-lock no-error.
                    if not avail modal
                    then wpag.wnome = "".
                    else wpag.wnome = modal.modnom.
                    
                    find first wfor where
                               wfor.wcod = titudesp.clifor and
                               wfor.wmodcod = titudesp.modcod
                                no-error.
                    if not avail wfor
                    then do:
                        create wfor.
                        assign
                            wfor.wcod = titudesp.clifor
                            wfor.wmodcod = titudesp.modcod
                            .
                    end.
                    find first wdoc where
                               wdoc.wcod  = titudesp.clifor and
                               wdoc.wmod  = titudesp.modcod and
                               wdoc.wnome = if titudesp.titobs[1] <> ""
                                then titudesp.titobs[1]
                                else  (titudesp.titnum + "/" +
                                           string(titudesp.titpar)) 
                               no-error.
                    if not avail wdoc
                    then do:
                        create wdoc.
                        assign
                            wdoc.wcod = titudesp.clifor 
                            wdoc.wmod = titudesp.modcod
                            wdoc.wnome = if titudesp.titobs[1] <> ""
                                then titudesp.titobs[1]
                                else  (titudesp.titnum + "/" +
                                    string(titudesp.titpar))
                            .
                    end.           
                    assign            
                    wpag.wcob  = wpag.wcob  + titudesp.titvlcob
                    wpag.wjur  = wpag.wjur  + titudesp.titvljur
                    wpag.wdes  = wpag.wdes  + titudesp.titvldes
                    wpag.wpag  = wpag.wpag  + titudesp.titvlpag
                    wfor.wcob  = wfor.wcob  + titudesp.titvlcob
                    wfor.wjur  = wfor.wjur  + titudesp.titvljur
                    wfor.wdes  = wfor.wdes  + titudesp.titvldes
                    wfor.wpag  = wfor.wpag  + titudesp.titvlpag
                    wdoc.wcob  = wdoc.wcob  + titudesp.titvlcob
                    wdoc.wjur  = wdoc.wjur  + titudesp.titvljur
                    wdoc.wdes  = wdoc.wdes  + titudesp.titvldes
                    wdoc.wpag  = wdoc.wpag  + titudesp.titvlpag.
                    
                end.

end.

