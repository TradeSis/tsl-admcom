{admcab.i new}
def var t1 as dec decimals 4 format ">>,>>>,>>9.9999".
def var t2 as dec decimals 4 format ">>,>>>,>>9.9999".
def var t3 as dec decimals 4 format ">>,>>>,>>9.9999".
def var t4 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d1 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d2 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d3 as dec decimals 4 format ">>,>>>,>>9.9999".
def var d4 as dec decimals 4 format ">>,>>>,>>9.9999".
def var dcan as dec.

def var agt as dec.

def buffer cmapctb for mapctb.
def buffer emapctb for mapctb.

def NEW SHARED temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(20)"        label "Serial     "
    field datmov as date
    field datatu as date
    field datred as date 
    field gti as dec  format "->>,>>>,>>9.99"  label "GT Inicial "
    field gtf as dec  format "->>,>>>,>>9.99"  label "GT Final   "
    field t01 as dec  label "Reducao 17%"
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field t05 as dec
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    field red as char format "x"
    field cup as char format "x"
    .

def new shared temp-table tt-plani like plani.

def temp-table tt-redz
    field etbcod like estab.etbcod
    field equipa as int
    field datref as date
    index i1 etbcod datref
.    
def buffer bmapctb for mapctb.

def var vlinha as char.

def var dgt as dec.
def var d01 as dec.
def var d04 as dec.
def var dca as dec. 

def var vda1 as dec.
def var vda2 as dec.
def var tvda as dec.   

def var vgt as dec.
def var vgtf as dec.
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
def var vequip1 as int.

def temp-table tt-tabecf like tabecf.

def var vetbcod1 like estab.etbcod.

do on error undo:
update vetbcod  with frame f-dat side-label width 80.
if vetbcod > 0
then do:
find estab where estab.etbcod = vetbcod no-lock.
/*disp estab.etbnom no-label with frame f-dat.
*/
end.    
vetbcod1 = vetbcod.
update vetbcod1 label "Ate"  with frame f-dat side-label width 80.
if vetbcod1 > 0
then do:
/*find estab where estab.etbcod = vetbcod1 no-lock.
disp estab.etbnom no-label with frame f-dat.
*/
end. 
vdtf = ?. 
update vdti at 1 label "Periodo de"  with frame f-dat.
vdtf = vdti.
update vdtf      label "Ate" with frame f-dat. 
if vdtf = ?
then vdtf = vdti.

vequip1 = 0.
update vequip1 at 1 label "Equipamento" 
        with frame f-dat.
end.

def var vqc as int.

vgt = 0.
vgtf = 0. 

def var vmovpc like movim.movpc.
def var valor as dec.
def var vl-can as dec.
def var vl1-can as dec.
def var vqtd as int.

procedure valida-cupom:

