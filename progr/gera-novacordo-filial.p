{admcab.i}

def input parameter p-gera-novacordo as log.
def input parameter p-clicod like clien.clicod.
def output parameter p-ok as log.

def var recid-contrato as recid.
def var i as int.

find clien where clien.clicod = p-clicod no-lock.

def shared temp-table tpb-contrato like contrato
    field exportado1 as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
     .

def shared temp-table tpb-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def new shared temp-table tt-recib
        field rectit as recid
        field titnum like titulo.titnum
        field ordpre as int.
 
def new shared var vtot like titulo.titvlcob.
def new shared var vjuro-ac as dec.
def new shared var vparcela like titulo.titvlcob.
def new shared var vplano as int format "99".

def temp-table wf-tit like fin.titulo.
def new shared temp-table wf-titulo like fin.titulo.
def new shared temp-table wf-contrato like fin.contrato.
def var vokj as log.
def var vgera like contrato.contnum.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var vezes as int format ">9".
def var vdtven like titulo.titdtven init today.
def var ventrada as dec.
def var juro-alt as dec.
def var vjuro-ori as dec.
def var vcond as char format "x(40)"  extent 5.
def var valor_cobrado as dec extent 5.
def var valor_juro    as dec extent 5.
def var valor_novacao as dec extent 5.
def var vdata as date.

