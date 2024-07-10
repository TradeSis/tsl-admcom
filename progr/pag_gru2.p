/*----------------------------------------------------------------------------*/
/* finan/pag_gru2.p                                         Agenda - Listagem */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
{result.i}

def var vfornom like forne.fornom.
def var /* input parameter */ vesc as log init yes.
def var varquivo as char format "x(20)".
def var vv as char.
def var vtot like fin.titulo.titvlcob.
def buffer bmodgru for modgru.
def var vperc as dec.

define input parameter vdti as date.
def input parameter vdtf as date.

def temp-table wpag
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wmogsup like modgru.mogsup
    field wdes  like fin.titulo.titvlcob
    field wjur  like fin.titulo.titvlcob
    field wcob  like fin.titulo.titvlcob
    field wpag  like fin.titulo.titvlcob
    field wven  like fin.titulo.titvlcob.

def temp-table wgru
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
    field wmodcod like fin.titulo.modcod
    field wdes  like fin.titulo.titvlcob
    field wjur  like fin.titulo.titvlcob
    field wcob  like fin.titulo.titvlcob
    field wpag  like fin.titulo.titvlcob
    field wven  like fin.titulo.titvlcob.

def temp-table wfor
    field wcod like fin.titulo.clifor
    field wnome like forne.fornom
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
def var vven as dec.
form with frame f-pag.
def var vpfor as log format "Sim/Nao".
def var vana as log format "Sim/Nao".
/*
repeat with column 50 side-labels 1 down width 31 row 4 frame f1:
 */
    assign 
           vana = yes  
           vpfor = yes
           wetbcod = 0
           wmodcod = ""
           wtitnat = yes
           wclifor = 0.
           
    /*
    assign wdti = date(month(date(month(today),1,year(today)) - 1)
                   ,1,
                   year(date(month(today),1,year(today)) - 1)) 
           wdtf = date(month(today),1,year(today)) - 1.
    */
    assign
        wdti = vdti
        wdtf = vdtf
        .   


   find first tt-result
               where tt-result.dt = vdti  no-error.
    if not avail tt-result
    then do:
         create tt-result.
         tt-result.dtresult = vdti.
    end.             
    assign tt-result.irpj = 0
           tt-result.imposto  = 0
           tt-result.encargos = 0.

