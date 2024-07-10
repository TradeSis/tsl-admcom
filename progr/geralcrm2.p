{admcab.i}

def var vparticipa as log format "Sim/Nao".

def var vtotalvlcus like plani.platot.
def var vtotal-liq like plani.platot.
def var tot-ven  like plani.platot.
def var tot-mar  like plani.platot.
def var tot-acr  like plani.platot.
def var vvlmarg like plani.platot.
def var vvlperc like plani.platot.
def var dev-m like plani.platot.
def var dev-c like plani.platot.
def var cus-m like plani.platot.
def var cus-c like plani.platot.
def var ven-c like plani.platot.
def var des-c like plani.platot.
def var acr-c like plani.platot.
def var ven-m like plani.platot.
def var des-m like plani.platot.
def var acr-m like plani.platot.
def var varquivo as char format "x(30)".
def var aa-c like plani.platot.
def var aa-m like plani.platot.
def var mm-c like plani.platot.
def var mm-m like plani.platot.
def buffer bplani for plani.
def var xx as i format "99".
def var vfer as int.
def var ii as i.
def var vv as date.
def var vdtimp      as date.
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
    field   wacum-m  like plani.platot
    field   wcus-c   like plani.platot
    field   wven-c   like plani.platot format ">>,>>>,>>9.99"
    field   wdes-c   like plani.platot format ">>,>>9.99"
    field   wacr-c   like plani.platot 
    field   wdev-c   like plani.platot
    field   wcus-m   like plani.platot format ">>>>>,>>9.99"
    field   wven-m   like plani.platot format ">>,>>>,>>9.99"
    field   wdes-m   like plani.platot format ">>,>>9.99"
    field   wacr-m   like plani.platot 
    field   wdev-m   like plani.platot.

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
def var vcatcod like produ.catcod.
def buffer bcontnf for contnf.