def var vtit as char.
def var ljuros as log.
def var vnumdia as int.
def var per_acr as dec.
def var per_des as dec.
def var per_cor as dec.
def var vtitj as dec.
def var vtitvlp as dec.
def var val-origem as dec.
def var vok as log.
def var p4-semjuro as log .
def var lp-ok as log.
def var nov31 as log.
def var vdia as int.
def var vdata-futura as date init today.
def var vv as int.
def var vbanco as int init 1.

    assign
        p4-semjuro = no
        vbanco = 1
        .
    for each tpb-titulo:
        find first tpb-contrato where
                   tpb-contrato.contnum = int(tpb-titulo.titnum)
                and tpb-contrato.exportado = yes   no-error.
        if not avail tpb-contrato
        then delete tpb-titulo.
        else do:
            if (tpb-titulo.etbcod = 100 or
                     tpb-titulo.etbcod = 101) 
                and setbcod = tpb-titulo.etbcod
            then p4-semjuro = yes.
            if tpb-contrato.banco = 10
            then vbanco = 10.
        end.     
    end. 
                                  
    lp-ok = no.
    for each tpb-titulo use-index dt-ven:
        if tpb-titulo.titpar > 50
        then lp-ok = yes.
        if tpb-titulo.titdtven < vdtven
        then vdtven = tpb-titulo.titdtven.
        
    end.
    
    nov31 = no.
    vdia = (today - vdtven).
    vdia = (vdata-futura - vdtven).
    
    if vdia < 31    then do:
        message "-- Cliente com " vdia " de atraso, operacao negada".
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

        for each tpb-titulo use-index dt-ven:     
          
            if vdata-futura > tpb-titulo.titdtven
            then do:
                 ljuros = yes.

                if vdata-futura - tpb-titulo.titdtven = 3
                then do:
                    find dtextra where exdata = vdata-futura - 3 no-error.
                    if weekday(vdata-futura - 3) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.


                if vdata-futura - tpb-titulo.titdtven = 2
                then do:
                    find dtextra where exdata = vdata-futura - 2 no-error.
                    if weekday(vdata-futura - 2) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                else do:
                    if vdata-futura - tpb-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros
                          then 0
                          else vdata-futura - tpb-titulo.titdtven.

                if vnumdia > 1766
                then vnumdia = 1766.

                find first tabjur where 
                        tabjur.nrdias = vnumdia no-lock no-error.
                if  not avail tabjur
                then do:
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                end.
                assign vtot    = vtot    + tpb-titulo.titvlcob
                       vtitvlp = vtitvlp + (tpb-titulo.titvlcob * tabjur.fator). 
        
            end.
            else do:

                do:   
                    vnumdia = tpb-titulo.titdtven - today.
                
                    assign vtot    = vtot    + tpb-titulo.titvlcob.   
                           vtitvlp = vtitvlp + tpb-titulo.titvlcob.
                end.
            end.                    
                    
        end.
        
        if vdia >= 30  and
           vdia <= 270  /*promocao 150*/ and
           lp-ok = no
        then nov31 = yes.
    
        vtitvlp = vtitvlp + (vtitvlp * per_acr).
    
        vtitj = vtitvlp - vtot.
        
        vtitvlp = vtot + vtitj.
    
        
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
    
    val-origem = vtot.
    
    run cal-juro.
    
    
    display  vdtven   label "Maior Atraso" 
             vdia     label "Dias de atraso" 
                with frame f-dias side-label centered
                row 6 color message no-box. 
    pause 0.

    run p-disp-planos.
    
    /***
    display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            "      " 
            vtitj                label "Juro Atraso"
            valor_novacao[1]       at 17 label "Novacao Calculada" 
            "      "
            valor_juro[1]        label "Juro Plano "
            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada"
            "      "  
            valor_juro[2]        label "Juro Plano "
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada"  
            "      "
            valor_juro[3]        label "Juro Plano "
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" 
            "      "
            valor_juro[4]        label "Juro Plano "
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
            "      "
            valor_juro[5]        label "Juro Plano "
                with frame f-plano side-label 
                    centered title " CONDICOES PARA RENEGOCIAÇÃO " width 80
                    row 8. 
    ***/ 
    vjuro-ac = vtitj.
    vjuro-ori = vtitj. 
    
    disp vtitj with frame f-cond.   
    juro-alt = vtitj.     
    repeat :            
        update vtitj label "JURO" with frame f-cond .
        if vtitj = juro-alt
        then leave.

        if setbcod <> 999
        then do:
        if vtitj > vjuro-ori 
        then do:
            bell.
             message "Alteração no valor de juro não permitida." .
             pause.
             next.
        end.
        vokj = yes.
        if vdia >= 31 and
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
         end.
         hide frame f-cond no-pause.
         do vv = 1 to 5:
            valor_juro[vv] = vtitj.
         end.
         juro-alt = vtitj.
         run cal-juro.
         
         run p-disp-planos.
         
         /****
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
                with frame f-plano  .
        *****/
        
    end.
            
    vjuro-ac = vtitj.
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
    end.                    
    
    hide frame f-plano no-pause.
    
    run p-disp-planos.

    /***
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
    ***/
           
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
    
    if p-gera-novacordo
    then do:
        hide frame f-cond no-pause.
        hide frame f-plano no-pause.
        vparcela = vezes.
        run gera-novacordo.p(input p-clicod, 
                             input vplano, 
                             input vcond[vplano],
                             output p-ok). 
        if p-ok
        then do:
            bell.
            message color red/with
            "ACORDO GERADO COM SUCESSO!"
            view-as alert-box.
            leave.
        end.      
    end.
    else do:
        message "Deseja gerar novacao" update sresp.
        if sresp = no
        then next.
    
        if vdata-futura <> today
        then do:
    
            message "Operacao negada, alterar data para HOJE.".
            pause 3 no-message.
            next.

        end.
    
        hide frame fpag99 no-pause.

        do on error undo, retry:
        
            ventrada = vtot / vezes.
            disp ventrada with frame f3.
            do:
                update ventrada label "Entrada"  
                with frame f3 side-label centered.

                if ventrada < (vtot / vezes) - ((vtot / vezes) * .20)
                then do:
                    message "VALOR DE ENTRADA NAO AUTORIZADO".
                    undo, retry.
                end.
            end.
        
            vdata = today + 30.
            do on error undo:
                update vdata label "Vencimento" with frame f3.
                if vdata > today + 40 or
                    vdata < today
                then do:
                    bell.
                    message "DATA DE VENCIMENTO NAO AUTORIZADO.".
                    undo.
                end.
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
    
    
    /***** CRIA TEMP-TABLE PARA PAGAR PRESTACOES ANTIGAS NO FINAL **********/
    
        for each tpb-titulo:     
          

            assign tpb-titulo.titdtpag = today
                   tpb-titulo.etbcobra = setbcod 
                   tpb-titulo.datexp   = today 
                   tpb-titulo.cxmdata  = today 
                   tpb-titulo.cxacod   = scxacod 
                   tpb-titulo.moecod   = "NOV" 
                   tpb-titulo.titsit   = "PAG" 
                   tpb-titulo.titvlpag = tpb-titulo.titvlcob.
               
            create wf-tit.
            {tt-titulo.i wf-tit tpb-titulo}.
    
        end. 

        /********************* GERA TITULOS DE NOVACAO ***********************/
    
        run p-geraclicod.p (input setbcod,
                        output vgera).

        create wf-contrato.

        if setbcod >= 100
        then wf-contrato.contnum =  int("1" + string(setbcod,"999") +
                                          string(vgera,"999999")).
        else wf-contrato.contnum = int(string(string(vgera,"99999999") +
                                   string(setbcod,"99"))).

        assign wf-contrato.clicod    = clien.clicod
           wf-contrato.dtinicial = today 
           wf-contrato.etbcod    = setbcod 
           wf-contrato.datexp    = today 
           wf-contrato.vltotal   = vtot 
           wf-contrato.vlentra   = ventrada
           wf-contrato.banco = vbanco.
    
     
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
               /*wf-titulo.titdtpag = today*/
               wf-titulo.titvlpag = 0 /*ventrada*/
               wf-titulo.titvlcob = ventrada
               wf-titulo.cobcod = 2
               wf-titulo.titsit = /*"PAG"*/ "LIB"
               /*wf-titulo.etbcobra = setbcod*/
               
               wf-titulo.datexp = today
               /*wf-titulo.moecod = "NOV"*/ .

            down with frame f4.
            display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit 
                        column-label "Vl.Cob" with frame f4 down centered
                 title " Pagar Entrada na tela de Caixa ".
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

    
        for each tpb-titulo:
            delete tpb-titulo.
        end.
    
        find first wf-titulo where wf-titulo.titpar = 0 no-error.
        if avail wf-titulo
        then do:
            create tpb-titulo.
            {tt-titulo.i tpb-titulo wf-titulo}.
        end.
    
    
        for each tpb-titulo:
              
            find titulo where titulo.empcod = tpb-titulo.empcod
                          and titulo.titnat = tpb-titulo.titnat
                          and titulo.modcod = tpb-titulo.modcod
                          and titulo.clifor = tpb-titulo.clifor
                          and titulo.etbcod = tpb-titulo.etbcod
                          and titulo.titnum = tpb-titulo.titnum
                          and titulo.titpar = tpb-titulo.titpar no-error.
            if avail titulo
            then do transaction:
                assign titulo.titsit   = tpb-titulo.titsit
                   titulo.titdtpag = tpb-titulo.titdtpag
                   titulo.titvlpag = tpb-titulo.titvlpag
                   titulo.titvlcob = tpb-titulo.titvlcob
                   titulo.titjuro  = tpb-titulo.titjuro
                   titulo.titdesc  = tpb-titulo.titdesc
                   titulo.titvljur = tpb-titulo.titvljur
                   titulo.cxacod   = tpb-titulo.cxacod
                   titulo.cxmdata  = tpb-titulo.cxmdata
                   titulo.etbcobra = tpb-titulo.etbcobra
                   titulo.datexp   = tpb-titulo.datexp
                   titulo.moecod   = tpb-titulo.moecod.
            end.
            else do transaction:
                create titulo.
                assign titulo.empcod   = tpb-titulo.empcod
                   titulo.modcod   = tpb-titulo.modcod
                   titulo.clifor   = tpb-titulo.clifor
                   titulo.titnum   = tpb-titulo.titnum 
                   titulo.titpar   = tpb-titulo.titpar 
                   titulo.titsit   = tpb-titulo.titsit 
                   titulo.titnat   = tpb-titulo.titnat 
                   titulo.etbcod   = tpb-titulo.etbcod 
                   titulo.titdtemi = tpb-titulo.titdtemi 
                   titulo.titdtven = tpb-titulo.titdtven 
                   titulo.titdtpag = today 
                   titulo.titvlcob = tpb-titulo.titvlcob 
                   titulo.cobcod   = tpb-titulo.cobcod 
                   titulo.titvlpag = tpb-titulo.titvlpag 
                   titulo.titvljur = tpb-titulo.titvljur 
                   titulo.etbcobra = tpb-titulo.etbcobra 
                   titulo.titjuro  = tpb-titulo.titjuro 
                   titulo.titdesc  = tpb-titulo.titdesc 
                   titulo.cxacod   = tpb-titulo.cxacod 
                   titulo.cxmdata  = tpb-titulo.cxmdata 
                   titulo.datexp   = tpb-titulo.datexp
                   titulo.moecod   = tpb-titulo.moecod.
            end.

            find first tt-recib where tt-recib.titnum = tpb-titulo.titnum and
                                  tt-recib.ordpre = tpb-titulo.titpar
                            no-error.
            if not avail tt-recib /* and tpb-titulo.titpar <> 0 */
            then do:
                 create tt-recib.
                assign tt-recib.rectit = recid(tpb-titulo)
                    tt-recib.ordpre = tpb-titulo.titpar
                    tt-recib.titnum = tpb-titulo.titnum.
            end.

        end.    
    
        find first tt-recib no-error.
        if avail tt-recib
        then do:
             run valuet(srecibo) (input tt-recib.rectit,
                            input tt-recib.titnum).
        end.

        if nov31
        then run novfil-novacao.p(output recid-contrato).
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
    
            run novdrag-novacao.p(output recid-contrato).

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
            do on error undo:
                create tit_novacao.
                assign
                 tit_novacao.ger_contnum = wf-contrato.contnum
                 tit_novacao.id_acordo = ""
                 tit_novacao.ori_empcod = wf-titulo.empcod
                 tit_novacao.ori_titnat = wf-titulo.titnat
                 tit_novacao.ori_modcod = wf-titulo.modcod
                 tit_novacao.ori_etbcod = wf-titulo.etbcod
                 tit_novacao.ori_clifor = wf-titulo.clifor
                 tit_novacao.ori_titnum = wf-titulo.titnum
                 tit_novacao.ori_titpar = wf-titulo.titpar
                 tit_novacao.ori_titdtemi = wf-titulo.titdtemi
                 tit_novacao.ori_titdtven = wf-titulo.titdtven
                 tit_novacao.dtnovacao = today
                 tit_novacao.hrnovacao = time
                 tit_novacao.etbnovacao = setbcod
                 tit_novacao.funcod = sfuncod       
                 .
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
    
                if wf-contrato.banco = 10
                then run contratoimp-novacao.p(recid-contrato).

                
            end.  
        end.
    
    end. 

