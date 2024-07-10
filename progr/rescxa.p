{admcab.i }

def var vdataini        like titulo.cxmdat.
def var vdatafim        like titulo.cxmdat.
def var vdata           like titulo.cxmdat.
def var i               as integer.
def var tcob            like titulo.titvlcob.
def var tjur            like titulo.titjuro.
def var tdes            like titulo.titdesc.
def var vjuro           like titulo.titdesc.
def var vdesc           like titulo.titdesc.

def temp-table wfres
    field    wfcxacod       like titulo.cxacod
    field    wfetbcod       like titulo.etbcod
    field    wfdata         like titulo.cxmdat
    field    wfcob          like titulo.titvlcob
    field    wfjur          like titulo.titjuro
    field    wfdes          like titulo.titdesc.

/*form  wfres.wfcxacod  column-label "Caixa"
      wfres.wfetbcod
      estab.etbnom
      wfres.wfdata    column-label "Data"
      wfres.wfcob     column-label "Valor Pago"
      wfres.wfjur     column-label "Valor Juro"
      wfres.wfdes     column-label "Valor Desconto"
      with width 133 frame flin2.*/

update vdataini colon 20    label "Data Inicial"
       vdatafim colon 20    label "Data Final"
       with side-label row 4 color blue/cyan centered.

do vdata = vdataini to vdatafim:
        FOR EACH ESTAB where estab.etbcod =  1 or
                             estab.etbcod =  6 or
                             estab.etbcod =  7 or
                             estab.etbcod = 15 or
                             estab.etbcod = 17 :
            do i = 1 to 3:
                assign
                    tcob = 0
                    tjur = 0
                    tdes = 0.
                    pause 0.

                for each titulo where titulo.etbcod = estab.etbcod  and
                                      titulo.cxacod = i             and
                                      titulo.cxmdat = vdata:

                    if titulo.titdtpag = ?
                    then next.
                    if titulo.titpar    = 0
                    then next.
                    if titulo.clifor = 1
                    then next.
                    /*
                    if titulo.etbcobra <> ESTAB.etbcod
                    then next .
                    */

                    find clien where clien.clicod = titulo.clifor no-error.
                    vjuro = if titulo.titjuro = titulo.titdesc
                            then 0
                            else titulo.titjuro.
                    vdesc = if titulo.titjuro = titulo.titdesc
                            then 0
                            else titulo.titdesc.
                    assign
                        tcob = tcob + titulo.titvlcob
                        tjur = tjur + vjuro
                        tdes = tdes + vdesc.
                end.

                if tcob <> 0
                then do:
                    create wfres.
                    assign  wfcxacod = i
                            wfetbcod = 1
                            wfdata   = vdata
                            wfcob    = tcob
                            wfjur    = tjur
                            wfdes    = tdes.
                end.
            end.
        END.
 end.

    {mdadmcab.i
        &Saida     = "PRINTER"
        &Page-Size = "64"
        &Cond-Var  = "133"
        &Page-Line = "66"
        &Nom-Rel   = """PAGMAG"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO DE DIGITACAO DE PAGAMENTOS"""
        &Width     = "133"
        &Form      = "frame f-cabLOJ"}

    for each wfres.
        find estab where estab.etbcod = wfres.wfetbcod no-lock.

        display     wfres.wfcxacod  column-label "Caixa"
                    wfres.wfetbcod
                    estab.etbnom
                    wfres.wfdata    column-label "Data"
                    wfres.wfcob     column-label "Valor Pago"
                    wfres.wfjur     column-label "Valor Juro"
                    wfres.wfdes     column-label "Valor Desconto"
                    with width 133 frame flin2 DOWN.
      DOWN WITH FRAME FLIN2.
    end.