repeat:
    for each wplani:
        delete wplani.
    end.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

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

        if opsys = "UNIX"
        then varquivo = "../relat/geral" + string(time).
        else varquivo = "..\relat\geral" + string(time).

        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE ESTOQUE""  + ""       DEPARTAMENTO ""
                            + string(categoria.catcod,""99"")"
            &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") +
                                  ""  Dep. "" + string(vcatcod,""99"")"
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
               aa-m     = 0
               vtotal-liq = 0.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        assign vmov    = 0
               vcon    = 0
               acum-c  = 0
               acum-m  = 0
               cus-m   = 0
               cus-c   = 0
               ven-c   = 0
               des-c   = 0
               acr-c   = 0
               ven-m   = 0
               des-m   = 0
               acr-m   = 0
               dev-m   = 0
               dev-c   = 0.

        do dt = vdti to vdtf:

            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                
                run p-participa-acao (input plani.desti,
                                      input vdti, 
                                      input vdtf, 
                                      output vparticipa).
                if not vparticipa
                then next.
                
                assign vvldesc = 0 
                       vvlacre = 0.

                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                      no-lock:
                    find produ where produ.procod = movim.procod
                                                        no-lock no-error.
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 31.
                        else vcat = produ.catcod.
                        find estoq where estoq.etbcod = plani.etbcod and
                                         estoq.procod = produ.procod
                                                no-lock no-error.
                        if not avail estoq
                        then next.

                        if (vcat = 31 or
                            vcat = 35 or
                            vcat = 50)
                        then cus-m = cus-m + (movim.movqtm * estoq.estcusto).
                        else cus-c = cus-c + (movim.movqtm * estoq.estcusto).
                    end.
                end.

                output stream stela to terminal.
                disp stream stela plani.etbcod
                                  plani.pladat
                                    with frame fffpla centered color white/red.
                pause 0.
                output stream stela close.

                /************* Calculo do acrescimo *****************/

                vvlcont = 0.
                wacr = 0.
                if plani.crecod > 1
                then do:
                    if plani.biss > (plani.platot - plani.vlserv)
                    then assign wacr = plani.biss - 
                                      (plani.platot - plani.vlserv).
                    else wacr = plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.


                if (vcat = 31 or
                    vcat = 35 or
                    vcat = 50)
                then assign acum-m = acum-m + (plani.platot - plani.vlserv -
                                               vvldesc + vvlacre)
                            ven-m  = ven-m + plani.platot
                            des-m  = des-m + vvldesc
                            acr-m  = acr-m + vvlacre
                            dev-m  = dev-m + plani.vlserv.

                else if vcat <> 88
                     then assign
                            acum-c = acum-c + (plani.platot - plani.vlserv -
                                     vvldesc + vvlacre)
                            ven-c  = ven-c + plani.platot
                            des-c  = des-c + vvldesc
                            acr-c  = acr-c + vvlacre
                            dev-c  = dev-c + plani.vlserv.

            end.
        end.

        create wplani.
        assign wplani.wetbcod = estab.etbcod
               wplani.wacum-c  = acum-c
               wplani.wacum-m  = acum-m
               wplani.wcus-c   = cus-c
               wplani.wven-c   = ven-c
               wplani.wdes-c   = des-c
               wplani.wacr-c   = acr-c
               wplani.wdev-c   = dev-c
               wplani.wcus-m   = cus-m
               wplani.wven-m   = ven-m
               wplani.wdes-m   = des-m
               wplani.wacr-m   = acr-m
               wplani.wdev-m   = dev-m.
    end.

    if categoria.catcod = 41
    then do:
        for each wplani by wplani.wetbcod:

            vvlmarg = (wplani.wven-c - wplani.wcus-c).
            vvlperc = (vvlmarg * 100) / wplani.wven-c.
            if vvlperc = ?
            then vvlperc = 0.

            if wplani.wven-c = 0
            then next.

            find estab where estab.etbcod = wplani.wetbcod no-lock no-error.

            disp estab.etbcod column-label "Filial"
                 wplani.wcus-c(total) column-label "Vl.Custo"
                 wplani.wven-c(total) column-label "Vl.Venda"
                 (wplani.wven-c - wplani.wcus-c)(total) column-label "Margem"
                                                format "->,>>>,>>9"
                 vvlperc        when vvlperc >= 0 format "->>9.99%"
                 wplani.wdes-c(total) column-label "Desconto"
                 format ">>>,>>9.99"
                 wplani.wacr-c(total) column-label "Acrescimo"
                 (wplani.wven-c - wplani.wdes-c + wplani.wacr-c) (total)
                                    format "->,>>>,>>9.99"
                                        column-label "Vl.Bruta"
                 ((wplani.wacr-c / wplani.wven-c) * 100)
                                    label "M %" format ">>9.99"
                 wplani.wdev-c(total) column-label "Devolucao"
                        
                 (wplani.wven-c - wplani.wdes-c + wplani.wacr-c
                  - wplani.wdev-c)(total) column-label "Vl.Liq."
                                    format "->,>>>,>>9.99"
                                            with frame f-imp width 150 down.

                tot-ven = tot-ven + wplani.wven-c.
                tot-mar = tot-mar + vvlmarg.
                tot-acr = tot-acr  + wplani.wacr-c.
                vtotalvlcus = vtotalvlcus + wplani.wcus-c.
                vtotal-liq = vtotal-liq + 
                        (wplani.wven-c - wplani.wdes-c + wplani.wacr-c
                  - wplani.wdev-c).
        end.
        display ((tot-mar / tot-ven) * 100) no-label format "->>9.99 %" at 53
                ((tot-acr / tot-ven) * 100) no-label format "->>9.99 %" at 103
                              with frame f-tot width 150 no-label no-box.
        
        run p-final.
        
        assign tot-ven = 0.
               tot-mar = 0.
               tot-acr = 0.
               vtotal-liq = 0.
               vtotalvlcus = 0.
               
    end.
    else do:
        for each wplani by wplani.wetbcod:

            vvlmarg = (wplani.wven-m - wplani.wcus-m).
            vvlperc = (vvlmarg * 100) / wplani.wven-m.
            if vvlperc = ?
            then vvlperc = 0.
            if wplani.wven-m = 0
            then next.


            find estab where estab.etbcod = wplani.wetbcod no-lock no-error.


            disp estab.etbcod column-label "Filial"
                 wplani.wcus-m(total) column-label "Vl.Custo"
                 wplani.wven-m(total) column-label "Vl.Venda"
                 (wplani.wven-m - wplani.wcus-m)(total) column-label "Margem"
                                                format "->,>>>,>>9"
                 vvlperc        when vvlperc >= 0 format "->>9.99%"
                 wplani.wdes-m(total) column-label "Desconto"
                         format ">>>,>>9.99"
                 wplani.wacr-m(total) column-label "Acrescimo"
                 (wplani.wven-m - wplani.wdes-m + wplani.wacr-m) (total)
                                    format "->,>>>,>>9.99"
                                        column-label "Vl.Bruta"
                 ((wplani.wacr-m / wplani.wven-m) * 100)
                                    label "M %" format ">>9.99"
                 wplani.wdev-m(total) column-label "Devolucao"
                 (wplani.wven-m - wplani.wdes-m + wplani.wacr-m
                  - wplani.wdev-m)(total) column-label "Vl.Liq."
                                    format "->,>>>,>>9.99"
                                            with frame f-imp1 width 150 down.

                tot-ven = tot-ven + wplani.wven-m.
                tot-mar = tot-mar + vvlmarg.
                tot-acr = tot-acr  + wplani.wacr-m.
                vtotal-liq = vtotal-liq + (wplani.wven-m - wplani.wdes-m + wplani.wacr-m
                  - wplani.wdev-m).
                vtotalvlcus = vtotalvlcus + wplani.wcus-m.
        end.

        display ((tot-mar / tot-ven) * 100) no-label format "->>9.99 %" at 45
                ((tot-acr / tot-ven) * 100) no-label format "->>9.99 %" at 90
                              with frame f-tot width 150 no-label no-box.
        run p-final.
        
        assign tot-ven = 0.
               tot-mar = 0.
               tot-acr = 0.
               vtotal-liq = 0.
               vtotalvlcus = 0.
    end.

   
    
    output close.
    /*
    dos silent value("type " + varquivo + "  > prn").
    */
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.
end.

