{admcab.i} 

def var vclicod like clien.clicod.

def var vjuro-ori as dec.
def var vcond as char format "x(40)"  extent 5.
def var valor_cobrado as dec extent 5. 
def var valor_juro    as dec extent 5.
def var valor_novacao as dec extent 5.
          
def var  vok as log.
def var vtit as char format "x(30)". 
def var vv as int.
def var per_cor as dec.
def var nov31 as log.
def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.
/*
def buffer bttservidor for ttservidor.
    

input from /usr/admcom/progr/servidor.txt.
    repeat :
        create ttservidor.
        import ttservidor.
    end.
input close.
*/
def var per_acr as dec.
def var per_des as dec.
def var vdia as int.
def var vdesc as dec.
def var vdata like plani.pladat.
def var ventrada like fin.contrato.vlentra.
def var i as int.
def var varq  as char.
def var vtot  like fin.titulo.titvlcob.
def var vtitvlp like fin.titulo.titvlcob.
def var vtitj like fin.titulo.titvlcob.
def var vnumdia as i.
def var ljuros  as l.

def new shared temp-table tp-contrato like fin.contrato
        field exportado as log.
def new shared temp-table tp-titulo like fin.titulo
        index dt-ven titdtven
        index titnum empcod 
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.


def temp-table wf-tit like fin.titulo.
def new shared temp-table wf-titulo like fin.titulo.
def new shared temp-table wf-contrato like fin.contrato.

def var vplano as int format "99".
def var vgera like fin.contrato.contnum.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var vezes as int format ">9".
def var vdtven like fin.titulo.titdtven.
def var vokj as log.
def var lp-ok as log.

