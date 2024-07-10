{admcab.i }
def var tot1 as dec format ">>>,>>>,>>9.99".
def var tot2 as dec format ">>>,>>>,>>9.99".
def var tot3 as dec format ">>>,>>>,>>9.99".

def var varquivo as char format "x(30)".
def temp-table tt-nova
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field saldo  like titulo.titvlcob
    field juros  like titulo.titvlcob
        index ind1 etbcod
                   clicod.
              
def temp-table tt-cli
    field clinom like clien.clinom
    field etbcod like clien.clicod
    field clicod like clien.clicod
        index ind2 etbcod
                   clinom.

    input from ..\relat\novacao.
    repeat:
        create tt-nova.
        import tt-nova.
        display tt-nova with 1 down. pause 0.
        find clien where clien.clicod = tt-nova.clicod no-lock no-error.
        if not avail clien
        then next.
        create tt-cli.
        assign tt-cli.clinom = clien.clinom
               tt-cli.etbcod = tt-nova.etbcod
               tt-cli.clicod = tt-nova.clicod.
    end.

    
    varquivo = "..\relat\nov1".

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""NOV_IMP""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """SALDO DE CLIENTES"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    for each tt-cli use-index ind2 break by tt-cli.etbcod 
                          by tt-cli.clinom:
        find first tt-nova use-index ind1
                           where tt-nova.etbcod = tt-cli.etbcod and
                                 tt-nova.clicod = tt-cli.clicod no-error.
        if not avail tt-nova
        then next.
        display tt-nova.etbcod column-label "Fl."
                tt-cli.clicod column-label "Conta"
                tt-cli.clinom column-label "Nome"
                tt-nova.saldo 
                  column-label "Saldo" format ">>>,>>>,>>9.99"
                tt-nova.juros column-label "Correcao"
                ( tt-nova.juros + tt-nova.saldo)
                        column-label "Total" format ">>>,>>>,>>9.99"
                                with frame f1 width 130 down.
        tot1 = tot1 + tt-nova.saldo.
        tot2 = tot2 + tt-nova.juros.
        tot3 = tot3 + (tt-nova.saldo + tt-nova.juros).
        if last-of(tt-cli.etbcod)
        then do:
            put skip tot1 to 71
                     tot2 to 88
                     tot3 to 103.
            tot1 = 0.
            tot2 = 0.
            tot3 = 0.
            page.
        end.
    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").


 
