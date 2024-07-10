{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial yes.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vcob    like cobrador.codcob.
def var varquivo as char.
def stream stela.

repeat:
    update vsit    label "Situacao" colon 10
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
           vcob  label "Cobrador" colon 10
                with frame f-dep centered side-label color blue/cyan row 4.
        find cobrador where cobrador.codcob = vcob no-lock no-error.
        display cobrador.nome no-label with frame f-dep.

    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".

    varquivo = "/admcom/relat/cheli5" + string(mtime).
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI5""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS - "" + vsitu +
                            ""   "" + string(cobrador.nome,""x(20)"")"
            &Width     = "120"
            &Form      = "frame f-cabcab"}

    for each cheque where cheque.chesit = vsitu        and
                          cheque.codcob = vcob         and
                          cheque.chepag >= vdti        and
                          cheque.chepag <= vdtf
                                        no-lock by cheque.nome:

            if cheque.cheetb = 900
            then next.
            output stream stela to terminal.
            disp stream stela
                 cheque.cheven
                 cheque.clicod
                  with frame fffpla centered 1 down.
            pause 0.
            output stream stela close.

            display cheque.nome format "x(25)"
                    cheque.cheval(total) space(4)
                    cheque.cheven space(4)
                    (cheque.cheval + cheque.chejur)(total)
                                            column-label "Vl.Pago" space(4)
                    cheque.chejur(total)
                    cheque.cheetb column-label "Fil." format ">>9"
                                with frame f-imp width 150 down.
    end.
    output close.
    pause 1 no-message.
    run visurel.p (input varquivo, input "").
end.

