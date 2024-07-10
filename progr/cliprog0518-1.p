/*
VENDA PRAZO
*/

{admcab.i new}

def var vetb-cod like estab.etbcod.
def var vcli-for like clien.clicod.
def var vtotal as dec.

def var vtipo as char.
def var data-ori as date.
def var data-des as date.
def var valor-tr as dec format ">>,>>>,>>9.99".
def var valor-ux as dec format ">>,>>>,>>9.99".
def var valor-tb as dec format ">>,>>>,>>9.99".
def var valor-tb1 as dec format ">>,>>>,>>9.99".

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
 
def var valor-jr as dec.
def var total-jr as dec.
def var total-jr1 as dec.
def var vatu as log format "Sim/Nao".
repeat:
vatu = no.
update data-ori Label "Origem"
       data-des label "Destino"
       valor-tr label "Emissao" format ">,>>>,>>9.99"
       valor-jr label "Acresc" format ">,>>>,>>9.99"
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

def var val-acresc as dec.

valor-ux = 0.
total-jr = 0.
total-jr1 = 0.

for each estab where estab.etbcod < 200 
            or estab.etbcod = 996 no-lock:
    disp "Processando... " estab.etbcod valor-tr valor-ux
                                    total-jr1 format ">,>>>,>>9.99"
    with frame f-dd 1 down no-box no-label
    row 15 centere color message overlay.
    pause 0.
    
    if valor-ux < valor-tr and
       valor-tr - valor-ux > 2
    then do:
        valor-tb = 0.
        
        for each tabdac17 where
                 tabdac17.etblan = estab.etbcod and
                 tabdac17.datlan >= date(month(data-ori),09,year(data-ori)) and
                 tabdac17.datlan <= data-ori and
                 tabdac17.tiplan   = "EMISSAO" and
                 tabdac17.sitlan = "LEBES"
                 no-lock:
            vclifor = tabdac17.clicod.
            vtitnum = tabdac17.numlan.
            vtitdtpag   = tabdac17.datlan.
            vtitpar = 0.
        
            if tabdac17.datemi < data-des
            then.
            else next.
            val-acresc = 0.
            if valor-jr > 0
            then do:
                find first btabdac17 where
                           btabdac17.etblan = estab.etbcod and
                           btabdac17.datlan = btabdac17.datlan and
                           btabdac17.tiplan = "ACRESCIMO" and
                           btabdac17.sitlan = "LEBES" and
                           btabdac17.clicod = tabdac17.clicod and
                           btabdac17.numlan = tabdac17.numlan
                           no-lock no-error.
                if not avail btabdac17
                then next. 
                val-acresc = btabdac17.vallan.
            end.
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = 0
                 no-lock no-error.
            if avail titulo then next.
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = 1     and
                 titulo.titdtven <= data-des
                 no-lock no-error.
            if avail titulo then next.
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   > 10
                 no-lock no-error.
             if avail titulo    
             then do:     
                total-jr = total-jr + val-acresc.
                valor-tb = valor-tb + tabdac17.vallan.
            end.
        end.

        if valor-tb <= 0 then next.

        valor-tb1 = 0.

        for each tabdac17 where 
                 tabdac17.etblan = estab.etbcod and
                 tabdac17.datlan >= date(month(data-ori),09,year(data-ori)) and
                 tabdac17.datlan <= data-ori and
                 tabdac17.tiplan   = "EMISSAO" and
                 tabdac17.sitlan = "LEBES"
                 :
                
            vclifor = tabdac17.clicod.
            vtitnum = tabdac17.numlan.
            vtitdtpag   = tabdac17.datlan.
            vtitpar = 0.
            
            if tabdac17.datemi < data-des
            then.
            else next.
            val-acresc = 0.
            if valor-jr > 0
            then do:
                find first btabdac17 where
                           btabdac17.etblan = estab.etbcod and
                           btabdac17.datlan = tabdac17.datlan and
                           btabdac17.tiplan = "ACRESCIMO" and
                           btabdac17.sitlan = "LEBES" and
                           btabdac17.clicod = tabdac17.clicod and
                           btabdac17.numlan = tabdac17.numlan
                           no-lock no-error.
                if not avail btabdac17
                then next. 
                val-acresc = btabdac17.vallan.
            end.
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = 0
                 no-lock no-error.
            if avail titulo then next.
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = 1     and
                 titulo.titdtven <= data-des
                 no-lock no-error.
            if avail titulo then next.
            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac17.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   > 10
                 no-lock no-error.
             if avail titulo 
             then do: 
                if 
                    (tabdac17.vallan + valor-tb1) <= valor-tb and
                    (tabdac17.vallan + valor-ux)  <= valor-tr and
                    (total-jr = 0 or (val-acresc + total-jr1 <= valor-jr))
                then do:
                    valor-tb1 = valor-tb1 + tabdac17.vallan.
                    valor-ux = valor-ux + tabdac17.vallan.
                    total-jr1 = total-jr1 + val-acresc.
                    if vatu
                    then do:

                        for each btitulo where
                                btitulo.empcod   = 19 and
                                btitulo.titnat   = no   and
                                btitulo.modcod   = "CRE" and
                                btitulo.etbcod   = tabdac17.etbcod and
                                btitulo.clifor   = vclifor and
                                btitulo.titnum   = vtitnum and
                                btitulo.titpar   > 0
                                no-lock:
                            find first TEC2017 where
                                   TEC2017.empcod = 19 and
                                   TEC2017.titnat = no and
                                   TEC2017.modcod = "CRE" and
                                   TEC2017.etbcod = btitulo.etbcod and
                                   TEC2017.clifor = btitulo.clifor and
                                   TEC2017.titnum = btitulo.titnum and
                                   TEC2017.titpar = btitulo.titpar
                                    no-error.
                            if not avail TEC2017
                            then do:
                                create TEC2017.
                                buffer-copy btitulo to TEC2017.
                            end.
                        
                            TEC2017.titdtemiaux = data-des.
                        end.
                        
                        assign
                                tabdac17.mes = month(data-des)
                                tabdac17.ano = year(data-des)
                                tabdac17.datlan = data-des
                                tabdac17.situacao = 9
                                .

                        if val-acresc > 0
                        then do:
                            find first btabdac17 where
                                     btabdac17.etblan = estab.etbcod and
                                     btabdac17.datlan = tabdac17.datlan and
                                     btabdac17.tiplan = "Acrescimo" and
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
end.                        
                
