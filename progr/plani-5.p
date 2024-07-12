{admcab.i}
def var aa-c like plani.platot.
def var aa-m like plani.platot.

def var mm-c like plani.platot.
def var mm-m like plani.platot.

def buffer bplani for plani.
def var xx as i format "99".
def var vfer as int.
def var ii as i.
def var vv as date.
def var vdtimp                  as date.
def var totmeta like plani.platot.
def var totvend like plani.platot.
def temp-table wplani
    field   wetbcod  like estab.etbcod
    field   wmeta    as char format "X"
    field   wetbcon  like estab.etbcon format ">>,>>>,>>9.99"
    field   wetbmov  like estab.etbmov format ">>,>>>,>>9.99"
    field   wdia     as int format "99"
    field   wmeta-c  like plani.platot
    field   wacum-c  like plani.platot
    field   wmeta-m  like plani.platot
    field   wacum-m  like plani.platot.

def var dt     like plani.pladat.
def var acum-c like plani.platot.
def var acum-m like plani.platot.
def var vdia as int format ">9".
def var meta-c like plani.platot.
def var meta-m like plani.platot.
def var vcon like plani.platot.
def var vmov like plani.platot.
def buffer cmovim for movim.
def var vcat like produ.catcod initial 41.
def var lfin as log.
def var lcod as i.
def var vok as l.

def var vldev like plani.vlserv.
def buffer bmovim for movim.
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def stream stela.
def buffer bcontnf for contnf.

