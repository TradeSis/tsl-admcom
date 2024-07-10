{admcab.i new} 

def buffer btitulo for titulo.

def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var tot01 like plani.platot.
def var tot02 like plani.platot format ">,>>9.99".
def var tot03 like plani.platot.
def var tot-cli as int.
def var cob-tot as int extent 3.

def var iTotQbr01   like plani.platot                    no-undo.
def var iTotQbr02   like plani.platot                    no-undo.
def var iTotQbr03   like plani.platot                    no-undo.
def var iTotQbA01   like plani.platot                    no-undo.
def var iTotQbA02   like plani.platot                    no-undo.
def var iTotQbA03   like plani.platot                    no-undo.

def buffer bcobranca for cobranca.
def stream stela.

def var varquivo as char format "x(20)".
def var saldo-vencer like plani.platot.
def var saldo-vencido like plani.platot.

def var vetbcod like estab.etbcod.
def var vcobcod like cobfil.cobcod.
def new shared temp-table tp-contrato like fin.contrato
            field exportado as log.
def new shared temp-table tp-titulo like fin.titulo
    index iclicod clifor
    index dt-ven titdtven
    index titnum empcod 
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

def buffer btp-titulo for  tp-titulo.

def var i as int.
repeat:

    update vetbcod label "Filial" colon 16 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    update vcobcod label "Cobrador" colon 16 with frame f1.
    /*find cobfil where cobfil.etbcod = estab.etbcod and
                      cobfil.cobcod = vcobcod no-lock.
    disp cobfil.cobnom no-label with frame f1.
    */
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.

    
    for each cobranca where cobranca.etbcod = vetbcod and
                            cobranca.cobcod = vcobcod
                            no-lock:
        for each fin.titulo where fin.titulo.clifor = cobranca.clicod no-lock:
            create tp-titulo.
            buffer-copy fin.titulo to tp-titulo.        
        end.
    end.

    run drag_tit.p (vetbcod, vcobcod).
    
    varquivo = "/admcom/relat/comi" + string(vetbcod,"99")
                               + string(vcobcod,"99")
                               + "." + string(time).

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""comi-cob""
            &Nom-Sis   = """SISTEMA DE COBRANCA"""
            &Tit-Rel   = """COBRADOR:  "" +
                            string(vcobcod,""99"") + ""  "" +
                            string("" "",""x(20)"") + "" Filial: "" +
                            string(vetbcod,""99"") + ""   PERIODO: "" +
                            string(vdti,""99/99/9999"") + "" A "" +
                            string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    tot01 = 0.
    tot02 = 0.
    tot03 = 0.

    for each cobranca where cobranca.etbcod = vetbcod and
                            cobranca.cobcod = vcobcod
                                              break by cobranca.etbcod
                                              by cobranca.cobeta
                                              by cobranca.cobatr:
        
        find first tp-titulo use-index iclicod
                          where tp-titulo.clifor   = cobranca.clicod and
                                tp-titulo.titdtpag >= vdti           and
                                tp-titulo.titdtpag <= vdtf           and
                                tp-titulo.titdtven <= 
                                            (tp-titulo.titdtpag - 60) 
                                            no-lock no-error.
                                            
        if avail tp-titulo
        then.
        else next.
        
        for each tp-titulo where tp-titulo.clifor = cobranca.clicod no-lock:



            if tp-titulo.titpar = 0
            then do:
                find first  btp-titulo where 
                            btp-titulo.empcod = 19 and
                            btp-titulo.titnat = no and
                            btp-titulo.modcod = "CRE" and
                            btp-titulo.etbcod = vetbcod and
                            btp-titulo.clifor = tp-titulo.clifor and
                            btp-titulo.titnum = tp-titulo.titnum and
                            btp-titulo.titpar > 30
                                         no-lock no-error.
                if avail btp-titulo                         
                then.

                else next.
            end.
            if tp-titulo.etbcobra <> vetbcod
            then next.
            
            if tp-titulo.moecod = "NOV"
            then next.
            
            if tp-titulo.etbcobra >= 900 or
              {conv_igual.i tp-titulo.etbcobra} 
            then next.

            if tp-titulo.etbcod = 100
            then next.
            
            if tp-titulo.titsit = "LIB"
            then next.
            
            if tp-titulo.titdtpag < vdti or
               tp-titulo.titdtpag > vdtf
            then next.
            if tp-titulo.titdtven > vdtf
            then next.

            
            if tp-titulo.titpar = 0 /** and
               tp-titulo.moecod = "NOV" **/
            then.
            else do:   
                if (tp-titulo.titdtven + 10) >= tp-titulo.titdtpag
                then next.
            end.
          
            output stream stela to terminal.
                display stream stela
                        tp-titulo.clifor
                        tp-titulo.titnum
                        tp-titulo.titpar with frame ff side-label 1 down.
                pause 0.
            output stream stela close.
            find clien where clien.clicod = cobranca.clicod no-lock.
            tot01 = tot01 + tp-titulo.titvlcob.
            tot02 = tot02 + (tp-titulo.titvlpag - tp-titulo.titvlcob).
            tot03 = tot03 + tp-titulo.titvlpag.
            display clien.clicod
                    clien.clinom
                    tp-titulo.titnum
                    tp-titulo.titpar
                    tp-titulo.titdtven
                    tp-titulo.titdtpag
                    tp-titulo.titvlcob
                    (tp-titulo.titvlpag - tp-titulo.titvlcob)
                        format ">,>>9.99" column-label "Juros"
                    tp-titulo.titvlpag format ">,>>>,>>9.99"
                                        column-label "Total"
                                with frame f2 down width 200.

            assign iTotQbr01 = iTotQbr01 + tp-titulo.titvlcob
                   iTotQbr02 = iTotQbr02 + (tp-titulo.titvlpag - 
                                            tp-titulo.titvlcob)
                   iTotQbr03 = iTotQbr03 + tp-titulo.titvlpag.
            assign iTotQbA01 = iTotQbA01 + tp-titulo.titvlcob
                   iTotQbA02 = iTotQbA02 + (tp-titulo.titvlpag - 
                                            tp-titulo.titvlcob)
                   iTotQbA03 = iTotQbA03 + tp-titulo.titvlpag.                
            if line-counter = 63 
            then do:
                    put "Total Pagina    = [ Valor Cobrado: "
                        iTotQbr01 form ">,>>>,>>9.99"
                        " Juros: " 
                        iTotQbr02 form ">>,>>9.99"
                        " Total: "
                        iTotQbr03 form ">,>>>,>>9.99"
                        " ]"
                        skip
                        "Total Acumulado = [ Valor Cobrado: "
                        iTotQbA01 form ">,>>>,>>9.99"
                        " Juros: " 
                        iTotQbA02 form ">>,>>9.99"
                        " Total: "
                        iTotQbA03 form ">,>>>,>>9.99"
                        " ]"
                        skip.
                    assign iTotQbr01 = 0
                           iTotQbr02 = 0
                           iTotQbr03 = 0.    
            end.
        end.
    end.
    put "Total Pagina    = [ Valor Cobrado: "
        iTotQbr01 form ">,>>>,>>9.99"
        " Juros: " 
        iTotQbr02 form ">,>>>,>>9.99"
        " Total: "
        iTotQbr02 form ">,>>>,>>9.99"
        " ]"
        skip.    
    put skip fill("-",130) format "x(130)" skip
        tot01 to 108
        tot02 to 117
        tot03 to 130 skip
        fill("-",130) format "x(130)" skip.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
    /*
    os-command silent /fiscal/lp value(" " + varquivo).
    */
end.
