
/*
Diretorio correto:

/var/www/drebes/arquivosdesenv/etqverde/arqs

*/

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
    field clacod    like produ.clacod
    field procod    like produ.procod
    field etbcod    like precohrg.etbcod
    .
    
for each precohrg where precohrg.dativig = vdata no-lock,
    first produ where 
               produ.procod = precohrg.procod and produ.catcod = 41 
                        no-lock by pronom.
    find aclasse where aclasse.clacod = produ.clacod no-lock no-error.
    if not avail aclasse then next.
    find bclasse where bclasse.clacod = aclasse.clasup no-lock no-error.
    find cclasse where cclasse.clacod = bclasse.clasup no-lock no-error.

    /*
    find dclasse where dclasse.clacod = cclasse.clasup no-lock no-error.
    */
    
    find first tt-proalt where
               tt-proalt.procod = precohrg.procod and
               tt-proalt.etbcod = precohrg.etbcod
               no-error.
    
    if not avail tt-proalt
    then do:
        create tt-proalt.
        tt-proalt.procod = precohrg.procod.
        tt-proalt.etbcod = precohrg.etbcod.
        /*
        if avail dclasse
        then tt-proalt.clacod = dclasse.clacod.
        else*/
        if avail cclasse
        then tt-proalt.clacod = cclasse.clacod.
        else if avail bclasse
        then tt-proalt.clacod = bclasse.clacod.
        else if avail aclasse
        then tt-proalt.clacod = aclasse.clacod.
        
    end.


end.

for each  tt-proalt.
disp  tt-proalt.
end. pause 2.
def temp-table tt-propromo
    field clacod like clase.clacod
    field seq as int
    field procod like produ.procod
    field etbcod like estab.etbcod
    field pronom like produ.pronom
    field qtdest like estoq.estatual
    field pvenda like estoq.estvenda
    index i1 procod etbcod.

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
        for each tt-proalt where tt-proalt.etbcod = estab.etbcod:
            find produ where produ.procod = tt-proalt.procod no-lock no-error.
            if not avail produ then next.
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod
                             no-lock no-error.
            if not avail estoq or estoq.estatual <= 0
            then next.
            find first tt-propromo where
                       tt-propromo.procod = produ.procod and
                       tt-propromo.etbcod = estab.etbcod
                       no-error.
            if not avail tt-propromo
            then do:            
                vseq = vseq + 1.
                create tt-propromo.
                assign
                    tt-propromo.seq = vseq
                    tt-propromo.procod = produ.procod
                    tt-propromo.etbcod = estab.etbcod
                    tt-propromo.pronom = produ.pronom
                    tt-propromo.qtdest = estoq.estatual
                    tt-propromo.pvenda = estoq.estvenda
                    tt-propromo.clacod = tt-proalt.clacod
                    .
            end.
        end.
        v1 = 0.
        for each tt-propromo where 
                 tt-propromo.etbcod = estab.etbcod and
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
                    then
                    varquivo = 
                    "/var/www/drebes/arquivosdesenv/etqverde/arqs/" +
                    "etiquetas-" + 
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
        find first tt-propromo no-error.
        if avail tt-propromo
        then do:
        if opsys = "UNIX"
        then varquivo = "/var/www/drebes/arquivosdesenv/etqverde/arqs/produtos-" + 
                        string(day(vdata),"99") +
                   string(month(vdata),"99") +
                   string(year(vdata),"9999") +
                   "-" + string(estab.etbcod,"999") +
                   ".txt".
        else  varquivo = "l:~\custom~\teste~\produtos-" + 
                    string(day(vdata),"99") +
                   string(month(vdata),"99") +
                   string(year(vdata),"9999") +
                   "-" + string(estab.etbcod,"999") +
                   ".txt".

        output to value(varquivo).
        for each tt-propromo where tt-propromo.etbcod = estab.etbcod no-lock 
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
