
/*
Diretorio correto:

/var/www/drebes/arquivosdesenv/etqverde/arqs

*/

def var vdiretorio as char.
vdiretorio = "/var/www/drebes/arquivosdesenv/etqverde/arqs/".

def input parameter p-sequencia like ctpromoc.sequencia.
def input parameter vdata as date.

def var v1 as int.
def var v2 as int.
def var v3 as int.
def var v4 as int.
def var varquivo as char.
def var vprocod as int extent 4.
def var vseq as int.

def buffer bctpromoc for ctpromoc.

def buffer aclasse for clase.
def buffer bclasse for clase.
def buffer cclasse for clase.
def buffer dclasse for clase.

def temp-table tt-proalt
    field clacod like produ.clacod
    field procod like produ.procod
    field preco-ant like hispre.estvenda-ant
    field preco-nov like hispre.estvenda-nov.
    
for each hispre where hispre.dtal = vdata no-lock,
    first produ where 
          produ.procod = hispre.procod and 
          produ.catcod = 31 no-lock by pronom.

    if hispre.estvenda-ant = hispre.estvenda-nov
    then next.
            
    find aclasse where aclasse.clacod = produ.clacod no-lock no-error.
    if not avail aclasse then next.
    find bclasse where bclasse.clacod = aclasse.clasup no-lock no-error.
    find cclasse where cclasse.clacod = bclasse.clasup no-lock no-error.

    find first tt-proalt where
               tt-proalt.procod = hispre.procod
               no-error.
    
    if not avail tt-proalt
    then do:
        create tt-proalt.
        tt-proalt.procod = hispre.procod.
        if avail cclasse
        then tt-proalt.clacod = cclasse.clacod.
        else if avail bclasse
        then tt-proalt.clacod = bclasse.clacod.
        else if avail aclasse
        then tt-proalt.clacod = aclasse.clacod.
        tt-proalt.preco-ant = hispre.estvenda-ant.
        tt-proalt.preco-nov = hispre.estvenda-nov.
    end.
end.

def var vpreco-ant as char.
def var vpreco-nov as char.
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
        disp "Gerando arquivos... Aguarde!   Filial: " estab.etbcod
            with frame f-disp1 no-label row 10 centered color message no-box
            1 down width 80.
        pause 0.    
        for each tt-propromo: delete tt-propromo. end.
        v1 = 1. v2 = 0. v3 = 0. v4 = 0.
        vseq = 0.
        for each tt-proalt:
            find produ where produ.procod = tt-proalt.procod no-lock no-error.
            if not avail produ then next.
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod
                             no-lock no-error.
            if not avail estoq or estoq.estatual <= 0
            then next.
            
            find aux_estoq where aux_estoq.etbcod      = estoq.etbcod and     
                     aux_estoq.procod      = estoq.procod and    
                     aux_estoq.Nome_Campo  = "PRICE_TYPE"        
                     no-lock no-error.                           
 
            if not avail aux_estoq then next.
            if aux_estoq.Valor_Campo <> "C" then next. 
            
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
                    tt-propromo.clacod = tt-proalt.clacod
                    .
            end.
        end.
        v1 = 0.
        for each tt-propromo where 
                 tt-propromo.procod > 0 /*no-lock*/ 
                 break by tt-propromo.clacod
                       by tt-propromo.seq:
            find produ where produ.procod = tt-propromo.procod no-lock no-error.
            if not avail produ then next.
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod
                             no-lock no-error.
            if not avail estoq or estoq.estatual <= 0
            then next.
            find first tt-proalt where
                       tt-proalt.procod = estoq.procod
                       no-error.
            if avail tt-proalt then             
            do v3 = 1 to estoq.estatual:
                if v4 = 0
                then do:
                    output close.
                    v1 = v1 + 1.
                    if opsys = "UNIX"
                    then
                    varquivo = vdiretorio + "etiquetas-31-" + 
                                string(day(vdata),"99") +
                               string(month(vdata),"99") +
                               string(year(vdata),"9999") +
                               "-" + string(estab.etbcod,"999") +
                               "-" + string(v1,"999") + ".txt".
                    else varquivo = "l:~\custom~\teste~\etiquetas-31-" + 
                     string(day(vdata),"99") +
                               string(month(vdata),"99") +
                               string(year(vdata),"9999") +
                               "-" + string(estab.etbcod,"999") +
                               "-" + string(v1,"999") + ".txt".
                    output to value(varquivo).
                    v4 = 1.
                end.
                v2 = v2 + 1.

                assign
                    vpreco-ant = string(tt-proalt.preco-ant,">>>,>>9.99")
                    vpreco-ant = replace(vpreco-ant,",",":")
                    vpreco-ant = replace(vpreco-ant,".",",")
                    vpreco-ant = replace(vpreco-ant,":",".")
                    vpreco-nov = string(tt-proalt.preco-nov,">>>,>>9.99")
                    vpreco-nov = replace(vpreco-nov,",",":")
                    vpreco-nov = replace(vpreco-nov,".",",")
                    vpreco-nov = replace(vpreco-nov,":",".")
                    .
                    
                put trim(vpreco-ant) + " - " +
                    trim(vpreco-nov) + " - " +
                    trim(string(estoq.procod))format "x(60)".

                if v2 = 1
                then do:
                    put skip.
                    v2 = 0.
                    v4 = v4 + 1.
                end.
                if v4 = 10
                then do:
                    v4 = 0.
                end.
            end.
            
            tt-propromo.qtdest = estoq.estatual.
            
            if last-of(tt-propromo.clacod)
            then do:
                put skip.
                    v2 = 0.
                    v4 = v4 + 1.
            end.    
        end.
        /**************************/
        output close.
        
        /*****************
        find first tt-propromo no-error.
        if avail tt-propromo
        then do:
        if opsys = "UNIX"
        then varquivo = vdiretorio + "produtos-31-" + 
                        string(day(vdata),"99") +
                   string(month(vdata),"99") +
                   string(year(vdata),"9999") +
                   "-" + string(estab.etbcod,"999") +
                   ".txt".
        else  varquivo = "l:~\custom~\teste~\produtos-31-" + 
                    string(day(vdata),"99") +
                   string(month(vdata),"99") +
                   string(year(vdata),"9999") +
                   "-" + string(estab.etbcod,"999") +
                   ".txt".

        output to value(varquivo).
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
                 tt-propromo.qtdest /*column-label "Qtd." */ format ">>>>>>9"
                 with frame f-propromo1 width 100 down.
           down with frame f-propromo1.      
           if last-of(tt-propromo.clacod)
           then down(1) with frame f-propromo1.
        end.
        output close.
        end.
        *************/
    end.
