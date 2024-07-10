{admcab.i}
def var tot-vencer  like plani.platot format ">,>>>,>>9.99".
def var tot-vencido like plani.platot format ">>,>>>,>>9.99".
def var tot-saldo   like plani.platot format ">>,>>>,>>9.99".
def var tot-cli as int.
def var cob-tot as int extent 3.


def buffer bcobranca for cobranca.
def stream stela.

def var varquivo as char format "x(20)".
def var saldo-vencer like plani.platot.
def var saldo-vencido like plani.platot.

def var vetbcod like estab.etbcod.
def var vcobcod like cobfil.cobcod.

repeat:
    
    update vetbcod label "Filial" colon 16 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vcobcod label "Cobrador" colon 16 with frame f1.
    find cobfil where cobfil.etbcod = estab.etbcod and
                      cobfil.cobcod = vcobcod no-lock.
    disp cobfil.cobnom no-label with frame f1.


    
    varquivo = "i:\admcom\relat\cob-" + string(vetbcod,">>9") 
                               + string(vcobcod,"99").

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""relcob""
            &Nom-Sis   = """SISTEMA DE COBRANCA""" 
            &Tit-Rel   = """COBRADOR:  "" +
                            string(cobfil.cobcod,""99"") + ""  "" + 
                            string(cobfil.cobnom,""x(20)"") + "" Filial: "" +
                            string(vetbcod,"">>9"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    cob-tot[01] = 0.
    cob-tot[02] = 0.
    cob-tot[03] = 0.
    for each cobranca where cobranca.etbcod = vetbcod no-lock:
        if cobcod = 99
        then next.
        cob-tot[cobranca.cobeta] = cob-tot[cobranca.cobeta] + 1.
    end.
        

    for each cobranca where cobranca.etbcod = vetbcod and
                            cobranca.cobcod = vcobcod 
                                        break by cobranca.cobeta
                                              by cobranca.cobatr:

        saldo-vencer = 0.
        saldo-vencido = 0.

        for each titulo where titulo.clifor = cobranca.clicod no-lock:

            if titulo.titsit = "LIB"
            then do:
                if titulo.titdtven >= today
                then saldo-vencer = saldo-vencer + titulo.titvlcob.
                if titulo.titdtven < today
                then saldo-vencido = saldo-vencido + titulo.titvlcob.
            end.
            output stream stela to terminal.
                display stream stela 
                        titulo.clifor
                        titulo.titnum
                        titulo.titpar with frame ff side-label 1 down.
                pause 0.
            output stream stela close.
        end.
        find clien where clien.clicod = cobranca.clicod no-lock.
        display clien.clicod
                clien.clinom
                cobranca.cobgera column-label "Data Gerada"
                cobranca.cobatr column-label "Dias!Atraso"
                saldo-vencer  format ">,>>>,>>9.99"
                            column-label "Saldo!Vencer"
                saldo-vencido format ">,>>>,>>9.99"
                            column-label "Saldo!Vencido"
                (saldo-vencer + saldo-vencido) 
                              format ">,>>>,>>9.99"
                        column-label "Saldo!Total"
                        with frame f2 down width 200.
        tot-vencer  = tot-vencer + saldo-vencer.
        tot-vencido = tot-vencido + saldo-vencido.
        tot-saldo   = saldo-vencer + saldo-vencido.
        tot-cli     = tot-cli + 1.
        if last-of(cobranca.cobeta) 
        then do:
            find first bcobranca where 
                                 bcobranca.etbcod  = cobranca.etbcod and
                                 bcobranca.cobcod = 99              and
                                 bcobranca.cobeta  = cobranca.cobeta 
                                    no-lock no-error.
            if avail bcobranca
            then put skip fill("-",130) format "x(130)"
                      "Cli. Possiveis: " to 20
                      bcobranca.cobatr
                      "  Em Cobranca: "
                      cob-tot[cobranca.cobeta]
                      tot-vencer                   to 84
                      tot-vencido                  
                      tot-saldo                    
                      tot-cli                       skip
                      fill("-",130) format "x(130)" skip.
            
            assign tot-vencer  = 0
                   tot-vencido = 0
                   tot-saldo   = 0
                   tot-cli     = 0.

        end.
    
    end.
    
    output close.
    dos silent value("type " + varquivo + "  > prn").

end.
    

