/*
connect ninja -H db2 -S sdrebninja -N tcp.
*/

{admcab.i}

def var vetb-cod like estab.etbcod.
def var vcli-for like clien.clicod.
def var vtotal as dec.

def var vtipo as char.
def var data-ori as date.
def var data-des as date.
def var valor-tr as dec format ">>>,>>>,>>9.99".
def var valor-ux as dec format ">>>,>>>,>>9.99".
def var valor-tb as dec format ">>>,>>>,>>9.99".
def var valor-tb1 as dec format ">>>,>>>,>>9.99".

def var vest as dec.
def var vrec1 as dec.
def var vrec2 as dec.

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def var v-finestemi as dec.
def var v-finestacr as dec.
def var v-reneg as dec.
def var v-devol as dec.
def var v-estorno as dec.
def var v-recnovacao as dec.
def var vacrescimo as dec.
def var vemiacre as dec.
def var v-emicanfin as dec.
def var v-recestfin as dec.

def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var vetbcod like estab.etbcod.
def var vmoecod like fin.moeda.moecod.
 
def buffer sc2015 for TSC2017.

def var valor-jr as dec.
def var total-jr as dec.
def var total-jr1 as dec.
def var vatu as log format "Sim/Nao".
repeat:
vatu = no.
update data-ori Label "Origem"
       data-des label "Destino"
       valor-tr label "Valor Pago" format ">>,>>>,>>9.99"
       valor-jr label "Juro" format ">>>,>>9.99"
       vmoecod  label "Moeda"
       vatu     label "Atu"
       with frame f-dt down
       title " transfere recebimentos "
       .

def buffer barqclien for arqclien.
def buffer ctitulo for fin.titulo.

def buffer btabdac17 for tabdac17.

def var vclifor like fin.titulo.clifor.
def var vtitnum like fin.titulo.titnum.
def var vtitdtpag like fin.titulo.titdtpag.
def var vtitpar like fin.titulo.titpar.
def buffer btitulo for fin.titulo.

valor-ux = 0.
total-jr = 0.
total-jr1 = 0.

