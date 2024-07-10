def input parameter par-rec as recid.
def input parameter tip-ped as char.
def input parameter par-diretorio   as char.
def input parameter par-arquivo     as char.

def var par-bkp as char.
def var par-sai as char.

def var v-lote as char.
        
def var v-serie as char.

def var vPROPRIETaRIO       as char init "900".
def var Transportadora as char init "999".

find tdocbase where recid(tdocbase) = par-rec no-error.
if not avail tdocbase
then leave.

/* #3 */
def var vmoveis_ecommerce as log.
/*
vmoveis_ecommerce = no.
for each tdocbpro of tdocbase no-lock.  /* #3 */
    find produ of tdocbpro no-lock.
    if produ.catcod <> 41 
    then vmoveis_ecommerce = yes.
end.
if vmoveis_ecommerce = no /* se nao ha produto moveis ou outros */
then return. /* #3 */
*/

def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/MOVEIS/".

/*
if tip-ped = "VEXM"
then vdiretorio-apos = "/usr/ITF/dat/in/".
else vdiretorio-apos = "/usr/ITF_CELL/dat/in".
*/

def var vqtdtot as dec.
def var vindvex as log.
def var vindnor as log.
vindvex = no.
vindnor = no.
vqtdtot = 0.
for each tdocbpro of tdocbase no-lock:
    find produ of tdocbpro no-lock.
    if tip-ped = "VEXM" and produ.catcod = 41 /*and produ.ind_vex*/
    then do:
        vindvex = yes.
        vqtdtot  = vqtdtot + 1.
    end. 
    else if tip-ped = "NORM" and produ.catcod = 31
    then do:
        vindnor = yes.
        vqtdtot  = vqtdtot + 1.
    end.    
end.

par-bkp = vdiretorio-ant +      par-arquivo. /* "ORDVH" + string(int(p-valor),"99999999") + ".DAT". */
par-sai = par-diretorio  +      par-arquivo. /* "ORDVH" + string(int(p-valor),"99999999") + ".DAT".*/ 
 
output to value(par-bkp).

    put unformatted 
        "LEBES"                 format "x(10)"                  
        "ORDV"                  format "x(4)"                   
        "ORDVH"                 format "x(8)"                   
        "CD3"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  

        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"                
        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"                
        Transportadora          format "x(12)"
        string(tdocbase.dtdoc,"99999999")    format "xxxxxxxx"
        string(tdocbase.etbdes)    format "x(12)"
        ""                      format "x(10)"
        tip-ped                  format "x(4)"
        tdocbase.ordem          format ">>>"
        string(vqtdtot)         format "xxxx"
        string(tdocbase.box,"99") format "x(5)"
        skip.                     

for each tdocbpro of tdocbase :

    find produ of tdocbpro no-lock.

    v-lote = "".    
    if tip-ped = "PESP"
    then do:
        find abascorteprod where 
                abascorteprod.dcbcod    = tdocbpro.dcbcod and
                abascorteprod.dcbpseq   = tdocbpro.dcbpseq
            no-lock no-error.
        if avail abascorteprod
        then do:
            find abastransf of abascorteprod no-lock no-error.
            if avail abastransf
            then do:
                find first abascompra where abascompra.etbcod = abastransf.etbcod and
                                            abascompra.abtcod = abastransf.abtcod
                                            no-lock no-error.
                if avail abascompra
                then do:
                    find pedid where pedid.etbcod = abascompra.etbped and
                                     pedid.pedtdc = abascompra.pedtdc and
                                     pedid.pednum = abascompra.pednum
                            no-lock no-error.
                    if avail pedid
                    then do:
                        find first plaped where
                                plaped.pedetb = pedid.etbcod and
                                plaped.plaetb = pedid.etbcod and
                                plaped.pednum = pedid.pednum
                                no-lock no-error.
                        if avail plaped
                        then do:
                            find plani where plani.etbcod = plaped.plaetb and
                                    plani.placod = plaped.placod
                                no-lock no-error.
        
                            if avail plani
                            then do:
                                v-lote = string(plani.numero).
                                v-serie = "".
                                if length(plani.serie) = 1
                                then v-serie = "00" + string(plani.serie).
                                else if length(plani.serie) = 2
                                then v-serie = "0" + string(plani.serie).
                                else if length(plani.serie) = 3
                                then v-serie = string(plani.serie).
                                v-lote = v-lote + v-serie.
                            end.
                        end.
                    end.
                end.
            end.
        end.                                  
    end.
    
    put unformatted 
        "LEBES"                 format "x(10)"                  
        "ORDV"                  format "x(4)"                   
        "ORDVI"                 format "x(8)"                   
        "CD3"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  
        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"                
        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"  
        string(tdocbpro.dcbpseq)    format "9999" 
        string(tdocbpro.procod)    format "x(40)"                  
        tdocbpro.movqtm * 1000000000           format "999999999999999999"     
        produ.prouncom          format "x(06)"                  
        v-lote                  format "x(20)"
        skip.                 
            
    tdocbpro.situacao = "L".            
                     
end.
output close.

tdocbase.campo_char1 = tdocbase.campo_char1 +
                    "DATAENVIOORDVWMS=" + string(today,"99/99/9999") +
                   "|HORAENVIOORDVWMS=" + string(time,"hh:mm:ss") +
                   "|ARQUIVOORDVWMS=" + par-bkp.
tdocbase.situacao = "L".




unix silent value("cp " + par-bkp +  " " + par-sai).

hide message no-pause.
message color normal "GERADO MOVEIS " par-sai.
do on endkey undo , leave.
pause 1 no-message.
end.


