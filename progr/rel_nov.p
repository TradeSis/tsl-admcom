{admcab.i}

def buffer btitulo for titulo.
def var vetbcod like estab.etbcod.
def var varquivo as char.

def temp-table tt-cli
    field clicod like clien.clicod.

repeat:    
    for each tt-cli:
        delete tt-cli.
    end.
    
    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
    
    for each titulo where titulo.empcod = 19    and
                          titulo.titnat = no    and
                          titulo.modcod = "CRE" and
                          titulo.titsit = "Lib" and
                          titulo.etbcod = estab.etbcod and
                          titulo.tpcontrato <> "" /*titpar > 30*/
                    no-lock break by titulo.clifor:
        if first-of(titulo.clifor)
        then do:
            display titulo.clifor with 1 down. pause 0.
            find first btitulo where btitulo.clifor = titulo.clifor and
                                     btitulo.titsit = "lib"         and
                                     btitulo.tpcontrato = "" /*titpar < 30*/
                               no-lock no-error.
            if avail btitulo
            then do:
                find first tt-cli where tt-cli.clicod = titulo.clifor no-error.
                if not avail tt-cli
                then do:
                    create tt-cli.
                    assign tt-cli.clicod = titulo.clifor.
                end.
            end.
        end.
     end.

    varquivo = "../relat/rel_nov" + string(mtime).
    {mdcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_nov""
        &Nom-Sis   = """SISTEMA DE COBRANCA"""
        &Tit-Rel   = """CLIENTES COM NOVACAO - FILIAL: "" + string(vetbcod)"
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    for each tt-cli:
        find clien where clien.clicod = tt-cli.clicod no-lock.
        display clien.clicod
                clien.clinom
                clien.ciccgc
                with frame f2 down.
    end.
 
    output close. 

    run visurel.p (input varquivo, input "").
end.