procedure p-final:
    put skip(2).
    
    put "MARGEM MES...:" space(2)
          ((  (((tot-acr / tot-ven) * 100) + 100) / 
                      (100 - ((tot-mar / tot-ven) * 100)) - 1) * 100)
                      format "->>9.99 %".
    
    put skip(1).
    
    put "VERBA GERADA.:" (vtotal-liq * (if vcatcod = 31
                                        then 0.65
                                        else 0.54)) format "->>>,>>>,>>9.99".

    put skip.
    
    put "VERBA EFETIVA:" vtotalvlcus format "->>>,>>>,>>9.99".

    put skip.
    
    put "SALDO........:" ((vtotal-liq * (if vcatcod = 31 
                                         then 0.65  
                                         else 0.54)) - vtotalvlcus)
                                         format "->>>,>>>,>>9.99".
    
    put skip(2).
 
end procedure.

procedure p-participa-acao:

    def input  parameter  p-clicod    like clien.clicod.
    def input  parameter  p-dtini     as   date format "99/99/9999".
    def input  parameter  p-dtfin     as   date format "99/99/9999".
    def output parameter p-participa as   log format "Sim/Nao".

    def var vdata1 as date format "99/99/9999".
    def var vdata2 as date format "99/99/9999".
    
    p-participa = no.
    
    for each acao-cli where acao-cli.clicod = p-clicod no-lock.
        find acao where acao.acaocod = acao-cli.acaocod no-lock no-error.
        if avail acao
        then do:   
            do vdata1 = vdti to vdtf:
                do vdata2 = acao.dtini to acao.dtfin:
                    if vdata1 = vdata2
                    then p-participa = yes.
                end.
            end.
        end.
    end.
    
end procedure.
