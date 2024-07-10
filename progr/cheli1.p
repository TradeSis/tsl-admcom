{admcab.i}

def temp-table tt-che
    field codcob like cheque.codcob
    index ind-1  codcob. 

def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial no.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vdata like plani.pladat.
def var varquivo as   char.

repeat:
    for each tt-che:
        delete tt-che.
    end.
    update vsit    label "Situacao"
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
                with frame f-dep centered side-label color blue/cyan row 4.
        repeat:
            create tt-che.
            update tt-che.codcob format ">>9"
                    with frame f-cob side-label centered down.
            find cobrador where cobrador.codcob = tt-che.codcob no-lock.
            display cobrador.nome no-label with frame f-cob.
        end.
    
    varquivo = "/admcom/relat/cheli1" + string(mtime).
    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".
    
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI1""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS - "" + vsitu"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

    for each cheque where cheque.chesit = vsitu and
                          cheque.cheven >= vdti and
                          cheque.cheven <= vdtf no-lock break by cheque.nome.
            find first tt-che where tt-che.codcob = cheque.codcob no-error.
            if avail tt-che
            then next.
            if cheque.cheetb = 900
            then next.

            display cheque.cheetb column-label "Fil" format ">>9"
                    cheque.nome format "x(25)"
                    cheque.clicod 
                    cheque.cheval (total) 
                    cheque.cheemi 
                    cheque.cheven 
                    cheque.cheban 
                    cheque.cheage 
                    cheque.chenum 
                    cheque.checid format "x(12)"
                    cheque.chealin column-label "Alin"
                    cheque.codcob column-label "Cobr." format ">>9"
                                with frame f-imp width 150 down.
    end.
    output close.
    pause 1 no-message.
    run visurel.p (input varquivo, input "").
end.

