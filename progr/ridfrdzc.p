{admcab.i}

def var vetbcod like estab.etbcod.
def var vdata as date format "99/99/9999".
def var vcxacod as int format ">9".
def var t17 as dec.
def var t07 as dec.
def var t12 as dec.
def var t25 as dec.
def var t00 as dec.
def var it17 as dec format ">>,>>9.99".
def var it07 as dec format ">>,>>9.99".
def var it12 as dec format ">>,>>9.99".
def var it25 as dec format ">>,>>9.99".
def var it00 as dec format ">>,>>9.99".
def var i17 as dec.
def var i07 as dec.
def var i12 as dec.
def var i25 as dec.
def var i00 as dec.
def var ti17 as dec format ">>,>>9.99".
def var ti07 as dec format ">>,>>9.99".
def var ti12 as dec format ">>,>>9.99".
def var ti25 as dec format ">>,>>9.99".
def var ti00 as dec format ">>,>>9.99".
def var di17 as dec format ">>,>>9.99".
def var di07 as dec format ">>,>>9.99".
def var di12 as dec format ">>,>>9.99".
def var di25 as dec format ">>,>>9.99".
def var di00 as dec format ">>,>>9.99".

  
def temp-table tt-item
    field etbcod like estab.etbcod
    field placod like plani.placod
    field movtdc like plani.movtdc
    field movdat like movim.movdat
    field numero like plani.numero
    field procod like produ.procod
    field valorb as dec format ">>,>>9.99"
    field valori as dec format ">>,>>9.99"
    field alicms as dec format ">>9.99"
    index i1 etbcod placod movtdc movdat procod
    .

vetbcod = estab.etbcod.

form   vetbcod at 5  label "Filial"
       estab.etbnom  no-label
       vdata    at 1 label "Data Red Z"
       vcxacod label "Equipamento"
       with frame f1 side-label 1 down width 80.

update vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock no-error.
if not avail estab then undo.
disp estab.etbnom with frame f1.

update vdata with frame f1.
if vdata = ? or vdata < today - 45
then undo.

update vcxacod with frame f1.

find first mapctb where mapctb.etbcod = vetbcod and
                        mapctb.cxacod = vcxacod and
                        mapctb.datmov = vdata
                        no-lock no-error.
if not avail mapctb
then do:
    bell.
    message "Reducção Z não encontrada."
    view-as alert-box.
    undo.
end.
for each plani where plani.etbcod = vetbcod and
                     plani.movtdc = 5 and
                     plani.pladat = vdata and
                     plani.cxacod = vcxacod and
                     plani.notped <> ""   and
                     plani.ufemi <> ""
                     no-lock.

    if entry(1,plani.notped,"|") <> "C"
    then next.
    if plani.ufemi <> mapctb.ch1
    then next.
                         
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
        if movim.movalicms = 0
        then assign 
                t00 = t00 + (movim.movpc * movim.movqtm).
        else if movim.movalicms = 17
        then assign
                i17 = i17 + ((movim.movpc * movim.movqtm) * .17)
                t17 = t17 + (movim.movpc * movim.movqtm).
        else if movim.movalicms = 07
        then assign
                i07 = i07 + ((movim.movpc * movim.movqtm) * .07)
                t07 = t07 + (movim.movpc * movim.movqtm).
        else if movim.movalicms = 12
        then assign
                i12 = i12 + ((movim.movpc * movim.movqtm) * .12)
                t12 = t12 + (movim.movpc * movim.movqtm).
        else if movim.movalicms = 25
        then assign
                t25 = t25 + (movim.movpc * movim.movqtm)
                i25 = i25 + ((movim.movpc * movim.movqtm) * .25).

        create tt-item.
        assign
            tt-item.etbcod = movim.etbcod
            tt-item.placod = movim.placod
            tt-item.movtdc = movim.movtdc
            tt-item.movdat = movim.movdat 
            tt-item.numero = plani.numero
            tt-item.procod = movim.procod
            tt-item.alicms = movim.movalicms
            tt-item.valorb = round ((movim.movpc * movim.movqtm),2)
            .
        if movim.movicms > 0
        then tt-item.valori = movim.movicms.
        else tt-item.valori = round (((movim.movpc * movim.movqtm) *
                             (movim.movalicms / 100)),2)
             .                
     end.
end.                         
                     
assign
    di17 = 0 di07 = 0 di12 = 0 di25 = 0 di00 = 0
    ti17 = 0 ti07 = 0 ti12 = 0 ti25 = 0 ti00 = 0
    it17 = 0 it07 = 0 it12 = 0 it25 = 0 it00 = 0            
    .
