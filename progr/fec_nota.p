{admcab.i}
def var outras-icms as dec format "->>>,>>9.99".
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def stream sarq.

def var d-dtini     as   date format "99/99/9999" init today   no-undo.
def var i-nota      like plani.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.


def new shared temp-table tt-nota
    field etbcod like estab.etbcod 
    field numero like plani.numero
    field data   like plani.pladat
    field fornom like forne.fornom format "x(20)"
    field emite  like plani.emite
    field rec    as recid
    field base   as dec
    field platot as dec
    field dif    as dec
        index ind1 etbcod
                   data.



repeat:

    for each tt-nota:
        delete tt-nota.
    end.
    
    update vetbcod label "Filial" with frame f1 side-label.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:

        message "Filial nao cadastrada".
        undo, retry.
    
    end.

    display estab.etbnom no-label with frame f1.
    
    update vdti label "Data Inicial" at 1
           vdtf label "Data Final" with frame f1 side-label width 80.
    
    do vdt = vdti to vdtf:
    
        for each plani where plani.movtdc = 4            and 
                             plani.etbcod = estab.etbcod and 
                             plani.pladat = vdt no-lock:
           
            if plani.platot < (plani.bicms + plani.ipi + plani.frete)
            then do:
                find forne where forne.forcod = plani.emite no-lock no-error.
                create tt-nota.
                assign  tt-nota.etbcod   = plani.etbcod
                        tt-nota.data     = plani.pladat
                        tt-nota.numero   = plani.numero
                        tt-nota.emite    = plani.emite
                        tt-nota.fornom   = forne.forfant
                        tt-nota.rec      = recid(plani)
                        tt-nota.base     = (plani.bicms + 
                                            plani.ipi   + 
                                            plani.frete)
                        tt-nota.platot   = plani.platot
                        tt-nota.dif      = (plani.bicms + 
                                            plani.ipi   + 
                                            plani.frete) - plani.platot.


            end.
        end.
    end.

    run tt-fec.p.    

end.
