{admcab.i}
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vdata       like titulo.titdtemi.
def var vdt1        as   date  format "99/99/9999". 
def var vdt2        as   date  format "99/99/9999".

repeat with 1 down side-label width 80 row 4 color blue/white:

    update vetbi label "Filial" colon 20
           vetbf label "Filial".

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20.
        

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        
        do vdata = vdt1 to vdt2:

            for each titulo where titulo.etbcobra = estab.etbcod and
                                  titulo.titdtpag = vdata        no-lock.
                                  
                if titulo.clifor = 1
                then next.

                if titulo.titnat = yes
                then next.
                
                if titulo.modcod <> "CRE"
                then next.
                
                find titold where titold.empcod = titulo.empcod and
                                  titold.titnat = titulo.titnat and
                                  titold.modcod = titulo.modcod and
                                  titold.etbcod = titulo.etbcod and
                                  titold.clifor = titulo.clifor and
                                  titold.titnum = titulo.titnum and
                                  titold.titpar = titulo.titpar no-error.
                
                if not avail titold
                then do transaction:
                    create titold.
                    {titold.i titold titulo}.
                end.    

 
                display "Gerando Lancamentos...."
                             titold.etbcobra column-label "Filial"
                             titold.titdtpag column-label "Data"
                                    with frame f1 1 down centered.
                pause 0.

            
            end.
            
        end.

    end.

end.