for each estab no-lock:

    if vetbcod > 0 and
       estab.etbcod < vetbcod
    then next.
    if vetbcod1 > 0 and
       estab.etbcod > vetbcod1
    then next.
    
    disp estab.etbcod  with frame f2. pause 0.


    for each  tt-tabecf . delete tt-tabecf . end.

    if vequip1 = 0
    then do:
        for each tabecf where
             tabecf.etbcod = estab.etbcod no-lock:
        if (tabecf.datini <= vdti and
           tabecf.datfin >= vdtf) or
           (tabecf.datini >= vdti and
            tabecf.datini <= vdtf and
            tabecf.datfin > tabecf.datini)
        then do:   
            create tt-tabecf.
            buffer-copy tabecf to tt-tabecf.
        end.
    end.
    end.
    else do:
        find first tabecf where
               tabecf.etbcod = estab.etbcod and
               tabecf.equip = vequip1 and
               tabecf.datini <= vdti and
               tabecf.datfin >= vdtf
               no-lock no-error.
        if avail tabecf
        then do:
            create tt-tabecf.
            buffer-copy tabecf to tt-tabecf.
        end.
    end.                
    for each tt-tabecf where tt-tabecf.equipa > 0:
        vequip = tt-tabecf.equipa.
         
        disp vequip with frame f2 .
        pause 0.
        
        vgt = 0.
        vgtf = 0. 

        do vdata = vdti to vdtf:

            disp vdata with frame f2.
            pause 0.
            t1 = 0.
            t4 = 0.

            find last tabecf where tabecf.etbcod = estab.etbcod and
                       tabecf.equip  = vequip and
                       tabecf.datini <= vdata and
                       tabecf.datfin >= vdata
                       no-lock no-error.
    
            
            find first bmapctb where bmapctb.etbcod = estab.etbcod and
                       bmapctb.ch1    = tabecf.serie and 
                       bmapctb.datmov = vdata and
                       bmapctb.cxacod = vequip
                       no-error.

            if not avail bmapctb
            then do:

                run de-mapcxa-para-mapctb.

                find first bmapctb where bmapctb.etbcod = estab.etbcod and
                       bmapctb.ch1    = tabecf.serie and 
                       bmapctb.datmov = vdata and
                       bmapctb.cxacod = vequip
                       no-error.

                if not avail bmapctb
                then do:
                    find first bmapctb where 
                           bmapctb.etbcod = estab.etbcod and
                           bmapctb.datmov = vdata and
                           bmapctb.cxacod = vequip
                           no-lock no-error.
                    if avail bmapctb
                    then do:
                        run ver-mapctb.
                        find first bmapctb where 
                                bmapctb.etbcod = estab.etbcod and
                                bmapctb.ch1    = tabecf.serie and 
                                bmapctb.datmov = vdata and
                                bmapctb.cxacod = vequip
                                no-lock no-error.
                        if not avail bmapctb
                        then next.   
                    end.
                    else next.
                end.
            end.
            
            if bmapctb.ch1 = ""
            then find last mapctb use-index ind-2 
                        where mapctb.etbcod = bmapctb.etbcod and
                              mapctb.ch1    = bmapctb.ch1    and
                              mapctb.cxacod = bmapctb.cxacod and
                              /*mapctb.ch2 <> "E"             and*/ 
                              mapctb.datmov < bmapctb.datmov
                              
                                         no-error.
                                        
            else find last mapctb use-index ind-1 
                        where mapctb.ch1    = bmapctb.ch1 and 
                              /*mapctb.ch2 <> "E"          and*/    
                              mapctb.datmov < bmapctb.datmov 
                                      no-error.
        
            if avail mapctb  
            then vgt = mapctb.gtotal.  
            else vgt = bmapctb.gtotal - 
                   (bmapctb.t01 + bmapctb.t02 + bmapctb.t03 +
                        bmapctb.vlsub) -
                            bmapctb.vlcan +  
                            bmapctb.vlacr.

    
            if bmapctb.ch2 = "E"                 
            then next.               
    
            create tt-caixa.
            assign
                    tt-caixa.etbcod = estab.etbcod
                    tt-caixa.cxacod = tabecf.de1
                    tt-caixa.equip  = tabecf.equip
                    tt-caixa.serie  = tabecf.serie
                    tt-caixa.datmov = vdata
                    tt-caixa.gti    = vgt
                    tt-caixa.gtf    = bmapctb.gtotal
                    tt-caixa.t01    = bmapctb.t01
                    tt-caixa.t02    = bmapctb.t02
                    tt-caixa.t03    = bmapctb.t03
                    tt-caixa.t04    = bmapctb.t04
                    tt-caixa.t05    = bmapctb.t05
                    tt-caixa.tsub  = bmapctb.vlsub
                    tt-caixa.tcan  = bmapctb.vlcan
                    .
        end.
    end.
    
    do vdata = vdti to vdtf:
    
        t1 = 0. t2 = 0. t3 = 0. t4 = 0. 
        vl-can = 0.    
        for each plani where plani.movtdc = 5 and
                plani.etbcod = estab.etbcod and 
                plani.pladat = vdata and 
                (plani.serie = "V" or plani.serie = "V1") and
                plani.ufemi  <> ""
                no-lock.
            if vequip1 = 0
            then.
            else if vequip1 <> plani.cxacod
            then next.
        
            if substr(plani.notped,1,1) = "C"
            then.
            else next.

            disp plani.ufemi format "x(30)"
                  notsit desti format ">>>>>>>>>9" notped   pedcod 
                  plani.cxacod  . 
            pause 0.
        
            t1 = 0. t2 = 0. t3 = 0. t4 = 0.
            for each movim where movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod and
                    movim.movtdc = plani.movtdc and
                    movim.movdat = plani.pladat
                    no-lock.
                
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom matches "*RECARGA*"
                THEN NEXT.   

                vmovpc = movim.movpc.
                /*
                run aredonda-10-pl17.
                */
                if movalicms = 17
                then  t1 = t1 + round(vmovpc * movim.movqtm,2).
                if movalicms = 12
                then  t2 = t2 + round(vmovpc * movim.movqtm,2).
                if movalicms = 7
                then t3 = t3 + round(vmovpc * movim.movqtm,2).
                if movalicms = 0
                then  t4 = t4 + round(vmovpc * movim.movqtm,2).

            end.
            run grava.
        end.
            
        /*cancelamento*/
        
        vl-can = 0.
        t1 = 0. t2 = 0. t3 = 0. t4 = 0.
        for each plani where plani.movtdc = 45 and
                plani.etbcod = estab.etbcod and 
                plani.pladat = vdata and 
                (plani.serie = "V" or plani.serie = "V1") and
                plani.ufemi  <> ""                        
                no-lock.
            if vequip1 = 0
            then.
            else if vequip1 <> plani.cxacod
            then next.

            if substr(plani.notped,1,1) = "C"
            then.
            else next.

            disp plani.ufemi format "x(30)"
                    notsit plani.desti format ">>>>>>>>>9" notped   pedcod 
                    plani.cxacod  . 
            pause 0.
        
            vl-can = vl-can + plani.platot.
            
            run grava.
        
            vl-can = 0.
        end. 
        
        vl1-can = 0.

        t1 = 0. t2 = 0. t3 = 0. t4 = 0. 
        
        for each plani where plani.movtdc = 5 and
                plani.etbcod = estab.etbcod and 
                plani.pladat = vdata and 
                (plani.serie = "V" or plani.serie = "V1") 
                no-lock.
        
                if substr(plani.notped,1,1) = "C" and
                   plani.ufemi  <> ""
                then next.
                                              
                vqc = vqc + 1.

                disp plani.ufemi format "x(30)"
                    notsit plani.desti format ">>>>>>>>>9" notped   pedcod 
                    plani.cxacod  . 
                pause 0.
                d1 = 0. d2 = 0. d3 = 0. d4 = 0.
                for each movim where movim.etbcod = plani.etbcod and
                    movim.placod = plani.placod and
                    movim.movtdc = plani.movtdc and
                    movim.movdat = plani.pladat
                    no-lock.
        
                    find produ where produ.procod = movim.procod no-lock.
                    if produ.pronom matches "*RECARGA*"
                    THEN NEXT.   

                    vmovpc = movim.movpc.
                    /*
                    run aredonda-10-pl17.
                    */
                    if movalicms = 17
                    then  d1 = d1 + round(vmovpc * movim.movqtm,2).
                    if movalicms = 12
                    then  d2 = d2 + round(vmovpc * movim.movqtm,2).
                    if movalicms = 7
                    then d3 = d3 + round(vmovpc * movim.movqtm,2).
                    if movalicms = 0
                    then  d4 = d4 + round(vmovpc * movim.movqtm,2).
                

                    find first tt-plani where
                               tt-plani.etbcod = plani.etbcod and
                               tt-plani.placod = plani.placod
                                no-error.
                    if not avail tt-plani
                    then do:   
                        create tt-plani.
                        buffer-copy plani to tt-plani.
                        tt-plani.ufemi = "".
                    end.
                end.
                run grava-d.
        end.
            
        /*cancelamento*/
        vl-can = 0.
        for each plani where plani.movtdc = 45 and
                plani.etbcod = estab.etbcod and 
                plani.pladat = vdata and 
                (plani.serie = "V" or plani.serie = "V1") 
                no-lock.
        
        
                if substr(plani.notped,1,1) = "C" and
                    plani.ufemi  <> ""
                then next.
                
                vqc = vqc + 1.

                disp plani.ufemi format "x(30)"
                    plani.notsit plani.desti format ">>>>>>>>>9" 
                    plani.notped   plani.pedcod 
                    plani.cxacod  . 
                pause 0.
        
                dcan = dcan + plani.platot.
                                            
                create tt-plani.
                buffer-copy plani to tt-plani.
                
                run grava-d.
                
                dcan = 0.
            
        end. 
        
        vl1-can = 0.
        

    end.
