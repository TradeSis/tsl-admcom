{admcab.i new}

def var varquivo as char format "x(70)".
def var vdir as char.
def var vnom as char.
vdir = "/admcom/relat/".
vnom = "produ_MTP_" + string(time) + ".csv".
varquivo = vdir + vnom .

update varquivo label "Informe o caminho e nome do arquivo" with frame f1 1 down width 80
title " Gera arquivo csv com todos os produtos cadatrados ".

def var vcont-aux  as integer.
def var sparam     as char.
def stream s-disp.

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

def var varq as char.


assign vcont-aux = 0.

do on error undo, leave.

    output to value(varquivo).
    
    assign vcont-aux = vcont-aux + 1.

    put "Codigo;Nome;Clas.Fiscal;Aliq.ICMS;Aliq.PIS;Aliq.COFINS;MVA"
    skip.
    
end.

def var valiqicms as dec.
def var valiqpis as dec.
def var valiqcofins as dec.

def var vcodfis as char.
def var vtipo as int.
def var vgenero as int.
def var vmva as dec.
def var vuninven as char.
def var vprodu_procod  like produ.procod.
def var vprodu_pronom  as char.
def var vprodu_prounven like produ.prounven.

output stream s-disp to terminal.

for each produ no-lock:

    disp stream s-disp produ.procod format ">>>>>>>>>9" produ.pronom 
        with 1 down
         .
    pause 0.
        
    vtipo = 0.
    
    if produ.catcod = 51 or
       produ.catcod = 91
    then vtipo = 7 .  

    if produ.codfis > 0
    then vgenero = int(substr(string(produ.codfis),1,2)).
    else vgenero = 00.
    vcodfis = "". 
    vmva = 0.   
    if  produ.codfis > 0
    then do:
        vcodfis = substring(string(produ.codfis),1,4) + 
                                       "." +   
                                       substring(string(produ.codfis),5,2) +  
                                       "." +  
                                       substring(string(produ.codfis),7,2).
 
        find clafis where clafis.codfis = produ.codfis no-lock no-error.
        if not avail clafis
        then
            assign
                valiqpis    = 1.65
                valiqcofins = 7.6.
        else
            assign
                valiqpis    = clafis.pisent
                valiqcofins = clafis.cofinsent
                vmva = clafis.mva_estado1.
                
                
            /**
            if tipmov.tipemite or
               tipmov.movtvenda
            then assign
                    valiqpis    = clafis.pissai
                    valiqcofins = clafis.cofinssai.
            else assign
                    valiqpis    = clafis.pisent
                    valiqcofins = clafis.cofinsent.
            **/
 
    end.
    
    if produ.proipiper = 99
    then valiqicms = 0.
    else valiqicms = produ.proipiper .
    

    assign vprodu_procod   = produ.procod
           vprodu_pronom   = produ.pronom
           vprodu_prounven = produ.prounven.


    run put-produtos.
            
end.

/**
for each prodnewfree no-lock:

    vtipo = 0.

    vgenero = 00.
    
    vcodfis = "".    

    assign vprodu_procod   = prodnewfree.procod
           vprodu_pronom   = prodnewfree.pronom
           vprodu_prounven = prodnewfree.prounven.

    run put-produtos.
            
end.
**/
output stream s-disp close.
output close.

/*
if opsys = "unix" 
then varq = "/admcom/audit/servicos.txt".
else do:
    message "gerando arquivo servicos....".
    varq = "l:\audit\servicos.txt".
end.
output to value(varq).

for each produsrv no-lock:
    put unformatted
        /* 1-3 */     "SRV"  
        /* 4-4 */     "S"    
        /* 5-24 */    string(produsrv.procod) format "x(20)" 
        /* 25-174 */  produsrv.pronom format "x(150)"        
        /* 175-202 */ " " format "x(28)"                     
        /* 203-230 */ " " format "x(28)"                     
        /* 231-250 */ " " format "x(20)" 
        /* 251-251 */ " " format "x"
        /* 252-279 */ produsrv.proindice format "x(28)"
        /* 280-280 */ " " format "x"
        /* 281-281 */ " " format "x"
        /* 282-282 */ " " format "x"
        /* 283-283 */ " " format "x"
        /* 284-284 */ " " format "x"
        /* 285-285 */ " " format "x"
        /* 286-286 */ " " format "x"
        /* 287-292 */ " " format "x(6)"
        /* 293-298 */ " " format "x(6)"
        /* 299-305 */ "0000.00"
        /* 306-312 */ "0000.00"
        /* 313-319 */ "0000.00"
        skip.                   
        
        
end.
output close.

****/

output close.
              
message color red/with
              "Arquivo gerado: " skip
              varquivo
              view-as alert-box.
              
              
procedure put-produtos:
              
    put unformatted
        string(vprodu_procod) format "x(20)"   ";"
        vprodu_pronom         format "x(45)"   ";"
        vcodfis              format "x(10)"    ";"
        valiqicms                              ";"
        valiqpis                               ";"
        valiqcofins                            ";"
        vmva                 format "999.9999"    
        .

    put skip.
              
end procedure.              
