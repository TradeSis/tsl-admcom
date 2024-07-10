{admcab.i}
{setbrw.i}
{admcom_funcoes.i}
{fpc.i}

def var vcomputacd   as logical initial  no format "sim/Nao".
def var vetccod like produ.etccod     init 0.
def var vcarcod like subcaract.carcod init 0.
def var vsubcod like subcaract.subcod init 0.

def buffer bmovim for movim.
def var vdata-comp as date format "99/99/9999".
def var vcomp-val  like movim.movpc.
def var vcomp-qtd  like movim.movqtm.

def var vint-qtdestgeral as integer.

def buffer zestoq for estoq.
def buffer bestoq for estoq.
def var recatu1 as recid.
def var vforcod like forne.forcod.
def var v-imagem as char.

def var vcomcod     like compr.comcod.

define            variable vmes  as char format "x(05)" extent 13 initial
    ["  JAN","  FEV","  MAR","  ABR","  MAI","  JUN",
     "  JUL","  AGO","  SET","  OUT","  NOV","  DEZ", "TOTAL"].
     
form
    with frame f-comp centered overlay row 19 no-box.

def var vmes2 as char format "x(05)" extent 13.

def var vaux        as int.
def var vano        as int.
def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.
def var vtotcomp    like himov.himqtm extent 13.

def var vqtdped as int.

def var vdias as int format ">>>9" label "Dias de Analise" initial /*90*/ 30.
def var vdata1 as date format "99/99/9999" label "Periodo de Analise".

def var vdiasori as int.

vdata1 = today - /*90*/ 30.
def var vdata2 as date format "99/99/9999".
vdata2 = today.

def var vcobertura as int format ">>>>9" label "Cobertura".

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def temp-table tt-clase-inf
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def buffer cestab for estab.

def var vestdep like estoq.estatual.
def var vprocod like produ.procod.
def var vclacod like clase.clacod.
def var vqtd    like movim.movqtm.
def var vqtdest like movim.movqtm.
def var totven  like movim.movqtm.
def var totpcven like movim.movpc.
def var vmargem like movim.movpc.
def var vdata   like plani.pladat.
def var totper  like estoq.estatual.
def var totdis  like estoq.estatual.
def var totdisest like estoq.estatual.
def var ii as int. 
def var i as int.

def new shared temp-table tt-pro
    field procod  like produ.procod
    field pronom  like produ.pronom
    field fabcod  like fabri.fabcod
    field fabnom  like fabri.fabnom
    field estdep  like vestdep
    field totven  like totven

    field totpcven  like totpcven
    
    field cober     as   int
    field cober-dep-loj as int
    field pcvenda like estoq.estvenda
    field pccusto like estoq.estcusto

    field totpccusto like totpcven
    
    field qtdest  as int
    field qtdped  as int
    
    /**field pcped   like liped.lippreco**/
    
    field comp-val like movim.movpc
    field comp-qtd like movim.movqtm
    field estgeral like estoq.estatual
    
    index icober cober asc
    index icober-dep-loj cober-dep-loj asc 
    index ipronom pronom
    index iprocod procod
    index ifabnom fabnom
    index iqven totven desc
    index ipven /*pcvenda*/ totpcven desc
    index iedep estdep desc
    index ieloj qtdest desc
    index iqped qtdped desc.
    

def var vt-totven     like totven         format ">,>>>,>>9".
def var vt-totpcven   like totpcven       format ">,>>>,>>9".
def var vt-margem     like totpcven       format ">,>>>,>>9".
def var vt-pccusto    like estoq.estcusto format ">,>>>,>>9".
def var vt-qtdest-lj  as   int            format "->>>>,>>9".
def var vt-qtdest-dep as   int            format "->>>>,>>9".

def var vt-cobertura  as   int            format "->>>>,>>9".
def var vt-qtdped     as   int            format "->>>>,>>9".
def var vt-pcped      like totpcven       format ">,>>>,>>9".
def var vt-pvped      like totpcven       format ">,>>>,>>9".

def var vt-comp-val   like totpcven       format ">,>>>,>>9".
def var vt-comp-qtd   as   int            format "->>>>,>>9".

def var vt-pcvenda    as decimal          format "->>>,>>>,>>9".
def var vt-pccusto2   as decimal          format "->>>,>>>,>>9".

def var vordenar as int.
def var vfiltro as int.
def var vfiltrar as char extent 2 format "x(16)"
/*        init["1. Cobert. Dep." ,"2. Cobert. Total"].*/
          init["1. Cobert. Total" , "2. Cobert. Dep."].

def var vordem as char extent 10  format "x(22)"
                init["1. Cobertura Deposito ",
                     "2. Cobertura Total    ",
                     "3. Codigo Produto     ",
                     "4. Descricao Produto  ",
                     "5. Fabricante         ",
                     "6. Total Venda (Qtd)  ",  /*"7. Preco Venda        ",*/
                     
                     "7. Total Venda (Valor)",
                     "8. Estoque Deposito   ",
                     "9. Estoque Loja       ",
                     "A. Quantidade Pedido  "].

form
    tt-pro.procod                label "Codigo" format ">>>>>9"
    tt-pro.pronom format "x(12)" label "Produto"
    /**tt-pro.fabnom format "x(15)" label "Fabricante"**/
    tt-pro.totven                column-label "Q.Ven"   format ">>>>9"
    /*tt-pro.pcvenda*/
    tt-pro.totpcven   column-label /*"P.Ven"*/ "T.Ven"  format ">>>>>>9"

    tt-pro.totpccusto column-label             "T.Cus"  format "->>>>>9"

    vmargem column-label "Margem" format "->>>>>9"
    
    /*tt-pro.pccusto               column-label "P.Cus" format ">,>>9"*/

    tt-pro.estdep                column-label "E.Dep" format "->>>9"
    tt-pro.cober                 column-label "Cober" format "->>>9"
    tt-pro.qtdest                column-label "E.Loj" format "->>>9"
    tt-pro.cober-dep-loj         column-label "Cob.T" format "->>>9"
    tt-pro.qtdped                column-label "Q.Ped" format ">>>>9"
    with frame frame-a row 10 6 down overlay no-box width 81.
    
