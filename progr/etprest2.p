{admbatch.i new}
setbcod = 999.
def var vtipo-proc as char.
vtipo-proc = SESSION:PARAMETER.
  
form vetbcod like estab.etbcod at 5 label "Filial"
     estab.etbnom no-label
     vcatcod as int at 6 label "Setor"
     categoria.catnom no-label
     vsequencia like ctpromoc.sequencia  at 3 label "Promocao"
     vclacod like clase.clacod
     sclacod like clase.clacod label "SubClasse"
     with frame f1 width 80 side-label.

def temp-table tt-clase like clase.
vcatcod = 31.
if vtipo-proc = ""
then do:
{selestab.i vetbcod f1}
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
end. /*** vtipo-proc ***/

else do:
    for each estab where estab.etbcod < 200 no-lock:
        create tt-lj.
        tt-lj.etbcod = estab.etbcod.
    end.     
end.
def var vdirarq as char format "x(40)".
if opsys = "UNIX"
then vdirarq = "/admcom/relat/".
else vdirarq = "l:~\relat~\".

if vtipo-proc = ""
then
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
                     estoq.estatual > 0
                     no-lock,
    first produ where produ.procod = estoq.procod no-lock,
    first clase where clase.clacod = produ.clacod no-lock
            by clase.clasup:
    
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
else
for each tt-lj no-lock,
    first estab where estab.etbcod = tt-lj.etbcod and
                            estab.etbnom begins "DREBES-FIL" no-lock,
    each tt-produ no-lock,
    first estoq where estoq.etbcod = vetbcod and
                      estoq.procod = tt-produ.procod and  
                     estoq.estatual > 0
                     no-lock,
    first produ where produ.procod = estoq.procod no-lock,
    first clase where clase.clacod = produ.clacod no-lock
                    by clase.clasup:
    
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

    vpag = 0.      
    vpro = 0.      
    
    for each tt-preco where
             tt-preco.etbcod = tt-lj.etbcod use-index i1:
        if vpro = 0
        then do:
            vpag = vpag + 1.
            if opsys = "UNIX"
            then varquivo = vdirarq + "r" + string(tt-lj.etbcod,"999") 
                            + "_" + string(vpag) + ".txt" .
            else varquivo = vdirarq + "r" + string(tt-lj.etbcod,"999") 
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
    /*
    message color red/with
        varquivo
        view-as alert-box title " Arquivo gerado "
        .
        */
        
end.

def var varquivo1 as char.
def var v1 as int.
def var v2 as int.
def var v3 as int.
def var v4 as int.
def var vprocod as int extent 4.
def var vseq as int.



