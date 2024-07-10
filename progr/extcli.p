{admcab.i}
def var vtotal like plani.platot.
def var vclicod like clien.clicod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.

repeat:
    update vclicod with frame f1 side-label width 80.
    find clien where clien.clicod = vclicod no-lock.
    disp clien.clinom no-label with frame f1.

    update vdti label "Data Inicial" 
           vdtf label "Data Final"with frame f1.
    vtotal= 0.
    for each titulo where titulo.clifor    = clien.clicod and
                          titulo.titdtpag >= vdti         and
                          titulo.titdtpag <= vdtf         and
                          titulo.titnat = no   no-lock 
                                by titulo.titdtpag desc:
        vtotal = vtotal + (titulo.titvlcob + titulo.titjuro).
        disp titulo.etbcod format ">>9" column-label "Fl"
             titulo.titnum format "x(08)" 
             titulo.titpar format "99" 
             titulo.titdtpag
             titulo.titdtven
             titulo.titvlcob(total) column-label "Principal" format ">>,>>9.99"
             titulo.titjuro(total) format ">,>>9.9"
             (titulo.titvlcob + titulo.titjuro)(total) column-label "Total"
                             format ">>,>>9.99"
             vtotal column-label "Acumul" format ">,>>9.9"
              with frame f2 width 80 down.
    end.
end.            