repeat:
    
    for each wf-contrato:
        delete wf-contrato.
    end.
    for each tp-contrato:
        delete tp-contrato.
    end.    
    for each tp-titulo:
        delete tp-titulo.
    end.
    
    for each wf-titulo.
        delete wf-titulo.
    end.
    
    for each wf-tit.
        delete wf-tit.
    end.
    
    assign vtot    = 0
           vtitj   = 0
           vtitvlp = 0.

    vdtven = today.
    /* solic 18742 */
    if sretorno matches "*CLICOD*"
    then do.
        vclicod = int(acha("CLICOD",sretorno)).
        display vclicod label "Cliente"
                with frame f1 side-label width 80. 
    end.
    else update vclicod label "Cliente"
            with frame f1 side-label width 80.
    
    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao cadastrado".
        undo, retry.
    end.
    display clien.clinom no-label with frame f1.

    i = 0.
            repeat:
             
                message "Conectando.....D .".
                run conecta_d.p.
                /*
                connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d
                                            no-error.
                */                                                
       
                if not connected ("d")
                then do:
                    if i = 1 
                    then leave.
                    i = i + 1.
                    next.
               end. 
               else leave.
            end.
            run busdra01.p(vclicod).

            disconnect d.
            hide message no-pause.
            pause 2 message "Desconectando......".

    for each fin.titulo use-index iclicod 
    where titulo.clifor = vclicod no-lock:
    
    if titulo.titnat <> no
    then next.
    if titulo.modcod <> "CRE"
    then next.
    find first tp-contrato where 
                tp-contrato.contnum = int(titulo.titnum)
                no-error.
    if not avail tp-contrato
    then do:
        find fin.contrato where
             fin.contrato.contnum = int(fin.titulo.titnum)
             no-lock no-error.
        if avail contrato
        then do:
            create tp-contrato.
            buffer-copy contrato to tp-contrato.
        end.     
    end.            
    create tp-titulo.
    
    assign
        tp-titulo.empcod    = titulo.empcod
        tp-titulo.modcod    = titulo.modcod
        tp-titulo.Clifor    = titulo.clifor
        tp-titulo.titnum    = titulo.titnum
        tp-titulo.titpar    = titulo.titpar
        tp-titulo.titnat    = titulo.titnat
        tp-titulo.etbcod    = titulo.etbcod
        tp-titulo.titdtemi  = titulo.titdtemi
        tp-titulo.titdtven  = titulo.titdtven
        tp-titulo.titvlcob  = titulo.titvlcob
        tp-titulo.titsit    = titulo.titsit.
    end.

    for each tp-titulo:
        if tp-titulo.titsit = "PAG"
        then delete tp-titulo.
    end.

    run sel-contrato.

    if keyfunction(lastkey) = "end-error"
    then leave.

    find first tp-contrato no-error.
    if not avail tp-contrato
    then leave.
    
    for each tp-titulo:
        find first tp-contrato where
                   tp-contrato.contnum = int(tp-titulo.titnum)
               and tp-contrato.exportado = yes    no-error.
        if not avail tp-contrato
        then delete tp-titulo.
    end.  
        

    lp-ok = no.
    for each tp-titulo use-index dt-ven:
        if tp-titulo.titpar > 50
        then lp-ok = yes.
        if tp-titulo.titdtven < vdtven
        then vdtven = tp-titulo.titdtven.
        
    end.
    
    nov31 = no.
    vdia = (today - vdtven).
    
    if vdia < 31 
    then do:
        message "Cliente com " vdia " de atraso, operacao negada".
        pause.
        undo, retry.
    end.

    do vv = 1 to 5:
        
        vok = yes.
        
        assign per_acr = 0  
               per_des = 0  
               per_cor = 0  
               vtot    = 0 
               vtitj   = 0 
               vtitvlp = 0.
        
        vplano = vv.

        for each tp-titulo use-index dt-ven:     
          
            if today > tp-titulo.titdtven
            then do:
                ljuros = yes.
                if today - tp-titulo.titdtven = 2
                then do:
                    find fin.dtextra where exdata = today - 2 NO-LOCK no-error.
                    if weekday(today - 2) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = today - 1 NO-LOCK no-error.
                        if weekday(today - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.    
                end.
                else do:
                    if today - tp-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = today - 1 NO-LOCK no-error.
                        if weekday(today - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros 
                          then 0 
                          else today - tp-titulo.titdtven.
                if vnumdia > 1766
                then vnumdia = 1766.
                
                find first fin.tabjur where tabjur.nrdias = vnumdia
                                  and tabjur.etbcod = 0 no-lock no-error.
                if  not avail tabjur
                then do:
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                end.
                
                assign vtot    = vtot    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + (tp-titulo.titvlcob * tabjur.fator). 
            end.
            else do:

                /*if vdia <= 90 
                then. 
                else*/ do:   
                    vnumdia = tp-titulo.titdtven - today.
                
                    assign vtot    = vtot    + tp-titulo.titvlcob.   
                           vtitvlp = vtitvlp + tp-titulo.titvlcob.
                        
                    /*
                      + (tp-titulo.titvlcob * per_cor)
                      - (tp-titulo.titvlcob * (vnumdia * (per_des / 100))).
                    */
                
                end.
            end.                    
    
        end.
         
        if vdia >= 30  and
           vdia <  270 /*150*/  and
           lp-ok = no
        then nov31 = yes.
    
        vtitvlp = vtitvlp + (vtitvlp * per_acr).
    
        vtitj = vtitvlp - vtot.

/***        vtitvlp = vtot + vtitj.***/
    
        if vv = 1
        then vtit = "[ 1 ]  6  vezes(1+5) ".
        if vv = 2
        then vtit = "[ 2 ]  10 vezes(1+9) ".
        if vv = 3
        then vtit = "[ 3 ]  15 vezes(1+14)".
        if vv = 4
        then vtit = "[ 4 ]  20 vezes(1+19)".
        if vv = 5 
        then vtit = "[ 5 ]  25 vezes(1+24)".

        if vok 
        then assign vcond[vv]         = vtit
                    valor_cobrado[vv] = vtot 
                    valor_juro[vv]    = vtitj  
                    valor_novacao[vv] = vtitvlp.
        else assign vcond[vv]         = vtit + " - NAO DISPONIVEL"   
                    valor_cobrado[vv] = 0
                    valor_juro[vv]    = 0
                    valor_novacao[vv] = 0.
    end.
   
    run cal-juro.
    
    display  vdtven   label "Maior Atraso" 
             vdia     label "Dias de atraso" 
                with frame f-dias side-label centered. 
    pause.
    hide frame f-dias no-pause.
    
    display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            valor_novacao[1]       at 17 label "Novacao Calculada" skip

            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada" skip 
            
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada" skip 
            
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" skip
            
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
                with frame f-plano side-label 
                    centered title " CONDICOES " width 80.
    
    vjuro-ori = vtitj.
    vtitj = valor_juro[1].
    disp vtitj with frame f-cond.        
    repeat:            
        update vtitj label "JURO" with frame f-cond .
        if vtitj = valor_juro[1]
        then leave.
        if vtitj > vjuro-ori
        then do:
            bell.
             message "Alteração no valor de juro não permitida." .
             pause.
             next.
        end.
        vokj = yes.
        if vdia >= 75 and
           vdia <= 360 and
           vtitj < vjuro-ori - (vjuro-ori * .33)
        then  vokj = no.
        else if vdia >= 361 and
                vdia <= 600 and
                vtitj < vjuro-ori - (vjuro-ori * .66)
             then  vokj = no.
               else if vdia > 600 and
                        vtitj < vjuro-ori / 20
                    then vokj = no.
         if vokj = no
         then do:
             bell.
             message "Alteração no valor de juro não permitida." .
             pause.
             next.
         end.
         hide frame f-cond no-pause.
         do vv = 1 to 5:
            if vdia > 600
            then valor_juro[vv] = vtitj * 15.
            else valor_juro[vv] = vtitj.
            
         end.
         run cal-juro.
         display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            valor_novacao[1]       at 17 label "Novacao Calculada" skip

            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada" skip 
            
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada" skip 
            
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" skip
            
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
                with frame f-plano side-label 
                    centered title " CONDICOES " width 80. 
          
    end.
    vplano = 0.
    disp vplano label "Plano" 
            with frame f-cond side-label centered no-box color message.
    /*  solic 18742 */
     if sretorno matches "*CLICOD*" 
     then do . sretorno = "". leave. end.
   
    /******        
    clear frame f-cond all.
    do on error undo, retry:
        vplano = 0.
        update vplano label "Plano" 
            with frame f-cond side-label centered no-box color message.
            
        if vplano = 0 or
           vplano > 5 or
           valor_novacao[vplano] = 0
        then do: 
            message "Plano Invalido".
            undo, retry.
        end.
        display vcond[vplano] no-label with frame f-cond.
        /****
        assign vtot    = valor_cobrado[vplano]
               vtitj   = valor_juro[vplano]
               vtitvlp = valor_novacao[vplano].
        disp vtitj with frame f-cond.
        do on error undo:
            if vdia > 600
            then disp vtitj with frame f-cond.
            else do:
                update vtitj label "JURO" with frame f-cond .
                vokj = yes.
                if vdia >= 75 and
                   vdia <= 360 and
                   vtitj < valor_juro[vplano] - (valor_juro[vplano] * .33)
                then  vokj = no.
                else if vdia >= 361 and
                    vdia <= 600 and
                    vtitj < valor_juro[vplano] - (valor_juro[vplano] * .66)
                    then  vokj = no.
                if vokj = no
                then do:
                    bell.
                    message "Alteração no valor de juro não permitida." .
                    pause.
                    undo.
                end.
            end.
        end.
        assign
            vtitvlp = valor_cobrado[vplano] + vtitj
            valor_juro[vplano]    = vtitj  
            valor_novacao[vplano] = vtitvlp.
        ****/
    end. 
                       
    hide frame f-plano no-pause.
                       
    display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            valor_novacao[1]       at 17 label "Novacao Calculada" skip

            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada" skip 
            
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada" skip 
            
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" skip
            
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
                with frame f-plano.
                
           
    assign vtot    = valor_novacao[vplano]
           vtitj   = valor_juro[vplano]
           vtitvlp = valor_novacao[vplano].
                        
    if vplano = 1 
    then vezes = 6.  
    if vplano = 2  
    then vezes = 10.  
    if vplano = 3  
    then vezes = 15.  
    if vplano = 4  
    then vezes = 20.
    if vplano = 5
    then vezes = 25.
    
    message "Deseja gerar novacao" update sresp.
    if sresp = no
    then next.
    
    hide frame fpag99 no-pause.

    do on error undo, retry:
        
        
        ventrada = vtot / vezes.
        /*
        if nov31
        then ventrada = vtot * 0.22.
        */
        disp ventrada with frame f3.
        
        if vplano <> 4 and vplano <> 5
        then do:
            update ventrada label "Entrada"  
                with frame f3 side-label centered.

            if ventrada < (vtot / vezes) - ((vtot / vezes) * .20)
            then do:
                message "Entrada deve ser maior ou igual a " (vtot / vezes).
                undo, retry.
            end.
        end.
        
        vdata = today + 30.
        
        update vdata label "Vencimento" with frame f3.
        
        do on error undo:
            update vdata label "Vencimento" with frame f3.
            if vdata > today + 40
            then do:
                bell.
                message "DATA DE VENCIMENTO NAO AUTORIZADO.".
                undo.
            end.
        if nov31
        then do:
        
            if vdata > today + 35
            then do:
                message "Vencimento deve ser menor que 35 dias".
                undo, retry.
            end.
        end.
        else do:
        
            if vdata > today + 45
            then do:
                message "Vencimento deve ser menor que 45 dias".
                undo, retry.
            end.
        end.
        end.
        
    end.
    
         
    
    /***** CRIA TEMP-TABLE PARA PAGAR PRESTACOES ANTIGAS NO FINAL **********/
    
    for each tp-titulo:     
          

        /*if vdia <= 90 and 
           today <= tp-titulo.titdtven
        then. 
        else*/ do:
            assign tp-titulo.titdtpag = today
                   tp-titulo.etbcobra = setbcod 
                   tp-titulo.datexp   = today 
                   tp-titulo.cxmdata  = today 
                   tp-titulo.cxacod   = scxacod 
                   tp-titulo.moecod   = "NOV" 
                   tp-titulo.titsit   = "PAG" 
                   tp-titulo.titvlpag = tp-titulo.titvlcob.
            create wf-tit.
            {tt-titulo.i wf-tit tp-titulo}.
        end.
    
    end.   
               
    
         
    /********************* GERA TITULOS DE NOVACAO ***********************/
    
    
    do transaction:
        do for geranum on error undo on endkey undo:
            find geranum where geranum.etbcod = setbcod.
            vgera = geranum.contnum.
            assign geranum.contnum = geranum.contnum + 1.
        end.
    end.
    
    create wf-contrato.
    assign wf-contrato.contnum =
           int(string(string(vgera,"999999") +
                      string(setbcod,">>9"))).

    assign wf-contrato.clicod    = clien.clicod
           wf-contrato.dtinicial = today 
           wf-contrato.etbcod    = setbcod 
           wf-contrato.datexp    = today 
           wf-contrato.vltotal   = vtot 
           wf-contrato.vlentra   = ventrada.
    
     
    /*******************************  ENTRADA *************************/
    do on error undo: 
        create wf-titulo.
        assign wf-titulo.empcod = wempre.empcod
               wf-titulo.modcod = "CRE"
               wf-titulo.cxacod = scxacod
               wf-titulo.cliFOR = clien.clicod
               wf-titulo.titnum = string(wf-contrato.contnum) 
               wf-titulo.titpar = 0
               wf-titulo.titnat = no
               wf-titulo.etbcod = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = today
               wf-titulo.titdtpag = today
               wf-titulo.titvlpag = ventrada
               wf-titulo.titvlcob = ventrada
               wf-titulo.cobcod = 2
               wf-titulo.titsit = "PAG"
               wf-titulo.etbcobra = setbcod
               wf-titulo.datexp = today
               wf-titulo.moecod = "NOV".

        down with frame f4.
        display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit 
                        column-label "Vl.Cob" with frame f4 down centered.
        down with frame f4.
        
    end.
    /******************************************************************/
    
    if nov31
    then wcon = 30.
    else wcon = 50.
    vday = day(vdata).


    vtot = vtot - ventrada.
    
    vmes = month(vdata).
    vano = year(vdata).
    
    if vmes = 1
    then assign vmes = 12
                vano = year(vdata) - 1.
                
    else assign vmes = month(vdata) - 1
                vano = year(vdata).
    
    vdata = date(vmes,day(vdata),vano). 
    
        
    vdata = date(vmes,day(vdata),vano). 

    vano = year(vdata).
    
    do i = 1 to vezes - 1:
                      
    
        assign wcon = wcon + 1
               vmes = vmes + 1.
                 
        if vmes > 12 
        then assign vano = vano + 1
                    vmes = 1.
        
        do on error undo: 
            create wf-titulo.
            assign wf-titulo.empcod = wempre.empcod
                   wf-titulo.modcod = "CRE"
                   wf-titulo.cxacod = scxacod
                   wf-titulo.cliFOR = clien.clicod
                   wf-titulo.titnum = string(wf-contrato.contnum) 
                   wf-titulo.titpar = wcon
                   wf-titulo.titnat = no
                   wf-titulo.etbcod = setbcod
                   wf-titulo.titdtemi = today
                   wf-titulo.titdtven = date(vmes,
                                        IF VMES = 2
                                        THEN IF VDAY > 28
                                             THEN 28
                                             ELSE VDAY
                                        ELSE if VDAY > 30
                                             then 30
                                             else vday,
                                        vano)

                   wf-titulo.titvlcob = vtot / ( vezes - 1)
                   wf-titulo.cobcod = 2
                   wf-titulo.titsit = "LIB"
                   wf-titulo.datexp = today.

        end.
        
        down with frame f4.
        
        display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit
                        column-label "Vl.Cob" with frame f4 down centered.
        
        down with frame f4.
        
    end.

    
    for each tp-titulo:
        delete tp-titulo.
    end.
    
    find first wf-titulo where wf-titulo.titpar = 0 no-error.
    if avail wf-titulo
    then do:
        create tp-titulo.
        {tt-titulo.i tp-titulo wf-titulo}.
    end.
    
    
    for each tp-titulo:
          
        find titulo where titulo.empcod = tp-titulo.empcod
                          and titulo.titnat = tp-titulo.titnat
                          and titulo.modcod = tp-titulo.modcod
                          and titulo.clifor = tp-titulo.clifor
                          and titulo.etbcod = tp-titulo.etbcod
                          and titulo.titnum = tp-titulo.titnum
                          and titulo.titpar = tp-titulo.titpar no-error.
        if avail titulo
        then do transaction:
            assign titulo.titsit   = tp-titulo.titsit
                   titulo.titdtpag = tp-titulo.titdtpag
                   titulo.titvlpag = tp-titulo.titvlpag
                   titulo.titvlcob = tp-titulo.titvlcob
                   titulo.titjuro  = tp-titulo.titjuro
                   titulo.titdesc  = tp-titulo.titdesc
                   titulo.titvljur = tp-titulo.titvljur
                   titulo.cxacod   = tp-titulo.cxacod
                   titulo.cxmdata  = tp-titulo.cxmdata
                   titulo.etbcobra = tp-titulo.etbcobra
                   titulo.datexp   = tp-titulo.datexp
                   titulo.moecod   = tp-titulo.moecod.
        end.
        else do transaction:
            create titulo.
            assign titulo.empcod   = tp-titulo.empcod
                   titulo.modcod   = tp-titulo.modcod
                   titulo.clifor   = tp-titulo.clifor
                   titulo.titnum   = tp-titulo.titnum 
                   titulo.titpar   = tp-titulo.titpar 
                   titulo.titsit   = tp-titulo.titsit 
                   titulo.titnat   = tp-titulo.titnat 
                   titulo.etbcod   = tp-titulo.etbcod 
                   titulo.titdtemi = tp-titulo.titdtemi 
                   titulo.titdtven = tp-titulo.titdtven 
                   titulo.titdtpag = today 
                   titulo.titvlcob = tp-titulo.titvlcob 
                   titulo.cobcod   = tp-titulo.cobcod 
                   titulo.titvlpag = tp-titulo.titvlpag 
                   titulo.titvljur = tp-titulo.titvljur 
                   titulo.etbcobra = tp-titulo.etbcobra 
                   titulo.titjuro  = tp-titulo.titjuro 
                   titulo.titdesc  = tp-titulo.titdesc 
                   titulo.cxacod   = tp-titulo.cxacod 
                   titulo.cxmdata  = tp-titulo.cxmdata 
                   titulo.datexp   = tp-titulo.datexp
                   titulo.moecod   = tp-titulo.moecod.
        end.
    
        
        run value(srecibo) (input recid(tp-titulo),
                            input tp-titulo.titnum).
 
        
    end.    
    

    if nov31
    then run novfil.p.
    else do:
    
        repeat:
        
            message "Conectando.....D .".
            connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d no-error.
        
            if not connected ("d")
            then do:  
                if i = 1  
                then leave.  
                i = i + 1.  
                next.  
            end.   
            else leave.
        
        end.
    
        run novdrag.p.

        disconnect d.
        hide message no-pause.
    
    end.            
    
        

    
    
    /************ PAGAMENTO DE PRESTACOES ANTIGAS *************/
    
    for each wf-tit:
        
        find titulo where titulo.empcod = wf-tit.empcod
                          and titulo.titnat = wf-tit.titnat
                          and titulo.modcod = wf-tit.modcod
                          and titulo.clifor = wf-tit.clifor
                          and titulo.etbcod = wf-tit.etbcod
                          and titulo.titnum = wf-tit.titnum
                          and titulo.titpar = wf-tit.titpar
                                use-index titnum no-error.
        if avail titulo
        then do transaction:
            assign titulo.titsit   = wf-tit.titsit
                   titulo.titdtpag = wf-tit.titdtpag
                   titulo.titvlpag = wf-tit.titvlpag
                   titulo.moecod   = wf-tit.moecod
                   titulo.titvlcob = wf-tit.titvlcob
                   titulo.titjuro  = wf-tit.titjuro
                   titulo.titdesc  = wf-tit.titdesc
                   titulo.titvljur = wf-tit.titvljur
                   titulo.cxacod   = wf-tit.cxacod
                   titulo.cxmdata  = wf-tit.cxmdata
                   titulo.etbcobra = wf-tit.etbcobra
                   titulo.datexp   = wf-tit.datexp.
        end.
        else do transaction:
            create titulo.
            assign titulo.empcod   = wf-tit.empcod
                   titulo.modcod   = wf-tit.modcod
                   titulo.clifor   = wf-tit.clifor
                   titulo.titnum   = wf-tit.titnum 
                   titulo.titpar   = wf-tit.titpar 
                   titulo.titsit   = wf-tit.titsit
                   titulo.moecod   = wf-tit.moecod
                   titulo.titnat   = wf-tit.titnat 
                   titulo.etbcod   = wf-tit.etbcod 
                   titulo.titdtemi = wf-tit.titdtemi 
                   titulo.titdtven = wf-tit.titdtven 
                   titulo.titdtpag = today 
                   titulo.titvlcob = wf-tit.titvlcob 
                   titulo.cobcod   = wf-tit.cobcod 
                   titulo.titvlpag = wf-tit.titvlpag 
                   titulo.titvljur = wf-tit.titvljur 
                   titulo.etbcobra = wf-tit.etbcobra 
                   titulo.titjuro  = wf-tit.titjuro 
                   titulo.titdesc  = wf-tit.titdesc 
                   titulo.cxacod   = wf-tit.cxacod 
                   titulo.cxmdata  = wf-tit.cxmdata 
                   titulo.datexp   = wf-tit.datexp.
        end.
    
    end.    
    
    find first wf-contrato no-error.
    if avail wf-contrato
    then do:
        message "Vc Confirma a Emissao do Controle de Vencimentos ?" 
        update sresp.
        hide message. 
        if sresp 
        then do:
   
            find caixa where caixa.etbcod = setbcod and
                             caixa.cxacod = scxacod no-lock no-error.
            if caixa.moecod = "bar"
            then run carne_n.p.
    
        end.  
    end.
    *******/
end.
    
procedure cal-juro:
    do vv = 1 to 5:
        
        if vdia > 600
        then do:
            valor_juro[vv] = valor_juro[vv] / 15 .
        end.
                             
        valor_novacao[vv] = valor_cobrado[vv] + valor_juro[vv].

        if vv = 2
        then do:
            /***
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .10).
            ***/
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
        if vv = 3
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .15).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
        if vv = 4
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .20).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
        if vv = 5
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .25).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
                      
    end.