form
    estoq.etbcod                 column-label "Estab"
    tt-pro.procod                column-label "Codigo" format ">>>>>9"
    tt-pro.pronom                column-label "Produto"
    estoq.estatual               column-label "Estoq!Atual" format "->>>>9"   
    with frame f-est.
    
def var totpccusto like totpcven. 
def var vcla-cod like clase.clacod.

repeat:
                  
    assign vqtd    = 0 vprocod = 0 vclacod = 0 
           totven  = 0 recatu1 = ? totpcven = 0 totpccusto = 0.
           
    for each tt-pro:
        delete tt-pro.  
    end.
    for each tt-clase.
        delete tt-clase.
    end.

    hide frame f-linha1 no-pause.
    hide frame f-comp no-pause.    

    update /*vfabcod*/ vforcod
           at 2 label "Fabricante" with frame f1 side-label width 80.

    if /*vfabcod*/ vforcod <> 0
    then do:
        find forne where forne.forcod = vforcod no-lock.
        
        find fabri where fabri.fabcod = forne.forcod no-lock.
        display fabri.fabnom format "x(19)" no-label with frame f1.
    end.
    else disp "Todos" @ fabri.fabnom format "x(19)" with frame f1.

    update vcla-cod label "Classe" with frame f1.
    vclacod = vcla-cod.
    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(20)" no-label with frame f1.
    end.
    else disp "Todas" @ clase.clanom with frame f1.
    
    /* antonio Sol 26328 */
    do on error undo:
            update vetccod at 3 with frame f1.
            if vetccod <> 0
            then do:
                find first estac where estac.etccod = vetccod no-lock no-error.
                if not avail estac 
                then do:
                    message "Estacao Inexistente"   view-as alert-box.
                    undo, retry.
                end.
                else disp estac.etcnom no-label with frame f1.
            end.  
            else disp "Todas" @ estac.etcnom with frame f1.  
            update vcarcod label "Caracteristica" at 3
                    with frame f1.
            if vcarcod <> 0
            then do:
                find first caract 
                            where caract.carcod = vcarcod no-lock no-error.
                if not avail caract
                then do:
                     message "Caracteristica Inexistente" VIEW-AS ALERT-BOX.
                     undo, retry.
                end.
            end.
            scopias = vcarcod.
            update vsubcod label "Sub-Caracteristica"
                        with frame f1.
            if vsubcod <> 0
            then do:
                    find first subcarac where subcarac.subcod = vsubcod
                    no-lock no-error.
                    if not avail subcaract
                    then do:
                            message "Sub-Caracteristica Inexistente"
                                VIEW-AS ALERT-BOX.
                            undo, retry.
                    end.
                    disp subcaract.subdes no-label with frame f1.
            end.  
            else disp "Todas" @ subcaract.subdes with frame f1.  
            scopias = 0.
    end.
    
    /**/    
    assign vcobertura = 99999
           vdata1     = today - 30
           vdata2     = today.
    
    update vcobertura at 3  
           /*vdias to 50*/ space(3)
           vdata1                  " a "
           vdata2 no-label
           with frame f1.

    update vcomcod at 3 label "Comprador" format ">>>9"
                   with frame f1.

    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                   
    if avail compr then display compr.comnom format "x(27)" no-label
                               with frame f1.
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                                with frame f1.
    else do:
         message "Comprador não encontrado!" view-as alert-box.
         undo, retry.
    end.
     
    message "Processa Estoque Disponivel no Deposito, Somente CD 900 ?"
        update vcomputacd.
    
    vdias = 0.
    vdias = vdata2 - vdata1.

    vdiasori = vdias.

    disp "(" + string(vdias) + " Dias)" no-label format "x(12)" with frame f1.
    for each tt-clase: delete tt-clase. end.    

    
    disp vfiltrar[1]    format "x(16)"
         vfiltrar[2]    format "x(16)"
         with frame f-fil 1 down  title "Filtrar por"
         centered color with/black no-label overlay. 
    
    choose field vfiltrar auto-return with frame f-fil.
    
    vfiltro = frame-index.
    vordenar = frame-index.

    assign vordenar = 7.
    
    hide frame f-fil no-pause.
    
    if vclacod <> 0
    then do:
        find first clase where clase.clasup = vclacod no-lock no-error. 
        if avail clase 
        then do:
            message "Montando Tabela Temporaria de Classes...".
            pause 2 no-message.
            run cria-tt-clase. 
            hide message no-pause.
        end. 
        else do:
            find clase where clase.clacod = vclacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao Cadastrada".
                undo.
            end.

            create tt-clase.
            assign tt-clase.clacod = clase.clacod
                   tt-clase.clanom = clase.clanom.
        end.
    end.
    
    if vforcod <> 0
    then do:
        run Pi-Ger-Paifilho(input vforcod).

        for each tt-forpaifi,
        
            each produ use-index iprofab
                       where produ.fabcod = tt-forpaifi.forcod no-lock:
            
            vdias = vdiasori.       
                             
            if vcomcod > 0
            then do:
                release liped.
                release pedid.
                find last liped where liped.procod = produ.procod
                                  and liped.pedtdc = 1
                                      no-lock use-index liped2 no-error.

                find first pedid of liped no-lock no-error.
        
                if (avail pedid and pedid.comcod <> vcomcod)
                    or not avail pedid
                then next.
                    
            end.
                    
            disp produ.procod format ">>>>>>>>>9" no-label 
                    produ.pronom no-label
                    with frame fdidp
                    centered side-labels 1 down width 68. pause 0.

            if vclacod <> 0
            then do:
                find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                if not avail tt-clase
                then next.
            end.
                 
            /* Estacao */
            if vetccod  <> 0
            then
                if produ.etccod <> vetccod then next.

            /* Caracterirstica - leitura antiga 
            if vcarcod <> 0
            then do:
                find first procaract 
                  where procaract.procod = produ.procod no-lock no-error.
                    if avail procaract                       
                    then do:
                        find first subcaract where
                                subcaract.subcar = procaract.subcod
                                    no-lock no-error.
                        if not avail subcaract then next.            
                        if subcaract.carcod <> vcarcod then next.
                    end.
            end.********************/
            /* Caracterirstica */
            def var vnext as log.
            if vcarcod <> 0
            then do:
                vnext = yes.
                for each procaract where procaract.procod = produ.procod 
                                                    no-lock. 
                        find first subcaract where
                                subcaract.subcar = procaract.subcod
                                    no-lock no-error.
                        if not avail subcaract then next.            
                        if subcaract.carcod = vcarcod then vnext = no.
                end.
                if vnext then next.
            end.
            /* Sub-caracteristica */
            if vsubcod <> 0
            then do:
                find first subcaract where
                        subcaract.subcar = vsubcod
                                no-lock no-error.
                if not avail subcaract then next.
                find procaract where procaract.procod  = produ.procod and
                                  procaract.subcod  = vsubcod
                            no-lock no-error.                
                if not avail procaract then next.
            end.     
            /***/
       
            assign vestdep = 0.
            for each estoq where (estoq.etbcod >= 980 or
                      {conv_igualb.i estoq.etbcod} ) and
                       estoq.procod = produ.procod no-lock:

                /* Marcio - Solicitou Somente CD */
                if (estoq.etbcod = 900 or estoq.etbcod = 993) 
                   and vcomputacd = yes
                then vestdep = vestdep + estoq.estatual.
                else if vcomputacd = no then vestdep = vestdep + estoq.estatual.
                /**/
            end.                           

            totven = 0.                       
            do vdata = vdata1 to vdata2:
                for each movim where movim.procod = produ.procod     and
                                         movim.movtdc = 5           and
                                         movim.movdat = vdata no-lock:
                    
                    find zestoq where zestoq.etbcod = movim.etbcod
                                  and zestoq.procod = movim.procod
                                  no-lock no-error.

                    assign totven = totven + movim.movqtm
                           totpccusto = totpccusto +
                                (movim.movqtm * zestoq.estcusto).
                           /*     
                           totpcven = totpcven + (movim.movqtm * movim.movpc).
                           */
                    totpcven = totpcven + venda-liquida-item(recid(movim)).
                end.
            end.                                               
            
            find first movim use-index datsai
                             where movim.procod = produ.procod and
                                   movim.movtdc = 5 no-lock no-error.
            if avail movim
            then
                if movim.movdat > vdata1
                then vdias = (vdata2 - movim.movdat).

            if vfiltro = 2 
            then
                if int((vestdep * vdias) / totven) > vcobertura
                then next. 
                            
            vqtdest = 0.
            for each cestab where cestab.etbcod < 980 and
                                   {conv_difer.i cestab.etbcod} and
                                  cestab.etbcod <> 22  and
                                  cestab.etbcod <> 991
                                  no-lock:
                                  
                for each estoq where estoq.etbcod = cestab.etbcod  and
                                     estoq.procod = produ.procod no-lock:
                    if estoq.etbcod = 991 then next.
                    
                    vqtdest = vqtdest + estoq.estatual.
                end.
            end.
            
            if vfiltro = 1
            then if int(((vestdep + vqtdest) * vdias) / totven) > vcobertura
                 then next.

            vqtdped = 0.
            do vdata = today - 180 to today:
                for each liped where liped.pedtdc = 1
                                 and liped.procod = produ.procod
                                 and liped.predt  = vdata no-lock:
                    find pedid of liped no-lock no-error.             
                    /*
                    if (today - pedid.peddtf) > 90
                    then next.    
                    */
                    if pedid.sitped = "F" then next.
                    
                    vqtdped = vqtdped + (liped.lipqtd - liped.lipent).
                end.
            end.                 

            if vqtdped <= 0 and
               totven <= 0  and
               vestdep <= 0  
            then do:
                find last movim where movim.procod = produ.procod 
                            no-lock no-error.
                if avail movim and movim.movdat > today - 30
                then.
                else next.
            end.
               
            if vqtdped  < 0
            then vqtdped = 0.   

            /*** ini compras ***/
            
            assign vcomp-val = 0 vcomp-qtd = 0.
            
            find last movim where movim.movtdc = 4 
                              and movim.procod = produ.procod no-lock no-error.
            if avail movim 
            then do:                
                assign vcomp-val = 0 vcomp-qtd = 0.
                
                do vdata-comp = vdata1 to vdata2:
                
                    for each bmovim where bmovim.procod = produ.procod 
                                      and bmovim.movtdc = 4 
                                      and bmovim.datexp = vdata-comp no-lock: 
                        
                        assign 
                          vcomp-val = vcomp-val + (bmovim.movqtm * bmovim.movpc)
                          vcomp-qtd = vcomp-qtd + bmovim.movqtm.
                    end.
                end.
            end.
            
            /*** fin compras ***/
            
            find tt-pro where tt-pro.procod = produ.procod no-error.
            if not avail tt-pro
            then do:
            
                assign vint-qtdestgeral = 0.
                for each estoq where estoq.procod = produ.procod
                                 and estoq.estatual > 0 no-lock:
                    vint-qtdestgeral = vint-qtdestgeral + estoq.estatual.
                end.
                                                
                find first estoq of produ no-lock.
                
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                
                create tt-pro.
                assign tt-pro.procod = produ.procod
                       tt-pro.pronom = produ.pronom
                       tt-pro.fabcod = produ.fabcod
                       tt-pro.fabnom = if avail fabri
                                       then fabri.fabnom
                                       else "Nao Cadastrado"
                       tt-pro.estdep = vestdep
                       tt-pro.totven = totven
                       tt-pro.totpcven = totpcven
                       tt-pro.cober    = int((vestdep * vdias) / totven)
                       tt-pro.pcvenda = estoq.estvenda
                       tt-pro.pccusto = estoq.estcusto
                       tt-pro.totpccusto = totpccusto
                       tt-pro.qtdest  = vqtdest
                       tt-pro.qtdped  = vqtdped
                       tt-pro.cober-dep-loj = 
                        int(((vestdep + vqtdest) * vdias) / totven)
                       tt-pro.comp-val = vcomp-val
                       tt-pro.comp-qtd = vcomp-qtd
                       tt-pro.estgeral = vint-qtdestgeral.
            end.
            assign vestdep   = 0 totven    = 0 totpcven   = 0
                   vqtdest   = 0 vqtdped   = 0 totpccusto = 0
                   vcomp-val = 0 vcomp-qtd = 0.
        end.         
    end.
    else do:
        
        for each produ no-lock:
                 
            if vcomcod > 0
            then do:
                release liped.
                release pedid.
                find last liped where liped.procod = produ.procod
                                  and liped.pedtdc = 1
                                      no-lock use-index liped2 no-error.

                find first pedid of liped no-lock no-error.
        
                if (avail pedid and pedid.comcod <> vcomcod)
                    or not avail pedid
                then next.
            end.

            vdias = vdiasori.       
            disp produ.procod no-label produ.pronom no-label
                    with centered side-labels 1 down. pause 0.
            if vclacod <> 0
            then do:
                find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                if not avail tt-clase
                then next.
            end.

            /* Estacao */
            if vetccod  <> 0
            then
                if produ.etccod <> vetccod then next.


            /* Caracterirstica - leitura era assim
            if vcarcod <> 0
            then do:
                find first procaract 
                  where procaract.procod = produ.procod no-lock no-error.
                    if avail procaract                       
                    then do:
                        find first subcaract where
                                subcaract.subcar = procaract.subcod
                                    no-lock no-error.
                        if not avail subcaract then next.            
                        if subcaract.carcod <> vcarcod then next.
                    end.
            end.*****************************/
            
            /* Caracterirstica */
            if vcarcod <> 0
            then do:
                vnext = yes.
                for each procaract where procaract.procod = produ.procod 
                                                    no-lock. 
                        find first subcaract where
                                subcaract.subcar = procaract.subcod
                                    no-lock no-error.
                        if not avail subcaract then next.            
                        if subcaract.carcod = vcarcod then vnext = no.
                end.
                if vnext then next.
            end.

            /* Sub-caracteristica */
            if vsubcod <> 0
            then do:
                find first subcaract where
                        subcaract.subcar = vsubcod
                                no-lock no-error.
                if not avail subcaract then next.
                find procaract where procaract.procod  = produ.procod and
                                  procaract.subcod  = vsubcod
                            no-lock no-error.
                if not avail procaract then next.
            end.     
            /***/

            vestdep = 0.
            for each estoq where (estoq.etbcod >= 980 or
                                  estoq.etbcod = 900 or
                                  {conv_igual.i estoq.etbcod}) and
                                 estoq.procod = produ.procod no-lock:

                /* Marcio - Solicitou Somente CD */
                if (estoq.etbcod = 900 or estoq.etbcod = 993) 
                   and vcomputacd = yes
                then vestdep = vestdep + estoq.estatual.
                else 
                if vcomputacd = no then vestdep = vestdep + estoq.estatual.
                /**/
            end.                           

            totven = 0.                       
            do vdata = vdata1 to vdata2:
                for each movim where movim.procod = produ.procod     and
                                         movim.movtdc = 05           and
                                         movim.movdat = vdata no-lock:
                    find zestoq where zestoq.etbcod = movim.etbcod
                                  and zestoq.procod = movim.procod
                                  no-lock no-error.

                    assign
                     /* totpcven = totpcven + (movim.movqtm * movim.movpc) */
                           totpccusto = totpccusto +
                                (movim.movqtm * zestoq.estcusto)
                          
                           totven   = totven + movim.movqtm.
                    totpcven = totpcven + venda-liquida-item(recid(movim)).                     end.
            end.                                               
            
            find first movim use-index datsai
                             where movim.procod = produ.procod and
                                   movim.movtdc = 5 no-lock no-error.
            if avail movim
            then
                if movim.movdat > vdata1
                then vdias = (vdata2 - movim.movdat).

            if vfiltro = 2
            then if int((vestdep * vdias) / totven) > vcobertura
                 then next. 

            vqtdest = 0.
            for each cestab where cestab.etbcod < 980 and
                                  {conv_difer.i cestab.etbcod} and
                                  cestab.etbcod <> 22 and
                                  cestab.etbcod <> 900 and
                                  cestab.etbcod <> 991                   
                                   no-lock:
                                  
                for each estoq where estoq.etbcod = cestab.etbcod  and
                                     estoq.procod = produ.procod no-lock:
                
                    if estoq.etbcod = 991 then next.
                    vqtdest = vqtdest + estoq.estatual.  
                end.
            end.      

            if vfiltro = 1
            then if int(((vestdep + vqtdest) * vdias) / totven) > vcobertura
                 then next.
           
            vqtdped = 0.        
            do vdata = today - 180 to today:
                for each liped where liped.pedtdc = 1
                                 and liped.procod = produ.procod
                                 and liped.predt  = vdata no-lock:
                    find pedid of liped no-lock  no-error.             
                    /*
                    if (today - pedid.peddtf) > 90
                    then next.    
                    */
                    if pedid.sitped = "F" then next.
                    
                    vqtdped = vqtdped + (liped.lipqtd - liped.lipent).

                end.
            end.
            
            /*
            if vqtdped <= 0 and
               totven <= 0 
            then next.   
            */

            if vqtdped <= 0 and
               totven <= 0  and
               vestdep <= 0  
            then do:
                find last movim where movim.procod = produ.procod 
                            no-lock no-error.
                if avail movim and movim.movdat > today - 30 
                then.
                else next.   
            end.

            if vqtdped  < 0
            then vqtdped = 0.   

            /*** ini compras ***/
            
            assign vcomp-val = 0 vcomp-qtd = 0.
            
            find last movim where movim.movtdc = 4 
                              and movim.procod = produ.procod no-lock no-error.
            if avail movim 
            then do:
                
                assign vcomp-val = 0 vcomp-qtd = 0.

                do vdata-comp = vdata1 to vdata2:
                
                    for each bmovim where bmovim.procod = produ.procod 
                                      and bmovim.movtdc = 4 
                                      and bmovim.datexp = vdata-comp no-lock: 
                        
                        assign 
                          vcomp-val = vcomp-val + (bmovim.movqtm * bmovim.movpc)
                          vcomp-qtd = vcomp-qtd + bmovim.movqtm.
                        
                    end.
                end.
            end.
            
            /*** fin compras ***/

            find tt-pro where tt-pro.procod = produ.procod no-error.
            if not avail tt-pro
            then do:
            
                assign vint-qtdestgeral = 0.
                           
                for each estoq where estoq.procod = produ.procod
                                 and estoq.estatual > 0 no-lock:
                                                 
                    assign vint-qtdestgeral = vint-qtdestgeral + estoq.estatual.

                end.
            
                find first estoq of produ no-lock.
                
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                
                create tt-pro.
                assign tt-pro.procod = produ.procod
                       tt-pro.pronom = produ.pronom
                       tt-pro.fabcod = produ.fabcod
                       tt-pro.fabnom = if avail fabri
                                       then fabri.fabnom
                                       else "Nao Cadastrado"
                       tt-pro.estdep = vestdep
                       tt-pro.totven = totven
                       tt-pro.totpcven = totpcven
                       tt-pro.cober    = 
                           int((vestdep * vdias) / totven)
                       tt-pro.pcvenda = estoq.estvenda
                       tt-pro.pccusto = estoq.estcusto
                       tt-pro.totpccusto = totpccusto
                       tt-pro.qtdest  = vqtdest
                       tt-pro.qtdped  = vqtdped
                       tt-pro.cober-dep-loj =
                        int(((vestdep + vqtdest) * vdias) / totven)
                       tt-pro.comp-val = vcomp-val 
                       tt-pro.comp-qtd = vcomp-qtd
                       tt-pro.estgeral = vint-qtdestgeral.
                        
            end. 
            assign vestdep = 0 totven = 0 vqtdest = 0
                   vqtdped = 0 totpcven = 0 totpccusto = 0
                   vcomp-val = 0 vcomp-qtd = 0.
        end.
    end.


