/*  itim/par510.p                       */
{admcab.i}
def var vdtini       as date format "99/99/9999".
def var vdtfim       as date format "99/99/9999".
def var vvalor like tbcntgen.valor.
find first tbcntgen where tbcntgen.tipcon = 510 and
                          tbcntgen.etbcod = 0 no-lock. 
vdtini      = tbcntgen.datini. 
vdtfim      = tbcntgen.datfim. 
vvalor = tbcntgen.valor.
def var vemail as char format "x(50)".
vemail = tbcntgen.campo1[2].

do on error undo with side-label row 4 centered.
    update vdtini label "Data Inicial"  .
    if vdtini = ? or vdtini > today
    then do.
        message "Data Invalida".
        undo.
    end.
    do on error undo .
        update vdtfim label "Data Final"  .
        if vdtfim < vdtini
        then do.
            message "Data Invalida".
            undo.
        end.
    end.
    update vvalor label "Sequencia Anterior Arquivo" format ">>>>>9" .
    update vemail label "E-Mail" .
end.
do on error undo.
    find first tbcntgen where tbcntgen.tipcon = 510 and
                              tbcntgen.etbcod = 0 no-error.
    tbcntgen.datini = vdtini. 
    tbcntgen.datfim = vdtfim.
    tbcntgen.valor = vvalor.
    tbcntgen.campo1[2] = vemail.
    tbcntgen.campo1[1] = "/admcom/tmp/itim-off/ADMCOM_0510_FULL_" +
                         string(tbcntgen.valor,"99999") + ".DAT".
end.
