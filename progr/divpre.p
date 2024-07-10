{admcab.i}
def input parameter vetbcod like estab.etbcod.
def input parameter vdata   like plani.pladat.

def var vent-ven like contrato.vlentra.
def var vent-mov like contrato.vlentra.

def var vfin like finan.finfat.
def var vpre like finan.finnpc.
def var vperc  like estoq.estproper format "->>9.99".
def var totglo like globa.gloval.
def var vvenda like estoq.estvenda.
def var    vqtdcon    as i label "QTD".
def var    vvalcon    as dec label "VALOR".
def var    vqtdconesp as i label "QTD".
def var    vvalconesp as dec label "VALOR".
def buffer btitulo for titulo.
def buffer bcontrato for contrato.
def buffer bmovim for movim.
def var wpla like contrato.crecod.
def var vlpres      like plani.platot.
def var vpago       like titulo.titvlpag.
def var vdesc       like titulo.titdesc.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vmodcod     like titulo.modcod.
def var conta1      as integer.
def var conta2      as integer.
def var conta4      as integer.

find estab where estab.etbcod = vetbcod no-lock.

find first bmovim where bmovim.movdat = vdata no-lock no-error.
if not avail bmovim
then leave.

for each plani where plani.movtdc = 5 and
                     plani.etbcod = estab.etbcod and
                     plani.pladat = vdata no-lock:

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movdat = plani.pladat and
                         movim.movtdc = plani.movtdc no-lock:


        wpla = 0.

        find produ of movim no-lock no-error.
        if not avail produ
        then next.

        if produ.procod = 454478 or
           produ.procod = 457331 or
           produ.procod = 401425
        then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = movim.procod no-lock no-error.
        if not avail estoq
        then next.

        vvenda = ESTOQ.ESTVENDA.
        if estprodat <> ?
        then if estprodat >= VDATA
             then vvenda = estoq.estproper.
             else vvenda = estoq.estvenda.


        find first contnf where contnf.etbcod = plani.etbcod and
                                contnf.placod = plani.placod no-lock no-error.

        if avail contnf
        then do:
            find contrato of contnf no-lock no-error.
            if avail contrato
            then wpla = contrato.crecod.
        end.


        if wpla <> 72 and
           wpla <> 16 and
           wpla <> 73 and
           wpla <> 74 and
           wpla <> 40
        then do:

            if vvenda = movim.movpc
            then next.
            if plani.crecod = 1 and
               estoq.estrep > 0 and
               estoq.estinvdat >= today and
               estoq.estinvdat <> ?
            then do:
                if movim.movpc >= estoq.estrep
                then next.
            end.

           if produ.pronom begins "Saldo"
           then next.
           /*
            if produ.proabc = "B" and produ.catcod <> 41
            then next.
             */
            if plani.crecod = 1 and
               produ.etccod = 2 and
               ( 100 - ((movim.movpc / vvenda) * 100)) <= 54
            then next.

            if (vvenda - movim.movpc) < 1
            then next.



            if produ.etccod = 2 and
              ( 100 - ((movim.movpc / vvenda) * 100)) <= 33 and
              (wpla = 56 or
               wpla = 57)
            then next.

            if produ.etccod = 2 and
               ( 100 - ((movim.movpc / vvenda) * 100)) <= 18 and
               (wpla = 60 or
                wpla = 61)
            then next.
        end.


        find divpre where divpre.etbcod = plani.etbcod and
                          divpre.placod = plani.placod and
                          divpre.procod = movim.procod no-error.
        if not avail divpre
        then do transaction:
            create divpre.
            assign divpre.etbcod = plani.etbcod
                   divpre.placod = plani.placod
                   divpre.procod = produ.procod
                   divpre.movpc  = movim.movpc
                   divpre.prefil = vvenda
                   divpre.fincod = wpla
                   divpre.divdat = plani.pladat
                   divpre.datexp = today
                   divpre.visto  = no.

        end.
    end.

end.