repeat:
    for each wplani:
        delete wplani.
    end.

    update vetbi label "Estabelecimento"
           vetbf no-label
            with frame f-etb centered color blue/cyan row 12
                                    title " Filial " side-label.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""PLANI-4""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """PLANILHA DE FECHAMENTO FILIAL - "" +
                          string(vetbi) + "" A "" +
                          string(vetbf) + "" VENDAS ATE  "" +
                          string(vdtf,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}


        assign vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               acum-m   = 0
               acum-c   = 0
               mm-c     = 0
               mm-m     = 0
               aa-c     = 0
               aa-m     = 0.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.

        if not avail duplic
        then next.
        vdtimp = vdtf.
        vfer = 0.
        ii = 0.
        vfer = 0.
        vdia = 0.
        do vv = vdti to vdtimp:
           if weekday(vv) = 1
           then ii = ii + 1.
           find dtextra where dtextra.exdata  = vv no-error.
           if avail dtextra
           then vfer = vfer + 1.
           find dtesp where dtesp.datesp = vv and
                            dtesp.etbcod = estab.etbcod no-lock no-error.
           if avail dtesp
           then vfer = vfer + 1.
        end.

        vdia = int(day(vdtimp)) - ii - vfer.

        assign vmov    = 0
               vcon    = 0
               acum-c  = 0
               acum-m  = 0.

        do dt = vdti to vdtimp:

            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                vvldesc  = 0.
                vvlacre = 0.

                for each bmovim where bmovim.etbcod = plani.etbcod and
                                      bmovim.placod = plani.placod and
                                      bmovim.movtdc = plani.movtdc and
                                      bmovim.movdat = plani.pladat no-lock:

                    find produ where produ.procod = bmovim.procod
                                                        no-lock no-error.
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 88.
                        else vcat = produ.catcod.
                        leave.
                    end.
                end.

                output stream stela to terminal.
                disp stream stela plani.etbcod
                                  plani.pladat
                                    with frame fffpla centered color white/red.
                pause 0.
                output stream stela close.

                /************* Calculo do acrescimo *****************/

                vvltotal = 0.
                vvlcont = 0.
                wacr = 0.
                if plani.crecod > 1
                then do:
                    find first contnf where contnf.etbcod = plani.etbcod and
                                            contnf.placod = plani.placod
                                                            no-lock no-error.
                    if avail contnf
                    then do:
                        for each bcontnf where
                                         bcontnf.etbcod = contnf.etbcod and
                                         bcontnf.contnum = contnf.contnum
                                                                      no-lock:
                            find first bplani where
                                        bplani.etbcod = bcontnf.etbcod and
                                        bplani.placod = bcontnf.placod and
                                        bplani.movtdc = plani.movtdc   and
                                        bplani.pladat = plani.pladat
                                                      no-lock no-error.
                            if not avail bplani
                            then next.
                            vvltotal = vvltotal +
                                        (bplani.platot - bplani.vlserv).
                        end.
                        find contrato where contrato.contnum = contnf.contnum
                                                             no-lock no-error.
                        if avail contrato
                        then do:
                            /*
                            find finan where finan.fincod = contrato.crecod
                                                        no-lock no-error.
                            if avail finan
                            then do:
                            */
                                lfin = yes.
                                lcod = contrato.crecod.  /* finan.fincod. */
                                vvlcont = contrato.vltotal.
                                valortot = contrato.vltotal.
                            /*
                            end.
                            */
                            wacr = vvlcont  - vvltotal.

                            wper = plani.platot / vvltotal.

                            wacr = wacr * wper.

                        end.
                        else do:
                            wacr = plani.acfprod.
                            valortot = plani.platot.
                        end.

                        if wacr < 0 or wacr = ?
                        then wacr = 0.

                        assign vvldesc  = vvldesc  + plani.descprod
                               vvlacre  = vvlacre  + wacr.
                    end.
                end.


                if (vcat = 31 or
                    vcat = 35 or
                    vcat = 50)
                then assign acum-m = acum-m + (plani.platot - plani.vlserv -
                                                           vvldesc + vvlacre)
                     vmov   = vmov + (plani.platot - plani.vlserv -
                                           vvldesc + vvlacre).

                else if vcat <> 88
                     then assign vcon  = vcon + (plani.platot - plani.vlserv -
                                         vvldesc + vvlacre)
                                acum-c = acum-c + (plani.platot - plani.vlserv -
                                         vvldesc + vvlacre).
            end.
        end.

        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.

        create wplani.
        assign wplani.wetbcod = estab.etbcod
               wplani.wdia    = day(vdtimp).
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod
                                        no-lock no-error.
        if avail duplic
        then assign wplani.wetbcon = duplic.dupval
                    wplani.wetbmov = duplic.dupjur.

        if duplic.dupval > 0 and
           duplic.dupjur = 0
        then wplani.wmeta = "C".

        if duplic.dupval = 0 and
           duplic.dupjur > 0
        then wplani.wmeta = "M".


        if duplic.dupval > 0
        then assign wplani.wmeta-c  = ((duplic.dupval / duplic.dupdia) * vdia).

        wplani.wacum-c  = acum-c.


        if duplic.dupjur > 0
        then assign wplani.wmeta-m  = ((duplic.dupjur / duplic.dupdia) * vdia).

        wplani.wacum-m  = acum-m.


    end.

    put
"              CONFECCOES                                     MOVEIS" SKIP
         fill("-",130) format "x(130)" skip.

        for each wplani by wplani.wetbcod:
            vdia = 0.
            vdia = wplani.wdia.




            if (wplani.wmeta = "C" or
                wplani.wmeta = "") or
                wplani.wacum-c > 0
            then do:
                 display wplani.wetbcod column-label "Estab."
                         wplani.wetbcon(total) when wplani.wetbcon > 0
                                column-label "META/MES"
                        (wplani.wmeta-c)(total) when wplani.wacum-c > 0
                                        column-label "META"
                        (wplani.wacum-c)(total) column-label "ACUM"
                        "(" wplani.wdia no-label ")"
                        (((wplani.wacum-c / wplani.wmeta-c) * 100) - 100)
                            when wplani.wacum-c > 0
                        format "->9.99%" column-label " % "
                                    with frame f-a down width 140.

                mm-c = mm-c + wplani.wmeta-c.
                aa-c = aa-c + wplani.wacum-c.
            end.

            if (wplani.wmeta = "M" or
                wplani.wmeta = "") or
                wplani.wacum-m > 0
            then do:
                 display wplani.wetbcod column-label "Estab."
                         wplani.wetbmov(total) when wplani.wetbmov > 0
                                    column-label "META/MES"
                        (wplani.wmeta-m)(total) when wplani.wacum-m > 0
                                    column-label "META"
                        (wplani.wacum-m)(total) column-label "ACUM"
                        "(" vdia no-label ")"
                        (((wplani.wacum-m / wplani.wmeta-m) * 100) - 100)
                            when wplani.wacum-m > 0
                        format "->9.99%" column-label " % " with frame f-a.
                aa-m = aa-m + wplani.wacum-m.
                mm-m = mm-m + wplani.wmeta-m.
            end.
        end.
        display (((aa-c / mm-c) * 100) - 100) at 55
                        format "->9.99%" no-label
                (((aa-m / mm-m) * 100) - 100) at 110
                        format "->9.99%" no-label with frame f-tot no-box
                            no-label width 140.
        totmeta = 0.
        totvend = 0.

    output close.
end.