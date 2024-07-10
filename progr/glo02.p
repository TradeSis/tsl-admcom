{admcab.i}
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

    update vdti label "Data Inicial"
           vdtf label "Data Final"
            with frame f-dat centered color blue/cyan row 8
                                    title " Periodo " side-label.


        varquivo = "..\relat\glo" + string(day(today)).

        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""glo02""
            &Nom-Sis   = """SISTEMA DE CONSORCIO"""
            &Tit-Rel   = """LISTAGEM DE ADESAO PERIODO "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}
        for each estab no-lock,
            each globa where globa.glodat >= vdti and
                             globa.glodat <= vdtf and
                             globa.etbcod = estab.etbcod and
                             ( substring(globa.glogr,1,3) = "888" or
                               substring(globa.glogr,1,3) = "999" )
                          /* globa.vencod <> 0 */
                                    no-lock break by globa.etbcod
                                                  by globa.vencod.

  
            find func where func.etbcod = estab.etbcod and
                            func.funcod = globa.vencod no-lock no-error.
            display globa.etbcod
                    globa.vencod when globa.vencod <> 0 column-label "Vend."
                    func.funnom when avail func
                    globa.glodat
                    globa.glopar
                    globa.glocot
                    globa.gloval(total by globa.vencod)
                    globa.glocon(total by globa.vencod) when globa.vencod <> 0
                            with frame f-glo down width 200.
        end.
    output close.   
    dos silent value("type " + varquivo + "  > prn"). 
end.
