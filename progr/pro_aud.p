/*
{admcab.i}

def stream stela.
message "Gerar arquivo de Produtos" update sresp.
if not sresp
then return.


output stream stela to terminal.
output to l:\audit\produto.txt.
*/

def var vcont-aux  as integer.
def var sparam     as char.

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

def var varq as char.

if opsys = "unix" 
then varq = "/admcom/audit/produto.txt".
else do:
    message "gerando arquivo produtos....".
    varq = "l:\audit\produto.txt".
end.

assign vcont-aux = 0.

do on error undo, leave.

    output to value(varq).
    
    assign vcont-aux = vcont-aux + 1.
    
end.

/*Unico programa que não mostra o erro na tela ao tentar o output para arquivo*/
if vcont-aux = 0 
then do:

    if sparam = "Anita"
    then do:
        pause.
        return.
    end.
    else do:
        return.    
    end.    

end.

def var vcodfis as char.
def var vtipo as int.
def var vgenero as int.
def var vmva as dec.
def var vuninven as char.
def var vprodu_procod  like produ.procod.
def var vprodu_pronom  as char.
def var vprodu_prounven like produ.prounven.

for each produ no-lock:

    vtipo = 0.
    vgenero = 00.

    if produ.catcod = 51 or
       produ.catcod = 91
    then vtipo = 7.

    if produ.codfis > 0
    then vgenero = int(substr(string(produ.codfis),1,2)).
/***
    vcodfis = "".    
    if  produ.codfis > 0
    then vcodfis = substring(string(produ.codfis),1,4) + 
                                       "." +   
                                       substring(string(produ.codfis),5,2) +  
                                       "." +  
                                       substring(string(produ.codfis),7,2).
***/

    assign vprodu_procod   = produ.procod
           vprodu_pronom   = produ.pronom
           vprodu_prounven = produ.prounven
           vcodfis = string(produ.codfis).

    run put-produtos.
end.

for each prodnewfree no-lock:

    vtipo = 0.
    vgenero = 0.
    vcodfis = "".    

    if prodnewfree.codfis > 0
    then vgenero = int(substr(string(prodnewfree.codfis),1,2)).

    assign vprodu_procod   = prodnewfree.procod
           vprodu_pronom   = prodnewfree.pronom
           vprodu_prounven = prodnewfree.prounven
           vcodfis         = string(prodnewfree.codfis).

    run put-produtos.
end.

output close.

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

if opsys = "unix"
then.
else do:
    message "Arquivo gerado".
    pause.
end.    
              
procedure put-produtos:
              
    put unformatted
        "1"                   format "x(1)"        /* 001-001 */
        string(vprodu_procod) format "x(20)"       /* 002-021 */
        vprodu_pronom         format "x(45)"       /* 022-066 */
        vprodu_prounven       format "x(03)"       /* 067-069 */
        vcodfis               format "x(10)"       /* 070-079 */
        " "                   format "x(03)"       /* 080-082 */
        "0000.00"                                  /* 083-089 */
        "0000.00"                                  /* 090-096 */
        "0000.00"                                  /* 097-103 */
        " "                   format "x(02)"       /* 104-105 */ 
        vmva                  format "999.9999"    /* 106-112 */
        vuninven              format "x(3)"        /* 113-115 */
        vtipo                 format ">99"         /* 116-118 */
        .
    if vgenero > 0
    then put unformatted vgenero   format "99"      /* 119-120 */
          .
    put skip.
              
end procedure.              
