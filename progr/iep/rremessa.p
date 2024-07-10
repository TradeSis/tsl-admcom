{admcab.i}
def var vlrcobradocustas as dec.
def var vlrcobrado as dec.
def var vcp as char init ";".
def var pordem as int.
 
def var wdti as date format "99/99/9999".
def var wdtf as date format "99/99/9999".
def var varqcsv as char format "x(65)".
wdti = today.
wdtf = today.
update 
     wdti    label "de"       colon 18  
     wdtf    label "a"       colon 35  
                    with side-labels width 80 frame f1.
    varqcsv = "/admcom/relat/iep/rremessa_" + string(wdti,"99999999") + string(wdtf,"99999999") + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    update varqcsv no-label colon 12
        with frame f1
        title "REMESSAS".

message "Aguarde...". 
output to value(varqcsv).
put unformatted  "remessa;" 
                 "dt envio;"
                 "cpf;"
                 "cliente;"
                 "nome cliente;"
                 "contrato;"
                 "dt emissao;"
                 "parcela;"
                 "vencimento;"
                 "valor;"
                 "juros;"
                 "vlr cobrado;"
                 "vlr custas;"
                 "total;"
                 "situacao;"
                 skip.

for each titprotremessa 
    where 
    dtinc >= wdti and
    dtinc <= wdtf 
    no-lock.

    for each titprotesto of titprotremessa no-lock.
        
        find neuclien where neuclien.clicod = titprotesto.clicod no-lock.
        find clien of neuclien no-lock.
        find contrato of titprotesto no-lock.
        
        for each titprotparc of titprotesto no-lock.
            find titulo where titulo.empcod = 19 and titulo.titnat = no and
                titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
                titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
                titulo.titpar = titprotparc.titpar
                no-lock.
            vlrcobrado       = titprotparc.titvlcob + titprotparc.titvljur.
            vlrcobradocustas = titprotparc.titvlcob + titprotparc.titvljur + titprotparc.titvlrcustas.
            
            put unformatted 
                 titprotremessa.remessa vcp
                 string(titprotremessa.dtinc,"99/99/9999") vcp
                 string(neuclien.cpf,"99999999999999") vcp
                 clien.clicod vcp
                 clien.clinom vcp
                 contrato.contnum vcp
                 string(contrato.dtinicial,"99/99/9999") vcp
                 titulo.titpar vcp
                 string(titulo.titdtven,"99/99/9999") vcp
                 trim(string(titulo.titvlcob,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(titprotparc.titvljur,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(vlrcobrado,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(titprotparc.titvlrcustas,"->>>>>>>>>>>>>>>>9.99")) vcp
                 trim(string(vlrcobradocustas,"->>>>>>>>>>>>>>>>9.99")) vcp
                 titprotesto.situacao vcp
                 skip.
        end.
    end.    
end.
output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        pause.    
 
