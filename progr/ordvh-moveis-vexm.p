/* Ordem de Venda          WMS Alcis                              */
/** 31/05/2017 - #3 Projeto Moda no ecommerce, se for ecommerce, rodara interface para moda, e dentro da interface somente ira exportar produtos nmoda. a interface para moveis nao ira exportar produtos moda.
*/


def input parameter par-rec as recid.
def input parameter tip-ped as char.
def var par-arq as char.

def var vPROPRIETaRIO       as char init "900".
def shared var vALCIS-ARQ-ORDVH   as int.
vALCIS-ARQ-ORDVH = 0.

def temp-table tt-pedid like pedid.
def temp-table tt-liped like liped.
 
find tdocbase where recid(tdocbase) = par-rec no-error.
if not avail tdocbase
then leave.

/* #3 */
def var vmoveis_ecommerce as log.
vmoveis_ecommerce = no.
for each tdocbpro of tdocbase no-lock.  /* #3 */
    find produ of tdocbpro no-lock.
    if produ.catcod = 41 and produ.ind_vex 
    then vmoveis_ecommerce = yes.
end.
if vmoveis_ecommerce = no /* se nao ha produto moveis ou outros */
then return. /* #3 */

for each tdocbpro of tdocbase.

    find produ where produ.procod = tdocbpro.procod no-lock.
    if produ.catcod = 41 and  produ.ind_vex
    then. else next.
    /*
    message tdocbpro.etbdes tdocbpro.pednum
    tdocbase.etbdes . pause.
    */
    find first tt-pedid where 
               tt-pedid.pedtdc = 95 and
               tt-pedid.etbcod = tdocbpro.etbdes and
               tt-pedid.pednum = tdocbpro.pednum no-lock no-error.
    if not avail tt-pedid
    then do:
        create tt-pedid.
        assign
            tt-pedid.pedtdc = 95
            tt-pedid.etbcod = tdocbpro.etbdes
            tt-pedid.pednum = tdocbpro.pednum
            tt-pedid.peddat = tdocbase.dtdoc
            tt-pedid.regcod = tdocbase.ordem
            .
    end.
    create tt-liped.
    assign
        tt-liped.pedtdc = tt-pedid.pedtdc
        tt-liped.etbcod = tt-pedid.etbcod
        tt-liped.pednum = tt-pedid.pednum
        tt-liped.procod = tdocbpro.procod
        tt-liped.lipqtd = tdocbpro.movqtm 
        .
    tdocbpro.situacao = "F".
end.                
    
/*****
if vALCIS-ARQ-ORDVH = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ORDVH" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-ORDVH"
               tab_ini.valor     = "0"
               tab_ini.dtinclu   = today
               tab_ini.dtexp     = today
               tab_ini.exportar  = no.
    end.
    else do.
        def var v as int.
        v = int(tab_ini.valor).
        v = v + 1.
        tab_ini.valor = string(v).
    end.
end. 
****/
def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/MOVEIS/".
def var vdiretorio-bkp as char.
vdiretorio-bkp = "/admcom/tmp/alcis/MOVEIS/bkp/".
def var vdiretorio-apos as char.
if tip-ped = "VEXM"
then vdiretorio-apos = "/usr/ITF/dat/in/".
else vdiretorio-apos = "/usr/ITF_CELL/dat/in".

def var vqtdtot as dec.
def var vindvex as log.
def var vindnor as log.
vindvex = no.
vindnor = no.
vqtdtot = 0.
for each tdocbpro of tdocbase no-lock:
    find produ of tdocbpro no-lock.
    if tip-ped = "VEXM" and produ.catcod = 41 and produ.ind_vex
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

def var v as int.
def var Transportadora as char init "999".

if (tip-ped = "VEXM" and  not vindvex) or
   (tip-ped = "NORM" and  not vindnor)
