{admcab.i }
def var tot1 as dec format ">>>,>>>,>>9.99".
def var tot2 as dec format ">>>,>>>,>>9.99".
def var tot3 as dec format ">>>,>>>,>>9.99".

def var varquivo as char format "x(30)".
def temp-table tt-nova
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field saldo  like titulo.titvlcob
    field juros  like titulo.titvlcob.


    input from ..\relat\novalp.
    repeat:
        create tt-nova.
        import tt-nova.
        display tt-nova with 1 down. pause 0.
    end.

    
    varquivo = "..\relat\novlp".

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


    for each tt-nova where tt-nova.etbcod > 0 break by tt-nova.etbcod:
        find clien where clien.clicod = tt-nova.clicod no-lock.
        display tt-nova.etbcod column-label "Fl."
                clien.clicod column-label "Conta"
                clien.clinom column-label "Nome"
                tt-nova.saldo 
                  column-label "Saldo" format ">>>,>>>,>>9.99"
                tt-nova.juros column-label "Correcao"
                ( tt-nova.juros + tt-nova.saldo)
                        column-label "Total" format ">>>,>>>,>>9.99"
                                with frame f1 width 130 down.
        tot1 = tot1 + tt-nova.saldo.
        tot2 = tot2 + tt-nova.juros.
        tot3 = tot3 + (tt-nova.saldo + tt-nova.juros).
        if last-of(tt-nova.etbcod)
        then do:
            put skip(2)  tot1 to 71
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


 
