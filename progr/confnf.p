{admcab.i }
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc format "99".
def var vetbcod like plani.etbcod.

repeat:
    update vetbcod label "Filial" colon 16 
        with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    update vmovtdc label "Tipo de Nota" colon 16
        with frame f1 side-label.
    find tipmov where tipmov.movtdc = vmovtdc no-lock.
    disp tipmov.movtnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final"
                with frame f1 side-label.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = tipmov.movtdc and
                         plani.datexp >= vdti and
                         plani.datexp <= vdtf no-lock:
        disp plani.numero
             plani.serie column-label "S"
             plani.pladat
             plani.datexp
             plani.desti format ">>>>>>999"
             plani.vencod column-label "Vend"
             plani.vlserv column-label "Devol."
             plani.platot(total) with frame f2 down width 80 .
    end.
end.
