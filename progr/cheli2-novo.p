{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial no.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetb   like estab.etbcod.
def stream stela.
def var vdata like plani.pladat.
def var varquivo as char.

repeat:
    update vsit    label "Situacao" colon 10
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
           vetb  label "Filial" colon 10
                with frame f-dep centered side-label color blue/cyan row 4.
        find estab where estab.etbcod = vetb no-lock no-error.
        display estab.etbnom no-label with frame f-dep.

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/che." + string(time).
 else
 varquivo = "l:\relat\che" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI2""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS"" + "" - "" +
                            string(vsit,""PAG/LIB"") + ""   "" +
                            string(estab.etbnom,""x(20)"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".




    for each cheque where cheque.chesit = vsitu        and
                          cheque.cheetb = estab.etbcod and
                          cheque.cheven >= vdti        and
                          cheque.cheven <= vdtf
                                        no-lock break by cheque.cheetb
                                                      by cheque.nome:

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
                    cheque.cheval(total) space(4)
                    cheque.cheemi space(4)
                    cheque.cheven space(4)
                    cheque.cheban space(4)
                    cheque.cheage space(4)
                    cheque.chenum space(4)
                    cheque.checid format "x(12)"
                    cheque.chealin column-label "Alin"
                    cheque.codcob column-label "Cobr."
                                with frame f-imp width 150 down.
    end.
    output close.
if opsys = "UNIX"
        then do:
                run visurel.p (input varquivo, input "VENDA POR MOEDA").
        end.
        else do:
                {mrod.i}
        end.
/* Finaliza o gerenciador de Impressao */

end.
