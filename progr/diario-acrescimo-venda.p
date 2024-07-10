def var rec-plani as recid.
def var ventrada as dec.
def var vcfop as int init 5102 format ">>>9".
def buffer btabdac for tabdac17.
def var vl-total as dec.
def var vp as int.
def var vplatot like plani.platot.
def var vnumero as char.
def var vetbcod like estab.etbcod.

def shared var vmes as int format "99".
def shared var vano as int format "9999".

def temp-table tt-movim like movim.
def var vtot-mov as dec.
def var t-movim as dec.
def var a-movim as dec.


disp "Aguarde processamento... " with frame f-processa
    1 down column 40 row 20 overlay no-box color message.
pause 0.


def var varquivo as char.
varquivo = "/admcom/relat/diario-acrescimo-venda-prazo-" + string(vmes,"99")
                + "-" + string(vano,"9999") + ".csv".
output to value(varquivo).
put 
"Filial;CNPJ;Numero;Nome;CPF;Valor Venda;Entrada;Acrescimo;Contrato;Valor Contrato;CFOP;Produto;NCM;Descricao;ICMS;Valor Item;Acrescimo Item" skip.  


for each tabdac17 where
         tabdac17.meslan = vmes and
         tabdac17.anolan = vano and
         tabdac17.tiplan = "ACRESCIMO" and 
         tabdac17.sitlan = "LEBES"
         no-lock.
    if vallan = 0 then next.
    find first btabdac where btabdac.etbcod = tabdac17.etbcod and
                           btabdac.clicod = tabdac17.clicod and
                           btabdac.numlan = tabdac17.numlan and
                           btabdac.tiplan = "EMISSAO"
                           no-lock no-error.
    if not avail btabdac then next.
    find fin.contrato where fin.contrato.contnum = int(tabdac17.numlan) 
                no-lock no-error.
    rec-plani = ?.
    if avail fin.contrato
    then
    for each fin.contnf where
             fin.contnf.etbcod = fin.contrato.etbcod and
             fin.contnf.contnum = fin.contrato.contnum
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.pladat = fin.contrato.dtinicial and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.
    else if avail btabdac
    then for each fin.contnf where
             fin.contnf.etbcod = btabdac.etblan and
             fin.contnf.contnum = int(btabdac.numlan)
             no-lock:
        find first plani where plani.etbcod = fin.contnf.etbcod and
                               plani.placod = fin.contnf.placod and
                               plani.movtdc = 5 and
                               plani.serie  = fin.contnf.notaser
                               no-lock no-error.
        if avail plani
        then do:
            rec-plani = recid(plani).
            leave.
        end.                       
    end.

    find plani where recid(plani) = rec-plani no-lock no-error.
    if not avail plani 
    then find last plani where plani.movtdc = 5 and
                                plani.desti = int(tabdac17.clicod) and
                                plani.pladat = tabdac17.datlan 
                                no-lock no-error.
    
    if avail plani
    then vetbcod = plani.etbcod.
    else vetbcod = fin.contrato.etbcod.
    
    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        vetbcod = tabdac17.etblan.
        find first estab where estab.etbcod = vetbcod no-lock no-error.
    end.
    
    find clien where clien.clicod = fin.contrato.clicod no-lock no-error.
    if not avail clien
    then find clien where clien.clicod = plani.desti no-lock no-error.
    if avail btabdac
    then vl-total = btabdac.vallan + tabdac17.vallan.
    else vl-total = fin.contrato.vltotal.
    if avail plani
    then  ventrada = tabdac17.vallan - (vl-total - plani.platot).

    if ventrada < 0 and avail btabdac
    then do:
        vl-total = btabdac.vallan + tabdac17.vallan.
        ventrada = 0.
    end. 

    vplatot = 0.
    vnumero = "".
    if avail plani 
    then assign
            vnumero = string(plani.numero)
            vplatot = plani.platot
            ventrada = 0.
    else next.
    
    put unformatted
         estab.etbcod 
         ";"
         estab.etbcgc
         ";"
         vnumero
         ";"
         clien.clinom
         ";"
         clien.ciccgc
         ";"
         /*vcfop
         ";" */
         replace(string(vplatot,">>>>>>>>>9.99"),".",",")
         ";"
         replace(string(ventrada,">>>>>>>>>9.99"),".",",")
         ";"
         replace(string(tabdac17.vallan,">>>>>>>>>9.99"),".",",")
         ";"
         tabdac17.numlan format "x(20)"
         ";"
         replace(string(vl-total,">>>>>>>>>9.99"),".",",")
         .
    vp = 0.
    for each tt-movim: delete tt-movim. end.
    vtot-mov = 0.
    for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc and
             movim.movdat = plani.pladat
             no-lock,
        first produ where produ.procod = movim.procod no-lock:         
        if produ.proipiper = 98
        then next.
        create tt-movim.
        buffer-copy movim to tt-movim.
        vtot-mov = vtot-mov + (movim.movpc * movim.movqtm). 
    end. 
    if vtot-mov > 0
    then
    for each tt-movim no-lock,
        first produ where produ.procod = tt-movim.procod no-lock
        :

        vp = vp + 1.
        if vp > 1
        then put ";;;;;;;;;".
        if tt-movim.opfcod > 0
        then put ";" tt-movim.opfcod format ">>>9".
        else put ";" vcfop.
        
        t-movim = (tt-movim.movpc * tt-movim.movqtm).
        a-movim = tabdac17.vallan * (t-movim / vtot-mov).
        
        put unformatted
            ";" produ.procod
            ";" produ.codfis
            ";" produ.pronom 
            ";" produ.proipiper
            ";" replace(string(t-movim,">>>>>>>>>9.99"),".",",") 
            ";" replace(string(a-movim,">>>>>>>>>9.99"),".",",")
            skip. 
    end.
    put skip.     
end.
output close.

hide frame f-processa no-pause.

message color red/with
    "Arquivo gerado:" skip
    varquivo
    view-as alert-box.
    
    
