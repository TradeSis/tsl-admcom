{admcab.i}
def var varquivo as char format "x(15)".
def stream stela.
def var vsit as char format "x(15)".
def var vdti like plani.pladat.
def var fila as char.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vetb like estab.etbcod.

def new shared temp-table tt-plani
    field plarec as recid
    field desti  like clien.clicod
        index ind-1 desti.  

 
repeat:

    for each tt-plani:
        delete tt-plani.
    end.
    
    vetb = 0.
    update vetbcod label "Filial" with frame f1 side-label.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1 width 80.
    update vdti label "Data" with frame f1.

    for each plani where plani.movtdc = 5       and
                         plani.etbcod = vetbcod and
                         plani.pladat = vdti    and
                         plani.crecod = 2       no-lock:
                         
        
                         

        find first tt-plani where tt-plani.plarec = recid(plani) no-error.
        if not avail tt-plani
        then do:
            create tt-plani.
            assign tt-plani.plarec = recid(plani)
                   tt-plani.desti  = plani.desti.
        end.
        
    end.

    run venda1_p.p.


end.

 