end.            

hide frame f2 no-pause.

def var vtot-pla as dec.

for each tt-caixa:
    
    if tt-caixa.gti <= 0 or 
       tt-caixa.gtf <= 0 or
       tt-caixa.t01 <> tt-caixa.c01 or
       tt-caixa.t02 <> tt-caixa.c02 or
       tt-caixa.t03 <> tt-caixa.c03 or
       tt-caixa.t04 <> tt-caixa.c04 or 
       tt-caixa.t05 <> tt-caixa.c05 or 
       tt-caixa.tsub <> tt-caixa.csub /*or
       tt-caixa.tcan <> tt-caixa.ccan 
        */
    then do:
        tt-caixa.difer = yes.
        vtot-pla = 0.
        for each tt-plani where
            (tt-plani.movtdc = 5 or tt-plani.movtdc = 45) and
             tt-plani.etbcod = tt-caixa.etbcod and
             tt-plani.pladat = tt-caixa.datmov and
            (tt-plani.serie = "V" or tt-plani.serie = "V1") and
             tt-plani.cxacod = tt-caixa.equip and
             (tt-plani.notped = "" or tt-plani.ufemi  = "")
             .                                    

            if tt-plani.platot = (tt-caixa.t01 - tt-caixa.c01) or
               tt-plani.platot = (tt-caixa.tsub - tt-caixa.csub)
            then do:
                tt-plani.ufemi = tt-caixa.serie.       
                if tt-plani.notped = ""
                then tt-plani.notped = "C|||".   
                find plani where plani.etbcod = tt-plani.etbcod and
                                 plani.placod = tt-plani.placod and
                                 plani.movtdc = tt-plani.movtdc
                                 no-error.
                if avail plani
                then do on error undo:
                    plani.ufemi = tt-plani.ufemi.
                    plani.notped = tt-plani.notped.
                    tt-caixa.difer = no.
                end.                     
            end.
            vtot-pla = vtot-pla + tt-plani.platot.
        end.
        if tt-caixa.difer = yes
        then do:
            if vtot-pla = (tt-caixa.t01 - tt-caixa.c01) or
               vtot-pla = (tt-caixa.tsub - tt-caixa.csub) or
               vtot-pla = ((tt-caixa.t01 - tt-caixa.c01) +
                           (tt-caixa.tsub - tt-caixa.csub))
            then do:
                for each tt-plani where
                    (tt-plani.movtdc = 5 or tt-plani.movtdc = 45) and
                     tt-plani.etbcod = tt-caixa.etbcod and
                     tt-plani.pladat = tt-caixa.datmov and
                    (tt-plani.serie = "V" or tt-plani.serie = "V1") and
                     tt-plani.cxacod = tt-caixa.equip and
                    (tt-plani.notped = "" or tt-plani.ufemi  = "")
                    .      
                    tt-plani.ufemi = tt-caixa.serie.       
                    if tt-plani.notped = ""
                    then tt-plani.notped = "C|||".   
                    find first plani where plani.etbcod = tt-plani.etbcod and
                                 plani.placod = tt-plani.placod and
                                 plani.movtdc = tt-plani.movtdc
                                 no-error.
                    if avail plani
                    then do on error undo:
                        plani.ufemi = tt-plani.ufemi.
                        plani.notped = tt-plani.notped.
                        tt-caixa.difer = no.
                    end.                     
                end.
                vtot-pla = 0.
            end.
         end.
    end.
    if tt-caixa.t01 > 0 or
       tt-caixa.t02 > 0 or
       tt-caixa.t03 > 0 or
       tt-caixa.t04 > 0 or
       tt-caixa.t05 > 0 or
       tt-caixa.tsub > 0 or
       tt-caixa.tcan > 0
    then tt-caixa.red = "*".
       
    if tt-caixa.c01 > 0 or
       tt-caixa.c02 > 0 or
       tt-caixa.c03 > 0 or
       tt-caixa.c04 > 0 or 
       tt-caixa.c05 > 0 or 
       tt-caixa.csub > 0 or
       tt-caixa.ccan > 0 
    then tt-caixa.cup = "*".
       
 end.
