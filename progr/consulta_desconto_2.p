{admcab.i}

def input parameter  v-flini like plani.etbcod.
def input parameter  v-flfim like plani.etbcod.

def var v-dtini like plani.pladat.
def var v-dtfim like plani.pladat.
def var v-totalvenda like plani.platot.
def var v-totaldesc like plani.platot.
def var v-valdesc like plani.platot.
def var v-percent like plani.platot.

def var vltotven like plani.platot.
def var vltotdes like plani.platot.
def var vpercmed like plani.platot.
def var val-total-movim as dec.
def var val-total-plani as dec.

def var vok as log.
def var vokc as log.
def var vokd as log.

v-dtini = today - 30.
v-dtfim = today.

v-totalvenda = 0.
v-totaldesc = 0.

vltotven = 0.
vltotdes = 0.

output to /admcom/relat/consulta_desconto.csv.

put "FILIAL ; VENDA ; DESCONTO ; PERCENTUAL" skip.

for each plani where emite >= v-flini and 
           emite <= v-flfim and 
           pladat >= v-dtini and 
           pladat <= v-dtfim and
           movtdc = 5 no-lock
           break by plani.etbcod:

  /****** VENDA COM DESCONTO ******/ 

  if acha("DESCONTO_FUNCIONARIO",plani.notobs[3]) = "SIM"
    then next.

    val-total-plani = 0.
    
    if plani.biss > plani.platot - plani.vlserv
        then val-total-plani = plani.biss.
            else val-total-plani = plani.platot - plani.vlserv.
            
    val-total-movim = 0.
    
    vok = yes.
    vokc = no.
    vokd = yes.
    for each movim where 
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc and
             movim.movdat = plani.pladat
             no-lock:
        find last produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        if produ.clacod = 101 or
           produ.clacod = 102 or
           produ.clacod = 107 or
           produ.clacod = 109 or
           produ.clacod = 201 or
           produ.clacod = 191 or
           produ.clacod = 181 
        then do:
            vok = no.
            leave.
        end.   
        
        if produ.clacod = 100 or
           produ.clacod = 101 or
           produ.clacod = 102 or
           produ.clacod = 107 or
           produ.clacod = 190 or
           produ.clacod = 191 or
           produ.clacod = 201 or
           produ.clacod = 202 or
           produ.procod = 405248 or
           produ.procod = 1383 or
           produ.procod = 493563
         then next.
        if produ.catcod = 31
        then do:
            vokc = yes.
            val-total-movim = val-total-movim + (movim.movpc * movim.movqtm).
        end.    
        
    end.      
    if vokc = no then next.
    
    val-total-plani = val-total-plani * (val-total-movim / plani.protot).
    vltotven = vltotven + val-total-plani.

    if vok = no then next.      

    if plani.notobs[2] <> "" then do:

      if acha("DESCONTO",plani.notobs[2]) <> ? and dec(acha("DESCONTO",plani.notobs[2])) > 0 
        then v-totaldesc = v-totaldesc + dec(acha("DESCONTO",plani.notobs[2])).

      else if acha("DESCONTO",plani.notobs[2]) = ? and dec(plani.notobs[2]) > 0 
        then v-totaldesc = v-totaldesc + dec(plani.notobs[2]).

    end.

vpercmed = ((v-totaldesc / vltotven) * 100).

  if last-of(plani.etbcod)
    then do:
      /*disp "Vnd FL " + string(plani.etbcod) + ":" format "x(9)"
        vltotven  no-label
        "Desc FL " + string(plani.etbcod) + ":" format "x(10)"
        vltotdes  no-label
        "Perc FL " + string(plani.etbcod) + ":" format "x(10)"
        vpercmed + "%"  no-label*/
        
        put string(plani.etbcod) ";" vltotven ";" v-totaldesc ";" vpercmed skip.

        vltotven = 0.
        v-totaldesc = 0.
        vpercmed = 0.
    end.
end.

output close.

message "ARQUIVO consulta_desconto.csv GERADO COM SUCESSO EM L:/relat" view-as alert-box title "  ATENCAO!  ".