find first tt-pro no-lock no-error.
if not avail tt-pro
then do:
    message "Nao foram encontrados produtos nesta situacao".
    undo.
end.

assign vt-cobertura  = 0
       vt-qtdped     = 0
       vt-totven     = 0
       vt-totpcven   = 0
       vt-pccusto    = 0
       vt-qtdest-lj  = 0
       vt-qtdest-dep = 0
       vt-pcped      = 0
       vt-pvped      = 0
       vt-comp-val   = 0
       vt-comp-qtd   = 0
       vt-pccusto2   = 0
       vt-pcvenda    = 0.
       

for each tt-pro:
    
    if tt-pro.cober = ?
    then tt-pro.cober = 0.
    
    if tt-pro.qtdped = ?
    then tt-pro.qtdped = 0.
    
    if tt-pro.cober-dep-loj = ?
    then tt-pro.cober-dep-loj = 0.
    
    assign vt-totven     = vt-totven     + tt-pro.totven
           vt-totpcven   = vt-totpcven   + tt-pro.totpcven
           vt-pccusto    = vt-pccusto    + tt-pro.totpccusto
           vt-qtdest-lj  = vt-qtdest-lj  + tt-pro.qtdest
           vt-qtdest-dep = vt-qtdest-dep + tt-pro.estdep
           vt-cobertura  = vt-cobertura  + tt-pro.cober
           vt-qtdped     = vt-qtdped     + tt-pro.qtdped
           vt-pcped      = vt-pcped      + (tt-pro.qtdped * tt-pro.pccusto)
           vt-pvped      = vt-pvped      + (tt-pro.qtdped * tt-pro.pcvenda)
           vt-comp-val   = vt-comp-val   + tt-pro.comp-val
           vt-comp-qtd   = vt-comp-qtd   + tt-pro.comp-qtd
           vt-pcvenda    = vt-pcvenda    + (tt-pro.estgeral * tt-pro.pcvenda)
           vt-pccusto2   = vt-pccusto2   + (tt-pro.estgeral * tt-pro.pccusto).
    

