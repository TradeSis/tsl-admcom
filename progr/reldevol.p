{admcab.i}

def var varquivo as char.
def var vetbcod  like estab.etbcod.
def var vdata    as date format "99/99/9999".
def var vcxacod  as int.

repeat:

    update vetbcod vdata vcxacod.
    
    varquivo = if opsys = "UNIX"
               then "/usr/admcom/relat/reldevol." + string(time)
               else "l:\relat\reldevol." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "160"
                &Page-Line = "66"
                &Nom-Rel   = ""DREB040""
                &Nom-Sis   = """SISTEMA ESTOQUE"""
                &Tit-Rel   = """LISTAGEM DE DEVOLUCOES "" +
                              "" LOJA "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom "
                &Width     = "160"
                &Form      = "frame f-cabcab3"}


    for each titulo where titulo.datexp = vdata
                      and titulo.modcod = "DEV"
                      and titulo.etbcod = vetbcod 
                      and titulo.cxacod = if vcxacod <> 0
                                          then vcxacod
                                          else titulo.cxacod
                      no-lock break by titulo.titobs[2].
        

        disp titulo.titobs[2] format "x(15)" column-label "Troca/Devolucao"
             titulo.etbcod                   column-label "Filial"
             titulo.clifor                   column-label "Cliente"
             titulo.moecod                   column-label "Moeda"
             titulo.titvlcob                 column-label "Credito" 
             (total by titulo.titobs[2])
             titulo.titvlpag                 column-label "Utilizado"
             (total by titulo.titobs[2])
             with centered width 160.

    end.

    output close.

    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
        {mrod.i}
    end.
end.