/*
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
    repeat:
****/        
       for each wpag:
            delete wpag.
       end.
       for each wfor:
        delete wfor.
       end. 
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
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        update wdti
               wdtf with frame fdat.
   ****/               
        for each wmodal:
            delete wmodal.
        end.
  
        if wmodcod = ""
        then do:

            for each fin.modal where fin.modal.modcod <> "DEV"
                                 and fin.modal.modcod <> "BON"
                                 and fin.modal.modcod <> "CHP" no-lock:

                if fin.modal.modcod = "DUP" THEN NEXT.
                                 
                create wmodal.
                assign wmodal.modcod = fin.modal.modcod
                       wmodal.modnom = fin.modal.modnom.
            end.
            vlog = yes.
         /*
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
            */
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
  /*
        vana = no.
        message "Relatorio Analitico?" update vana.
        vpfor = no.
        if vana = yes
        then do:
            message "Por Fornecedor ? " update vpfor.
        end.
        {confir.i 1 "impressao de Agenda Financeira"}
        */
        
        vtitrel = if wtitnat
                  then "PAGAR"
                  else "RECEBER" .
        if wclifor = 0
        then vv = "GERAL".
        else vv = "forne.fornom".
        if opsys = "UNIX"
        then varquivo = "../relat/pag4-" + string(time).
        else varquivo = "l:\relat\pag4-" + string(time).
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
                                  fin.titulo.titsit   =   "PAG" no-lock:

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
                    assign            
                    wpag.wcob  = wpag.wcob  + fin.titulo.titvlcob
                    wpag.wjur  = wpag.wjur  + fin.titulo.titvljur
                    wpag.wdes  = wpag.wdes  + fin.titulo.titvldes
                    wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag
                    wfor.wcob  = wfor.wcob  + fin.titulo.titvlcob
                    wfor.wjur  = wfor.wjur  + fin.titulo.titvljur
                    wfor.wdes  = wfor.wdes  + fin.titulo.titvldes
                    wfor.wpag  = wfor.wpag  + fin.titulo.titvlpag
                    .
                    if wpag.wpag = ?
                    then wpag.wpag = 0.
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
                        
                        assign            
                        wpag.wcob  = wpag.wcob  + banfin.titulo.titvlcob
                        wpag.wjur  = wpag.wjur  + banfin.titulo.titvljur
                        wpag.wdes  = wpag.wdes  + banfin.titulo.titvldes
                        wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag
                        wfor.wcob  = wfor.wcob  + banfin.titulo.titvlcob
                        wfor.wjur  = wfor.wjur  + banfin.titulo.titvljur
                        wfor.wdes  = wfor.wdes  + banfin.titulo.titvldes
                        wfor.wpag  = wfor.wpag  + banfin.titulo.titvlpag
                        .
                        if wpag.wpag = ?
                        then wpag.wpag = 0.
                        
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
            end.
        end.
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
                    wgru.wven = wgru.wven + wpag.wven
                    .
                wpag.wmogsup = bmodgru.mogcod.
            end.
        end.
        vtot = 0. vven = 0.
        for each wgru no-lock,
            first modgru where modgru.mogsup = 0 and
                               modgru.modcod = wgru.wmodcod
                               no-lock break by modgru.mognom:

            vperc = ((wgru.wpag / wgru.wven) * 100). 
            if vperc = ? then vperc = 0.
            display wgru.wmodcod
                    wgru.wnome column-label "MODALIDADE"
                    wgru.wpag 
                        format "->>>,>>>,>>>,>>9.99" column-label "Vl.Pago"
                        with frame f-pag down width 100.
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
                    wpag.wpag      @ wgru.wpag 
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
                    then vfornom = string(forne.forcod) + "    " + forne.fornom.
                    else vfornom = "    " + string(wfor.wcod).            
                    display vfornom  @ wgru.wnome
                        wfor.wpag      @ wgru.wpag 
                        with frame f-pag .
                    down with frame f-pag.

                   if wfor.wcod = 100077 or /* COFINS CFS */
                      wfor.wcod = 110351 or /* DEP JUDICIAL DJP */
                      wfor.wcod = 103523 or /* ICMS DIVERSOS ICD */
                      wfor.wcod = 100074 or /* ICMS MES ICM */
                      wfor.wcod = 100079    /* PIS */
                   then tt-result.imposto = tt-result.imposto + wfor.wpag.
                   
                   if wfor.wcod = 536 or /* CONTRIBUICAO S  COS */
                      wfor.wcod = 100186 /* IRPJ */
                   then tt-result.irpj = tt-result.irpj + wfor.wpag.
                   

                end.
            end.
            /*put fill("=",100) format "x(80)" skip.*/
            end.
            else do:
                for each wpag where 
                     wpag.wmogsup = modgru.mogcod
                        break by wpag.wnome:
                    /*vtot  = vtot  + wpag.wpag.*/
                end.
            end.

            if wgru.wpag <> ?
            then assign vtot = vtot + wgru.wpag.
            
        end.
        put fill("=",100) format "x(80)" skip.
        for each wpag where 
                     wpag.wmogsup = 0
                        break by wpag.wnome:
                vacum = vacum + wpag.wpag.
                
                if wpag.wpag <> ?
                then assign vtot  = vtot  + wpag.wpag.
                
                vven  = vven  + wpag.wven.
                vperc = (wpag.wpag / wpag.wven) * 100.
                if vperc = ? then vperc = 0.
                display wpag.wmodcod  @ wgru.wmodcod
                    wpag.wnome     @ wgru.wnome
                    wpag.wpag      @ wgru.wpag 
                    with frame f-pag.
                down with frame f-pag.
                if vpfor
                then
                for each wfor where 
                     wfor.wmodcod = wpag.wmodcod
                        no-lock:
                    find forne where 
                        forne.forcod = wfor.wcod no-lock .       
                    display forne.fornom  @ wgru.wnome
                        wfor.wpag      @ wgru.wpag 
                        with frame f-pag .
                    down with frame f-pag.
                end.

        end.
        down(1) with frame f-pag.
        disp "Total Geral" @ wgru.wnome
                vtot @ wgru.wpag
                with frame f-pag.

        assign tt-result.encargos = vtot.
 

        output close.
        
 /*****  
   DISP TT-RESULT WITH 3 COL.
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
       {mrod.i} .
       end.
 ***/    
  /*  end.
end.
*****/