end.


def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 6
    initial ["Ordenar por ",
             " Estoque ",
             " Pedidos ",
             " Notas ",
             " Imagem ",
             " Extrato "].
def var esqcom2         as char format "x(12)" extent 6
            initial [" Relatorio "," Preco"," Verba","",""].
def var esqhel1         as char format "x(80)" extent 6
    initial ["  ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 6
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer btt-pro       for tt-pro.
def var vtt-pro         like tt-pro.procod.


form
    esqcom1
    with frame f-com1
                 row 9 no-box no-labels side-labels column 1 centered.
                 
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        if vordenar = 1
        then find tt-pro use-index icober where 
                                   recid(tt-pro) = recatu1 no-lock.
        else 
        if vordenar = 2
        then find tt-pro use-index icober-dep-loj where 
                                   recid(tt-pro) = recatu1 no-lock.

        else                           
        if vordenar = 3
        then find tt-pro use-index iprocod where 
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 4
        then find tt-pro use-index ipronom where
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 5
        then find tt-pro use-index ifabnom where
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 6
        then find tt-pro use-index iqven where
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 7
        then find tt-pro use-index ipven where
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 8
        then find tt-pro use-index iedep where
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 9
        then find tt-pro use-index ieloj where
                                   recid(tt-pro) = recatu1 no-lock.
        else
        if vordenar = 10
        then find tt-pro use-index iqped where
                                   recid(tt-pro) = recatu1 no-lock.
    
    
    if not available tt-pro
    then esqvazio = yes.           
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-pro).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-pro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            if vordenar = 1
            then find tt-pro use-index icober where
                                       recid(tt-pro) = recatu1 no-lock.
            else 
            if vordenar = 2 
            then find tt-pro use-index icober-dep-loj where 
                                       recid(tt-pro) = recatu1 no-lock.
            else                           
            if vordenar = 3
            then find tt-pro use-index iprocod where 
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 4
            then find tt-pro use-index ipronom where
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 5
            then find tt-pro use-index ifabnom where
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 6
            then find tt-pro use-index iqven where
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 7
            then find tt-pro use-index ipven where
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 8
            then find tt-pro use-index iedep where
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 9
            then find tt-pro use-index ieloj where
                                       recid(tt-pro) = recatu1 no-lock.
            else
            if vordenar = 10
            then find tt-pro use-index iqped where
                                       recid(tt-pro) = recatu1 no-lock.
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-pro.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-pro.procod)
                                        else "".
            run compras.
            run color-message.
            choose field tt-pro.procod 
                help "[T] Totais "
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up t T
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            
            if keyfunction(lastkey) = "T" or
               keyfunction(lastkey) = "t"
            then do:
                DO ON ERROR UNDO,LEAVE ON ENDKEY UNDO, retry:
                    pause 0.
                    vt-margem = 0.
                    vt-margem = (vt-totpcven - vt-pccusto).
                    
                    disp skip(1) space(2)
                         vt-totpcven   label "TOTAL DO VALOR DE VENDA........"
                         space(2) skip space(2)
                         vt-pccusto    label "TOTAL DO VALOR DE CUSTO........"
                         space(2) skip space(2)
                         vt-margem     label "MARGEM........................."
                         space(2) skip space(2)
                         vt-totven     label "TOTAL DE PECAS VENDIDAS........"
                         space(2) skip space(2)
                         vt-qtdest-lj  label "TOTAL DO ESTOQUE LOJA.........."
                         space(2) skip space(2)
                         vt-qtdest-dep label "TOTAL DO ESTOQUE DEPOSITO......"
                         space(2) skip space(2)
                       /*vt-cobertura  label "TOTAL COBERTURA................"*/
                       /* Antonio Sol 26328 */ 
                         vt-totven / (vt-qtdest-dep + vt-qtdest-lj)    
                                       label "TOTAL COBERTURA................"
                         space(2) skip space(2)
                         vt-pcvenda    label "VALOR DE VENDA DO ESTOQUE TOTAL"
                         skip space(2)
                         
                         vt-pccusto2    label "VALOR DE CUSTO DO ESTOQUE TOTAL"
                         skip space(2)
                         (vt-pcvenda - vt-pccusto2) format "->>>,>>>,>>9"
                                       label "MARGEM ESTOQUE................."
                         skip space(2)
                      /* vt-qtdped     label "PECAS PEDIDOS PENDENTES........"*/
                         space(2) skip space(2)
                         vt-pvped      label "VALOR DE VENDA DOS PEDIDOS....."
                         space(2) skip space(2)
                         vt-pcped      label "VALOR DE CUSTO DOS PEDIDOS....."
                         space(2) skip space(2)
                         (vt-pvped - vt-pcped) format "->>>,>>>,>>9"
                                        label "MARGEM DOS PEDIDOS............."                        /* vt-comp-qtd   label "TOTAL PECAS COMPRADAS....." */
                         space(2) skip space(2)
                      /* vt-comp-val   label "TOTAL VALOR COMPRADO......" */
                         skip(1)
                         with frame f-tt centered side-labels title " Totais "
                                         overlay row 6 /*10*/.
                                         
                END.

            end.
            
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 6 then 6 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pro
                then next.
                color display white/blue tt-pro.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pro      
                then next.
                color display white/blue tt-pro.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-pro
                 with frame f-tt-pro color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Estoque "
                then do with frame f-tt-pro on error undo.

                   run procest9.p(input string(tt-pro.procod), input vdias).
                   
                end.
                
                if esqcom1[esqpos1] = "Ordenar por "
                then do with frame f-tt-pro on error undo.
                    view frame frame-a. pause 0.
                    disp  vordem[1] skip   
                          vordem[2] skip 
                          vordem[3] skip
                          vordem[4] skip 
                          vordem[5] skip
                          vordem[6] skip 
                          vordem[7] skip
                          vordem[8] skip 
                          vordem[9] skip
                          vordem[10] 
                          with frame f-esc title "Ordenar por"
                             centered color with/black no-label overlay. 
    
                    choose field vordem auto-return with frame f-esc.
                    vordenar = frame-index.

                    clear frame f-esc no-pause.
                    hide frame f-esc no-pause.
                    
                    recatu1 = ?.
                    next bl-princ.
                 
                end.
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pro.
                    disp tt-pro.
                end.

                if esqcom1[esqpos1] = " Pedidos "
                then do with frame f-tt-pro on error undo.
    
                    if tt-pro.qtdped <> 0
                    then do:
                        /*Nede 11-01-2012 */
                        hide frame fdidp no-pause.
                        disp tt-pro.procod tt-pro.pronom
                        with frame fdidp1 side-labels no-labels centered.

                        hide frame f-comp no-pause.
                        run coberped.p (input tt-pro.procod).
                    end.
                    
                end.
                
                if esqcom1[esqpos1] = " Notas "
                then do with frame f-tt-pro on error undo.

                     hide frame f-comp no-pause.
                     run cobernf.p (input tt-pro.procod).

                end.

                if esqcom1[esqpos1] = " Extrato "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame f-comp  no-pause.

                    run extcob9.p( input tt-pro.procod,
                                   input vdata1,
                                   input vdata2 ).

                    view frame f1.
                    view frame f-com1.
                    view frame f-com2.
                                   
                end.
                
                if esqcom1[esqpos1] = " Imagem "
                then do with frame f-tt-pro on error undo.
                      /*     
                     if opsys = "UNIX"
                     then v-imagem = "/admcom/pro_im/" +
                                trim(string(tt-pro.procod)) +
                                ".jpg".

                     else*/ 

                     v-imagem = "l:~\pro_im~\" + 
                                trim(string(tt-pro.procod)) +
                                ".jpg".
                                
                     os-command silent start value(v-imagem).
                        
                end.


            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Relatorio "
                then do:
                    run lcobert9.p.
                end.
                if esqcom2[esqpos2] = " Preco"
                then do:
                    run promo-verba.p (input "preco", tt-pro.procod).
                end.
                if esqcom2[esqpos2] = " Verba"
                then do:
                    run promo-verba.p (input "verba", tt-pro.procod).
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-pro).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

