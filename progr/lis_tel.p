/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/
{admcab.i}
def var vlimite as dec.
def var varquivo as char.
def var vetbcod like estab.etbcod.
def workfile tt-produ
    field procod like produ.procod.

def workfile tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom.

repeat:

    for each tt-produ:
        delete tt-produ.
    end.

    for each tt-cli:
        delete tt-cli.
    end.

    update vetbcod label "Filial"
            with frame f1 side-label width 80.

    find estab where estab.etbcod = vetbcod no-lock no-error.

    display estab.etbnom no-label with frame f1.


    input from l:\progr\fone.i.
    repeat:
        create tt-produ.
        import tt-produ.
    end.
    input close.

    varquivo = "l:\work\tele" + string(vetbcod,">>9").

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""lis_tel""
        &Nom-Sis   = """SISTEMA COMERCIAL FILIAL"""
        &Tit-Rel   = """LISTEGAM DE CLIENTES TELEFONICA "" +
                    ""FILIAL "" + string(vetbcod)"
        &Width     = "160"
        &Form      = "frame f-cabcab"}

    for each tt-produ no-lock,
        each movim where movim.etbcod = estab.etbcod    and
                         movim.procod = tt-produ.procod and
                         movim.movtdc = 05              and
                         movim.movdat >= 01/01/2002     and
                         movim.movdat <= 01/31/2002 no-lock.

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod no-lock no-error.
        if not avail plani
        then next.

        find first tt-cli where tt-cli.clicod = plani.desti no-error.
        if not avail tt-cli
        then do:
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.

            create tt-cli.
            assign tt-cli.clicod = plani.desti
                   tt-cli.clinom = clien.clinom.
        end.
    end.

    for each tt-cli by tt-cli.clinom:

        find clien where clien.clicod = tt-cli.clicod no-lock.

        vlimite = 0.

        if clien.limite = 0
        then vlimite = 26.

        if clien.limite = 1
        then vlimite = 13.

        if clien.limite = 2
        then vlimite = 0.


        display tt-cli.clicod
                tt-cli.clinom
                vlimite column-label "Credito!Telefonica"
                     with frame f2 down.
    end.

    output close.
    message "Deseja imprimir listagem de clientes" update sresp.
    if not sresp
    then return.

    dos silent value("type " + varquivo + " > prn").

end.
