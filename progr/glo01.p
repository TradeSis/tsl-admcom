{admcab.i }
def var varquivo as char format "x(20)".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vetbcod like estab.etbcod.
def temp-table wgloba
    field wetbcod like estab.etbcod
    field wglodat like globa.glodat
    field wtotal  like globa.gloval
    field wtot    like globa.gloval
    field went    like globa.gloval.
repeat:
    for each wgloba:
        delete wgloba.
    end.

    update vetbcod with frame f-dat.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f-dat.
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
            &Nom-Rel   = ""glo01""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """MOVINTACOES DE CONSORCIO PERIODO "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}

        for each globa where globa.glodat >= vdti and
                             globa.glodat <= vdtf and
                             globa.etbcod = estab.etbcod
                                    no-lock break by globa.glodat.

            display globa.etbcod
                    globa.glodat
                    globa.glopar
                    globa.glogru
                    globa.glocot
                    globa.gloval(total by globa.glodat)
                            with frame f-glo down width 200.
        end.
    output close.
    dos silent value("type " + varquivo + "  > prn").
end.