end.

procedure frame-a.
vmargem = 0.
vmargem = (tt-pro.totpcven - tt-pro.totpccusto).

display 
    tt-pro.procod
    tt-pro.pronom
    /**tt-pro.fabnom**/
    tt-pro.totven
    /*tt-pro.pcvenda*/ tt-pro.totpcven
    tt-pro.totpccusto
    vmargem
    tt-pro.estdep
    tt-pro.cober
    /*tt-pro.pccusto*/
    tt-pro.qtdest
    tt-pro.cober-dep-loj
    tt-pro.qtdped
        with frame frame-a .
hide message no-pause.        
end procedure.

procedure color-message.

vmargem = 0.
vmargem = (tt-pro.totpcven - tt-pro.totpccusto).

color display message
      tt-pro.procod
      tt-pro.pronom
      /**tt-pro.fabnom**/
      tt-pro.totven
      /*tt-pro.pcvenda*/ tt-pro.totpcven
      tt-pro.totpccusto
      vmargem
      tt-pro.estdep
      tt-pro.cober
/*      tt-pro.pccusto */
      tt-pro.qtdest
      tt-pro.cober-dep-loj
      tt-pro.qtdped
        with frame frame-a.
message tt-pro.pronom " P.Venda: R$ " tt-pro.pcvenda " P.Custo: R$ " tt-pro.pccusto "Fabri: " tt-pro.fabnom.

