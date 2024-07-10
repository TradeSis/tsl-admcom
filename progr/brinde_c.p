{admcab.i}


def temp-table tt-brinde
    field procod like produ.procod.


def var varquivo as char format "x(15)".
def stream stela.
def var vsit as char format "x(15)".
def var vdti like plani.pladat.
def var fila as char.
def var vdtf like plani.pladat.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vetb like estab.etbcod.

def new shared temp-table tt-movim
    field movrec as recid.

 
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
                         
                                        
                find first tt-movim where tt-movim.movrec = recid(movim) 
                            no-error.
                if not avail tt-movim and movim.movpc <= 1 
                then do:
                    create tt-movim.
                    assign tt-movim.movrec = recid(movim).
                end.
        
            end.
        end.
    end.
    
    run brinde_m.p(input vdti,
                   input vdtf).


end.

 