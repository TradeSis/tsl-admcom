/*
connect ninja -H db2 -S sdrebninja -N tcp.
*/

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
for each contratodd where
         contratodd.dtinicial >= vdti and
         contratodd.dtinicial <= vdtf
         no-lock:
    
    if contratodd.crecod = 999 then next.
    
    if not can-find(first tabdac where tabdac.etbcod = contratodd.etbcod and
                                       tabdac.clicod = contratodd.clicod and
                                       tabdac.numlan = 
                                        string(contratodd.cont-num) and
                                       tabdac.parlan = ? and
                                       tabdac.datemi = contratodd.dtinicial and
                                       tabdac.tiplan begins "EMI")
    then next.                                   
                                       
    find first titulosal where
         titulosal.empcod = 19 and
         titulosal.titnat = no and
         titulosal.modcod = "CRE" and
         titulosal.etbcod = contratodd.etbcod and
         titulosal.clifor = contratodd.clicod and
         titulosal.titnum = string(contratodd.cont-num) and
         titulosal.titpar = 1
         no-error.
    if not avail titulosal and
        vtotal1 + contratodd.vltotal <= vtotal 
    then do:
          
        vtotal1 = vtotal1 + contratodd.vltotal.
        
        vdia = day(contratodd.dtinicial).
        vmes = month(contratodd.dtinicial).
        vano = year(contratodd.dtinicial).
        if vmes = 12 
        then assign
                vmes = 1 
                vano = vano + 1.
        else assign
                vmes = vmes + 1.
        if vdia > 28 and vmes = 2 then vdia = 28.
        if vdia = 31 then vdia = 30. 

        vtitdtven = date(vmes,vdia,vano).

        if vatu
        then do:
            create titulosal.
            assign
                titulosal.empcod = 19 
                titulosal.titnat = no
                titulosal.modcod = "CRE"
                titulosal.etbcod = contratodd.etbcod
                titulosal.clifor = contratodd.clicod
                titulosal.titnum = string(contratodd.cont-num)
                titulosal.titpar = 1
                titulosal.titdtemi = contratodd.dtinicial
                titulosal.titdtven = vtitdtven
                titulosal.titdtpag = (if vtitdtpag <> ? then vtitdtpag
                                    else vtitdtven)
                titulosal.titvlcob = contratodd.vltotal
                titulosal.titvlpag = contratodd.vltotal
                titulosal.etbcobra = contratodd.etbcod
                titulosal.moecod = vmoecod
                .
            
            find first tabdac where
                tabdac.etblan = titulosal.etbcobra and
                tabdac.datlan = titulosal.titdtpag and
                tabdac.clicod = titulosal.clifor and
                tabdac.numlan = titulosal.titnum and
                tabdac.parlan = titulosal.titpar and
                tabdac.tiplan = "RECEBIMENTO"
                no-lock no-error.
            if not avail tabdac 
            then do on error undo: 
                create tabdac.
                assign
                    tabdac.etbcod = titulosal.etbcod
                    tabdac.etblan = titulosal.etbcobra
                    tabdac.etbpag = titulosal.etbcob
                    tabdac.clicod = titulosal.clifor
                    tabdac.numlan = titulosal.titnum
                    tabdac.parlan = titulosal.titpar
                    tabdac.datemi = titulosal.titdtemi
                    tabdac.datven = titulosal.titdtven
                    tabdac.datlan = titulosal.titdtpag
                    tabdac.datpag = titulosal.titdtpag
                    tabdac.datexp = today
                    tabdac.vallan = titulosal.titvlcob
                    tabdac.tiplan = "RECEBIMENTO"
                    tabdac.sitlan = "LEBES"
                    tabdac.hislan = "RECEBIMENTO " + string(titulosal.titnum)
                    tabdac.anolan = year(titulosal.titdtpag)
                    tabdac.meslan = month(titulosal.titdtpag)
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
end.
disp vtotal1.    
end.     
