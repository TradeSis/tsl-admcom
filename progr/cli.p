{admcab.i}
def var vtot like plani.platot.
def var varquivo as char.
def temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    field etbcod like estab.etbcod
    field dtcad like clien.dtcad
    field totcon like plani.platot
        index ind-1 dtcad.

def var i as i.
def var vetbcod like estab.etbcod.
def var dt1   like clien.datexp.
def var dt2   like clien.datexp.
def var vdata as date.

repeat:
    for each tt-cli:
        delete tt-cli.
    end.
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update dt1 label "Periodo"
           dt2 no-label with frame f2 side-label.
    for each clien where clien.dtcad >= dt1 and
                         clien.dtcad <= dt2 no-lock:
        display clien.clicod
                int(substring(string(clien.clicod,"9999999999"),9,2))
                    with 1 down. pause 0.

        if int(substring(string(clien.clicod,"9999999999"),9,2)) <>
           int(string(estab.etbcod,"99"))
        then next.

        display estab.etbcod
                clien.clicod
                clien.clinom
                clien.dtcad
                clien.datexp with frame fcli down.
        vtot = 0.
        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.clicod = clien.clicod and
                                contrato.dtinicial = clien.dtcad no-lock.
            vtot = vtot + contrato.vltotal.
        end.
        create tt-cli.
        assign tt-cli.etbcod = estab.etbcod
               tt-cli.clicod = clien.clicod
               tt-cli.clinom = clien.clinom
               tt-cli.dtcad  = clien.dtcad
               tt-cli.totcon = vtot.

    end.
    
    varquivo = "l:\relat\cli".

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""IMPCUP""
        &Nom-Sis   = """SISTEMA DE CREDIARIO FILIAL - ""
                        + string(vetbcod,""999"")"
        &Tit-Rel   = """CLIENTES NOVOS - PERIODO DE "" +
                        string(dt1,""99/99/9999"") + "" A "" +
                        string(dt2,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}

     for each tt-cli use-index ind-1 no-lock:
         display tt-cli.etbcod 
                 tt-cli.clicod 
                 tt-cli.clinom 
                 tt-cli.dtcad  
                 tt-cli.totcon column-label "Valor!Compra"
                      with down width 200.
     end.


    
    output close.
    dos silent value("type " + varquivo + "> prn"). 

end.
