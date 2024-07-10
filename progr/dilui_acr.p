def input parameter vetbi like estab.etbcod.
def input parameter vetbf like estab.etbcod.
def input parameter vdti as date.
def input parameter vdtf as date.
def input parameter val-acrescimo as dec.
disable triggers for load of titulo.

def var vtotal-sel as dec.
def shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

disable triggers for load of titulo.
def var vdata as date.
def var v1 as int.
def var v2 as int.
def var v3 as int.
def var v4 as int.
def var vtitnum like titulo.titnum.

def var vndx as dec.
v2 = 0.
v3 = 0.
repeat:
do vdata = vdti to vdtf:
    if vdata = 01/01/09 then next.
    for each estab where estab.etbcod >= vetbi and
                     estab.etbcod <= vetbf 
                     no-lock.
        v2 = v2 + 1.
        v3 = v3 + 1.
        do v1 = 1 to v2:
            for each plani where plani.movtdc = 5
                         and plani.etbcod = estab.etbcod
                         and plani.pladat = vdata
                         and plani.crecod = 2
                         no-lock:
                find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
                if not avail contnf
                then next.
                find first titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = plani.etbcod and
                           titulo.clifor = plani.desti and
                           titulo.titnum = string(contnf.contnum) and
                           titulo.titbanpag = 999
                           no-lock no-error.
                if avail titulo
                then next.
                find first titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = plani.etbcod and
                           titulo.clifor = plani.desti and
                           titulo.titnum = string(contnf.contnum) and
                           titulo.titbanpag = 888
                           no-lock no-error.
                if avail titulo
                then next.
                
                for each titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = plani.etbcod and
                           titulo.clifor = plani.desti and
                           titulo.titnum = string(contnf.contnum)
                       .

                    if titulo.clifor = 1 or
                       titulo.titnat = yes or
                       titulo.titpar = 0 or
                       titulo.modcod <> "CRE" 
                    then next.
                
                    if titulo.titbanpag = 999
                    then next.
                    if titulo.titbanpag = 888
                    then next.
                    
                    find first tt-index use-index i1 where
                            tt-index.etbcod = titulo.etbcod and
                            tt-index.data = vdata no-lock no-error.
                    if avail tt-index and tt-index.indx = 0
                    then next.

                    if not avail tt-index 
                    then vndx = 1.
                    else vndx = tt-index.indx. 
                    vtotal-sel = vtotal-sel + (titulo.titvlcob - 
                        (titulo.titvlcob * vndx)).
                    titulo.titbanpag = 999.

                    if v2 >= 3 
                    then do:
                        if v3 >= 10
                        then do:
                            v3 = 0.
                            v2 = 3.
                        end.
                        else v2 = 0. 
                    end.
                end.         
                disp "Processando DLACR ... " vdata vtotal-sel
                        with frame f-dilui 1
                        down centered color message no-box 
                        no-label
                        . 
                        pause 0.
                leave.
            end.
            if vtotal-sel >= val-acrescimo
            then leave.
        end.
        if vtotal-sel >= val-acrescimo
            then leave.
    end.
    if vtotal-sel >= val-acrescimo
            then leave.
end.
if vtotal-sel >= val-acrescimo
then leave.

end.                              