procedure p-disp-planos:

    display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            "      " 
            vtitj                label "Juro Atraso"
            valor_novacao[1]       at 17 label "Novacao Calculada" 
            "      "
            valor_juro[1]        label "Juro Plano "
            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada"
            "      "  
            valor_juro[2]        label "Juro Plano "
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada"  
            "      "
            valor_juro[3]        label "Juro Plano "
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" 
            "      "
            valor_juro[4]        label "Juro Plano "
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
            "      "
            valor_juro[5]        label "Juro Plano "
                with frame f-plano side-label 
                    centered title " CONDICOES PARA RENEGOCIAÇÃO " width 80
                    row 8. 
 
end procedure.


procedure cal-juro:
    
    def var vjuro       as dec.
    def var vprincipal  as dec.
    do vv = 1 to 5.
        
        if vv = 1 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[1].    
            valor_juro[vv] = (vprincipal + vjuro) * .05.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 2 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[2].    
            valor_juro[vv] = (vprincipal + vjuro) * .10.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 3 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[3].    
            valor_juro[vv] = (vprincipal + vjuro) * .15.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 4 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[4].    
            valor_juro[vv] = (vprincipal + vjuro) * .35.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 5 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[5].    
            valor_juro[vv] = (vprincipal + vjuro) * .40.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
    end.

end procedure.