def temp-table tt-propromo
    field clacod like clase.clacod
    field seq as int
    field procod like produ.procod
    field pronom like produ.pronom
    field qtdest like estoq.estatual
    field pvenda like estoq.estvenda
    index i1 procod.
    
    for each estab where 
             estab.etbnom begins "DREBES-FIL"     and
             estab.etbcod < 200
             no-lock.
        find first tt-lj where tt-lj.etbcod = estab.etbcod no-lock no-error.
        if not avail tt-lj then next.
        if vtipo-proc <> ""
        then do:
        disp "Gerando arquivos... Aguarde!   Filial: " estab.etbcod
            with frame f-disp1 no-label row 10 centered color message no-box
            1 down width 80.
        pause 0.
        end.    
        for each tt-propromo: delete tt-propromo. end.
        v1 = 1. v2 = 0. v3 = 0. v4 = 0.
        vseq = 0.

        find first tt-preco where tt-preco.etbcod = estab.etbcod
                no-error.
        if not avail tt-preco then next.

        for each tt-propromo: delete tt-propromo. end.
        v1 = 1. v2 = 0. v3 = 0. v4 = 0.
        vseq = 0.

        for each tt-preco where
             tt-preco.etbcod = tt-lj.etbcod use-index i1:

            find produ where produ.procod = tt-preco.procod no-lock no-error.
            if not avail produ then next.
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod
                             no-lock no-error.
            if not avail estoq or estoq.estatual <= 0
            then next.
            find clase where clase.clacod = produ.clacod no-lock no-error.
            if not avail clase then next.
            
            find first tt-propromo where
                       tt-propromo.procod = produ.procod
                       no-error.
            if not avail tt-propromo
            then do:            
                vseq = vseq + 1.
                create tt-propromo.
                assign
                    tt-propromo.seq = vseq
                    tt-propromo.procod = produ.procod
                    tt-propromo.pronom = produ.pronom
                    tt-propromo.qtdest = estoq.estatual
                    tt-propromo.pvenda = estoq.estvenda
                    tt-propromo.clacod = clase.clasup
                    .
            end.
        end.
        v1 = 0.
        /***
        for each tt-propromo where 
                 tt-propromo.procod > 0 no-lock 
                 break by tt-propromo.clacod
                       by tt-propromo.seq:
            find produ where produ.procod = tt-propromo.procod no-lock no-error.
            if not avail produ then next.
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod
                             no-lock no-error.
            if not avail estoq or estoq.estatual <= 0
            then next.
            do v3 = 1 to estoq.estatual:
                if v4 = 0
                then do:
                    output close.
                    v1 = v1 + 1.
                    if opsys = "UNIX"
                    then varquivo = 
                        "/var/www/drebes/intranet/etqverde/arqs/etiquetas-" + 
                                string(day(vdata),"99") +
                               string(month(vdata),"99") +
                               string(year(vdata),"9999") +
                               "-" + string(estab.etbcod,"999") +
                               "-" + string(v1,"999") + ".txt".
                    else varquivo = "l:~\custom~\teste~\etiquetas-" + 
                     string(day(vdata),"99") +
                               string(month(vdata),"99") +
                               string(year(vdata),"9999") +
                               "-" + string(estab.etbcod,"999") +
                               "-" + string(v1,"999") + ".txt".
                    output to value(varquivo).
                    v4 = 1.
                end.
                v2 = v2 + 1.
                put estoq.estvenda format ">>>,>>9.99" " - " estoq.procod ";".
               /* put estoq.estvenda format ">>>,>>9.99"  ";". */
                if v2 = 4
                then do:
                    put skip.
                    v2 = 0.
                    v4 = v4 + 1.
                end.
                if v4 = 18
                then do:
                    /**
                    output close.
                    v1 = v1 + 1.
                    if opsys = "UNIX"
                    then varquivo = "/admcom/custom/teste/etiquetas-" + 
                                string(day(vdata),"99") +
                               string(month(vdata),"99") +
                               string(year(vdata),"9999") +
                               "-" + string(estab.etbcod,"999") +
                               "-" + string(v1,"999") + ".txt".
                    else varquivo = "l:~\custom~\teste~\etiquetas-" + 
                     string(day(vdata),"99") +
                               string(month(vdata),"99") +
                               string(year(vdata),"9999") +
                               "-" + string(estab.etbcod,"999") +
                               "-" + string(v1,"999") + ".txt".
                    output to value(varquivo).
                    **/
                    
                    v4 = 0.
                end.
            end.
            if last-of(tt-propromo.clacod)
            then do:
                put skip.
                    v2 = 0.
                    v4 = v4 + 1.
            end.    
        end.
        /**************************/
        output close.
        ******/
        
        find first tt-propromo no-error.
        if avail tt-propromo
        then do:
        if opsys = "UNIX"
        then varquivo1 = "/admcom/relat/produtos-r-" + 
                        string(day(vdata),"99") +
                   string(month(vdata),"99") +
                   string(year(vdata),"9999") +
                   "-" + string(estab.etbcod,"999") +
                   ".txt".
        else  varquivo1 = "l:~\relat~\produtos-r-" + 
                    string(day(vdata),"99") +
                   string(month(vdata),"99") +
                   string(year(vdata),"9999") +
                   "-" + string(estab.etbcod,"999") +
                   ".txt".

        output to value(varquivo1).
        for each tt-propromo no-lock 
                break by tt-propromo.clacod
                      by tt-propromo.seq:
           find clase where clase.clacod = tt-propromo.clacod no-lock. 
           
           if first-of(tt-propromo.clacod)
           then do:
                disp clase.clacod
                     clase.clanom  
                     with frame f-propromo down no-label.
                     down(1) with frame f-propromo.
            end.
            disp tt-propromo.procod /*column-label "Cod." */
                 tt-propromo.pronom /*column-label "Descricao"*/
                 tt-propromo.pvenda /*column-label "Preco"*/
                 tt-propromo.qtdest /*lumn-label "Qtd." */ format ">>>>>>9"
                 with frame f-propromo1 width 100 down.
           down with frame f-propromo1.      
           if last-of(tt-propromo.clacod)
           then down(1) with frame f-propromo1.
        end.
        output close.
        end.
    end.

if vtipo-proc = ""
then do:
message color red/with
        varquivo skip
        varquivo1
        view-as alert-box title " Arquivo(s) gerado(s) "
        .
end.