end procedure.
procedure color-normal.

vmargem = 0.
vmargem = (tt-pro.totpcven - tt-pro.totpccusto).

color display normal
        tt-pro.procod
        tt-pro.pronom
        /**tt-pro.fabnom**/
        tt-pro.totven
        /*tt-pro.pcvenda*/ tt-pro.totpcven
        tt-pro.totpccusto
        vmargem
        tt-pro.estdep
        tt-pro.cober
  /*      tt-pro.pccusto*/
        tt-pro.qtdest
        tt-pro.cober-dep-loj
        tt-pro.qtdped
        with frame frame-a.
hide message no-pause.        
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  do:
    if esqascend  
    then do:
        if vordenar = 1
        then 
            find first tt-pro use-index icober where true no-lock no-error.
        else 
        if vordenar = 2
        then
            find first tt-pro use-index icober-dep-loj where true
                                                       no-lock no-error.
        
        else                           
        if vordenar = 3
        then find first tt-pro use-index iprocod where true no-lock no-error.
        else
        if vordenar = 4
        then find first tt-pro use-index ipronom where true no-lock no-error.
        else
        if vordenar = 5
        then find first tt-pro use-index ifabnom where true no-lock no-error.
        else
        if vordenar = 6
        then find first tt-pro use-index iqven where true no-lock no-error.
        else
        if vordenar = 7
        then find first tt-pro use-index ipven where true no-lock no-error.
        else
        if vordenar = 8
        then find first tt-pro use-index iedep where true no-lock no-error.
        else
        if vordenar = 9
        then find first tt-pro use-index ieloj where true no-lock no-error.
        else
        if vordenar = 10

        then find first tt-pro use-index iqped where true no-lock no-error.
                                                       
    end.                                                       
    else do:
        if vordenar = 1
        then 
            find last tt-pro use-index icober where true no-lock no-error.
        else
        if vordenar = 2
        then
            find last tt-pro use-index icober-dep-loj where true
                                                      no-lock no-error.
                                                      
        else                           
        if vordenar = 3
        then find last tt-pro use-index iprocod where true no-lock no-error.
        else
        if vordenar = 4
        then find last tt-pro use-index ipronom where true no-lock no-error.
        else
        if vordenar = 5
        then find last tt-pro use-index ifabnom where true no-lock no-error.
        else
        if vordenar = 6
        then find last tt-pro use-index iqven where true no-lock no-error.
        else
        if vordenar = 7
        then find last tt-pro use-index ipven where true no-lock no-error.
        else
        if vordenar = 8
        then find last tt-pro use-index iedep where true no-lock no-error.
        else
        if vordenar = 9
        then find last tt-pro use-index ieloj where true no-lock no-error.
        else
        if vordenar = 10
        then find last tt-pro use-index iqped where true no-lock no-error.
                                                       
                                                      
    end.
