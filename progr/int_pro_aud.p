/* não colocar admcab.i */

def var sresp as log format "Sim/Nao".
def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
if opsys = "unix" and sparam = "AniTA"
then do:
    sresp = no.
    message "Confirma gerar arquivo de PRODUTOS?" update sresp.
    if not sresp then return.
end. 

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
vdtf = today - 1.
vdti = vdtf  - 60.

def var vcont-aux  as integer.

def var varq as char.

if opsys = "unix" and sparam = "AniTA" 
then varq = "/admcom/decision/produtos.txt".
else varq = "/file_server/produtos.txt".

assign vcont-aux = 0.

do on error undo, leave.

    output to value(varq).
    
    assign vcont-aux = vcont-aux + 1.
    
end.

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

def temp-table tt-produ like produ.

def var vachou as log.
for each produ no-lock:
    vachou = no.
    find first movim where movim.procod = produ.procod and
                           movim.movdat > vdti and
                           movim.movtdc <> 7 and
                           movim.movtdc <> 8
                           no-lock no-error.
    if avail movim 
    then vachou = yes.
    else do:
        find first estoq where
                   estoq.procod = produ.procod and
                   estoq.estatual > 0
                   no-lock no-error.
        if avail estoq
        then vachou = yes.           
    end.                       
    if avail movim and (movim.movtdc = 7 or
       movim.movtdc = 8)
    then vachou = no.   
    if vachou
    then do:
        create tt-produ.
        buffer-copy produ to tt-produ.
    end.
end.

for each prodnewfree no-lock:
    find first movim where movim.procod = prodnewfree.procod and
                           movim.movdat > vdti
                           no-lock no-error.
    if not avail movim
    then next.
    
    find first tt-produ where tt-produ.procod = prodnewfree.procod
                            no-error.
    if avail tt-produ
    then next.
    create tt-produ.
    buffer-copy prodnewfree to tt-produ.
end.                            
    
def var v-cest as char.
for each tt-produ no-lock:
    
    assign
        vtipo = 0
        vgenero = 00
        vcodfis = ""
        v-cest = ""
        .

    if tt-produ.catcod = 51 or
       tt-produ.catcod = 91
    then vtipo = 7.

    if tt-produ.codfis > 0
    then vgenero = int(substr(string(tt-produ.codfis),1,2)).

    assign vprodu_procod   = tt-produ.procod
           vprodu_pronom   = tt-produ.pronom
           vprodu_prounven = tt-produ.prounven
           vcodfis = string(tt-produ.codfis).
          if vcodfis="0" or vcodfis="99999999" 
          then vcodfis="".

    find first clafis where clafis.codfis = int(vcodfis)
                        no-lock no-error.
    if avail clafis 
    then v-cest = clafis.char1.
    else v-cest = "".

    run put-produtos.
    
end.

output close.

/**************
if opsys = "unix" and sparam = "AniTA" 
then varq = "/admcom/decision/servicos.txt".
else varq = "/file_server/servicos.txt".

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
**************/

/****
if opsys = "unix"
then.
else do:
    message "Arquivo gerado".
    pause.
end.    
****/
              
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
        vgenero               format "99"          /* 119-120 */
        v-cest                 format "x(10)"       /* 121-130 */
        .
        /*
    if vgenero > 0
    then put unformatted vgenero   format "99"      /* 119-120 */
          .*/
    put skip.
              
end procedure.              
