{admcab.i}
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
    field   wacum-m  like plani.platot
    field   wcus-c   like plani.platot
    field   wven-c   like plani.platot
    field   wdes-c   like plani.platot
    field   wacr-c   like plani.platot
    field   wdev-c   like plani.platot
    field   wcus-m   like plani.platot
    field   wven-m   like plani.platot
    field   wdes-m   like plani.platot
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
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def stream stela.
def var vcatcod like produ.catcod.
def buffer bcontnf for contnf.

repeat:
    for each wplani:
        delete wplani.
    end.
    update vetbi label "Estabelecimento"
            with frame f-etb centered color blue/cyan
                                    title " Filial " side-label.
    find estab where estab.etbcod = vetbi no-lock.
    disp estab.etbnom no-label with frame f-etb.
    for each acrfil:
        do transaction:
            delete acrfil.
        end.
    end.
    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".


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

    for each estab where estab.etbcod = vetbi no-lock:

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

                vvldesc  = 0.
                vvlacre = 0.
                if plani.crecod = 1
                then next.

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
                find first contnf where contnf.etbcod = plani.etbcod and
                                        contnf.placod = plani.placod
                                                            no-lock no-error.
                if avail contnf
                then do:
                    for each bcontnf where
                                     bcontnf.etbcod = contnf.etbcod and
                                     bcontnf.contnum = contnf.contnum no-lock:
                        find first bplani where
                                   bplani.etbcod = bcontnf.etbcod and
                                   bplani.placod = bcontnf.placod and
                                   bplani.pladat = plani.pladat   and
                                   bplani.movtdc = plani.movtdc
                                                      no-lock no-error.
                        if not avail bplani
                        then next.

                        vvltotal = vvltotal + (bplani.platot -
                                               bplani.vlserv - bplani.descprod).
                    end.
                    find contrato where contrato.contnum = contnf.contnum
                                                             no-lock no-error.
                    if not avail contrato
                    then next.
                    lfin = yes.
                    lcod = contrato.crecod.
                    vvlcont = contrato.vltotal.
                    valortot = contrato.vltotal.
                    wacr = vvlcont  - vvltotal.
                    wper = plani.platot / vvltotal.
                    wacr = wacr * wper.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.
                else next.
                if contrato.vltotal <= vvltotal
                then next.
                find clien where clien.clicod = contrato.clicod no-lock
                                                    no-error.
                if not avail clien
                then next.

                do transaction:
                    create acrfil.
                    ASSIGN acrfil.Etbcod  = estab.Etbcod
                           acrfil.acrdat  = plani.pladat
                           acrfil.clicod  = clien.clicod
                           acrfil.contnum = contrato.contnum
                           acrfil.acrven  = vvltotal
                           acrfil.acrcon  = contrato.vltotal
                           acrfil.acracr  = (contrato.vltotal -
                                       (plani.platot - plani.vlserv - vvldesc)).
                end.
            end.
        end.
    end.

    run ..\cadas\acr.p.



    varquivo = "i:\admcom\relat\acrfil" + string(day(today)).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""ACRFIL""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE   FILIAL -  ""
                            + string(vetbi,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DE VENDA - PERIODO DE "" +
                             string(vdti,""99/99/9999"") + "" A "" +
                             string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    for each acrfil no-lock use-index ind-2:

        find clien where clien.clicod = acrfil.clicod no-lock no-error.
        if not avail clien
        then next.
        disp acrfil.acrdat
             clien.clicod
             clien.clinom format "x(35)"
             acrfil.contnum column-label "Contrato"
             acrfil.acrven column-label "Vl.Venda"
             acrfil.acrcon column-label "Vl.Contrato"
             acrfil.acracr column-label "Acrescimo" format "->,>>>,>>9.99"
                                            with frame f-imp width 150 down.


        assign acum-m = acum-m + acrfil.acrven
               ven-m  = ven-m  + acrfil.acrcon
               acr-m  = acr-m  + acrfil.acracr.

    end.
    put skip(1)
        fill("-",130) format "x(130)" skip
        "TOTAL......."
         acum-m to 78
         ven-m  to 90
         acr-m  to 104 skip
         fill("-",130) format "x(130)".
    output close.

    message "Mostrar em tela" update sresp.
    if sresp
    then dos silent value("ved " + varquivo + "  > prn").

    message "Listar Relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + "  > prn").
end.