end procedure.

procedure sel-contrato:
    {setbrw.i}
    {esqcom.def}
    assign
        esqcom1[1] = "Marca/Desmarca"
        esqcom1[2] = "Confirma"
        .

    def var vmarca as char.
    disp esqcom1 with frame f-esqcom1.
    disp esqcom2 with frame f-esqcom2.     
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ? 
        esqpos1 = 1
        esqpos2 = 1
        esqregua = yes.
        .
    color disp message esqcom1[esqpos1] with frame f-esqcom1.    
    def var vpago as dec.
    def var vpend as dec.

    for each tp-contrato:
        find first tp-titulo where
            tp-titulo.titnum = string(tp-contrato.contnum)
            no-error.
        if avail tp-titulo
        then tp-contrato.exportado = yes.
        else delete tp-contrato.
    end.
    def var vdown as int.
    
    form vmarca no-label format "x"
         tp-contrato.contnum     format ">>>>>>>>9"
         tp-contrato.etbcod      column-label "Fil"
         tp-contrato.vltotal     format ">>>>>,>>9.99"  
                    column-label   "Valor Contrato"
         vpago column-label "Valor Pago"  format ">>>>>,>>9.99"
         vpend column-label "Valor Pendente"  format ">>>>>,>>9.99"
         with frame f-linha screen-lines - 11 down.
    l1: repeat:    
    {sklcls.i
        &file = tp-contrato
        &cfield = tp-contrato.contnum
        &noncharacter = /*
        &ofield = " vmarca
                    tp-contrato.etbcod
                    tp-contrato.vltotal
                    vpago
                    vpend
                  " 
        &aftfnd1 = " if tp-contrato.exportado
                     then vmarca = ""*"".
                     else vmarca = """".
                     vpend = 0.
                     for each tp-titulo where
                        tp-titulo.titnum = string(tp-contrato.contnum)
                        :
                        vpend = vpend + tp-titulo.titvlcob.
                    end.
                    vpago = tp-contrato.vltotal - vpend.
                                       "         
        &where = true
        &naoexiste1 = "
            bell.
            message color red/with
            SKIP ""Nenhum registro encontrado""
            skip
            view-as alert-box
            .
            leave l1. "
        &aftselect1 = " 
                    if keyfunction(lastkey) = ""RETURN""
                    then do:
                        if esqcom1[esqpos1] = ""Marca/Desmarca""
                        then do:
                            if tp-contrato.exportado = yes
                            then    assign
                                tp-contrato.exportado = no
                                vmarca = """".
                            else    assign
                                tp-contrato.exportado = yes
                                vmarca = ""*"".
                            disp vmarca with frame f-linha.
                            next keys-loop. 
                        end.
                        else leave keys-loop.
                    end.
                    "
        &go-on = " TAB CURSOR-RIGHT CURSOR-LEFT "
        &otherkeys = " esqcom1.i "
        &form  = " frame f-linha "
    }         
    if keyfunction(lastkey) = "end-error"
    then leave l1.
    if keyfunction(lastkey) = "TAB"
    then do:
        {esqcom1.i}
        next.
    end.
    if esqcom1[esqpos1] = "Confirma"
    then do:
        find first tp-contrato where 
            tp-contrato.exportado no-error.
        if not avail tp-contrato
        then do:
            bell.
            message color red/with
                skip
                "   NECESSARIO MARCAR CONTRATO   "
                skip
                view-as alert-box.
            next l1.
        end.
        leave l1.
    end.
    end.
end procedure.    
