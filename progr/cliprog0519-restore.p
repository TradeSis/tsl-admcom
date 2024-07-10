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
    if avail titulosal /*and
        vtotal1 + contratodd.vltotal <= vtotal*/ 
    then do:
          
        vtotal1 = vtotal1 + contratodd.vltotal.
        
        if vatu
        then do:
            find first tabdac where
                tabdac.etblan = titulosal.etbcobra and
                tabdac.datlan = titulosal.titdtpag and
                tabdac.clicod = titulosal.clifor and
                tabdac.numlan = titulosal.titnum and
                tabdac.parlan = titulosal.titpar and
                tabdac.tiplan = "RECEBIMENTO"
                no-error.
            if avail tabdac 
            then do on error undo: 
                find first ninja.ctcartcl where
                           ctcartcl.etbcod = tabdac.etblan and
                           ctcartcl.datref = tabdac.datlan
                           no-error.
                if avail ctcartcl
                then  
                ctcartcl.recebimento = ctcartcl.recebimento - tabdac.vallan.
                
                find first tabdicre where
                           tabdicre.etbcod = tabdac.etblan and
                           tabdicre.datref = tabdac.datlan
                           no-error.
                if avail tabdicre
                then tabdicre.recebimento_lebes =
                             tabdicre.recebimento_lebes - tabdac.vallan.
                                
                find first fin.moeda where moeda.moecod = vmoecod
                       no-lock no-error.
                do vi = 1 to 15:
                    if tabdicre.define_recebimento_moeda[vi] =
                                 moeda.moecod + " - " + moeda.moenom
                    then do:
                        tabdicre.recebimento_moeda_lebes[vi] =
                        tabdicre.recebimento_moeda_lebes[vi] - tabdac.vallan.
                        leave.
                    end.
                end.
                            
                find first ninja.ctbreceb where
                           ctbreceb.rectp = "RECEBIMENTO" and
                           ctbreceb.etbcod = tabdac.etblan and
                           ctbreceb.datref = tabdac.datlan and
                           ctbreceb.moecod = vmoecod
                           no-error.
                if avail ctbreceb
                then ctbreceb.valor1 = ctbreceb.valor1 - tabdac.vallan.                         delete tabdac.
            end. 
            delete titulosal.        
        end.      
    end. 
end.
disp vtotal1.    
end.     