end.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  do:
    if esqascend  
    then do:
        if vordenar = 1
        then find next tt-pro use-index icober where true no-lock no-error.
        else
        if vordenar = 2
        then find next tt-pro use-index icober-dep-loj where true
                                                       no-lock no-error.
        else                           
        if vordenar = 3
        then find next tt-pro use-index iprocod where true no-lock no-error.
        else
        if vordenar = 4
        then find next tt-pro use-index ipronom where true no-lock no-error.
        else
        if vordenar = 5
        then find next tt-pro use-index ifabnom where true no-lock no-error.
        else
        if vordenar = 6
        then find next tt-pro use-index iqven where true no-lock no-error.
        else
        if vordenar = 7
        then find next tt-pro use-index ipven where true no-lock no-error.
        else
        if vordenar = 8
        then find next tt-pro use-index iedep where true no-lock no-error.
        else
        if vordenar = 9
        then find next tt-pro use-index ieloj where true no-lock no-error.
        else
        if vordenar = 10
        then find next tt-pro use-index iqped where true no-lock no-error.
  
    
    end.                                                
    else do:  
        if vordenar = 1
        then find prev tt-pro use-index icober where true no-lock no-error.
        else
        if vordenar = 2
        then find prev tt-pro use-index icober-dep-loj where true
                                                       no-lock no-error.
                                                       
        else                           
        if vordenar = 3
        then find prev tt-pro use-index iprocod where true no-lock no-error.
        else
        if vordenar = 4
        then find prev tt-pro use-index ipronom where true no-lock no-error.
        else
        if vordenar = 5
        then find prev tt-pro use-index ifabnom where true no-lock no-error.
        else
        if vordenar = 6
        then find prev tt-pro use-index iqven where true no-lock no-error.
        else
        if vordenar = 7
        then find prev tt-pro use-index ipven where true no-lock no-error.
        else
        if vordenar = 8
        then find prev tt-pro use-index iedep where true no-lock no-error.
        else
        if vordenar = 9
        then find prev tt-pro use-index ieloj where true no-lock no-error.
        else
        if vordenar = 10
        then find prev tt-pro use-index iqped where true no-lock no-error.
                                                        
                                                       
    end.                                                
