{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial yes.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetb   like estab.etbcod.
def stream stela.
def var vdata like plani.pladat.
def var varquivo as char format "x(30)".


repeat:
    update vsit    label "Situacao" colon 10
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
           vetb  label "Filial" colon 10
                with frame f-dep centered side-label color blue/cyan row 4.
        find estab where estab.etbcod = vetb no-lock no-error.
        display estab.etbnom no-label with frame f-dep.

    varquivo = "/admcom/relat/cheli4" + string(mtime).
    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".
       
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI4""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS"" + "" - "" +
                            string(vsit,""PAG/LIB"") + ""   "" +
                            string(estab.etbnom,""x(20)"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    for each cheque where cheque.chesit = vsitu        and
                          cheque.cheetb = estab.etbcod and
                          cheque.chepag >= vdti        and
                          cheque.chepag <= vdtf
                                        no-lock break by cheque.cheetb
                                                      by cheque.nome:

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
                    cheque.codcob column-label "Cobr." format ">>9"
                                with frame f-imp width 150 down.
    end.
    output close.
    run visurel.p (input varquivo, input "").
end.