disp valor-ux total-jr1 format ">,>>>,>>9.99" with frame f-dt.
end.

procedure ajusta-ctbreceb:

    def var vi as int.
    
    find first tabcem17 where
                           tabcem17.etbcod = estab.etbcod and
                           tabcem17.datref = data-ori
                           no-error.
    if not avail tabcem17
    then do:
        create tabcem17.
        assign
            tabcem17.etbcod = estab.etbcod
            tabcem17.datref = data-ori
                            .
    end.
    assign
        tabcem17.venda_prazo_lebes =
            tabcem17.venda_prazo_lebes - tabdac17.vallan
        tabcem17.acrescimo_lebes  =
            tabcem17.acrescimo_lebes - val-acresc .
            
    
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-ori 
               no-error
               .
    if avail ctcartcl
    then assign
            ctcartcl.ecfprazo = ctcartcl.ecfprazo - tabdac17.vallan
            ctcartcl.acrescimo = ctcartcl.acrescimo - val-acresc 
            .
  
    find first tabcem17 where
                           tabcem17.etbcod = estab.etbcod and
                           tabcem17.datref = data-des
                           no-error.
    if not avail tabcem17
    then do:
        create tabcem17.
        assign
            tabcem17.etbcod = estab.etbcod
            tabcem17.datref = data-des
            .
    end.
    assign
        tabcem17.venda_prazo_lebes =
            tabcem17.venda_prazo_lebes + tabdac17.vallan
        tabcem17.acrescimo_lebes  =
            tabcem17.acrescimo_lebes + val-acresc.

    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-des 
               no-error
               .
    if avail ctcartcl
    then assign
            ctcartcl.ecfprazo = ctcartcl.ecfprazo + tabdac17.vallan
            ctcartcl.acrescimo = ctcartcl.acrescimo + val-acresc
            .
            
    else do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = estab.etbcod 
            ctcartcl.datref = data-des
            ctcartcl.ecfprazo = tabdac17.vallan
            ctcartcl.acrescimo = val-acresc
            .
    end.            
               
end procedure.