then.
else do on error undo:
    for each tt-pedid where tt-pedid.pednum > 0 no-lock:
        find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ORDVH" no-error.
        if not avail tab_ini
        then do.
            create tab_ini. 
            ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-ORDVH"
               tab_ini.valor     = "0"
               tab_ini.dtinclu   = today
               tab_ini.dtexp     = today
               tab_ini.exportar  = no.
        end.
        else do.
            v = int(tab_ini.valor).
            v = v + 1.
            tab_ini.valor = string(v).
        end.

        par-arq = vdiretorio-ant + 
            "ORDVH" + string(v,"99999999") + ".DAT".
        vALCIS-ARQ-ORDVH = vALCIS-ARQ-ORDVH + 1.

        message "Arquivo" par-arq.
            pause 1 no-message.
        hide message no-pause.
 
        vqtdtot = 0.
        for each tt-liped where 
                 tt-liped.pedtdc = tt-pedid.pedtdc and
                 tt-liped.etbcod = tt-pedid.etbcod and
                 tt-liped.pednum = tt-pedid.pednum and
                 tt-liped.procod > 0
                 no-lock:
            vqtdtot  = vqtdtot + 1.
        end.             
        
        output to value(par-arq) append.

        put unformatted 
                "LEBES"                 format "x(10)"                  
                "ORDV"                  format "x(4)"                   
                "ORDVH"                 format "x(8)"                   
                "CD3"                   format "x(3)"                   
                vPROPRIETaRIO           format "x(12)"                  

            (string(tt-pedid.etbcod,   "999") +
             string(tt-pedid.pednum,"999999999"))     format "x(12)"
            (string(tt-pedid.etbcod,   "999") +
             string(tt-pedid.pednum,"999999999"))     format "x(12)"   
             Transportadora          format "x(12)"
             string(tt-pedid.peddat,"99999999")    format "xxxxxxxx"
             string(tt-pedid.etbcod)    format "x(12)"
             ""                      format "x(10)"
             tip-ped                  format "x(4)"
             tt-pedid.regcod          format ">>>"
             string(vqtdtot)         format "xxxx"
             "99" format "x(5)"
             skip.                     
        for each tt-liped where 
                 tt-liped.pedtdc = tt-pedid.pedtdc and
                 tt-liped.etbcod = tt-pedid.etbcod and
                 tt-liped.pednum = tt-pedid.pednum and
                 tt-liped.procod > 0
                 no-lock:
        
            find produ where produ.procod = tt-liped.procod no-lock.
            def var vseq as int.
            vseq = vseq + 1.
    
            put unformatted 
                "LEBES"                 format "x(10)"                  
                "ORDV"                  format "x(4)"                   
                "ORDVI"                 format "x(8)"                   
                "CD3"                   format "x(3)"                   
                vPROPRIETaRIO           format "x(12)"                  
                (string(tt-liped.etbcod,   "999") +
                 string(tt-liped.pednum,"999999999"))     format "x(12)" 
                (string(tt-liped.etbcod,   "999") +
                 string(tt-liped.pednum,"999999999"))     format "x(12)"
                 string(vseq)    format "9999" 
                 string(tt-liped.procod)    format "x(40)"                  
                 tt-liped.lipqtd * 1000000000    
                        format "999999999999999999"     
                 produ.prouncom          format "x(06)"                  
                 ""                      format "x(20)"
                 skip.                 
            
        end.
        output close.
        
        find pedid where
             pedid.etbcod = tt-pedid.etbcod and
             pedid.pedtdc = tt-pedid.pedtdc and
             pedid.pednum = tt-pedid.pednum
             no-error.
        if avail pedid
        then do on error undo:      
            pedid.pedobs[4] = pedid.pedobs[4] +
                    "DATAENVIOORDVWMS=" + string(today,"99/99/9999") +
                   "|HORAENVIOORDVWMS=" + string(time,"hh:mm:ss") +
                   "|ARQUIVOORDVWMS=" + par-arq.
        end.   
        unix silent value("cp " + par-arq +  " " + vdiretorio-bkp).
        unix silent value("mv " + par-arq +  " " + vdiretorio-apos).    
    end.
    tdocbase.situacao = "F".
end.

/*******
message "MOVEIS " vdiretorio-apos + 
         "/ORDVH" + string(int(p-valor),"99999999") + ".DAT".
message "MOVEIS" vdiretorio-bkp + 
         "ORDVH" + string(int(p-valor),"99999999") + ".DAT".
pause 1 no-message.

{mens-interface-wms-alcis.i}
end.    
*********/
