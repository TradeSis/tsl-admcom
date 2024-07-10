{admcab.i}
def var totmeta like plani.platot.
def var totvend like plani.platot.
def temp-table wplani
    field   wdia     as int
    field   wmeta-c  like plani.platot
    field   wvend-c  like plani.platot
    field   wacum-c  like plani.platot
    field   wmeta-m  like plani.platot
    field   wvend-m  like plani.platot
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
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:
    for each wplani:
        delete wplani.
    end.

    update vetbi
            with frame f-etb centered color blue/cyan row 12
                                    title " Filial " side-label.
    find estab where estab.etbcod = vetbi no-lock.
    display estab.etbnom no-label with frame f-etb.



    update meta-m label "Meta Moveis"
           meta-c label "Meta Confeccoes"
           vdia label "Dia" with frame f-meta side-label
                        width 80 color white/cyan.


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
            &Nom-Rel   = ""PLANILHA""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """PLANILHA DE FECHAMENTO"" +
                          string(estab.etbnom) + ""    "" +
                          string(vdia) + "" "" + ""Dias""" +
                          ""    "" string(vdti,""99/99/999"").
            &Width     = "130"
            &Form      = "frame f-cabcab"}


        assign
               vvlvenda = 0
               vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               vldev    = 0
               acum-m   = 0
               acum-c   = 0.

    do dt = vdti to vdtf:

        assign vvlvenda = 0
               vvldesc  = 0
               vvlacre  = 0
               vmov    = 0
               vcon    = 0
               vldev    = 0.

        for each plani where plani.movtdc = 5 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat = dt no-lock:
            vvldesc = 0.
            vvlacre = 0.

            for each bmovim where bmovim.etbcod = plani.etbcod and
                                  bmovim.placod = plani.placod and
                                  bmovim.movtdc = plani.movtdc and
                                  bmovim.movdat = plani.pladat no-lock:

                find produ where produ.procod = bmovim.procod no-lock no-error.
                if avail produ
                then do:
                    vcat = produ.catcod.
                    leave.
                end.
            end.

            output stream stela to terminal.
            disp stream stela
                 plani.etbcod
                 plani.pladat with frame fffpla centered color white/red.
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
                    for each bcontnf where bcontnf.etbcod  = contnf.etbcod and
                                           bcontnf.contnum = contnf.contnum
                                               no-lock:
                        find first bplani where
                                          bplani.etbcod = bcontnf.etbcod and
                                          bplani.placod = bcontnf.placod and
                                          bplani.pladat = plani.pladat   and
                                          bplani.movtdc = plani.movtdc
                                          no-lock no-error.
                        if not avail bplani
                        then next.
                        vvltotal = vvltotal + (bplani.platot - bplani.vlserv).
                    end.
                    find contrato where contrato.contnum = contnf.contnum
                                                     no-lock no-error.
                    if avail contrato
                    then do:

                        find finan where finan.fincod = contrato.crecod
                                                    no-lock no-error.
                        if avail finan
                        then do:
                            lfin = yes.
                            lcod = finan.fincod.
                            vvlcont = contrato.vltotal.
                            valortot = contrato.vltotal.
                        end.

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

            assign vvlvenda = vvlvenda + plani.platot - plani.vlserv.

            if vcat = 31 or
               vcat = 35
            then assign acum-m = acum-m + (plani.platot - plani.vlserv -
                                           vvldesc + vvlacre)
                        vmov   = vmov + (plani.platot - plani.vlserv -
                                           vvldesc + vvlacre).

            else assign vcon  = vcon + (plani.platot - plani.vlserv -
                                        vvldesc + vvlacre)
                        acum-c = acum-c + (plani.platot - plani.vlserv -
                                           vvldesc + vvlacre).
        end.

        create wplani.
        assign wplani.wdia = day(dt).

        if meta-c > 0
        then assign wplani.wmeta-c  = ((meta-c / vdia) * day(dt))
                    wplani.wvend-c  = vcon
                    wplani.wacum-c  = acum-c.

        if meta-m > 0
        then assign wplani.wmeta-m  = ((meta-m / vdia) * day(dt))
                    wplani.wvend-m  = vmov
                    wplani.wacum-m  = acum-m.
    end.

    if meta-m > 0 and
       meta-c > 0
    then put
"        CONFECCOES                                               MOVEIS" SKIP
"        Meta: " meta-c space(39) "Meta: " meta-m skip
"        DATA     META        VENDA        ACUM             "
          "          META       VENDA        ACUM"
         skip fill("-",130) format "x(130)" skip.
    if meta-m > 0 and
       meta-c = 0
    then put
"        MOVEIS" SKIP
"        Meta: " meta-m skip
"        DATA     META        VENDA        ACUM"
         skip fill("-",130) format "x(130)" skip.

    if meta-m = 0 and
       meta-c > 0
    then put
"        CONFECCOES" SKIP
"        Meta: " meta-c skip
"        DATA     META        VENDA        ACUM"
         skip fill("-",130) format "x(130)" skip.

    for each wplani by wplani.wdia:
        if meta-c > 0 and
           meta-m > 0
        then put wplani.wdia
                 wplani.wmeta-c
                 wplani.wvend-c
                 wplani.wacum-c space(15)
                 wplani.wmeta-m
                 wplani.wvend-m
                 wplani.wacum-m skip.

        if meta-c > 0 and
           meta-m = 0
        then put wplani.wdia
                 wplani.wmeta-c
                 wplani.wvend-c
                 wplani.wacum-c skip.

        if meta-c = 0 and
           meta-m > 0
        then put wplani.wdia
                 wplani.wmeta-m
                 wplani.wvend-m
                 wplani.wacum-m skip.
    end.
    if meta-c > 0 and
       meta-m > 0
    then do:
        put SKIP(4)
"       ACUMULADO" skip
"       ---------" skip.
        for each wplani break by wplani.wdia:
            totmeta = totmeta + wplani.wmeta-m + wplani.wmeta-c.
            totvend = totvend + wplani.wvend-m + wplani.wvend-c.
            if last-of(wplani.wdia)
            then display wplani.wdia column-label "Data"
                         totmeta(total)     column-label "Meta"
                         totvend(total)     column-label "Real"
                                with frame f-tot down width 130.
        end.
        totmeta = 0.
        totvend = 0.
    end.

    output close.
end.