end.
             
             
if par-tipo = "up" 
then do:                 
    if esqascend   
    then do:
        if vordenar = 1
        then find prev tt-pro use-index  icober where true no-lock no-error.
        else
        if vordenar = 2
        then find prev tt-pro use-index icober-dep-loj where true
                                                       no-lock no-error.
                                                       
        else                           
        if vordenar = 3
        then find prev tt-pro use-index iprocod where true no-lock no-error.
        else
        if vordenar = 4
        then find prev tt-pro use-index ipronom where true no-lock no-error.
        else
        if vordenar = 5
        then find prev tt-pro use-index ifabnom where true no-lock no-error.
        else
        if vordenar = 6
        then find prev tt-pro use-index iqven where true no-lock no-error.
        else
        if vordenar = 7
        then find prev tt-pro use-index ipven where true no-lock no-error.
        else
        if vordenar = 8
        then find prev tt-pro use-index iedep where true no-lock no-error.
        else
        if vordenar = 9
        then find prev tt-pro use-index ieloj where true no-lock no-error.
        else
        if vordenar = 10
        then find prev tt-pro use-index iqped where true no-lock no-error.
 
                                                       
    end.                                        
    else do:
        if vordenar = 1
        then find next tt-pro use-index icober where true no-lock no-error.
        else
        if vordenar = 2
        then find next tt-pro use-index icober-dep-loj where true
                                                       no-lock no-error. 
                                                       
        else                           
        if vordenar = 3
        then find next tt-pro use-index iprocod where true no-lock no-error.
        else
        if vordenar = 4
        then find next tt-pro use-index ipronom where true no-lock no-error.
        else
        if vordenar = 5
        then find next tt-pro use-index ifabnom where true no-lock no-error.
        else
        if vordenar = 6
        then find next tt-pro use-index iqven where true no-lock no-error.
        else
        if vordenar = 7
        then find next tt-pro use-index ipven where true no-lock no-error.
        else
        if vordenar = 8
        then find next tt-pro use-index iedep where true no-lock no-error.
        else
        if vordenar = 9
        then find next tt-pro use-index ieloj where true no-lock no-error.
        else
        if vordenar = 10
        then find next tt-pro use-index iqped where true no-lock no-error.
                                                        
                                                       
    end.                                        
end.
        
end procedure.
         
procedure compras.

    vaux = 0. vano = 0. i = 0.
    vaux    = month(today).
    vano    = year(today).
    vaux = vaux + 1.
    do i = 1 to 12:
        vaux = vaux - 1.
        if vaux = 0
        then do:
            vmes2[i] = "DEZ".
            vaux = 12.
            vano = vano - 1.
        end.
        vmes2[i] = vmes[vaux].
        vnummes[i] = vaux.
        vnumano[i] = vano.
    end.
    vmes2[13] = "TOTAL".       
    disp
        vmes2[1] no-label space(1)
        vmes2[2] no-label space(1)
        vmes2[3] no-label space(1)
        vmes2[4] no-label space(1)
        vmes2[5] no-label space(1)
        vmes2[6] no-label space(1)
        vmes2[7] no-label space(1)
        vmes2[8] no-label space(1)
        vmes2[9] no-label space(1)
        vmes2[10] no-label space(1)
        vmes2[11] no-label space(1)
        vmes2[12] no-label space(1) 
        vmes2[13] no-label space(1)
        with frame f-comp
        /*title     " C O M P R A  M E S E S  A N T E R I O R E S "*/.

    for each produ where produ.procod = tt-pro.procod no-lock:
    vtotcomp[13] = 0.
    do i = 1 to 12: 
        vtotcomp[i] = 0.
    
        for each estab where estab.etbcod >= 993 or
                             estab.etbcod = 900 no-lock:
            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]  and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.
            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            vtotcomp[13] = vtotcomp[13] + himov.himqtm.
        end.
        
        find estab where estab.etbcod = 22 no-lock. 
        find himov where     himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 6            and
                             himov.himmes = vnummes[i]  and
                             himov.himano = vnumano[i] no-lock no-error.
        if not avail himov
        then next.
        vtotcomp[i] = vtotcomp[i] + himov.himqtm.
        vtotcomp[13] = vtotcomp[13] + himov.himqtm.
        

    end.

    disp
        vtotcomp[1] format ">>>>9" no-label
        vtotcomp[2] format ">>>>9" no-label
        vtotcomp[3] format ">>>>9" no-label
        vtotcomp[4] format ">>>>9" no-label
        vtotcomp[5] format ">>>>9" no-label
        vtotcomp[6] format ">>>>9" no-label
        vtotcomp[7] format ">>>>9" no-label
        vtotcomp[8] format ">>>>9"  no-label
        vtotcomp[9] format ">>>>9"  no-label
        vtotcomp[10] format ">>>>9" no-label
        vtotcomp[11] format ">>>>9" no-label
        vtotcomp[12] format ">>>>9" no-label 
        vtotcomp[13] format ">>>>9" no-label with frame f-comp.
   
   
   
   end.
   /*do on endkey undo.
       if keyfunction(lastkey) = "end-error"
       then do:
            hide frame f-comp no-pause.
            next.
       end.
       pause.
       hide frame f-comp no-pause.
       next .
   end.
     */
end procedure.


procedure cria-tt-clase.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-clase where tt-clase.clacod = gclase.clacod 
                                                        no-error.
                             if not avail tt-clase
                             then do:
                             
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.
