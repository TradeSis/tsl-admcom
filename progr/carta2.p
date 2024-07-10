{admcab.i}
             
def shared temp-table tt-cli 
    field clicod like clien.clicod
    field titnum like titulo.titnum
    field divida like titulo.titvlcob
    field etbcod like estab.etbcod
    field titdtven like titulo.titdtven.
 
def var vjuro like titulo.titvlcob.
def var i as i.
def var tot1 as dec format ">>>,>>>,>>9.99".
def var tot2 as dec format ">>>,>>>,>>9.99".
def var tot3 as dec format ">>>,>>>,>>9.99".
def var vsaldo like plani.platot.
def var qtd-15 as int.
def var parcela-paga like plani.platot.
def var varquivo as char format "x(30)".

if opsys = "unix"
then varquivo = "/admcom/work9/car" + string(time).
else varquivo = "l:~\work9~\car" + string(time).
    
    output to value(varquivo) page-size 64.
    for each tt-cli: 
        find clien where clien.clicod = tt-cli.clicod no-lock. 
        
        vsaldo = 0.
        vjuro  = 0.
        
        qtd-15 = 0.
        parcela-paga = 0.
        
        for each titulo use-index iclicod  
                        where titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = "CRE" and
                              titulo.titsit = "PAG" and
                              titulo.clifor = clien.clicod no-lock.
            if (titulo.titdtpag - titulo.titdtven) <= 15
            then qtd-15 = qtd-15 + 1.
            parcela-paga = parcela-paga + 1.
        
        end.
        if ((qtd-15 * 100) / parcela-paga) < 50
        then next.
        
        for each titulo use-index iclicod  
                        where titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = "CRE" and
                              titulo.titsit = "lib" and
                              titulo.clifor = clien.clicod no-lock.

            vsaldo = vsaldo + titulo.titvlcob.
            if titulo.titdtven < today
            then do: 
                find tabjur where tabjur.nrdias = today - titulo.titdtven
                                                         no-lock no-error.
                if not avail tabjur                     
                then next.
                vjuro  = vjuro +
                    ( (titulo.titvlcob * tabjur.fator) - 
                       titulo.titvlcob).
            end.
        end.
        if vsaldo < 400
        then next.
        vsaldo = vsaldo + (vjuro * 0.67).
        put skip(3)
            "L O J A S   L E B E S" at 50 skip
            "____________________"  at 50 skip(4).
        
        put "Prezado Sr(a): " at 15 skip
            clien.clinom at 15 skip(6)

        "CHEGOU SUA OPORTUNIDADE." at 10 skip(1)
        "AGORA VOCE PODE ACERTAR SEU DEBITO EM ATE 06 VEZES " at 10 skip(1)
        "DURANTE O MES DE OUTUBRO VOCE REPARCELA SUAS" at 10 skip(1)
        "CONTAS EM ATRASO, NAS SEGUINTES CONDICOES:" at 10 skip(2).
             
        put skip(1).
        
        
        put "ENTRADA DE " at 10 (vsaldo * 0.25) format ">>,>>9.99" skip
            "5 vezes de R$ " at 10 ( (vsaldo - (vsaldo * 0.25) ) / 5) 
                            format ">>,>>9.99".

        put skip(2)
          "PROCURE UMA DE NOSSAS LOJAS E NAO PERCA ESTA OPORTUNIDADE." 
           at 10 skip(1)
    "COM O PAGAMENTO DA ENTRADA SEU CREDITO E IMEDIATAMENTE REESTABELECIDO" 
           at 10 skip(1)
          "JUNTO A EMPRESA E AO SPC." at 10 skip(2)
          
          "LEVE JUNTO ESTA CORRESPONDENCIA." at 10 SKIP(2).
        put "CODIGO: " at 10 clien.clicod SKIP (6).  


        put   "ATENCIOSAMENTE." at 30 skip(7) 
             "________________________" at 50
                  "DPTO. DE CRDITO"     at 54.
        
        page.
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").        
    end.
    else do:
        {mrod.i}
        /*
        os-command silent type value(varquivo) > prn.
        */
    end.
    
 
