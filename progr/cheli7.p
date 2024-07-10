{admcab.i}
def var vcidade as char format "x(20)".
def temp-table tt-che
    field codcob like cheque.codcob
    index ind-1  codcob. 
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial no.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def stream stela.
def var vdata like plani.pladat.

repeat:
    for each tt-che:
        delete tt-che.
    end.
    update vsit    label "Situacao"
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
           vcidade label "Cidade" at 3
                with frame f-dep centered side-label color blue/cyan row 4.
        repeat:
            create tt-che.
            update tt-che.codcob with frame f-cob side-label centered down.
            find cobrador where cobrador.codcob = tt-che.codcob no-lock.
            display cobrador.nome no-label with frame f-cob.
        end.
        
        
        
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI1""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS"" + "" - "" +
                            string(vsit,""PAG/LIB"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".

    for each cheque where cheque.chesit = vsitu and
                          cheque.cheven >= vdti and
                          cheque.cheven <= vdtf no-lock break by cheque.nome.
            find first tt-che where tt-che.codcob = cheque.codcob no-error.
            if avail tt-che
            then next.
            if cheque.cheetb = 900
            then next.
            /*
            find first agenc where agenc.agecod = string(cheque.cheage) 
                                   no-lock no-error.
            if not avail agenc
            then next.
            */
            if cheque.checid <> vcidade
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
   /* dos silent ved c:\xxx. */
end.

