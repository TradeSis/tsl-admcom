/*************************INFORMA€OES DO PROGRAMA******************************
*  perfoest-cron.p
*  Versão Cron de perfoest.p
*  Antonio
*  alteração : Selecionar todas as clases de confecçoes do 
*              penultimo e ultimo niveis 
*  Versao 1.2
*******************************************************************************/

{admcab-batch.i}
def output parameter varqsai as char.

/*****
{admcab.i new}
def var varqsai as char.
****/

def var vlinha as int.
def var vcabec-clase as char. 
def var vtime as int.

def temp-table tclase-cron no-undo
field etbcod    like estab.etbcod
field clacod    like clase.clacod
field clasup    like clase.clasup
field nive      as int
field estatual like estoq.estatual
field seq       as int 
index k1  etbcod
          clasup
          clacod
          nive
index k2  etbcod
          seq. 
          

def temp-table tlista no-undo
field clasup like clase.clasup
field clacod like clase.clacod 
field estoq  like estoq.estatual
index k1 clasup
         clacod.

def buffer btclase-cron for tclase-cron.

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer clasup1 for clase.

def var vseq as int.
def var vkont as int initial 0.

def var v-clase-cod like clase.clacod.
def var v-nivel-list as int.
def var v-clase-list as int.
def var v-clase-imp    as int.
def var varquivo as char.
def var vforcod like forne.forcod.
def var vfabcod like fabri.fabcod.
def var v-clanom like clase.clanom.
def var v-totcom    as dec.
def var v-ttmet     as dec.
def var v-totperc   as dec.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok as logical.
def var vquant like movim.movqtm.
def var flgetb      as log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var j           as int.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var vetbcod     like plani.etbcod no-undo.
def var vetbcod2    like plani.etbcod no-undo.
def var v-totger    as  dec.
def new shared      var vdti as date format "99/99/9999" no-undo.
def new shared      var vdtf as date format "99/99/9999" no-undo.
def var p-vende     like func.funcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-clase1    like clase.clacod.
def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-titproaux as char.

def var v-etccod    like estac.etccod.
def var v-carcod    like caract.carcod.
def var v-subcod    like subcaract.subcar.

assign vtime = time.

                                               
do on error undo:

        find first estab no-lock no-error.
        if avail estab then vetbcod = estab.etbcod.
        else vetbcod = 1.
                 
        find last estab no-lock no-error.
        if avail estab then vetbcod2 = estab.etbcod.
        else vetbcod2 = 99999.

        assign  vfabcod  = 0
                v-etccod = 0
                v-carcod = 0
                v-subcod = 0.
    assign vdti = today - 7 vdtf = today.
    
    def var vdtini as date.
    def var vdtfin as date.
    def var vmes as i.
    def var vano as i.

    /* varquivo = "/admcom/work" + */
    varquivo = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
        "/perfoestcron" +
        string(day(today),"99") + string(month(today),"99") +  
        string(year(today)) + "." + string(time).

    run montacla.
    
    leave.
end.
leave.
    
procedure imprime.

def var vcabec as char format "x(1200)".
def var vdetal as char format "x(1200)".

end procedure .

Procedure Montacla.

def var vcabec as char.
def var vdetal as char.
def var vkont as int initial 0.
def var vfoi  as logical.

/* Parte 1 */

for each tclase-cron:
    delete tclase-cron.
end.
    
