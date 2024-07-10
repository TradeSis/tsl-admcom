{admcab.i}


def var varquivo as char.
def temp-table tt-brinde
    field procod like produ.procod.

def stream stela.
def var vsit as char format "x(15)".
def var vdti like plani.pladat.
def var fila as char.
def var vdtf like plani.pladat.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vetb like estab.etbcod.

def new shared temp-table tt-movim
    field etbcod like estab.etbcod
    field movqtm like movim.movqtm
    field procod like produ.procod
        index ind-1 etbcod
                    procod.

 
repeat:

        
    for each tt-brinde:
        delete tt-brinde.
    end.
    
    
    input from ..\progr\brinde.txt.
    repeat:
        create tt-brinde.
        import tt-brinde.
    end.
    input close.

    for each tt-brinde.

        find produ where produ.procod = tt-brinde.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-brinde.
            next.
        end.
    
    end.    
 
 
    
    for each tt-movim:
        delete tt-movim.
    end.
    
    vetb = 0.
    update vetbi label "Filial"
           vetbf label "Filial" with frame f1 side-label width 80.
    
    update vdti label "Data Inicial" 
           vdtf label "Data Final" with frame f1.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
    
        for each tt-brinde:
            for each movim where movim.movtdc = 5            and
                                 movim.etbcod = estab.etbcod and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        and
                                 movim.procod = tt-brinde.procod no-lock:
                
                if movim.movpc > 1
                then next.
                 
         
                                        
                find first tt-movim where tt-movim.etbcod = movim.etbcod and
                                          tt-movim.procod = movim.procod
                                                        no-error.
                if not avail tt-movim
                then do:
                    create tt-movim.
                    assign tt-movim.procod = movim.procod
                           tt-movim.etbcod = movim.etbcod.
                end.
                
                tt-movim.movqtm = tt-movim.movqtm + movim.movqtm.
                
                
            end.
        end.
    end.
 
    varquivo = "..\relat\brinde" + string(time).


    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = """relbri"""
        &Nom-Sis   = """SISTEMA DE VENDAS"""
        &Tit-Rel   = """VENDAS DE BRINDES "" +
                      ""LOJA "" + string(vetbi,"">>9"")
                        + "" - "" + string(vetbf,"">>9"")  + "" DE "" + 
                        string(vdti) + "" A "" + string(vdtf) "
        &Width     = "130"
        &Form      = "frame f-cab"}

    for each tt-movim break by tt-movim.etbcod:
        find estoq where estoq.etbcod = tt-movim.etbcod and
                         estoq.procod = tt-movim.procod no-lock no-error.
        if not avail estoq
        then next.
        
        find produ where produ.procod = tt-movim.procod no-lock no-error.
        
        if first-of(tt-movim.etbcod)
        then do:
            display "F I L I A L   : " tt-movim.etbcod format ">>9"
                        with frame f-estab no-label.
        end.

        display tt-movim.procod
                produ.pronom when avail produ
                tt-movim.movqtm(total by tt-movim.etbcod) 
                                                column-label "Quantidade"
                (tt-movim.movqtm * estoq.estcusto)(total by tt-movim.etbcod) 
                        column-label "Valor Custo"
                            with frame fa down width 137.
                            
                
    
    end.
    output close.
    {mrod.i}


    
end.

 