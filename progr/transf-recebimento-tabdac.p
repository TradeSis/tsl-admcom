/*
connect ninja -H db2 -S sdrebninja -N tcp.
*/


{admcab.i new}

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
def var vmoecod like moeda.moecod.
 
def var vatu as log format "Sim/Nao".

update data-ori Label "Data origem"
       data-des label "Data destino"
       valor-tr label "Valor transferir" format ">>,>>>,>>9.99"
       vmoecod  label "Moeda"
       vatu     label "Atualizar"
       with frame f-dt 1 down
       1 column.

def buffer barqclien for arqclien.
def buffer ctitulo for titulo.

def var vclifor like titulo.clifor.
def var vtitnum like titulo.titnum.
def var vtitdtpag like titulo.titdtpag.
def var vtitpar like titulo.titpar.
def buffer btitulo for titulo.

for each estab where estab.etbcod < 200 
            or estab.etbcod = 996 no-lock:

    disp "Processando... " estab.etbcod valor-tr valor-ux
    with frame f-dd 1 down no-box no-label
    row 10 centere color message.
    pause 0.
    
    if valor-ux < valor-tr and
       valor-tr - valor-ux > 2
    then do:
        valor-tb = 0.
        
        for each ninja.tabdac where
                 tabdac.etblan = estab.etbcod and
                 tabdac.datlan = data-ori and
                 tabdac.tiplan   = "RECEBIMENTO" and
                 tabdac.sitlan = "LEBES"
                 no-lock:
            vclifor = tabdac.clicod.
            vtitnum = tabdac.numlan.
            vtitdtpag   = tabdac.datlan.
            vtitpar = 0.

            if tabdac.datemi < data-des
            then.
            else next.

            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = tabdac.parlan and
                 titulo.moecod = vmoecod 
                 no-lock no-error.
            if not avail titulo then next.

            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   > tabdac.parlan  and
                 titulo.titdtpag > data-ori and
                 titulo.titdtpag <= data-des and
                 titulo.moecod = vmoecod 
                 no-lock no-error.
            if avail titulo then next.
     
            valor-tb = valor-tb + tabdac.vallan.

        end.
        if valor-tb <= 0 then next.
        /*
        valor-tb = valor-tb * .80.
        */
        valor-tb1 = 0.
        for each ninja.tabdac where 
                 tabdac.etblan = estab.etbcod and
                 tabdac.datlan = data-ori and
                 tabdac.tiplan   = "RECEBIMENTO" and
                 tabdac.sitlan = "LEBES"
                 :
                
            vclifor = tabdac.clicod.
            vtitnum = tabdac.numlan.
            vtitdtpag   = tabdac.datlan.
            vtitpar = 0.

            if tabdac.datemi < data-des
            then.
            else next.

            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   = tabdac.parlan and
                 titulo.moecod = vmoecod 
                 no-lock no-error.
            if not avail titulo then next.

            find first titulo where
                 titulo.empcod   = 19 and
                 titulo.titnat   = no   and
                 titulo.modcod   = "CRE" and
                 titulo.etbcod   = tabdac.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titpar   > tabdac.parlan  and
                 titulo.titdtpag > data-ori and
                 titulo.titdtpag <= data-des    and
                 titulo.moecod = vmoecod 
                 no-lock no-error.
            if avail titulo then next.

                 
            if (tabdac.vallan + valor-tb1) <= valor-tb and
               (tabdac.vallan + valor-ux)  <= valor-tr
            then do:
                valor-tb1 = valor-tb1 + tabdac.vallan.
                valor-ux = valor-ux + tabdac.vallan.
                
                if vatu
                then do:
                    
                    assign
                        tabdac.mes = month(data-des)
                        tabdac.ano = year(data-des)
                        tabdac.datlan = data-des
                        .

                    run ajusta-ctbreceb.

                end.   
            end.
        end.         
    end.
end.                        
                
disp valor-tr valor-ux.

procedure ajusta-ctbreceb:

    def var vi as int.
    
    find first tabdic where
                           tabdic.etbcod = estab.etbcod and
                           tabdic.datref = data-ori
                           no-error.
                if not avail tabdic
                then do:
                    create tabdic.
                    assign
                        tabdic.etbcod = estab.etbcod
                        tabdic.datref = data-ori
                            .
                end.
                tabdic.recebimento_lebes =
                             tabdic.recebimento_lebes - tabdac.vallan.
                                
                find first moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                
                do vi = 1 to 15:
                    if tabdic.define_recebimento_moeda[vi] = ""
                    then tabdic.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabdic.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabdic.recebimento_moeda_lebes[vi] =
                        tabdic.recebimento_moeda_lebes[vi] - tabdac.vallan.
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
            ctbreceb.valor1 = ctbreceb.valor1 - tabdac.vallan
            ctbreceb.valor2 = ctbreceb.valor2 + tabdac.vallan.
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-ori 
               no-error
               .
    if avail ctcartcl
    then ctcartcl.recebimento = ctcartcl.recebimento - tabdac.vallan.
  
    find first tabdic where
                           tabdic.etbcod = estab.etbcod and
                           tabdic.datref = data-des
                           no-error.
                if not avail tabdic
                then do:
                    create tabdic.
                    assign
                        tabdic.etbcod = estab.etbcod
                        tabdic.datref = data-des
                            .
                end.
                tabdic.recebimento_lebes =
                             tabdic.recebimento_lebes + tabdac.vallan.
                                
                find first moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                do vi = 1 to 15:
                    if tabdic.define_recebimento_moeda[vi] = ""
                    then tabdic.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabdic.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabdic.recebimento_moeda_lebes[vi] =
                        tabdic.recebimento_moeda_lebes[vi] + tabdac.vallan.
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
            ctbreceb.valor1 = ctbreceb.valor1 + tabdac.vallan
            ctbreceb.valor3 = ctbreceb.valor3 + tabdac.vallan.
    else do:
        create ctbreceb.
        assign
            ctbreceb.rectp  = "RECEBIMENTO"
            ctbreceb.etbcod =  estab.etbcod
            ctbreceb.datref =  data-des
            ctbreceb.moecod = vmoecod
            ctbreceb.valor1 = ctbreceb.valor1 + tabdac.vallan
            ctbreceb.valor3 = ctbreceb.valor3 + tabdac.vallan
            .
    end. 
    find first ninja.ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-des 
               no-error
               .
    if avail ctcartcl
    then ctcartcl.recebimento = ctcartcl.recebimento + tabdac.vallan.
    else do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = estab.etbcod 
            ctcartcl.datref = data-des
            ctcartcl.recebimento = tabdac.vallan
            .
    end.            
               
end procedure.


