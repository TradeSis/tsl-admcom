{admcab.i}

def var wvlpri      like titulo.titvlpag.
def var wvlpag      like titulo.titvlpag.

def var vdata       like titulo.titdtemi.
DEF VAR vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9".
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.

def temp-table wtit
    field etbcod like titulo.etbcod
    field wpago  like titulo.titvlpag
    field wrec   like titulo.titvlpag.

repeat:
    for each wtit:
        delete wtit.
    end.
    update vetbcod  with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    
    update vdt1 label "Data Incial" colon 16
           vdt2 label "Data Final" with frame f1.
    assign
        vpago = 0
        vdesc = 0
        vjuro = 0.
    do vdata = vdt1 to vdt2:
        
        for each titulo where titulo.etbcobra = vetbcod and
                              titulo.titdtpag = vdata no-lock:
                              
            if titulo.modcod <> "CRE"
            then next.
            if titulo.titpar = 0
            then next.
            if titulo.etbcod = vetbcod or titulo.clifor = 1
            then next.
            
            find first wtit where wtit.etbcod = titulo.etbcod no-error.
            if not avail wtit
            then create wtit.

            wtit.etbcod = titulo.etbcod.
            wtit.wrec = wtit.wrec       + 
                        titulo.titvlpag -
                        titulo.titjuro  + 
                        titulo.titdesc.
        end.
        
        for each titulo use-index titdtpag where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.titdtpag = vdata and
                 titulo.etbcod = estab.etbcod no-lock.

            
            if titulo.titpar = 0
            then next.
           
            if titulo.clifor = 1 or titulo.etbcobra = estab.etbcod
            then next.
            
            find first wtit where wtit.etbcod = titulo.etbcobra no-error.
            if not avail wtit
            then create wtit.
            wtit.etbcod = titulo.etbcobra.
            wtit.wpago = wtit.wpago + titulo.titvlpag
                         - titulo.titjuro + titulo.titdesc.
        end.
        

    end.
    for each wtit by wtit.etbcod:
        display wtit.etbcod column-label "Filial"
                wtit.wrec(total) column-label "Recebido de!Outras Lojas"
                wtit.wpag(total) column-label "Pago em!Outras Lojas"
                    with frame f-tit down centered.
    end.
end.
