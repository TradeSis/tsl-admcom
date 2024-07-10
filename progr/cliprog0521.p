def temp-table tt-plani 
    field etbcod like estab.etbcod
    field pladat like com.plani.pladat
    field platot like com.plani.platot
    index i1 etbcod pladat.
    
def temp-table tt-tabdac like tabdac.
def temp-table tt-venda like tabdicem.
def temp-table tt-receb like tabdicre.
def var p-sitlan as char.
def var vtitvlcob as dec.

def var vlvist as dec.
def var v-descarta as log.
def var vcontnum like contratodd.cont-num.
def var vdti as date.
def var vdtf as date.
def var vdifer as dec.
vdifer = 0.
def var vtotplani as dec.
def var vatu as log.
def var vpct as dec.
def var vsel-tot as dec.
def var vtotal as dec format ">>>,>>>,>>9.99".
def var vdata as date.

repeat:
update vdti vdtf vdifer format ">>>,>>>,>>9.99" vatu vpct.

vtotal = 0.
do vdata = vdti to vdtf:
disp vdata. 

for each estab no-lock:
def var ok-serie as log.
disp estab.etbcod with 1 down.
pause 0.
    
    vtotplani = 0.
    run gera-tt-plani.
    if vtotplani = 0 then next.
    vsel-tot = vtotplani * (vpct / 100).
    
    vtotplani = 0.
    disp vtotal.
    pause 0.
    for each com.plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata
                                           no-lock.
                
                if substr(string(plani.notped),1,1) <> "C" or
                    plani.ufemi = ""  /*or
                    plani.serie <> "V"  */
                then next.

                ok-serie = yes.
                if plani.serie <> "V"
                then do:
                    run valida-serie-NFCe.p(input plani.serie,
                                    input plani.ufemi,
                                    input plani.notped,
                                    output ok-serie).
                    if not ok-serie
                    then next.
                end.    

                
                if desti = 0 then next.
                if desti = 1 then next.
                if desti < 10000 then next.

                do:
                    find clien where clien.clicod = plani.desti 
                            no-lock no-error.
                    if not avail clien then next.
                end.
                v-descarta = no.
                for each com.movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then v-descarta = yes.
                        end.     
                end.     
                if v-descarta = yes
                then next.
                if plani.crecod = 1  and
                    vtotal + plani.platot <= vdifer and
                    vtotplani + plani.platot <= vsel-tot
                then do:
                    vcontnum = dec(string(plani.etbcod,"999") +
                        string(plani.numero,"999999999")).
                    find first contratodd where
                               contratodd.cont-num = vcontnum
                               no-lock no-error.
                    if not avail contratodd 
                    then do:      
                        if vatu
                        then do:
                         
                            create contratodd.
                            assign
                                contratodd.cont-num = vcontnum
                                contratodd.clicod = plani.desti
                                contratodd.dtinicial = plani.pladat
                                contratodd.etbcod = plani.etbcod
                                contratodd.vltotal = plani.platot
                                contratodd.situacao = 2.
                        end.
                        vtotal = vtotal + plani.platot.
                        vtotplani = vtotplani + plani.platot.
                    end.
                end. 
        end.
    end.
    disp vtotal.
    pause 0.
end.
if vatu
then run contratodd-gera-tabdac-tabdic.
disp vtotal.
end.

procedure gera-tt-plani:
    
    vtotplani = 0.
    
    for each com.plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata
                                           no-lock.
                
        if substr(string(plani.notped),1,1) <> "C" or
            plani.ufemi = ""
        then next.
        
        if desti < 10000 then next.
        /*        
        if desti = 1
        then do:
                    find clien where clien.clicod = plani.numero 
                            no-lock no-error.
                        if not avail clien then next.
        end.
        else do:
                   find clien where clien.clicod = plani.desti 
                            no-lock no-error.
                    if not avail clien then next.
        end.
        */
        v-descarta = no.
        for each com.movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then v-descarta = yes.
                        end.     
        end.     
        if v-descarta = yes
        then next.
                
        if plani.crecod = 1  
        then do:
            vtotplani = vtotplani + plani.platot.
        end.             
    end.
     
end procedure.

procedure contratodd-gera-tabdac-tabdic:

def var vdata1 as date.

do vdata1 = vdti to vdtf:
    for each estab no-lock:
 
        create tt-venda.
        tt-venda.etbcod = estab.etbcod.
        tt-venda.datref = vdata1.

        for each contratodd where contratodd.etbcod = estab.etbcod and
                                    contratodd.dtinicial = vdata1
                                    no-lock:

                if contratodd.crecod = 999
                then next.
          
                vtitvlcob = contratodd.vltotal.
                
                if vtitvlcob <= 0
                then next.
                p-sitlan = "LEBES".
                run put-contratodd.
        end.
    end.
end. 
def var vtotal as dec format ">>>,>>>,>>9.99".
for each tt-tabdac where tt-tabdac.etbcod > 0 no-lock:
     vtotal = vtotal + tt-tabdac.vallan.
end. 
disp vtotal. pause.

for each tt-tabdac where tt-tabdac.etbcod > 0 no-lock:
     create tabdac.
     buffer-copy tt-tabdac to tabdac.
end.    
for each tt-venda where tt-venda.etbcod > 0 no-lock:
    find first tabdicem where
               tabdicem.etbcod = tt-venda.etbcod and
               tabdicem.datref = tt-venda.datref
               no-error.
    if not avail tabdicem
    then do:
        create tabdicem.
        assign
            tabdicem.etbcod = tt-venda.etbcod
            tabdicem.datref = tt-venda.datref
            .
    end.
    tabdicem.venda_prazo_adicional = tabdicem.venda_prazo_adicional +
        tt-venda.venda_prazo_adicional.
    tabdicem.venda_prazo_lebes = tabdicem.venda_prazo_lebes +
        tt-venda.venda_prazo_adicional.
end. 
/*
run put-contratodd.
*/    
end procedure.

procedure put-contratodd:

    find first tt-tabdac where
         tt-tabdac.etbcod = contratodd.etbcod and
         tt-tabdac.clicod = contratodd.clicod and
         tt-tabdac.numlan = string(contratodd.cont-num) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = contratodd.dtinicial and
         tt-tabdac.tiplan = "EMISSAO" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = contratodd.etbcod
            tt-tabdac.etblan = contratodd.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = contratodd.clicod
            tt-tabdac.numlan = string(contratodd.cont-num)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = contratodd.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = contratodd.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMISSAO"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMISSAO " + string(contratodd.cont-num)
            tt-tabdac.anolan = year(contratodd.dtinicial)
            tt-tabdac.meslan = month(contratodd.dtinicial)
            tt-tabdac.natlan = "+"
            .
        release tt-tabdac no-error.
     end. 

     tt-venda.venda_prazo_adicional = 
        tt-venda.venda_prazo_adicional + vtitvlcob.
 
end procedure.

