{admcab.i}

form vetbcod like estab.etbcod at 5 label "Filial"
     estab.etbnom no-label
     vcatcod as int at 6 label "Setor"
     categoria.catnom no-label
     vsequencia like ctpromoc.sequencia  at 3 label "Promocao"
     vclacod like clase.clacod
     sclacod like clase.clacod label "SubClasse" skip
     vmix at 3   as log  label "Mix Loja" format "Sim/Nao"
     with frame f1 width 80 side-label.

{selestab.i vetbcod f1}
/*
update vdti vdtf with frame f1.
if vdtf = ? or vdtf = ? or
vdti > vdtf
then undo.
*/
def temp-table tt-clase like clase.
vcatcod = 31.
disp vcatcod with frame f1.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom with frame f1.
update vsequencia with frame f1.
do on error undo, retry:
update vclacod with frame f1.
if vclacod > 0
then do:
    find clase where clase.clacod = vclacod no-lock no-error.
    if avail clase
    then do:
    for each clase where clase.clasup = vclacod no-lock.
        create tt-clase.
        buffer-copy clase to tt-clase.
    end. 
    end.
    else undo, retry.
end.
if vclacod = 0
then 
do on error undo, retry:
update sclacod with frame f1.
if vclacod > 0
then do:
    find clase where clase.clacod = sclacod no-lock no-error.
    if avail clase
    then do:
        create tt-clase.
        buffer-copy clase to tt-clase.
    end.
    else undo, retry.
end.
end.
end.
update vmix with frame f1.

def var vdirarq as char format "x(40)".
if opsys = "UNIX"
then vdirarq = "/admcom/relat/".
else vdirarq = "l:~\relat~\".
do on error undo:
    update vdirarq label "Local para gerar os arquivos"
        with frame f3 1 down width 80 side-label
        .
    if vdirarq = ""
    then undo.
end.

def temp-table tt-preco
    field etbcod like estab.etbcod
    field procod like produ.procod
    field preco as dec
    field plano as int
    field parcela as dec
    index i1 etbcod procod.
    
def var vpromo as dec.
def var vvenda as dec.
def var vdata as date.
def var vfincod like finan.fincod.
def var vliqui as dec.
def var vparce as dec.
def var ventra as dec.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer btabmix for tabmix.

def temp-table tt-produ
    field procod like produ.procod.
if vsequencia > 0
then do:
    for each ctpromoc where
             ctpromoc.sequencia = vsequencia and
             ctpromoc.linha > 0 and
             ctpromoc.procod > 0
             no-lock:
        create tt-produ.
        tt-produ.procod = ctpromoc.procod.
    end.         
end.    
if vsequencia = 0
then
for each tt-lj no-lock,
    first estab where estab.etbcod = tt-lj.etbcod and
                            estab.etbnom begins "DREBES-FIL" no-lock,
    each estoq where estoq.etbcod = vetbcod and
                     /*(if vmix = no then estoq.estatual > 0 else true)*/
                     estoq.estatual > 0
                     no-lock,
    first produ where produ.procod = estoq.procod no-lock,
    first clase where clase.clacod = produ.clacod no-lock:
    
    if vcatcod > 0 and
       vcatcod <> produ.catcod
    then next.
    if vclacod > 0 and
       vclacod <> clase.clasup
    then next.
    if sclacod > 0 and
       sclacod <> clase.clacod
    then next.

    vfincod = 35.
    if clase.clasup <> 90
    then do:
            find bclase where 
                 bclase.clacod = clase.clasup no-lock  no-error.
            if bclase.clasup <> 90
            then do:
                find cclase where 
                     cclase.clacod = bclase.clasup no-lock  no-error.
                if cclase.clasup <> 90
                then.
                else vfincod = 35. 
            end.
            else vfincod = 35.     
    end.
    else vfincod = 35.

    assign
        vliqui = 0
        ventra = 0
        vparce = 0
        vdata = today.
    vvenda = estoq.estvenda.
    if estoq.estprodat >= today
    then vpromo = estoq.estproper.
    else do:
                vpromo = estoq.estvenda.
                if num-entries(substr(produ.pronom,1,3),"*") = 2
                then vpromo = vpromo * .80.
                else if num-entries(substr(produ.pronom,1,3),"*") = 3
                then vpromo = vpromo * .60.
                else if num-entries(substr(produ.pronom,1,3),"*") = 4
                then vpromo = vpromo * .40.
                vvenda = vpromo.
    end.
    find finan where finan.fincod = vfincod no-lock.
    run gercpg1.p( input finan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).
            
    find first tt-preco where tt-preco.etbcod = estab.etbcod and
                                      tt-preco.procod = produ.procod
                                      no-error.
    if not avail tt-preco
    then do:
                create tt-preco.
                assign
                    tt-preco.etbcod = estab.etbcod
                    tt-preco.procod = produ.procod
                    tt-preco.preco  = vpromo
                    tt-preco.parcela = vparce
                    tt-preco.plano = vfincod
                    .
    end.        