for each estab where estab.etbcod < 200 
            or estab.etbcod = 996 no-lock:
    disp "Processando... " estab.etbcod valor-tr valor-ux
                                    total-jr1
    with frame f-dd 1 down no-box no-label
    row 15 centere color message overlay.
    pause 0.
    
    if valor-ux < valor-tr and
       valor-tr - valor-ux > 2
    then do:
        valor-tb = 0.
        
        for each tabdac17 where
                 tabdac17.etblan = estab.etbcod and
                 tabdac17.datlan = data-ori and
                 tabdac17.tiplan   = "RECEBIMENTO" and
                 tabdac17.sitlan = "LEBES"
                 no-lock:
            vclifor = tabdac17.clicod.
            vtitnum = tabdac17.numlan.
            vtitdtpag   = tabdac17.datlan.
            vtitpar = 0.
        
            if tabdac17.datemi <= data-des
            then.
            else next.

            if vmoecod <> "CAR"
            then do:
            find first titpag where
                 titpag.empcod   = 19 and
                 titpag.titnat   = no   and
                 titpag.modcod   = "CRE" and
                 titpag.etbcod   = tabdac17.etbcod and
                 titpag.clifor   = vclifor and
                 titpag.titnum   = vtitnum and
                 titpag.titpar   = tabdac17.parlan and
                 titpag.moecod = vmoecod           
                 no-lock no-error.
            if not avail titpag 
            then next. /*****do:
                 find first titulosal where
                    titulosal.empcod   = 19 and
                    titulosal.titnat   = no   and
                    titulosal.modcod   = "CRE" and
                    titulosal.etbcod   = tabdac17.etbcod and
                    titulosal.clifor   = vclifor and
                    titulosal.titnum   = vtitnum and
                    titulosal.titpar   = tabdac17.parlan and
                    titulosal.moecod = vmoecod 
                     no-lock no-error.
                if not avail titulosal
                then do:
                    find first sc2015 where
                            sc2015.empcod   = 19 and
                            sc2015.titnat   = no   and
                            sc2015.modcod   = "CRE" and
                            sc2015.etbcod   = tabdac17.etbcod and
                            sc2015.clifor   = vclifor and
                            sc2015.titnum   = vtitnum and
                            sc2015.titpar   = tabdac17.parlan /*and
                            sc2015.moecod = vmoecod
                            no-lock*/ no-error.
                    if not avail sc2015
                    then do:
                        create sc2015.
                        assign
                            sc2015.empcod = 19 
                            sc2015.titnat = no 
                            sc2015.modcod = "CRE" 
                            sc2015.etbcod = tabdac17.etbcod 
                            sc2015.clifor = vclifor
                            sc2015.titnum = vtitnum 
                            sc2015.titpar = tabdac17.parlan
                            sc2015.titvlcob = tabdac17.vallan
                            sc2015.titdtemi = tabdac17.datemi
                            sc2015.titdtven = tabdac17.datven
                            sc2015.titdtpag = tabdac17.datpag
                            sc2015.titsit   = "PAG"
                            sc2015.titvlpag = tabdac17.vallan
                            sc2015.etbcobra = tabdac17.etbpag
                            sc2015.moecod = vmoecod
                            .
                    end.
                    else if sc2015.moecod  = ""
                    then sc2015.moecod = vmoecod.
                    find first sc2015 where
                        sc2015.empcod   = 19 and
                        sc2015.titnat   = no   and
                        sc2015.modcod   = "CRE" and
                        sc2015.etbcod   = tabdac17.etbcod and
                        sc2015.clifor   = vclifor and
                        sc2015.titnum   = vtitnum and
                        sc2015.titpar   > tabdac17.parlan  and
                        sc2015.titdtpag > data-ori and
                        sc2015.titdtpag <= data-des and
                        sc2015.moecod = vmoecod 
                        no-lock no-error.
                    if avail sc2015 then next.
                end.    
                else 
                find first titulosal where
                 titulosal.empcod   = 19 and
                 titulosal.titnat   = no   and
                 titulosal.modcod   = "CRE" and
                 titulosal.etbcod   = tabdac17.etbcod and
                 titulosal.clifor   = vclifor and
                 titulosal.titnum   = vtitnum and
                 titulosal.titpar   > tabdac17.parlan  and
                 titulosal.titdtpag > data-ori and
                 titulosal.titdtpag <= data-des and
                 titulosal.moecod = vmoecod 
                 no-lock no-error.
                if avail titulosal then next.
                
                valor-tb = valor-tb + tabdac17.vallan.
 
            end. *************/
            else do:
           
                find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   > tabdac17.parlan  and
                 titulo.titdtpag > data-ori and
                 titulo.titdtpag <= data-des 
                 no-lock no-error.
                 if avail titulo then next.

                 find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = tabdac17.parlan
                 no-lock no-error.
                 if not avail titulo then next.
                 
                 /*
                disp titpag.titvlpag 
                titulo.titvlpag
                titulo.titvlcob
                tabdac17.vallan.
                pause.
                */
                if titulo.titvlcob <> tabdac17.vallan
                then next.
                if titulo.titjuro > 0 and 
                    total-jr + titulo.titjuro <= valor-jr
                then.
                else if titulo.titjuro = 0 and valor-jr = 0
                    then.
                    else next.
                total-jr = total-jr + titulo.titjuro.
                valor-tb = valor-tb + tabdac17.vallan.
            end.
            end.
            else do:
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = tabdac17.parlan and
                 titulo.moecod = vmoecod           
                 no-lock no-error.
            if not avail titulo 
            then next. 
            else do:
           
                find first btitulo where
                 btitulo.empcod   = 19 and
                 btitulo.titnat   = no   and
                 btitulo.modcod   = "CRE" and
                 btitulo.etbcod   = tabdac17.etbcod and
                 btitulo.clifor   = vclifor and
                 btitulo.titnum   = vtitnum and
                 btitulo.titpar   > tabdac17.parlan  and
                 btitulo.titdtpag > data-ori and
                 btitulo.titdtpag <= data-des 
                 no-lock no-error.
                 if avail btitulo then next.

                if titulo.titvlcob <> tabdac17.vallan
                then next.
                if titulo.titjuro > 0 and 
                    total-jr + titulo.titjuro <= valor-jr
                then.
                else if titulo.titjuro = 0 and valor-jr = 0
                    then.
                    else next.
                total-jr = total-jr + titulo.titjuro.
                valor-tb = valor-tb + tabdac17.vallan.
            end.
            end.
        end.

        if valor-tb <= 0 then next.
        /*
        valor-tb = valor-tb * .80.
        */
        valor-tb1 = 0.

        for each tabdac17 where 
                 tabdac17.etblan = estab.etbcod and
                 tabdac17.datlan = data-ori and
                 tabdac17.tiplan   = "RECEBIMENTO" and
                 tabdac17.sitlan = "LEBES"
                 :
                
            vclifor = tabdac17.clicod.
            vtitnum = tabdac17.numlan.
            vtitdtpag   = tabdac17.datlan.
            vtitpar = 0.
            
            if tabdac17.datemi <= data-des
            then.
            else next.
            if vmoecod <> "CAR"
            then do:
            find first titpag where
                 titpag.empcod   = 19 and
                 titpag.titnat   = no   and
                 titpag.modcod   = "CRE" and
                 titpag.etbcod   = tabdac17.etbcod and
                 titpag.clifor   = vclifor and
                 titpag.titnum   = vtitnum and
                 titpag.titpar   = tabdac17.parlan and
                 titpag.moecod   = vmoecod 
                 no-lock no-error.
            if not avail titpag 
            then next. /******do:
                find first titulosal where
                    titulosal.empcod   = 19 and
                    titulosal.titnat   = no   and
                    titulosal.modcod   = "CRE" and
                    titulosal.etbcod   = tabdac17.etbcod and
                    titulosal.clifor   = vclifor and
                    titulosal.titnum   = vtitnum and
                    titulosal.titpar   = tabdac17.parlan and
                    titulosal.moecod = vmoecod 
                     no-lock no-error.
                if not avail titulosal
                then do:
                    find first sc2015 where
                            sc2015.empcod   = 19 and
                            sc2015.titnat   = no   and
                            sc2015.modcod   = "CRE" and
                            sc2015.etbcod   = tabdac17.etbcod and
                            sc2015.clifor   = vclifor and
                            sc2015.titnum   = vtitnum and
                            sc2015.titpar   = tabdac17.parlan and
                            sc2015.moecod = vmoecod
                            no-lock no-error.
                    if not avail sc2015
                    then next.
                    find first sc2015 where
                        sc2015.empcod   = 19 and
                        sc2015.titnat   = no   and
                        sc2015.modcod   = "CRE" and
                        sc2015.etbcod   = tabdac17.etbcod and
                        sc2015.clifor   = vclifor and
                        sc2015.titnum   = vtitnum and
                        sc2015.titpar   > tabdac17.parlan  and
                        sc2015.titdtpag > data-ori and
                        sc2015.titdtpag <= data-des and
                        sc2015.moecod = vmoecod 
                        no-lock no-error.
                    if avail sc2015 then next.
                end.
                else do: 
                    find first titulosal where
                        titulosal.empcod   = 19 and
                        titulosal.titnat   = no   and
                        titulosal.modcod   = "CRE" and
                        titulosal.etbcod   = tabdac17.etbcod and
                        titulosal.clifor   = vclifor and
                        titulosal.titnum   = vtitnum and
                        titulosal.titpar   > tabdac17.parlan  and
                        titulosal.titdtpag > data-ori and
                        titulosal.titdtpag <= data-des and
                        titulosal.moecod = vmoecod 
                        no-lock no-error.
                    if avail titulosal then next.
                end.
                
                find first sc2015 where
                                   sc2015.empcod = 19 and
                                   sc2015.titnat = no and
                                   sc2015.modcod = "CRE" and
                                   sc2015.etbcod = tabdac17.etbcod and
                                   sc2015.clifor = vclifor and
                                   sc2015.titnum = vtitnum and
                                   sc2015.titpar = tabdac17.parlan
                                   no-lock no-error.
 
                if  avail sc2015 and
                    (tabdac17.vallan + valor-tb1) <= valor-tb and
                    (tabdac17.vallan + valor-ux)  <= valor-tr
                then do:
                    valor-tb1 = valor-tb1 + tabdac17.vallan.
                    valor-ux = valor-ux + tabdac17.vallan.
                
                    if vatu
                    then do:
                    
                        assign
                            tabdac17.mes = month(data-des)
                            tabdac17.ano = year(data-des)
                            tabdac17.datlan = data-des
                            tabdac17.situacao = 9
                        .

                        find first sc2015 where
                                   sc2015.empcod = 19 and
                                   sc2015.titnat = no and
                                   sc2015.modcod = "CRE" and
                                   sc2015.etbcod = tabdac17.etbcod and
                                   sc2015.clifor = vclifor and
                                   sc2015.titnum = vtitnum and
                                   sc2015.titpar = tabdac17.parlan
                                   no-error.

                        sc2015.titdtpagaux = data-des.
                        sc2015.titsit = "PAG".
                        sc2015.titdtvenaux = data-des.
                        
                        run ajusta-ctbreceb.

                    end.   
                end.
                else if not avail sc2015
                then do:
                    
                    assign
                        valor-ux = valor-ux + tabdac17.vallan.
                        valor-tb1 = valor-tb1 + tabdac17.vallan.
                    create sc2015.
                    assign
                        sc2015.empcod = 19 
                        sc2015.titnat = no 
                        sc2015.modcod = "CRE" 
                        sc2015.etbcod = tabdac17.etbcod 
                        sc2015.clifor = vclifor
                        sc2015.titnum = vtitnum 
                        sc2015.titpar = tabdac17.parlan
                        sc2015.titvlcob = tabdac17.vallan
                        sc2015.titdtemi = tabdac17.datemi
                        sc2015.titdtven = tabdac17.datven
                        sc2015.titdtpag = tabdac17.datpag
                        sc2015.titsit   = "PAG"
                        sc2015.titvlpag = tabdac17.vallan
                        sc2015.etbcobra = tabdac17.etbpag
                        sc2015.moecod = vmoecod
                        .
                        
                end.
            end. **************************/
            else do:
                find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   > tabdac17.parlan  and
                 titulo.titdtpag > data-ori and
                 titulo.titdtpag <= data-des 
                 no-lock no-error.
                 if avail titulo then next.

                 find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = tabdac17.parlan
                 no-lock no-error.
                 if not avail titulo then next.
                if titulo.titvlcob <> tabdac17.vallan
                then next.
                if titulo.titjuro > 0 and 
                    total-jr1 + titulo.titjuro <= valor-jr
                then.
                else if titulo.titjuro = 0 and valor-jr = 0
                    then. else next.
            
                find first TSC2017 where
                                   TSC2017.empcod = 19 and
                                   TSC2017.titnat = no and
                                   TSC2017.modcod = "CRE" and
                                   TSC2017.etbcod = tabdac17.etbcod and
                                   TSC2017.clifor = vclifor and
                                   TSC2017.titnum = vtitnum and
                                   TSC2017.titpar = tabdac17.parlan
                                    no-error.
  
                if (not  avail TSC2017 or data-ori > data-des) and
                    (tabdac17.vallan + valor-tb1) <= valor-tb and
                    (tabdac17.vallan + valor-ux)  <= valor-tr
                then do:
                    valor-tb1 = valor-tb1 + tabdac17.vallan.
                    valor-ux = valor-ux + tabdac17.vallan.
                    total-jr1 = total-jr1 + titulo.titjuro.
                    if vatu
                    then do:
                        /****************
                        find first sc2015 where
                                   sc2015.empcod = 19 and
                                   sc2015.titnat = no and
                                   sc2015.modcod = "CRE" and
                                   sc2015.etbcod = tabdac17.etbcod and
                                   sc2015.clifor = vclifor and
                                   sc2015.titnum = vtitnum and
                                   sc2015.titpar = tabdac17.parlan
                                   no-error.
                        if avail sc2015
                        then do:
                        **************/

                        if not avail TSC2017
                        then do:
                            create TSC2017.
                            buffer-copy titulo to TSC2017.
                        end.
                        
                        TSC2017.titdtpagaux = data-des.
 
                        assign
                                tabdac17.mes = month(data-des)
                                tabdac17.ano = year(data-des)
                                tabdac17.datlan = data-des
                                tabdac17.situacao = 9
                        .

                        if titulo.titjuro > 0
                        then do:
                            find first btabdac17 where
                                     btabdac17.etblan = estab.etbcod and
                                     btabdac17.datlan = data-ori and
                                     btabdac17.tiplan = "JUROS" and
                                     btabdac17.sitlan = "LEBES" and
                                     btabdac17.clicod = tabdac17.clicod and
                                     btabdac17.numlan = tabdac17.numlan
                                     no-error.
                            if avail btabdac17
                            then assign
                                     btabdac17.mes = month(data-des)
                                     btabdac17.ano = year(data-des)
                                     btabdac17.datlan = data-des
                                     btabdac17.situacao = 9
                                     .
                        end.

                        run ajusta-ctbreceb.

                        /*end.*/
                    end.   
                end.
                
                /**************
                else if not avail sc2015
                then do:
                    
                    assign
                        valor-ux = valor-ux + tabdac17.vallan.
                        valor-tb1 = valor-tb1 + tabdac17.vallan.
                    create sc2015.
                    buffer-copy titulo to sc2015.
                    sc2015.titdtpagaux = data-des.
                    
                    /*****************
                    assign
                        sc2015.empcod = 19 
                        sc2015.titnat = no 
                        sc2015.modcod = "CRE" 
                        sc2015.etbcod = tabdac17.etbcod 
                        sc2015.clifor = vclifor 
                        sc2015.titnum = vtitnum 
                        sc2015.titpar = tabdac17.parlan
                        sc2015.titvlcob = tabdac17.vallan
                        sc2015.titdtemi = tabdac17.datemi
                        sc2015.titdtven = tabdac17.datven
                        sc2015.titdtpag = tabdac17.datpag
                        sc2015.titsit   = "PAG"
                        sc2015.titvlpag = tabdac17.vallan
                        sc2015.etbcobra = tabdac17.etbpag
                        sc2015.moecod = vmoecod
                        .
                    ***************/  
                end.
                ******************/
            end.
            end.
            else do:
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = tabdac17.parlan and
                 titulo.moecod   = vmoecod 
                 no-lock no-error.
            if not avail titulo 
            then next. 
            else do:
                find first btitulo where
                 btitulo.empcod   = 19 and
                 btitulo.titnat   = no   and
                 btitulo.modcod   = "CRE" and
                 btitulo.etbcod   = tabdac17.etbcod and
                 btitulo.clifor   = vclifor and
                 btitulo.titnum   = vtitnum and
                 btitulo.titpar   > tabdac17.parlan  and
                 btitulo.titdtpag > data-ori and
                 btitulo.titdtpag <= data-des 
                 no-lock no-error.
                 if avail btitulo then next.

                if titulo.titvlcob <> tabdac17.vallan
                then next.
                if titulo.titjuro > 0 and 
                    total-jr1 + titulo.titjuro <= valor-jr
                then.
                else if titulo.titjuro = 0 and valor-jr = 0
                    then. else next.
            
                find first TSC2017 where
                                   TSC2017.empcod = 19 and
                                   TSC2017.titnat = no and
                                   TSC2017.modcod = "CRE" and
                                   TSC2017.etbcod = tabdac17.etbcod and
                                   TSC2017.clifor = vclifor and
                                   TSC2017.titnum = vtitnum and
                                   TSC2017.titpar = tabdac17.parlan
                                    no-error.
  
                if (not  avail TSC2017 or data-ori > data-des) and
                    (tabdac17.vallan + valor-tb1) <= valor-tb and
                    (tabdac17.vallan + valor-ux)  <= valor-tr
                then do:
                    valor-tb1 = valor-tb1 + tabdac17.vallan.
                    valor-ux = valor-ux + tabdac17.vallan.
                    total-jr1 = total-jr1 + titulo.titjuro.
                    if vatu
                    then do:

                        if not avail TSC2017
                        then do:
                            create TSC2017.
                            buffer-copy titulo to TSC2017.
                        end.
                        
                        TSC2017.titdtpagaux = data-des.
 
                        assign
                                tabdac17.mes = month(data-des)
                                tabdac17.ano = year(data-des)
                                tabdac17.datlan = data-des
                                tabdac17.situacao = 9
                        .

                        if titulo.titjuro > 0
                        then do:
                            find first btabdac17 where
                                     btabdac17.etblan = estab.etbcod and
                                     btabdac17.datlan = data-ori and
                                     btabdac17.tiplan = "JUROS" and
                                     btabdac17.sitlan = "LEBES" and
                                     btabdac17.clicod = tabdac17.clicod and
                                     btabdac17.numlan = tabdac17.numlan
                                     no-error.
                            if avail btabdac17
                            then assign
                                     btabdac17.mes = month(data-des)
                                     btabdac17.ano = year(data-des)
                                     btabdac17.datlan = data-des
                                     btabdac17.situacao = 9
                                     .
                        end.

                        run ajusta-ctbreceb.

                    end.   
                end.
            end.
            end.
        end. 
        /*
        message estab.etbcod valor-tb valor-tb1. pause.       
        */
    end.
