{admcab.i}
def var vpago like fin.titulo.titvlpag.
def var vdesc like fin.titulo.titvlpag.
def var vjuro like fin.titulo.titvlpag.
 
def var vtotcomp    like fin.titulo.titvlcob.
def var ventrada    like fin.titulo.titvlcob.
def var vdata       like fin.titulo.titdtemi.
def var vdtf        like fin.titulo.titdtemi.
def var vdti        like fin.titulo.titdtemi.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vetbcod like estab.etbcod.
def temp-table tt-tit 
    field empcod like fin.titulo.empcod
    field titnat like fin.titulo.titnat
    field modcod like fin.titulo.modcod
    field etbcod like fin.titulo.etbcod
    field clifor like fin.titulo.clifor
    field titnum like fin.titulo.titnum
    field titpar like fin.titulo.titpar.

repeat:

    for each tt-tit:
        delete tt-tit.
    end.
    
    update vetbcod colon 20
        with frame f1 side-label width 80.
     
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti colon 20 label "Data Inicial"
           vdtf colon 20 label "Data Final" with frame f1.
    assign
        ventrada = 0
        vtotcomp = 0.
    do vdata = vdti to vdtf:
    
        ventrada = 0.
        vtotcomp = 0.
        for each fin.contrato where fin.contrato.etbcod = estab.etbcod and
                                    fin.contrato.dtinicial = vdata .
                assign
                    ventrada = ventrada + contrato.vlentra
                    vtotcomp = vtotcomp + contrato.vltotal .
        end.


        assign vpago = 0
               vdesc = 0
               vjuro = 0.
        
        for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                  fin.titulo.titnat = no and
                                  fin.titulo.modcod = "CRE" and
                                  fin.titulo.titdtpag = vdata and
                                  fin.titulo.etbcobra = vetbcod
                                            no-lock use-index etbcod:
            if fin.titulo.titpar = 0
            then next.
            if fin.titulo.etbcobra <> vetbcod or fin.titulo.clifor = 1
            then next.

            create tt-tit.
            assign tt-tit.empcod = fin.titulo.empcod
                   tt-tit.titnat = fin.titulo.titnat
                   tt-tit.modcod = fin.titulo.modcod
                   tt-tit.etbcod = fin.titulo.etbcod
                   tt-tit.modcod = fin.titulo.modcod
                   tt-tit.clifor = fin.titulo.clifor
                   tt-tit.titnum = fin.titulo.titnum
                   tt-tit.titpar = fin.titulo.titpar.
            
            assign
                vpago = vpago + fin.titulo.titvlpag
                              - fin.titulo.titjuro + fin.titulo.titdesc
                vjuro = vjuro + if fin.titulo.titjuro = fin.titulo.titdesc
                                then 0
                                else fin.titulo.titjuro
                vdesc = vdesc + if fin.titulo.titjuro = fin.titulo.titdesc
                                then 0
                                else fin.titulo.titdesc .
        end.
        
        for each d.titulo where d.titulo.empcod = wempre.empcod and
                                d.titulo.titnat = no      and
                                d.titulo.modcod = "CRE"   and
                                d.titulo.titdtpag = vdata and
                                d.titulo.etbcobra = vetbcod
                                            no-lock use-index etbcod:
            if d.titulo.titpar = 0
            then next.
            if d.titulo.etbcobra <> vetbcod or d.titulo.clifor = 1
            then next.
            find tt-tit where tt-tit.empcod = d.titulo.empcod and
                              tt-tit.titnat = d.titulo.titnat and
                              tt-tit.modcod = d.titulo.modcod and
                              tt-tit.etbcod = d.titulo.etbcod and
                              tt-tit.clifor = d.titulo.clifor and
                              tt-tit.titnum = d.titulo.titnum and
                              tt-tit.titpar = d.titulo.titpar no-error.
            if avail tt-tit
            then next.
                              
            
            assign
                vpago = vpago + d.titulo.titvlpag
                              - d.titulo.titjuro + d.titulo.titdesc
                vjuro = vjuro + if d.titulo.titjuro = d.titulo.titdesc
                                then 0
                                else d.titulo.titjuro
                vdesc = vdesc + if d.titulo.titjuro = d.titulo.titdesc
                                then 0
                                else d.titulo.titdesc.
        end.
        

        display vdata
                vtotcomp column-label "Val.Compra"  format ">>,>>9.99"
                vpago    column-label "Val.Pago"    format ">>,>>9.99"
                ventrada column-label "Val.Entrada" format ">>,>>9.99"
                vjuro    column-label "Val.Juro"    format ">>,>>9.99" 
                vdesc    column-label "Val.Desc."   format ">>,>>9.99" 
                    with frame ff 10 down width 80.    
        down with frame ff.            
    end.
 
    
end.
