def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.
def var statusfeirao as int.
def var minutoatual as char.
def var totaldias as int.

minutoatual = string(time,"hh:mm:ss").
minutoatual = substr(minutoatual,4,2).

totaldias = 0.

if (time >= 43200 and time <= 46800 and (int(minutoatual) < 30) ) then totaldias = 1. /* >=12h e <=13h */
if (time >= 57600 and time <= 61200 and (int(minutoatual) < 30) ) then totaldias = 1. /* >=16h e <=17h */
if (time >= 21600 and time <= 25200 and (int(minutoatual) < 30) ) then totaldias = 2. /* >=06h e <=07h */
if (time >= 0 and time <= 3600 and (int(minutoatual) < 30) ) then totaldias = 3. /* >=00h e <=01h */

output to "/admcom/lebesintel/bi_titulodiarioJULHOCRE.csv".

  for each estab use-index estab 
  where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock:

    for each fin.titulo  where
      fin.titulo.empcod = 19 and
      fin.titulo.titnat = no and
      fin.titulo.etbcod = estab.etbcod  and
      (fin.titulo.modcod = "CRE") and
      fin.titulo.titdtven >= 07/01/2018 and
      fin.titulo.titdtven <= 07/31/2018 no-lock:
      pause 0.

   /*   if fin.titulo.titdtven < 01/01/2014 then next. */

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

    /* ======================================= */


  end. /* estab */

output close.