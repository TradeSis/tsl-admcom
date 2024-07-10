{admcab.i}
def var dia-c like plani.platot.
def var dia-m like plani.platot.
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
def var vdtimp                  like plani.pladat.
def var totmeta like plani.platot.
def var totvend like plani.platot.
def temp-table wplani
    field   wetbcod  like estab.etbcod
    field   wmeta    as char format "X"
    field   wetbcon  like estab.etbcon format ">>,>>>,>>9.99"
    field   wetbmov  like estab.etbmov format ">>,>>>,>>9.99"
    field   wdia     as int format "99"
    field   wmes     as int format "99"
    field   wmeta-c  like plani.platot
    field   wacum-c  like plani.platot
    field   wmeta-m  like plani.platot
    field   wacum-m  like plani.platot
    field   wdia-c   like plani.platot
    field   wdia-m   like plani.platot.
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
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vdtultatu   as date format "99/99/9999" no-undo.
def stream stela.
def buffer bcontnf for contnf.
repeat:
    for each wplani:
        delete wplani.
    end.
    update vetbi label "Estabelecimento"
           vetbf no-label
            with frame f-etb centered color blue/cyan row 08
                                    title " Filial " side-label.
    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 12
                                    title " Periodo ".
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.
/*        varquivo = "/admcom/relat/conf-4" + string(day(today)). */
        
             if opsys = "UNIX"                                           
                      then varquivo = "/admcom/relat/conf-l4" + string(time). 
                                   else varquivo = "..\relat\conf-w4" + string(time).  
        
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""conf-4""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """PLANILHA DE FECHAMENTO FILIAL """
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
        if estab.etbcod = 22
        then next.
        vdtimp = today.
        vfer = 0.

        find last bplani where bplani.etbcod = estab.etbcod and
                               bplani.movtdc = 5 and
                               month(bplani.pladat) <= month(vdti) no-lock
                                    use-index pladat no-error.

        if avail bplani
        then vdtultatu = bplani.pladat.
                              
        if vdtf > vdtultatu
        then vdtimp = vdtultatu.
        else vdtimp = vdtf.
        vdtimp = vdtf.
        
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
               acum-m  = 0
               dia-m   = 0
               dia-c   = 0.
        
        create wplani.
        assign wplani.wetbcod = estab.etbcod
               wplani.wdia    = day(vdtimp)
               wplani.wmes    = month(vdtimp)
               wplani.wdia-c  = dia-c
               wplani.wdia-m  = dia-m.
        
        /* message estab.etbcod vdia dupdia dupven. */
        find first duplic where duplic.duppc = month(vdti) and
                                duplic.fatnum = estab.etbcod no-lock no-error.
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

    for each wplani by wplani.wetbcod:
        vdia = 0.
        vdia = wplani.wdia.




        if (wplani.wmeta = "C" or
            wplani.wmeta = "") 
        then do: 
            if wplani.wmes <> month(vdtf)
            then wplani.wmeta-c = 0.
            display wplani.wetbcod column-label "Fl" format ">>9"
                    wplani.wetbcon(total) when wplani.wetbcon > 0
                                column-label "META/MES" format ">>,>>>,>>9"
                    (wplani.wmeta-c)(total) 
                                column-label "META" format ">>,>>>,>>9"
                                    with frame f-a down width 140.

            mm-c = mm-c + wplani.wmeta-c.
        end.

        if (wplani.wmeta = "M" or 
            wplani.wmeta = "") 
        then do: 
            if wplani.wmes <> month(vdtf)
            then wplani.wmeta-m = 0.
            display wplani.wetbcod column-label "Fl" format ">>9" 
                    wplani.wetbmov(total) when wplani.wetbmov > 0
                                 column-label "META/MES" format ">>,>>>,>>9"
                    (wplani.wmeta-m)(total) 
                                 column-label "META" format ">>,>>>,>>9"
                    " * " when wplani.wmeta-m <> wplani.wetbmov
                                                          with frame f-a.
            mm-m = mm-m + wplani.wmeta-m.
        end.
    end.
    output close.
    run visurel.p (input varquivo, input "").
  
    /* {mrod.i}  */
end.
 
