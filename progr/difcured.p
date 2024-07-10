def var t1 as dec.
def var t2 as dec.
def var t3 as dec.
def var t4 as dec.

def temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(25)"
    field datmov as date
    field datatu as date
    field datred as date 
    field t01 as dec
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field ti01 as dec
    field ti02 as dec
    field ti03 as dec
    field ti04 as dec
    field di01 as dec
    field di02 as dec
    field di03 as dec
    field di04 as dec
    field fi01 as dec
    field fi02 as dec
    field fi03 as dec
    field fi04 as dec
    .

def temp-table tt-redz
    field etbcod like estab.etbcod
    field equipa as int
    field datref as date
    index i1 etbcod datref
        .
def var vlinha as char.
        
def var totecf as dec.

def var vetbcod like estab.etbcod.
def var vdata as date .
vdata = today - 1.
def var vdti as date.
def var vdtf as date.
def var vequip as int.

def var vdif1 as dec.
def var vdif2 as dec.
def var vdif3 as dec.
def var vdif4 as dec.


def temp-table tt-plani like plani.

update vetbcod  with frame f-dat side-label width 80.
if vetbcod > 0
then do:
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f-dat.
end.    
update vdti at 1 label "Periodo de"
       vdtf      label "Ate" with frame f-dat. 

update vequip at 1 label "Equipamento" 
        with frame f-dat.

def var vqc as int.
do vdata = vdti to vdtf:

for each estab where
        if vetbcod > 0
        then estab.etbcod = vetbcod else true no-lock:

disp vdata estab.etbcod with frame f2. pause 0.

for each tt-caixa:
delete tt-caixa.
end.

for each mapctb where mapctb.etbcod = estab.etbcod and
                      mapctb.datmov = vdata and
                      (if vequip > 0
                       then mapctb.cxacod = vequip
                       else true)  no-lock.

    if mapctb.ch2 = "E"                 
                then next.               

    find first tt-caixa where
               tt-caixa.etbcod = mapctb.etbcod and
               /*tt-caixa.cxacod = mapctb.cxacod and
               tt-caixa.equip  = mapctb.de1 and  */
               tt-caixa.serie  = mapctb.ch1
               no-error.
    if not avail tt-caixa   
    then do:
        create tt-caixa.
        assign
            tt-caixa.etbcod = mapctb.etbcod
            tt-caixa.cxacod = mapctb.cxacod 
            tt-caixa.equip  = mapctb.de1 
            tt-caixa.serie  = mapctb.ch1
            tt-caixa.datmov = mapctb.datmov
            tt-caixa.datatu = mapctb.datatu
            tt-caixa.datred = mapctb.datred
            .
    end.
    assign
        tt-caixa.t01 = mapctb.t01
        tt-caixa.t02 = mapctb.t02
        tt-caixa.t03 = mapctb.t03
        tt-caixa.t04 = mapctb.vlsub
        .        

    /*
    if length(trim(mapctb.ch1)) >= 20
    then do:
        for each plani where plani.movtdc = 5 and
            plani.etbcod = mapctb.etbcod and 
            plani.pladat = mapctb.datmov and 
            serie = "V" and
            plani.ufemi = substr(mapctb.ch1,1,15)
            :
            message mapctb.ch1 plani.ufemi. pause 0.
            plani.ufemi = mapctb.ch1.   
        end.    
    end.
    */
    
    for each plani where plani.movtdc = 5 and
            plani.etbcod = mapctb.etbcod and 
            plani.pladat = mapctb.datmov and 
            serie = "V" and
            /*plani.ufemi = mapctb.ch1*/ 
            plani.cxacod = mapctb.de1
             by numero.
        
        
        if substr(plani.notped,1,1) = "C"
        then.
        else next.
        
        vqc = vqc + 1.

        disp plani.ufemi format "x(30)"
            notsit desti format ">>>>>>>>>9" notped   pedcod 
                cxacod  . 
        pause 0.
        
        for each movim where movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod and
                    movim.movtdc = plani.movtdc and
                    movim.movdat = plani.pladat
                    no-lock.
        
            find produ where produ.procod = movim.procod no-lock.
            if produ.pronom matches "RECARGA"
            THEN NEXT.   

            if movalicms = 17
            then 
                /*if t01 >= t1 + (movim.movpc * movim.movqtm)
                then*/  t1 = t1 + (movim.movpc * movim.movqtm).
            if movalicms = 12
            then /*if t02 >= t2 + (movim.movpc * movim.movqtm)
                then*/ t2 = t2 + (movim.movpc * movim.movqtm).
            if movalicms = 7
            then /*if t03 >= t3 + (movim.movpc * movim.movqtm)
                then*/ t3 = t3 + (movim.movpc * movim.movqtm).
            if movalicms = 0
            then /*if vlsub >= t4 + (movim.movpc * movim.movqtm)
                then*/ t4 = t4 + (movim.movpc * movim.movqtm).
        end.
        if plani.ufemi = "" and
            plani.ufemi <> mapctb.ch1
        then do:
            /*message "Ufemi " plani.ufemi 
                    " Mapctb   " mapctb.ch1
                    " Total  " plani.platot.
            pause.
            if plani.ufemi = ""
            then*/ 
            plani.ufemi = mapctb.ch1. 
        end.
    end.
    assign
        tt-caixa.ti01 = t1
        tt-caixa.ti02 = t2
        tt-caixa.ti03 = t3
        tt-caixa.ti04 = t4
        tt-caixa.di01 = mapctb.t01 - t1
        tt-caixa.di02 = mapctb.t02 - t2
        tt-caixa.di03 = mapctb.t03 - t3
        tt-caixa.di04 = mapctb.vlsub - t4
        .

    assign
        vdif1 = t01 - t1
        vdif2 = t02 - t2
        vdif3 = t03 - t3
        vdif4 = vlsub - t4 .
    if vdif1 <> 0 or
       vdif2 <> 0 or
       vdif3 <> 0 or
       vdif4 <> 0 
    then do:    
        disp t01 at 1 t1 t01 - t1 
         t02 at 1 t2 t02 - t2
         t03 at 1 t3 t03 - t3
         vlsub at 1 t4 vlsub - t4 .
        pause 0.
        run proc-difer.
    end.
    t1 = 0. t2 = 0. t3 = 0. t4 = 0.

    