end procedure.

procedure relatorio:

def var varquivo as char.
varquivo = "/admcom/relat/cupom-dif-redz." + string(time).

{mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""cupom-dif-redz""
            &Nom-Sis   = """SISTEMA FISCAL/CONTABIL""" 
            &Tit-Rel   = """DIVERGENCIAS CUPONS X REDUCAO""" 
            &Width     = "160"
            &Form      = "frame f-cabcab"}

 
DISP WITH FRAME F-DAT.

for each tt-caixa where difer = yes no-lock.

    disp tt-caixa.etbcod column-label "Fil"
         tt-caixa.equip  column-label "Eqi"
         tt-caixa.cxacod column-label "Cxa"
         tt-caixa.datmov column-label "Data"
         tt-caixa.gti    column-label "GTI" 
         format ">>,>>>,>>9.99"
         tt-caixa.gtf    column-label "GTF"
         format ">>,>>>,>>9.99"
         tt-caixa.gtf - tt-caixa.gti  column-label "DifGT" 
         format "->>>,>>9.99"
         tt-caixa.t01                 column-label "17%R"  
         format ">>,>>9.99"
         tt-caixa.c01                 column-label "17%C"  
         format ">>,>>9.99"
         tt-caixa.c01 - tt-caixa.t01  column-label "Dif17%"
         format "->>,>>9.99"
         /*tt-caixa.t02                 column-label "07%R"  
         format ">>,>>9.99"
         tt-caixa.c02                 column-label "07%C"  
         format ">>,>>9.99"
         tt-caixa.c02 - tt-caixa.t02  column-label "Dif)&%"
         format "->>,>>9.99"
         tt-caixa.t03                 column-label "12%R"  
         format ">>,>>9.99"
         tt-caixa.c03                 column-label "12%C"  
         format ">>,>>9.99"
         tt-caixa.c03 - tt-caixa.t03  column-label "Dif12%"
         format "->>,>>9.99"*/
         /*tt-caixa.t04 
         tt-caixa.c04
         tt-caixa.c04 - tt-caixa.t04 
         tt-caixa.t05 
         tt-caixa.c05 
         tt-caixa.c05 - tt-caixa.t05*/
         tt-caixa.tsub                 column-label "STR"
         format ">>,>>9.99"
         tt-caixa.csub                 column-label "STC"
         format ">>,>>9.99"
         tt-caixa.csub - tt-caixa.tsub column-label "DifST"
         format "->>,>>9.99"
         tt-caixa.tcan                 column-label "CanR"
         format ">>,>>9.99"
         tt-caixa.ccan                 column-label "CanC"
         format ">>,>>9.99"
         tt-caixa.ccan - tt-caixa.tcan column-label "DifCan"
         format "->>,>>9.99"
         with frame f-disp width 200 down
         .
                                            
