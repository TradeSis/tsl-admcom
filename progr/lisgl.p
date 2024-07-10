{admcab.i}
def var vetbcod like estab.etbcod.
def var varquivo as char format "x(20)".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def temp-table wgloba
    field wetbcod like estab.etbcod
    field wglodat like globa.glodat
    field wtotal  like globa.gloval
    field wtot    like globa.gloval
    field wpre    like globa.gloval
    field wdin    like globa.gloval
    field wcon    like glopre.valpar
    field wade    like glopre.valpar.
repeat:
    for each wgloba:
        delete wgloba.
    end.

    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else display estab.etbnom no-label with frame f1.

    update vdti label "Data Inicial"
           vdtf label "Data Final"
            with frame f-dat centered color blue/cyan row 8
                                    title " Periodo " side-label.


        varquivo = "..\relat\global" + string(day(today)).

        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""LISGL""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """MOVIMENTACOES DE CONSORCIO PERIODO "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        for each globa where globa.glodat >= vdti and
                             globa.glodat <= vdtf and
                             globa.etbcod = estab.etbcod no-lock.
            
            find first wgloba where wgloba.wetbcod = globa.etbcod and
                                    wgloba.wglodat = globa.glodat no-error.
            if not avail wgloba
            then do:
                create wgloba.
                assign wgloba.wetbcod = globa.etbcod
                       wgloba.wglodat = globa.glodat.
            end.
            wgloba.wtotal  = wgloba.wtotal + globa.gloval.

            if substring(string(globa.glogru),1,3) = "888"
            then wgloba.wpre = wgloba.wpre + globa.gloval.

            if substring(string(globa.glogru),1,3) = "999"
            then wgloba.wdin = wgloba.wdin + globa.gloval.

            if substring(string(globa.glogru),1,3) <> "888" and
               substring(string(globa.glogru),1,3) <> "999"
            then wgloba.wtot = wgloba.wtot + globa.gloval.


        end.
        
        for each glopre where glopre.dtpag >= vdti and
                              glopre.dtpag <= vdtf and
                              glopre.etbcod = estab.etbcod and
                              glopre.parcela > 1 no-lock:
                              
            
            find first wgloba where wgloba.wetbcod = glopre.etbcod and
                                    wgloba.wglodat = glopre.dtpag no-error.
            if not avail wgloba
            then do:
                create wgloba.
                assign wgloba.wetbcod = glopre.etbcod
                       wgloba.wglodat = glopre.dtpag.
            end.
            wgloba.wcon    = wgloba.wcon + glopre.valpar.
            wgloba.wtotal  = wgloba.wtotal + glopre.valpar.
        end.
        
        for each glopre where glopre.dtpag >= vdti and
                              glopre.dtpag <= vdtf and
                              glopre.etbcod = estab.etbcod and
                              glopre.parcela = 1 no-lock:
                              
            
            find first wgloba where wgloba.wetbcod = glopre.etbcod and
                                    wgloba.wglodat = glopre.dtpag no-error.
            if not avail wgloba
            then do:
                create wgloba.
                assign wgloba.wetbcod = glopre.etbcod
                       wgloba.wglodat = glopre.dtpag.
            end.
            wgloba.wade = wgloba.wade + glopre.valpar.
            wgloba.wtotal  = wgloba.wtotal + glopre.valpar.
            
        end.
        

    end.
    for each wgloba break by wgloba.wglodat
                          by wgloba.wetbcod:
        disp wgloba.wglodat column-label "Data"
             "Filial - " wgloba.wetbcod column-label "Filial"
             wgloba.wtot(total by wgloba.wglodat)
                                    column-label "Total Ent"
             wgloba.wpre(total by wgloba.wglodat) column-label "Total Pre"
             wgloba.wdin(total by wgloba.wglodat) column-label "Total Din"
             wgloba.wcon(total by wgloba.wglodat) column-label "Total Carne"
             wgloba.wade(total by wgloba.wglodat) column-label "Total Adesao"
             wgloba.wtotal(total by wgloba.wglodat) column-label "Total Geral"
             with frame f-imp width 150 down.
    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").
end.