for each estab no-lock:
 for each estoq where estoq.etbcod = estab.etbcod and estoq.estatual > 0 no-lock,
    first produ of estoq no-lock.
    
    if produ.catcod <> 41 then next.
    find sclase where sclase.clacod = produ.clacod no-lock no-error.
    if not avail sclase then next.
    if sclase.clacod = 0 and sclase.clasup = 0 then next.
    find clase where clase.clacod = sclase.clasup no-lock no-error.
    if not avail clase then next.
    find clasup1 where clasup1.clacod = clase.clasup no-lock no-error.
    if not avail clasup1 then next.
    find grupo where grupo.clacod = clasup1.clasup no-lock no-error.
    if not avail grupo then next.
    if grupo.clacod = 0 and grupo.clasup = 0 then next.
    
    
    /* Nivel Cabecalho - Todas as clases */
    find first tclase-cron  use-index k1
                           where tclase-cron.etbcod = 0
                             and tclase-cron.clacod = grupo.clacod
                             and tclase-cron.clasup = grupo.clacod
                             and tclase-cron.nive = 1 no-error. 
    if not avail tclase-cron
    then do:
        create  tclase-cron.
        assign  tclase-cron.etbcod = 0
                tclase-cron.clacod = grupo.clacod
                tclase-cron.clasup = grupo.clacod
                tclase-cron.nive = 1.
    end.
    
    find first tclase-cron  use-index k1
                           where tclase-cron.etbcod = 0
                             and tclase-cron.clacod = clasup1.clacod
                             and tclase-cron.clasup = grupo.clacod
                             and tclase-cron.nive = 2 no-error. 
    if not avail tclase-cron
    then do:
        create  tclase-cron.
        assign  tclase-cron.etbcod = 0
                tclase-cron.clacod = clasup1.clacod
                tclase-cron.clasup = grupo.clacod
                tclase-cron.nive = 2.
    end.
    /**/
    
    /* Nivel Superior */
    find first tclase-cron  use-index k1
                           where tclase-cron.etbcod = estab.etbcod
                             and tclase-cron.clacod = grupo.clacod
                             and tclase-cron.clasup = grupo.clacod 
                             and tclase-cron.nive = 1 no-error. 
    if not avail tclase-cron
    then do:
         vkont = vkont + 1.
        create tclase-cron.
        assign  tclase-cron.etbcod = estab.etbcod
                tclase-cron.clacod = grupo.clacod
                tclase-cron.clasup = grupo.clacod
                tclase-cron.nive = 1.
    end.
    tclase-cron.estatual = tclase-cron.estatual + estoq.estatual.
    /**/
    
    /* Nivel Intermediario */
    find first tclase-cron  use-index k1
                           where tclase-cron.etbcod = estab.etbcod
                             and tclase-cron.clacod = clasup1.clacod
                             and tclase-cron.clasup = grupo.clacod
                             and tclase-cron.nive = 2 no-error. 
    if not avail tclase-cron
    then do:
        vkont = vkont + 1.
        create tclase-cron.
        assign  tclase-cron.etbcod = estab.etbcod
                tclase-cron.clacod = clasup1.clacod
                tclase-cron.clasup = grupo.clacod
                tclase-cron.nive = 2.
    end.
    tclase-cron.estatual = tclase-cron.estatual + estoq.estatual.
 end.    

end.


/* Parte II */ 

assign vkont = 0.
       vcabec = "FIL/CLA ".
for each tclase-cron where tclase-cron.etbcod = 0 by tclase-cron.etbcod
                                                  by tclase-cron.clasup
                                                  by tclase-cron.clacod :
 
    assign vcabec = vcabec + string(tclase-cron.clacod,">>>>>>9") + " ".
     assign vkont = vkont + 1
            tclase-cron.seq = vkont.
end.


/* Gerando arquivo */

assign /* varquivo = "/admcom/work" + */
        varquivo = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
        "/perfoestcron" +
        string(day(today),"99") + string(month(today),"99") +  
        string(year(today)) + "." + string(time).

output to value(varquivo).

put vcabec format "x(1200)" skip.

for each tclase-cron where tclase-cron.etbcod <> 0 
                           break by tclase-cron.etbcod
                                 by tclase-cron.clasup
                                 by tclase-cron.clacod :
 
    if first-of(tclase-cron.etbcod)
    then do:
         assign vdetal = string(tclase-cron.etbcod,">>>>>>9") + " ".
         for each tlista :
            delete tlista.
         end.   
    end.
 
    for each btclase-cron where btclase-cron.etbcod = 0 no-lock
                                 by btclase-cron.etbcod
                                 by btclase-cron.clasup
                                 by btclase-cron.clacod :

        find first tlista where tlista.clasup = btclase-cron.clasup and
                                tlista.clacod = btclase-cron.clacod
                            no-error.
        if not avail tlista 
        then do:
            create tlista.
            assign tlista.clasup = btclase-cron.clasup
                   tlista.clacod = btclase-cron.clacod
                   tlista.estoq = 0.
        end.            
        if btclase-cron.clasup   = tclase-cron.clasup and
           btclase-cron.clacod   = tclase-cron.clacod  
        then assign tlista.estoq = tclase-cron.estatual.
    end.
  
    if last-of(tclase-cron.etbcod)
    then do:
         for each tlista use-index k1 :
            assign vdetal = vdetal + string(tlista.estoq,">>>>>>9") + " ".
         end.   
         put skip vdetal format "x(1200)".
         vdetal = "".
    end.

end.

output close.

end procedure.