end.                        
                
disp valor-ux total-jr1 with frame f-dt.
end.
procedure ajusta-ctbreceb:

    def var vi as int.
    
    find first tabcre17 where
                           tabcre17.etbcod = estab.etbcod and
                           tabcre17.datref = data-ori
                           no-error.
                if not avail tabcre17
                then do:
                    create tabcre17.
                    assign
                        tabcre17.etbcod = estab.etbcod
                        tabcre17.datref = data-ori
                            .
                end.
                tabcre17.recebimento_lebes =
                             tabcre17.recebimento_lebes - tabdac17.vallan.
                
                tabcre17.juros_lebes = tabcre17.juros_lebes - titulo.titjuro.                
                find first fin.moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                
                do vi = 1 to 15:
                    if tabcre17.define_recebimento_moeda[vi] = ""
                    then tabcre17.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabcre17.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabcre17.recebimento_moeda_lebes[vi] =
                        tabcre17.recebimento_moeda_lebes[vi] - tabdac17.vallan.
                        tabcre17.receb_moeda_juros_lebes[vi] =
                                tabcre17.receb_moeda_juros_lebes[vi] -
                                titulo.titjuro.
                        leave.
                    end.
                end.

    find ninja.ctbreceb where
             ctbreceb.rectp  = "RECEBIMENTO" and
             ctbreceb.etbcod =  estab.etbcod and
             ctbreceb.datref =  data-ori and
             ctbreceb.moecod = vmoecod
             no-error.
    if avail ctbreceb
    then assign
            ctbreceb.valor1 = ctbreceb.valor1 - tabdac17.vallan
            ctbreceb.valor2 = ctbreceb.valor2 + tabdac17.vallan.
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-ori 
               no-error
               .
    if avail ctcartcl
    then assign
            ctcartcl.recebimento = ctcartcl.recebimento - tabdac17.vallan
            ctcartcl.juro        = ctcartcl.juro - titulo.titjuro
            .
  
    find first tabcre17 where
                           tabcre17.etbcod = estab.etbcod and
                           tabcre17.datref = data-des
                           no-error.
                if not avail tabcre17
                then do:
                    create tabcre17.
                    assign
                        tabcre17.etbcod = estab.etbcod
                        tabcre17.datref = data-des
                            .
                end.
                tabcre17.recebimento_lebes =
                             tabcre17.recebimento_lebes + tabdac17.vallan.
                tabcre17.juros_lebes = tabcre17.juros_lebes + titulo.titjuro.                
                find first moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                do vi = 1 to 15:
                    if tabcre17.define_recebimento_moeda[vi] = ""
                    then tabcre17.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabcre17.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabcre17.recebimento_moeda_lebes[vi] =
                        tabcre17.recebimento_moeda_lebes[vi] + tabdac17.vallan.
                        tabcre17.receb_moeda_juros_lebes[vi] =
                                tabcre17.receb_moeda_juros_lebes[vi] +
                                titulo.titjuro.
                        leave.
                    end.
                end.
    find ninja.ctbreceb where
             ctbreceb.rectp  = "RECEBIMENTO" and
             ctbreceb.etbcod =  estab.etbcod and
             ctbreceb.datref =  data-des and
             ctbreceb.moecod = vmoecod
             no-error.
    if avail ctbreceb
    then assign
            ctbreceb.valor1 = ctbreceb.valor1 + tabdac17.vallan
            ctbreceb.valor3 = ctbreceb.valor3 + tabdac17.vallan.
    else do:
        create ctbreceb.
        assign
            ctbreceb.rectp  = "RECEBIMENTO"
            ctbreceb.etbcod =  estab.etbcod
            ctbreceb.datref =  data-des
            ctbreceb.moecod = vmoecod
            ctbreceb.valor1 = ctbreceb.valor1 + tabdac17.vallan
            ctbreceb.valor3 = ctbreceb.valor3 + tabdac17.vallan
            .
    end. 
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-des 
               no-error
               .
    if avail ctcartcl
    then assign
            ctcartcl.recebimento = ctcartcl.recebimento + tabdac17.vallan
            ctcartcl.juro        = ctcartcl.juro + titulo.titjuro
            .
            
    else do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = estab.etbcod 
            ctcartcl.datref = data-des
            ctcartcl.recebimento = tabdac17.vallan
            ctcartcl.juro        = titulo.titjuro
            .
    end.            
               
end procedure.


