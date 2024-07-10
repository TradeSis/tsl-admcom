{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial no.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def stream stela.
def var vdata like plani.pladat.

repeat:
    update vdti  label "Data Inicial"
           vdtf  label "Data Final  "
                with frame f-dep centered side-label color blue/cyan row 4.

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""RPRE1""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES PRE-DATADOS"""
            &Width     = "160"
            &Form      = "frame f-cabcab"}


    for each cheque where cheque.chesit = "LIB" and
                          cheque.cheven >= vdti and
                          cheque.cheven <= vdtf
                                        no-lock break by cheque.cheven:
            if cheque.cheetb <> 990
            then next.
            output stream stela to terminal.
            disp stream stela
                 cheque.cheven
                 cheque.clicod
                  with frame fffpla centered 1 down.
            pause 0.
            output stream stela close.
            find banco where banco.bancod = cheque.cheban no-lock no-error.


            display cheque.nome column-label "NOMINAL" format "x(25)"
                    cheque.chenum space(4)
                    banco.bandesc column-label "BANCO"
                    cheque.cheval(total by cheque.cheven) space(4)
                    cheque.cheven space(4)
                                with frame f-imp width 150 down.
    end.
    output close.
end.