for each tt-item:
        if tt-item.alicms = 0
        then assign
                ti00 = ti00 + trunc(tt-item.valori,2) 
                it00 = it00 + trunc(tt-item.valorb,2).
        else if tt-item.alicms = 17
        then assign
                ti17 = ti17 + trunc(tt-item.valori,2)
                it17 = it17 + trunc(tt-item.valorb,2).
        else if tt-item.alicms = 07
        then assign
                ti07 = ti07 + trunc(tt-item.valori,2)
                it07 = it07 + trunc(tt-item.valorb,2).
        else if tt-item.alicms = 12
        then assign
                ti12 = ti12 + trunc(tt-item.valori,2)
                it12 = it12 + trunc(tt-item.valorb,2).
        else if tt-item.alicms = 25
        then assign
                ti25 = ti25 + trunc(tt-item.valori,2)
                it25 = it25 + trunc(tt-item.valorb,2).
end.

assign
    di17 = (mapctb.t01 * .17) - ti17
    di07 = (mapctb.t02 * .07) - ti07
    di12 = (mapctb.t03 * .12) - ti12
    di25 = (mapctb.t04 * .25) - ti25
    .

repeat:
disp "                           ECF      CUPOM      AUDIT         DIF  "
     "----------------- ------------ ---------- ---------- -----------  "
     skip
     "Base 17%           "
     mapctb.t01       no-label  format ">>>,>>9.99"
     t17              no-label  format ">>>,>>9.99"
     it17             no-label  format ">>>,>>9.99"
     skip
     "ICMS 17%           "
     mapctb.t01 * .17 no-label  format ">>>,>>9.99"
     i17              no-label  format ">>>,>>9.99"
     ti17             no-label  format ">>>,>>9.99"
     di17 when di17 <> 0 no-label format "->>>,>>9.99" 
     skip
     "Base 07%           "
     mapctb.t02       no-label format ">>>,>>9.99"
     t07              no-label format ">>>,>>9.99"
     it07             no-label format ">>>,>>9.99"
     skip
     "ICMS 07%           "
     mapctb.t02 * .07 no-label format ">>>,>>9.99"
     i07              no-label format ">>>,>>9.99"
     ti07             no-label format ">>>,>>9.99"
     di07 when di07 <> 0 no-label format "->>>,>>9.99"
     skip
     "Base 12%           "
     mapctb.t03       no-label format ">>>,>>9.99"
     t12              no-label format ">>>,>>9.99"
     it12             no-label format ">>>,>>9.99"
     skip
     "ICMS 12%           "
     mapctb.t03 * .12 no-label format ">>>,>>9.99"
     i12              no-label format ">>>,>>9.99"
     ti12             no-label format ">>>,>>9.99"
     di12 when di12 <> 0 no-label format "->>>,>>9.99"
     skip
     "Base 25%           "
     mapctb.t04       no-label format ">>>,>>9.99"
     t25              no-label format ">>>,>>9.99"
     it25             no-label format ">>>,>>9.99"
     skip
     "ICMS 25%           "
     mapctb.t04 * .25 no-label format ">>>,>>9.99"
     i25              no-label format ">>>,>>9.99"
     ti25             no-label format ">>>,>>9.99"
     di25 when di25 <> 0 no-label format "->>>,>>9.99"
     skip
     "Base ST            "
     mapctb.vlsub    no-label format ">>>,>>9.99"
     t00             no-label format ">>>,>>9.99"
     it00            no-label format ">>>,>>9.99"
     with frame f2 row 8
     /*title "  Filial " + string(estab.etbcod,">>9") +  
                       " Data " + 
                       string(vdata,"99/99/9999") + 
                       " Equipamento " + string(vcxacod) + "  "
     */
     .       

if di17 <> 0
then do:
    sresp = no.
    message "Ajustar diferença ? " update sresp.
    if sresp 
    then do:
        for each tt-item by tt-item.valorb descending:
            tt-item.valori = tt-item.valori + .01.
            di17 = di17 - .01.
            if di17 < .05
            then leave.
            find first movim where movim.etbcod = tt-item.etbcod and
                                   movim.placod = tt-item.placod and
                                   movim.movtdc = tt-item.movtdc and
                                   movim.movdat = tt-item.movdat and
                                   movim.procod = tt-item.procod
                                   no-error.
            if avail movim
            then movim.movicms = tt-item.valori.                       
        end.
    end.
    else do:
        
        leave.
    end.
end.    
end.    

