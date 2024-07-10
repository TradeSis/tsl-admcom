{admcab.i}

def var  v-flini like plani.etbcod.
def var  v-flfim like plani.etbcod.

def var v-dtini like plani.pladat.
def var v-dtfim like plani.pladat.
def var v-totalvenda like plani.platot.
def var v-totaldesc like plani.platot.
def var v-valdesc like plani.platot.
def var v-percent like plani.platot.

def var vok as log.
def var vokc as log.
def var vokd as log.

v-flini = 1.
v-flfim = 999.

v-dtini = today - 30.
v-dtfim = today.

v-totalvenda = 0.
v-totaldesc = 0.

/*update v-flini label "Filial inicial"
	   v-flfim label "Filial final"
with frame f1 centered side-label title "  Informe os dados  " width 80.

disp "Periodo de: " v-dtini no-label "ate: " v-dtfim no-label with frame f1 centered width 80.

if v-flini = v-flfim then do:
  message "Filial final deve ser diferente da inicial!" view-as alert-box title "  ATENCAO!  ".
  undo, retry.
end.*/

/*disp v-flini v-flfim v-dtini v-dtfim.*/

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
    
    vok = yes.
    vokc = yes.
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
         
        if produ.catcod <> 31
        then do:
            vokc = no.
            leave.
        end.    
        
    end.      
    if vokc = no then next.

	/****** ******/
	
	v-totalvenda = v-totalvenda + (if plani.biss > 0 then plani.biss else (plani.platot - plani.vlserv)).

	if vok = no then next.   
    
    /*if plani.notobs[2] <> ""  then do:
      if dec(plani.notobs[2]) > 0 
        then 
      	 if acha("DESCONTO",plani.notobs[2]) <> ? 
	        then v-totaldesc = v-totaldesc + dec(acha("DESCONTO",plani.notobs[2])).
      	 else
      	   v-totaldesc = v-totaldesc + dec(plani.notobs[2]).
    end.*/

    if plani.notobs[2] <> "" then do:

      if acha("DESCONTO",plani.notobs[2]) <> ? and dec(acha("DESCONTO",plani.notobs[2])) > 0 
        then v-totaldesc = v-totaldesc + dec(acha("DESCONTO",plani.notobs[2])).

      else if acha("DESCONTO",plani.notobs[2]) = ? and dec(plani.notobs[2]) > 0 
        then v-totaldesc = v-totaldesc + dec(plani.notobs[2]).

    end.

    v-percent = ((v-totaldesc / v-totalvenda) * 100).

	if last-of(plani.etbcod)
    then do:
      /*disp "Vnd FL " + string(plani.etbcod) + ":" format "x(9)"
        v-totalvenda  no-label
        "Desc FL " + string(plani.etbcod) + ":" format "x(10)"
        v-totaldesc  no-label
        "Perc FL " + string(plani.etbcod) + ":" format "x(10)"
        v-percent + "%"  no-label*/
        
        /*disp "Filial " + string(plani.etbcod) + " ->" format "x(13)"
          v-totalvenda label "Venda" format ">,>>>,>>9.99"
          v-totaldesc label "Desc." format ">,>>>,>>9.99"
          v-percent label "Perc." format ">>>9.99%"
        with frame f2 down width 80 side-labels.*/

        put string(plani.etbcod) ";" v-totalvenda ";" v-totaldesc ";" v-percent skip.

        v-totalvenda = 0.
        v-totaldesc = 0.
    end.
end.

output close.