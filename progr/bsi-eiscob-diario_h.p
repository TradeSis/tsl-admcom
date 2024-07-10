/* 26.09.2018 - Helio - Ajuste das datas para:
        Ultimos 30 dias, desde o dia 01 do mes
        Pegar titulos por vencimento
        Ajuste para AGILIZAR leitura pelo index por modalidade
         */

def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.
def var statusfeirao as int.


def var vantini as date.
def var vantfim as date.
def var vatuini as date.
def var vatufim as date.
def var vdata   as date.
def var vtoday as date.


    vtoday = today.
  
    /* #1 Regra - Fecha o mes atual e o mes anterior. Quando for dia Primeiro fecha mes atual como o mes passado ainda */ 
    if day(vtoday) = 01
    then do:
        vatufim = vtoday - 1.
        vatuini = date(month(vatufim),01,year(vatufim)).
        vantfim = vatuini - 1.
        vantini = date(month(vantfim),01,year(vantfim)).
    end.
    else do:
        vdata = vtoday.
        repeat.
            vdata = vdata + 1.
            if month(vdata) <> month(vtoday)
            then leave.
        end.
        vatufim = vdata - 1.
        vatuini = date(month(vatufim),01,year(vatufim)).
        vantfim = vatuini - 1.
        vantini = date(month(vantfim),01,year(vantfim)).
    end.


output to "/admcom/lebesintel/bi_titulodiario_AVULSO_H.csv".

  for each estab use-index estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock:
    for each modal where
       (modal.modcod = "CRE" or
        modal.modcod = "CP1" or
        modal.modcod = "CP0" or
        modal.modcod = "CPN") 
        no-lock.
    
    for each fin.titulo use-index titdtven where
      fin.titulo.empcod = 19 and
      fin.titulo.titnat = no and
      fin.titulo.etbcod = estab.etbcod  and
      fin.titulo.modcod = modal.modcod and
      fin.titulo.titdtven >= vatuini and
      fin.titulo.titdtven <= vatufim no-lock:
        pause 0 .

      if titulo.titsit  = "EXC" /* Helio - 26.09.2018 */
      then next.
        
      if fin.titulo.titdtven < 01/01/2014 then next.

      vTitvlcob = string(fin.titulo.titvlcob).
      vTitvlpag   = string(fin.titulo.titvlpag).

      if fin.titulo.tpcontrato = "L" then vTipoParcela = 1.
      else vTipoParcela = 0.

      /*
      if string(titobs[1]) matches "*RENOVACAO=SIM*" then vTipoParcela = 1.
      */

      if string(titobs[1]) matches "*FEIRAO-NOME-LIMPO=SIM*" then statusfeirao = 1.
      else statusfeirao = 0.

      put
        etbcod ";"
        titnum ";"
        clifor ";"
        titpar ";"
        etbcobra ";"
        empcod ";"
        YEAR(titdtven) format "9999" "-" MONTH(titdtven) format "99" "-" DAY(titdtven) format "99" ";"
        vTitvlcob ";"
        YEAR(titdtpag) format "9999" "-" MONTH(titdtpag) format "99" "-" DAY(titdtpag) format "99" ";"
        vTitvlpag ";"
        titsit ";"
        moecod ";"
        vTipoParcela ";"
        YEAR(titdtemi) format "9999" "-" MONTH(titdtemi) format "99" "-" DAY(titdtemi) format "99" ";"
        modcod ";"
        titdes ";"
        statusfeirao ";"
        substr(string(int(titulo.cxmhora), "hh:mm:ss"),1,2)
      skip.
    end. /* titulo */

    end. /* Modal */
    
  end. /* estab */

output close.