{admcab.i}
def temp-table tt-estoque
    field etbcod    like estoq.etbcod
    field procod    like estoq.procod
    field catcod    like produ.catcod
    field estatual  like estoq.estatual.

def var vdata       like plani.pladat.
def var vetbcod     like estab.etbcod.
def var vdtini      as date.
def var vdtfin      as date.
def var vcatcod     like produ.catcod.
def var varquivo    as char.
def var vtotprodu   as int.
def var vtotitens   as int.
def var vgtotprodu  as int.
def var vgtotitens  as int.

def buffer bestab for estab.

def temp-table tt-estab
       field etbcod as int.

for each tt-estab:
    delete tt-estab.
end.

form vetbcod label "Filial" colon 18 with frame f1 side-label width 80.
{selestab.i vetbcod f1}.


update vcatcod colon 18 with frame f1 color white/cyan width 80.
find categoria where categoria.catcod = vcatcod no-lock.
display categoria.catnom no-label with frame f1.
display estab.etbnom no-label with frame f1.
update vdtini label "Periodo" colon 18
           vdtfin no-label with frame f1.


for each tt-estoque.

    delete tt-estoque.
end.

varquivo = "/admcom/relat/relprodmov" + string(time).
{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""relprodmov""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """PRODUTOS EM ESTOQUE SEM MOVIMENTO "" +
                                  string(vetbcod,"">>9"") +
                          "" PERIODO DE "" +
                                  string(vdtini,""99/99/9999"")"
            &Width     = "140"
            &Form      = "frame f-cabcab"}



    if vetbcod > 0
    then do:
        for each bestab where bestab.etbcod = vetbcod no-lock:
            create tt-estab.
            buffer-copy bestab to tt-estab.
        end.    
    end.
    else do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        if not avail tt-lj
        then  for each bestab no-lock:
                create tt-estab.
                buffer-copy bestab to tt-estab.
        end. 
        else for each tt-lj where tt-lj.etbcod > 0 no-lock:
                create tt-estab.
                buffer-copy tt-lj to tt-estab.
        end.
    end.


for each tt-estab no-lock.
    for each estoq where etbcod = tt-estab.etbcod and 
                     estoq.estatual > 0 no-lock.
             
        find produ where    produ.procod = estoq.procod and
                            produ.catcod = vcatcod no-lock no-error.
                        
        if not avail produ then next.  
    
        /* Emitente */                 
        find last movim where movim.procod = estoq.procod and
                                movim.emite = estoq.etbcod and
                                movim.datexp >= vdtini      and
                                movim.datexp <= vdtfin
                                no-lock no-error. 
    
        if not avail movim 
        then find last movim where movim.procod = estoq.procod and
                                movim.desti = estab.etbcod and
                                movim.datexp >= vdtini       and
                                movim.datexp <= vdtfin
                                no-lock no-error. 
    
        if not avail movim
        then do:                
            find tt-estoque where tt-estoque.etbcod = estoq.etbcod and
                          tt-estoque.procod = estoq.procod no-lock no-error.
    
            if not avail tt-estoque        
            then do:
                create tt-estoque.
                assign 
                tt-estoque.etbcod = estoq.etbcod
                tt-estoque.procod = estoq.procod
                tt-estoque.catcod = produ.catcod
                tt-estoque.estatual = estoq.estatual.
            end.
        end.
    end. /* estoq */
end.  /* estab */

for each tt-estab no-lock.
    
    disp    tt-estab.etbcod no-label 
            estab.etbnom.
    
end.


for each tt-estoque no-lock 
    break   
            by tt-estoque.etbcod
            by tt-estoque.catcod 
            by tt-estoque.procod.
    find estab where estab.etbcod = tt-estoque.etbcod no-lock.
    find produ where  produ.procod = tt-estoque.procod no-lock.
    find categoria of produ no-lock.
    
         
    if first-of(tt-estoque.etbcod) then  
        disp estab.etbnom with frame f2.
    
    disp    tt-estoque.etbcod 
            tt-estoque.procod format "99999999"
            produ.pronom
            categoria.catnom
            tt-estoque.estatual with frame f2 width 200 down.
    
    vtotprodu = vtotprodu + 1.
    vtotitens = vtotitens + tt-estoque.estatual.
    
    if last-of(tt-estoque.etbcod) 
    then do:
        disp "Total Produtos" colon 27 no-label
            vtotprodu         colon 47 no-label
            with frame f3 width 200 2 down.
        disp "Total de itens" colon 27 no-label           
            vtotitens         colon 47 no-label
            with frame f3 width 2 down.
        vgtotprodu = vgtotprodu + vtotprodu.
        vgtotitens = vgtotitens + vtotitens.
        vtotprodu = 0.
        vtotitens = 0.
    end.
end.

    down 1 with frame f-linc.
    disp "TOTAL GERAL"        colon 27 no-label.
    disp "Total Produtos" colon 27 no-label
            vgtotprodu         colon 47 no-label
            with frame f-linc width 200 2 down.
        disp "Total de itens" colon 27 no-label           
            vgtotitens         colon 47 no-label
            with frame f-linc  width 2 down.
                   
    down 1 with frame f-linc.


if opsys = "UNIX"
then do:
    output close.
    run visurel.p (varquivo,"").
end.
else do:
    {mrod.i}
end.    

