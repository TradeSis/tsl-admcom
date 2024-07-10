{admcab.i}
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vdata like plani.pladat.
def var vdesc as char format "x(50)".
update vetbcod label "Filial      "  at 10
       vdti    label "Data Inicial" at 10
       vdtf    label "Data Final  " at 10
       vdesc   label "Descricao   " at 10
            with frame f1 side-label
                width 80 color cyan/white.
       

do vdata = vdti to vdtf:


    create dtesp.
    assign dtesp.etbcod = vetbcod
           datesp = vdata 
           dtdes  = vdesc.

end.