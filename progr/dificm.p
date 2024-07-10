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

def temp-table tt-nota
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field numero like plani.numero
    field serie  like plani.serie
    field platot like plani.platot
    field icms   like plani.icms
    field fornom like forne.fornom
    field vobs   as char format "x(50)"
        index ind1 etbcod
                   data.


repeat:
    for each tt-nota:
        delete tt-nota.
    end.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.
    do vdt = vdti to vdtf:
        for each estab where estab.etbcod >= 995 or
                             estab.etbcod = 900 no-lock:
            for each plani where plani.movtdc = 4       and
                                 plani.etbcod = estab.etbcod and
                                 plani.dtinclu = vdt and
                                 plani.notsit  = no no-lock:
                
                find forne where forne.forcod = plani.emite no-lock no-error.
                if plani.notobs[3] = ""
                then next.
                if plani.emite = 5027
                then next.
                create tt-nota.
                assign  tt-nota.etbcod   =  plani.etbcod
                        tt-nota.data     =  plani.dtinclu
                        tt-nota.numero   =  plani.numero
                        tt-nota.serie    =  plani.serie
                        tt-nota.platot   =  plani.platot
                        tt-nota.icms     =  plani.icms
                        tt-nota.fornom   =  forne.fornom
                        tt-nota.vobs     =  plani.notobs[3].

            end.
        end.
    end.

    for each tt-nota use-index ind1:
        
        display tt-nota.etbcod column-label "FL" format ">>9"
                tt-nota.data
                tt-nota.numero
                tt-nota.vobs column-label "OBSERVACAO"  format "x(25)"
                tt-nota.fornom format "x(18)"
                tt-nota.platot
                        with frame f2 down centered width 80.
    end.

end.