end.
else
for each tt-lj no-lock,
    first estab where estab.etbcod = tt-lj.etbcod and
                            estab.etbnom begins "DREBES-FIL" no-lock,
    each tt-produ no-lock,
    first estoq where estoq.etbcod = vetbcod and
                      estoq.procod = tt-produ.procod and  
                      /*(if vmix = no then estoq.estatual > 0 else true)*/
                      estoq.estatual > 0
                     no-lock,
    first produ where produ.procod = estoq.procod no-lock,
    first clase where clase.clacod = produ.clacod no-lock:
    
    if vcatcod > 0 and
       vcatcod <> produ.catcod
    then next.
    if vclacod > 0 and
       vclacod <> clase.clasup
    then next.
    if sclacod > 0 and
       sclacod <> clase.clacod
    then next.

    vfincod = 87.
    if clase.clasup <> 90
    then do:
            find bclase where 
                 bclase.clacod = clase.clasup no-lock  no-error.
            if bclase.clasup <> 90
            then do:
                find cclase where 
                     cclase.clacod = bclase.clasup no-lock  no-error.
                if cclase.clasup <> 90
                then.
                else vfincod = 88. 
            end.
            else vfincod = 88.     
    end.
    else vfincod = 88.

    assign
        vliqui = 0
        ventra = 0
        vparce = 0
        vdata = today.
    vvenda = estoq.estvenda.
    if estoq.estprodat >= today
    then vpromo = estoq.estproper.
    else do:
                vpromo = estoq.estvenda.
                if num-entries(substr(produ.pronom,1,3),"*") = 2
                then vpromo = vpromo * .80.
                else if num-entries(substr(produ.pronom,1,3),"*") = 3
                then vpromo = vpromo * .60.
                else if num-entries(substr(produ.pronom,1,3),"*") = 4
                then vpromo = vpromo * .40.
                vvenda = vpromo.
    end.
    find finan where finan.fincod = vfincod no-lock.
    run gercpg1.p( input finan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).
            
    find first tt-preco where tt-preco.etbcod = estab.etbcod and
                                      tt-preco.procod = produ.procod
                                      no-error.
    if not avail tt-preco
    then do:
                create tt-preco.
                assign
                    tt-preco.etbcod = estab.etbcod
                    tt-preco.procod = produ.procod
                    tt-preco.preco  = vpromo
                    tt-preco.parcela = vparce
                    tt-preco.plano = vfincod
                    .
    end.        
end.

def var varquivo as char.
def var vpag as int.
def var vpro as int.
for each tt-lj no-lock:
    find first tt-preco where tt-preco.etbcod = tt-lj.etbcod
                no-error.
    if not avail tt-preco then next.

    /*************************38501**********************/


    if vmix
    then do:
        release btabmix.
        find first btabmix where btabmix.tipomix = "M"
                             and btabmix.etbcod = tt-preco.etbcod
                                    no-lock no-error.
                                                        
        if not avail btabmix
        then next.

        release tabmix.
        find first tabmix where tabmix.codmix = btabmix.codmix 
                            and tabmix.promix = tt-preco.procod
                            and tabmix.tipomix = "P"
                                no-lock no-error.

        if not avail tabmix then next.
        
    end.
    

    
    /****************************************************/

    vpag = 0.      
    vpro = 0.      
    
    for each tt-preco where
             tt-preco.etbcod = tt-lj.etbcod use-index i1:
        if vpro = 0
        then do:
            vpag = vpag + 1.
            if opsys = "UNIX"
            then varquivo = vdirarq + "" + string(tt-lj.etbcod,"999") 
                            + "_" + string(vpag) + ".txt" .
            else varquivo = "l:~\relat~\" + string(tt-lj.etbcod,"999") 
                        + "_" + string(vpag) + ".txt" .
      
        end.
        output to value(varquivo) append.
            put  tt-preco.etbcod format "999"   ";"
                 vpag format ">>>9" ";"
                 tt-preco.procod format ">>>>>>99" ";"
                 tt-preco.plano format ">>>9" ";"
                 tt-preco.parcela format ">>,>>9.99" ";"
                 tt-preco.preco   format ">>,>>9.99"
                 skip.
        output close.
        vpro = vpro + 1.
        if vpro = 10
        then vpro = 0.
    end. 
    message color red/with
        varquivo
        view-as alert-box title " Arquivo gerado "
        .
end.
