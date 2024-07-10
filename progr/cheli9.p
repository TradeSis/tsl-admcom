{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial yes.

def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".

def var vdtveni    as date format "99/99/9999".
def var vdtvenf    as date format "99/99/9999".
def var varquivo as char.



def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def stream stela.
def var vdata like plani.pladat.

repeat:
    update vsit    label "Situacao" skip
           "Periodo de Pagamento : "
           vdti  no-label 
           vdtf  no-label    skip
           "Periodo de Vencimento: "
           vdtveni no-label
           vdtvenf no-label
                with frame f-dep centered side-label color blue/cyan row 4.

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        if opsys = "UNIX"
        then varquivo = "/admcom/relat/cheli" + string(time).
        else varquivo = "l:~\relat~\cheli" + string(time).
    
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "135"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI9""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS"" + "" - "" +
                            string(vsit,""PAG/LIB"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}


    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".


    for each cheque where cheque.chesit = vsitu    and
                          cheque.chepag >= vdti    and
                          cheque.chepag <= vdtf    and
                          cheque.cheven >= vdtveni and
                          cheque.cheven <= vdtvenf 
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

            display cheque.cheetb column-label "Fil"
                    cheque.nome format "x(25)"
                    cheque.clicod space(4)
                    cheque.cheven space(4)
                    cheque.cheval(total by cheetb) space(4)
                    cheque.chejur(total by cheetb) space(4)
                    cheque.codcob column-label "Cobr."
                                with frame f-imp width 150 down.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.
end.
