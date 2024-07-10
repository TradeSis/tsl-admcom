{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial yes.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var varquivo as char.
def stream stela.

repeat:
    update vsit  label "Situacao"
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
                with frame f-dep centered side-label color blue/cyan row 4.

    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".

    varquivo = "/admcom/relat/cheli3" + string(mtime).
    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI3""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS - "" + vsitu"
            &Width     = "120"
            &Form      = "frame f-cabcab"}

    for each cheque where cheque.chesit = vsitu and
                          cheque.chepag >= vdti and
                          cheque.chepag <= vdtf
                                        no-lock break by cheque.cheetb
                                                      by cheque.nome:

            if cheque.cheetb = 900
            then next.
            output stream stela to terminal.
            disp stream stela
                 cheque.cheven
                 cheque.clicod
                  with frame fffpla centered 1 down.
            pause 0.
            output stream stela close.

            display cheque.cheetb column-label "Fil" format ">>9"
                    cheque.nome format "x(25)"
                    cheque.clicod space(4)
                    cheque.cheven space(4)
                    cheque.cheval(total) space(4)
                    cheque.chejur(total) space(4)
                    cheque.codcob column-label "Cobr." format ">>9"
                                with frame f-imp width 150 down.
    end.
    output close.
    pause 1 no-message.
    run visurel.p (input varquivo, input "").
end.