end.
output close.

run visurel.p(varquivo,"").

end procedure.

{setbrw.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  CONSULTAR","  ATUALIZAR","  RECUPERAR",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","RELATORIO","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var vcup as char format "x".
def var vred as char format "x".

form tt-caixa.etbcod label "Fil"
     tt-caixa.datmov
     tt-caixa.equip  label "Eq"
     tt-caixa.serie 
     tt-caixa.t01    label "17%"
     tt-caixa.tsub   label "ST"
     tt-caixa.tcan   label "CAN" 
     tt-caixa.red    label "Z"
     tt-caixa.cup    label "C"
     with frame f-linha 11 down width 80
     row 5 overlay
      .
 
def var vreg as int.

for each tt-caixa: delete tt-caixa. end.
    
run valida-cupom.

run busca-filial.
    
procedure aredonda-10-pl17:
    def var vare as log.
    vare = no.
    if movim.etbcod = 6 
    then vare = yes.
    else if movim.etbcod = 52
    then vare = yes.
    else if movim.etbcod >= 66 and
            movim.etbcod <= 112 and
            movim.etbcod <> 110 and
            movim.etbcod <> 99 and
            movim.etbcod <> 93
    then vare = yes.
    else vare = no.        

    if vare then do: 
        if movim.movdat >= 01/01/2012
        then do:
            find finesp where finesp.fincod = plani.pedcod no-lock no-error.
            if avail finesp
            then do:
                if finesp.finarr > 0
                then  vmovpc = vmovpc - ( vmovpc * (finesp.finarr / 100)).
            end.
        end.
    end.
end.

procedure grava:
    find first tt-caixa where
                   tt-caixa.etbcod = plani.etbcod and
                   tt-caixa.datmov = plani.pladat and
                   tt-caixa.serie = plani.ufemi
                   no-error.
        if not avail tt-caixa
        then do:
            
            create tt-caixa.

            assign
                    tt-caixa.etbcod = plani.etbcod
                    tt-caixa.cxacod = plani.cxacod
                    tt-caixa.equip  = plani.cxacod
                    tt-caixa.serie  = plani.ufemi
                    tt-caixa.datmov = plani.pladat
                    .
        end.
                  
        assign
            tt-caixa.c01 = tt-caixa.c01 + t1
            tt-caixa.c02 = tt-caixa.c02 + t2
            tt-caixa.c03 = tt-caixa.c03 + t3
            tt-caixa.csub = tt-caixa.csub + t4
            tt-caixa.ccan = tt-caixa.ccan + vl-can
            tt-caixa.d01 = tt-caixa.d01 + d1
            tt-caixa.d02 = tt-caixa.d02 + d2
            tt-caixa.d03 = tt-caixa.d03 + d3
            tt-caixa.dsub = tt-caixa.dsub + d4
            tt-caixa.dcan = tt-caixa.dcan + dcan
 
            .
end procedure.

procedure grava-d:
    find first tt-caixa where
                   tt-caixa.etbcod = plani.etbcod and
                   tt-caixa.datmov = plani.pladat and
                   tt-caixa.equip = plani.cxacod
                   no-error.
        if avail tt-caixa
        then do:
            
            assign
            tt-caixa.d01 = tt-caixa.d01 + d1
            tt-caixa.d02 = tt-caixa.d02 + d2
            tt-caixa.d03 = tt-caixa.d03 + d3
            tt-caixa.dsub = tt-caixa.dsub + d4
            tt-caixa.dcan = tt-caixa.dcan + dcan
 
            .
    end.            
end procedure.



procedure ver-mapctb:
    if bmapctb.ch1 = ""
    then do:
        find last emapctb where emapctb.etbcod = estab.etbcod and
                       emapctb.ch1    = tabecf.serie and 
                       emapctb.cxacod = vequip and
                       emapctb.datmov < vdata 
                       no-lock no-error.
        if avail emapctb and
                 emapctb.ch1 <> ""
        then bmapctb.ch1 = emapctb.ch1.
    end.
end procedure.

procedure de-mapcxa-para-mapctb:
    find first mapcxa where mapcxa.Etbcod = estab.etbcod
           and mapcxa.cxacod = vequip 
           and mapcxa.datmov = vdata no-lock no-error.
    if avail mapcxa
    then do: 
        create mapctb.
        buffer-copy mapcxa to mapctb.
    end.    
end procedure. 

procedure busca-filial:
    def var vip as char.
    def var vstatus as char.
    for each estab where estab.etbcod < 189 no-lock:

        find first tt-caixa where
               tt-caixa.etbcod = estab.etbcod and
               tt-caixa.equip > 0 and
               tt-caixa.difer = yes
               no-error.
        if avail tt-caixa
        then do:
               
            vip = "filial" + string(estab.etbcod,"999").

            if connected ("admloja")
                    then disconnect admloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect adm -H value(vip) -S sadm -N tcp -ld admloja
                no-error.
    
            if not connected ("admloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                next.    
            end.
            
            vetbcod = int(substr(string(vip),7,3)).
        
            for each tt-caixa where tt-caixa.etbcod = estab.etbcod and
                                tt-caixa.difer  = yes no-lock:
            
                run busca-rdz-filial.p 
                    (tt-caixa.etbcod, tt-caixa.datmov, 
                     tt-caixa.cxacod, output vstatus ). 
            
        
            end.
            
            if connected ("admloja")
            then disconnect admloja.
            /*
            for each tt-caixa where tt-caixa.etbcod = estab.etbcod and
                                tt-caixa.difer  = yes:
                run mapcxa-mapctb.
            end.
            */
        end.
    end.
end procedure.
