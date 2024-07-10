def var vdti as date.
def var vdtf as date.

def var vdata as date.

def buffer btitulo for titulo.

assign vdti = 10/27/2012
       vdtf = 11/07/2012.

def var vparc-ant as char.

output to value("/admcom/work/lista-titulos-leote.csv").

put unformatted
     
     "FIL;COD CLI;CLIENTE;CONTRATO;PARCELA;VALOR COBRADO;VALOR PAGO;"
     "DATA VENCIMENTO;DATA PAGAMENTO;FIL COB.;"
     "PARCELAS ANTERIORES DO MESMO CONTRATO"
      skip.

do vdata = vdti to vdtf:

    for each estab where etbcod < 189 no-lock,
    
        each titulo where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = "cre"
                      and titulo.titdtpag = vdata 
                      and titulo.etbcod    = estab.etbcod
                      and titulo.titpar   >= 51 no-lock.
                   
        find first clien where clien.clicod = titulo.clifor no-lock no-error.           
        
        vparc-ant = "".
        
        for each btitulo where btitulo.empcod = titulo.empcod 
                           and btitulo.titnat = titulo.titnat
                           and btitulo.modcod = titulo.modcod
                           and btitulo.etbcod = titulo.etbcod
                           and btitulo.CliFor = titulo.CliFor
                           and btitulo.titnum = titulo.titnum
                           and btitulo.titpar < titulo.titpar
                                    no-lock.

            assign vparc-ant = vparc-ant + string(btitulo.titpar) + ", ".

        end.

        put unformatted
             estab.etbcod
             ";"
             clifor
             ";"
             clinom
             ";"
             titnum
             ";"
             titpar
             ";"
             titvlcob
             ";"
             titvlpag
             ";"
             titdtven
             ";"
             titdtpag
             ";"
             etbcobra 
             ";" 
             vparc-ant   skip.

end.


end.
