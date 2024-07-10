def var val-pis as dec.
def var val-cofins as dec.
def var base-pis as dec.
def var aux-uf as char.
def var per-pis as dec.
def var per-cofins as dec.
def var vcodsit as char.
def var t-pis as dec.
def var t-cofins as dec.
def temp-table tt-pla
    field numero like fiscal.numero
    field plarec like fiscal.plarec
    field emite  like fiscal.emite
    field desti  like fiscal.desti
    field platot like fiscal.platot
    field cfop   like fiscal.opfcod
    field pis    as dec
    field cofins as dec.
def var vdti as date.
def var vdtf as date.
def var vopfcod like fiscal.opfcod.

update vdti label "Periodo de"
 vdtf label "Ate"
 vopfcod label "CFOP" format ">>>>>9"
 with frame f1 side-label 1 down.        

for each estab no-lock:

    for each fiscal where fiscal.desti = estab.etbcod and
        (if vopfcod > 0
         then fiscal.opfcod = vopfcod else true) and
        plarec >= vdti and
        plarec <= vdtf /*and
        numero = 113826 */
        no-lock.

        find first forne where forne.forcod = fiscal.emite no-lock no-error.
        if avail forne
        then aux-uf = forne.ufecod.
        else aux-uf = "RS".
        disp numero movtdc etbcod.
        pause 0. 
        if fiscal.movtdc = 4 
        then find plani where plani.etbcod = estab.etbcod 
                                 and plani.emite  = fiscal.emite   
                                 and plani.movtdc = 4  
                                 and plani.serie  = fiscal.serie   
                                 and plani.numero = fiscal.numero 
                                            no-lock no-error.
        else find first plani where plani.etbcod = estab.etbcod 
                                           and plani.emite  = fiscal.emite 
                                           and plani.movtdc = 12 
                                           and plani.serie  = fiscal.serie 
                                           and plani.numero = fiscal.numero 
                                            no-lock no-error.
        t-pis = 0.
        t-cofins = 0.
        if avail plani
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc
                              no-lock.
            find produ where produ.procod = movim.procod no-lock.                            val-pis = 0.
            val-cofins = 0.
            run p-piscofins(produ.codfis,"E",
                                    (movim.movpc * movim.movqtm)
                                    /*(base_icms - valicm)*/ ).
            t-pis = t-pis + val-pis.
            t-cofins = t-cofins + val-cofins.
            
            end.
            create tt-pla.
            assign tt-pla.numero = fiscal.numero
                   tt-pla.plarec = fiscal.plarec
                   tt-pla.emite  = fiscal.emite
                   tt-pla.desti  = fiscal.desti
                   tt-pla.platot = fiscal.platot
                   tt-pla.pis    = t-pis
                   tt-pla.cofins = t-cofins
                   tt-pla.cfop   = fiscal.opfcod.
        end.
    end.
end.
form with frame f down.

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/audit/arq" + string(vopfcod) + ".txt".
else varquivo = "l:~\audit~\arq" + string(vopfcod) + ".txt".
output to value(varquivo).
for each tt-pla.                             
            disp tt-pla.numero  column-label "Numero"
                 tt-pla.plarec  column-label "Entrada"
                 tt-pla.emite   column-label "Emite" format ">>>>>>>>9"
                 tt-pla.desti   column-label "Desti"
                 tt-pla.platot(total)  column-label "Total"   
                            format ">>>,>>>,>>9.99"
                 tt-pla.pis        (total)  column-label "Pis"
                            format ">>>,>>>,>>9.99"
                 tt-pla.cofins     (total)  column-label "Cofins"
                            format ">>>,>>>,>>9.99"
                 with frame f down width 120 no-box.
            down with frame f.     
                 
end.

output close.

procedure p-piscofins:
   def input parameter pcodfis as char.
   def input parameter ptp     as char.
   def input parameter pbase   as dec.

assign pcodfis = replace(pcodfis,".","")
       base-pis = pbase.
       
assign
    per-pis   = 0.
    per-cofins = 0.
if aux-uf = "AM"
then assign per-pis    = 1
            per-cofins = 4.6.     
else 
    if int(pcodfis) = 0
    then assign per-pis = 1.65
                per-cofins = 7.6.  
    else do:
         find clafis where clafis.codfis = int(pcodfis) no-lock no-error.
         if not avail clafis
         then assign val-pis = 0
                    per-pis = 0
                    val-cofins = 0
                    per-cofins = 0
                    base-pis = 0.
         else do:
              if ptp = "E"
              then assign per-pis    = clafis.pisent
                          per-cofins = clafis.cofinsent.
              else assign per-pis    = clafis.pissai
                          per-cofins = clafis.cofinssai.
        end.                 
     end.
assign val-pis    = base-pis * (per-pis / 100)
       val-cofins = base-pis * (per-cofins / 100).
if per-pis = 0
then vcodsit = "0404".
else if per-pis = 1
     then vcodsit = "0202".
     else vcodsit = "0101".

end procedure.