end.
end.
end.    
                                           
procedure proc-difer:
    def var d1 as dec.
    def var d2 as dec.
    def var d3 as dec.
    def var d4 as dec.
    def var td1 as dec.
    def var td2 as dec.
    def var td3 as dec.
    def var td4 as dec.
 
     for each plani where plani.movtdc = 5 and
            plani.etbcod = mapctb.etbcod and 
            plani.pladat = mapctb.datmov and 
            serie = "V" and
            /*plani.ufemi = mapctb.ch1*/ 
            plani.cxacod = mapctb.de1
              .
        
        if plani.notped = "C"
        then next.
        
        for each movim where movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod and
                    movim.movtdc = plani.movtdc and
                    movim.movdat = plani.pladat
                    no-lock.
        
            find produ where produ.procod = movim.procod no-lock.
            if produ.pronom matches "RECARGA"
            THEN NEXT.   
            if movalicms = 17
            then  d1 = d1 + (movim.movpc * movim.movqtm).
            if movalicms = 12
            then  d2 = d2 + (movim.movpc * movim.movqtm).
            if movalicms = 7
            then  d3 = d3 + (movim.movpc * movim.movqtm).
            if movalicms = 0
            then  d4 = d4 + (movim.movpc * movim.movqtm).
        end.
        td1 = td1 + d1.
        td2 = td2 + d2.
        td3 = td3 + d3.
        td4 = td4 + d4.
        /*disp d1 d2 d3 d4. pause.
          */

        if vdif1 > 0 and
            d1 = vdif1
        then do:
            
            plani.notped = "C".
            
            message d1 vdif1 plani.notped.
            pause 0.
        end.
        if vdif2 > 0 and
           d2 = vdif2
        then do:
            
            plani.notped = "C".
            
            message d2 vdif2 plani.notped.
            pause 0.
        end.
        if vdif3 > 0 and
           d3 = vdif3
        then do:
            
            plani.notped = "C".
            
            message d3 vdif3 plani.notped.
            pause 0.
        end.
        if vdif4 > 0 and
           d4 = vdif4
        then do:
            
            plani.notped = "C".
            
            message d4 vdif4 plani.notped.
            pause 0.
        end.
            
    d1 = 0.
    d2 = 0.
    d3 = 0.
    d4 = 0.    
    end.
end procedure.
