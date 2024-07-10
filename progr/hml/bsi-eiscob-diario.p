/*#1 helio.neto 16.08.2019 - mudanca completa na versao */
/*#2*/
def var varq as char.

def var vTitvlcob as char.
def var vTitvlpag as char.
def var vTipoParcela as int.
def var statusfeirao as int.
/*#1*/
def buffer r_cretrigger for cretrigger.
def buffer oldtitulo for titulo.

def var vtoday as date.
def var vtime  as int.

vtoday = today.
vtime  = time.


/* Trigger de Loja */

pause 0 before-hide.
for each finexporta
    where finexporta.tabela = "TITULO" and
          finexporta.datatrig >= today - 10 
    no-lock.
    find r_cretrigger where r_cretrigger.titnat = no and
                          r_cretrigger.tabela = finexporta.tabela and
                          r_cretrigger.trecid = finexporta.tabela-recid
         no-error.
    if not avail r_cretrigger
    then do:
        find titulo where recid(titulo) = finexporta.tabela-recid no-lock.
        {/admcom/progr/cretrigger.i
             &tabela =   titulo
             &old    =   oldtitulo }
    end.  
end.

varq = "/admcom/tmp/lebesintel/bi_titulodiario" + string(vtoday,"999999") + replace(string(vtime,"HH:MM:SS"),":","") + ".csv".

output to value(varq).
for each r_cretrigger where r_cretrigger.titnat = no and
                          r_cretrigger.dtenvio =  vtoday and
                          r_cretrigger.hrenvio >= vtime - (5 * 60 * 60) /* ultimas 5 horas */ and
                          r_cretrigger.tabela  = "titulo"
                          no-lock.
                          
    find titulo where recid(titulo) = r_cretrigger.trecid no-lock.
    find modal  of titulo no-lock no-error.
    
    if avail modal and
       (modal.modcod = "CRE" or
        modal.modcod = "CP1" or
        modal.modcod = "CP0" or
        modal.modcod = "CPN") 
    then do:
        run exporta(recid(titulo)).
    end.
end.

for each r_cretrigger where r_cretrigger.titnat = no and
                          r_cretrigger.dtenvio = ? and
                          r_cretrigger.tabela  = "titulo"
                          no-lock.
                          
    find titulo where recid(titulo) = r_cretrigger.trecid no-lock.
    find modal  of titulo no-lock no-error.
    
    if avail modal and
       (modal.modcod = "CRE" or
        modal.modcod = "CP1" or
        modal.modcod = "CP0" or
        modal.modcod = "CPN") 
    then do:
        run exporta(recid(titulo)).
        run marca (recid(r_cretrigger),vtime).
    end.
    else do:
        run marca (recid(r_cretrigger),0).
    end.
end.

output close.

unix silent value("cp " + varq + " /admcom/lebesintel/bi_titulodiario.csv").


procedure exporta.
def input parameter prec as recid.

    find titulo where recid(titulo) = prec no-lock.


      vTitvlcob = string(titulo.titvlcob).
      vTitvlpag   = string(titulo.titvlpag).

      if titulo.tpcontrato = "L" then vTipoParcela = 1.
      else vTipoParcela = 0.

      if string(titobs[1]) matches "*FEIRAO-NOME-LIMPO=SIM*" 
      then statusfeirao = 1.
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

end procedure.


procedure marca.
def input param prec as recid.
def input param ptime as int.

do on error undo:

    find r_cretrigger where recid(r_cretrigger) = prec exclusive no-wait no-error.
    if avail r_cretrigger
    then do:
        r_cretrigger.dtenvio = vtoday.
        r_cretrigger.hrenvio = ptime.
    end.      

end. 

end procedure.


/*#1*/
/*#1
def var minutoatual as char.
def var totaldias as int.

minutoatual = string(time,"hh:mm:ss").
minutoatual = substr(minutoatual,4,2).

totaldias = 0.

if (time >= 43200 and time <= 46800 and (int(minutoatual) < 30) ) then totaldias = 1. /* >=12h e <=13h */
if (time >= 57600 and time <= 61200 and (int(minutoatual) < 30) ) then totaldias = 1. /* >=16h e <=17h */
if (time >= 21600 and time <= 25200 and (int(minutoatual) < 30) ) then totaldias = 2. /* >=06h e <=07h */
if (time >= 0 and time <= 3600 and (int(minutoatual) < 30) ) then totaldias = 3. /* >=00h e <=01h */


/* 26.09.2018 - Helio - Ajuste das datas para:
        Ultimos 30 dias, desde o dia 01 do mes
        Pegar titulos por vencimento
        Ajuste para AGILIZAR leitura pelo index por modalidade
         */



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


output to "/admcom/lebesintel/bi_titulodiario.csv".

  for each estab use-index estab where estab.etbcod >= 1 and estab.etbcod <= 999 no-lock:

    for each modal where
       (modal.modcod = "CRE" or
        modal.modcod = "CP1" or
        modal.modcod = "CP0" or
        modal.modcod = "CPN") 
        no-lock.
 
    for each fin.titulo use-index Por-Dtpag-Uo-Modal where
      fin.titulo.empcod = 19 and
      fin.titulo.titnat = no and
      fin.titulo.etbcod = estab.etbcod  and
      fin.titulo.modcod = modal.modcod and
      fin.titulo.titdtpag >= today - totaldias and
      fin.titulo.titdtpag <= today no-lock:
      pause 0.

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

    /* ======================================= */

    for each fin.titulo use-index datexp where
      fin.titulo.empcod = 19 and
      fin.titulo.titnat = no and
      fin.titulo.etbcod = estab.etbcod  and
      fin.titulo.modcod = modal.modcod and
      fin.titulo.datexp >= today - totaldias and
      fin.titulo.datexp <= today no-lock:
      pause 0.

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

  
    if day(today) = 01 or /* quando for final de quinzena, roda completo */
       day(today) = 16
    then   
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

 
    end. /* modal */

  end. /* estab */

output close.
#1*/
