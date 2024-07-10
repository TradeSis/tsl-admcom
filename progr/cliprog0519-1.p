/*
connect ninja -H db2 -S sdrebninja -N tcp.
*/

def temp-table tt-sc2015 like sc2015.

def var vtitdtpag like fin.titulo.titdtpag.
def var vtitdtven like fin.titulo.titdtven.
def var vmes as int.
def var vdia as int.
def var vano as int.
def var vi as int.
def var vatu as log format "Sim/Nao".
def var vdti as date.
def var vdtf as date.
def var vtotal as dec format ">>>,>>>,>>9.99".
def var vtotal1 as dec format ">>>,>>>,>>9.99".
def var vmoecod like fin.moeda.moecod.
repeat:
vatu = no.
vtotal1 = 0.    
update vdti vdtf vtotal vatu vtitdtpag
vmoecod.
disp vtotal1.
for each tt-sc2015:
    delete tt-sc2015.
end.    
for each sc2015 where sc2015.titdtemi >= vdti and
                      sc2015.titdtemi <= vdtf and
                      sc2015.titsit    = "LIB" and
                      sc2015.cobcod = 22
                      no-lock :
    
    if not can-find(first tabdac where tabdac.etbcod = sc2015.etbcod and
                                       tabdac.clicod = sc2015.clifor and
                                       tabdac.numlan = sc2015.titnum and
                                       tabdac.parlan = ? and
                                       tabdac.datemi = sc2015.titdtemi and
                                       tabdac.tiplan begins "EMI")
    then next.  
                                       
    if vtotal1 + sc2015.titvlcob <= vtotal 
    then do:
          
        vtotal1 = vtotal1 + sc2015.titvlcob.
        
        if vatu
        then do:
            create tt-sc2015.
            buffer-copy sc2015 to tt-sc2015.
        end.
    end.     
end.
if vatu
then do:
    for each tt-sc2015 no-lock:
        find first sc2015 where
                   sc2015.empcod = tt-sc2015.empcod and
                   sc2015.titnat = tt-sc2015.titnat and
                   sc2015.modcod = tt-sc2015.modcod and
                   sc2015.etbcod = tt-sc2015.etbcod and
                   sc2015.clifor = tt-sc2015.clifor and
                   sc2015.titnum = tt-sc2015.titnum and
                   sc2015.titpar = tt-sc2015.titpar
                   no-error.
        assign
            sc2015.titsit = "PAG"
            sc2015.titdtpag = vtitdtpag
            sc2015.titvlpag = sc2015.titvlcob
            sc2015.etbcobra = sc2015.etbcod
            sc2015.moecod = vmoecod.
            .
                
        find first tabdac where
                tabdac.etblan = sc2015.etbcobra and
                tabdac.datlan = sc2015.titdtpag and
                tabdac.clicod = sc2015.clifor and
                tabdac.numlan = sc2015.titnum and
                tabdac.parlan = sc2015.titpar and
                tabdac.tiplan = "RECEBIMENTO"
                no-lock no-error.
            if not avail tabdac 
            then do on error undo: 
                create tabdac.
                assign
                    tabdac.etbcod = sc2015.etbcod
                    tabdac.etblan = sc2015.etbcobra
                    tabdac.etbpag = sc2015.etbcob
                    tabdac.clicod = sc2015.clifor
                    tabdac.numlan = sc2015.titnum
                    tabdac.parlan = sc2015.titpar
                    tabdac.datemi = sc2015.titdtemi
                    tabdac.datven = sc2015.titdtven
                    tabdac.datlan = sc2015.titdtpag
                    tabdac.datpag = sc2015.titdtpag
                    tabdac.datexp = today
                    tabdac.vallan = sc2015.titvlcob
                    tabdac.tiplan = "RECEBIMENTO"
                    tabdac.sitlan = "LEBES"
                    tabdac.hislan = "RECEBIMENTO " + string(sc2015.titnum)
                    tabdac.anolan = year(sc2015.titdtpag)
                    tabdac.meslan = month(sc2015.titdtpag)
                    tabdac.natlan = "C"
                    .
                
                
                find first ninja.ctcartcl where
                           ctcartcl.etbcod = tabdac.etblan and
                           ctcartcl.datref = tabdac.datlan
                           no-error.
                if not avail ctcartcl
                then do:
                    create ctcartcl.
                    assign
                        ctcartcl.etbcod = tabdac.etblan
                        ctcartcl.datref = tabdac.datlan.       
                end.
                ctcartcl.recebimento = ctcartcl.recebimento + tabdac.vallan.
                
                find first tabdicre where
                           tabdicre.etbcod = tabdac.etblan and
                           tabdicre.datref = tabdac.datlan
                           no-error.
                if not avail tabdicre
                then do:
                    create tabdicre.
                    assign
                        tabdicre.etbcod = tabdac.etblan
                        tabdicre.datref = tabdac.datlan
                            .
                end.
                tabdicre.recebimento_lebes =
                             tabdicre.recebimento_lebes + tabdac.vallan.
                                
                find first fin.moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                do vi = 1 to 15:
                    if tabdicre.define_recebimento_moeda[vi] = ""
                    then tabdicre.define_recebimento_moeda[vi] =
                                        moeda.moecod + " - " + moeda.moenom.
                    if tabdicre.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabdicre.recebimento_moeda_lebes[vi] =
                        tabdicre.recebimento_moeda_lebes[vi] + tabdac.vallan.
                        leave.
                    end.
                end.
                            
                find first ninja.ctbreceb where
                           ctbreceb.rectp = "RECEBIMENTO" and
                           ctbreceb.etbcod = tabdac.etblan and
                           ctbreceb.datref = tabdac.datlan and
                           ctbreceb.moecod = vmoecod
                           no-error.
                if not avail ctbreceb
                then do:
                    create ctbreceb.
                    assign
                        ctbreceb.rectp = "RECEBIMENTO"
                        ctbreceb.etbcod = tabdac.etblan
                        ctbreceb.datref = tabdac.datlan
                        ctbreceb.moecod = vmoecod
                           .
                end.
                ctbreceb.valor1 = ctbreceb.valor1 + tabdac.vallan.           
            end.            
    end.
end.
disp vtotal1.    
end.
