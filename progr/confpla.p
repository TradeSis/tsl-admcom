{admcab.i}
def var vfincod like finan.fincod.
   
def var vetbcod like estab.etbcod.
def var vdata   like plani.pladat.

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
def stream stela.
def temp-table wpreco
    field  wcatcod like produ.procod
    field  wetbcod like estab.etbcod
    field  wnumero like plani.numero
    field  wserie  like plani.serie
    field  wvencod like plani.vencod
    field  wprocod like produ.procod
    field  wpronom like produ.pronom
    field  wmovpc  like movim.movpc
    field  wvenda  like estoq.estvenda
    field  wvalor  like plani.platot
    field  wdif    like plani.platot
    field  wcrecod like plani.crecod
    field  wprotot like plani.protot.

repeat with 1 down side-label width 80 row 4 color blue/white:
    for each wpreco:
        delete wpreco.
    end.
    update vetbcod label "Filial" 
           vdata label "Data"
           vfincod label "Plano".
    find estab where estab.etbcod = vetbcod no-lock.

    find first bmovim where bmovim.movdat = vdata no-lock no-error.
    if not avail bmovim
    then leave.

    {mdadmcab.i &Saida     = "printer"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""confpla""
                &Nom-Sis   = """SISTEMA ESTOQUE FILIAL     versao 3.0"""
                &Tit-Rel   = """LISTAGEM DE DIVERGENCIAS DE PRECOS NO DIA "" +
                             STRING(VDATA,""99/99/9999"") +
                              "" NA LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom "
                &Width     = "160"
                &Form      = "frame f-cabcab2"}

    for each plani where plani.movtdc = 5 and
                         plani.etbcod = estab.etbcod and
                         plani.pladat = vdata and
                         plani.pedcod = vfincod no-lock:

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movdat = plani.pladat and
                         movim.movtdc = plani.movtdc no-lock:

        output stream stela to terminal.
        disp stream stela movim.procod with 1 down frame ffff. pause 0.
        output stream stela close.

        find produ of movim no-lock no-error.
        if not avail produ
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

                
        create wpreco.
        assign wpreco.wcatcod = produ.catcod
               wpreco.wetbcod = plani.etbcod
               wpreco.wnumero = plani.numero
               wpreco.wserie  = plani.serie
               wpreco.wprocod = produ.procod
               wpreco.wpronom = produ.pronom
               wpreco.wmovpc  = movim.movpc
               wpreco.wvenda  = vvenda
               wpreco.wvalor  = (movim.movpc - vvenda)
               wpreco.wdif    = ((movim.movpc / vvenda) - 1) * 100
               wpreco.wcrecod = plani.pedcod
               wpreco.wprotot = plani.protot
               wpreco.wvencod = plani.vencod.
    end.
    end.
    
    for each wpreco by wpreco.wcatcod
                    by wpreco.wpronom:

        find produ where produ.procod = wpreco.wprocod no-lock no-error.
        
        if not avail produ
        then next.
        /*
        if produ.catcod = 41
        then do:
            if wpreco.wvalor < 0
            then next.
        end.
        */
        if wpreco.wvalor < 0
        then next.
        
        vfin = 1.
        vpre = 1.
        vent-ven = 0.
        vent-mov = 0.

        find finan where finan.fincod = wpreco.wcrecod no-lock no-error.
        if avail finan
        then do:
             assign vfin = finan.finfat
                    vpre = finan.finnpc.
             if finan.finent
             then assign vent-ven = wpreco.wvenda * vfin
                         vent-mov = wpreco.wmovpc * vfin.
             else assign vent-ven = 0
                         vent-mov = 0.
        end.

        if vpre = 0
        then assign vpre = 1
                    vent-ven = 0
                    vent-mov = 0.

        /*
        if (((wpreco.wmovpc * vfin) * vpre) + vent-mov) -
           (((wpreco.wvenda * vfin) * vpre) + vent-ven) = 0 and
              wpreco.wvalor = 0
        then next.

        if (wpreco.wvenda < wpreco.wmovpc) and
           ( (((wpreco.wvenda * vfin) * vpre) + vent-ven) <
             (((wpreco.wmovpc * vfin) * vpre) + vent-mov) )
        then next.
        */


        display wpreco.wnumero   column-label "Numero"
                wpreco.wserie    column-label "Sr"
                wpreco.wvencod   column-label "Ven" format ">>9"
                wpreco.wprocod
                wpreco.wpronom   format "x(30)"
                wpreco.wvenda    column-label "Preco!Certo"  format ">>,>>9.99"
                wpreco.wmovpc column-label "Preco!Vendido" format ">>,>>9.99"

                wpreco.wvalor column-label "Difer.!Preco" format "->>,>>9.9"

                ((wpreco.wvenda * vfin) * vpre) + vent-ven
                    column-label "Fin.!Certo" format ">>,>>9.99"
                        when wpreco.wcrecod <> 0
                ((wpreco.wmovpc * vfin) * vpre) + vent-mov
                    column-label "Fin.!Vendido" format ">>,>>9.99"
                        when wpreco.wcrecod <> 0

                (((wpreco.wmovpc * vfin) * vpre) + vent-mov) -
                (((wpreco.wvenda * vfin) * vpre) + vent-ven)
                    column-label "Difer.!Finan." format "->>,>>9.9"
                        when wpreco.wcrecod <> 0
                ( 100 - ((wpreco.wmovpc / wpreco.wvenda) * 100))
                    column-label "Dif%" format "->>9.9"
                   wpreco.wcrecod column-label "Pl"
                "___________________________________"
                    column-label "        J U S T I F I C A T I V A"
                    with no-box width 200.
    end.

   
    put skip(7)
        "Data:___/___/___" at 2
        "_______________________________"  at 30 skip
        "           GERENTE             "  at 30.


    output close.
end.
