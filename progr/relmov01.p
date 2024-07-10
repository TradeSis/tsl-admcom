{admcab.i}
def buffer aestoq for estoq.
def buffer bestoq for estoq.

def temp-table tt-estab
       field etbcod as int.

def temp-table tt-produ
       field procod   like produ.procod
       field etbcod   like estab.etbcod  
       field estloja  like estoq.estatual   label "Estoq"
       field qtdvenda like movim.movqtm     label "Qtd.Venda"
       field qtdmov   like movim.movqtm     label "Qtd.Mov"
       field qtdtrans like movim.movqtm     label "Qtd.Trans.Lj"
       field qtdvenlj like movim.movqtm     label "Qtd.Venda.Lj".

def var varquivo    as char.       
def var vetbi       like estab.etbcod.
def var vetbf       like estab.etbcod.
def var datasai     like plani.pladat.
def var vdt         like plani.pladat.
def var vnumero     as char format "x(07)".
def var vmovqtm     like movim.movqtm.
def var vmes as     int format "99".
def var vano as     int format "9999".
def var t-sai       like plani.platot.
def var t-ent       like plani.platot.
def var vdata       like plani.pladat.
def var vetbcod     like estab.etbcod.
def var vprocod     like produ.procod.
def var vtotdia     like plani.platot.
def var vtot        like movim.movpc.
def var vtotg       like movim.movpc.
def var vtotgeral   like plani.platot.
def var vdata1      like plani.pladat label "Data".
def var vdata2      like plani.pladat label "Data".
def var vtotal      like plani.platot.
def var vtoticm     like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom    like tipmov.movtnom.
def var vsalant     like estoq.estatual.
def var sal-ant     like estoq.estatual.
def var sal-atu     like estoq.estatual.
def var vdesti      like movim.desti.

def var aestatual   like estoq.estatual.
def var bestatual   like estoq.estatual.
def var vestatual   like estoq.estatual.

def var vqtdvendida     like movim.movqtm.
def var vmovimentada    like movim.movqtm.
def var vtransferida    like movim.movqtm.
def var vvendaloja      like movim.movqtm.

def var vtotestatual as dec.
def var vtotqtdmov   as dec.
def var vtotqtdtrans as dec.
def var vtotqtdvenlj    as dec.

def buffer bestab   for estab.

form datasai format "99/99/9999" column-label "Data Saida"
    vmovtnom column-label "Operacao" format "x(12)"
    vnumero 
    plani.serie column-label "SE" format "x(02)"
    movim.emite column-label "Emitente" format ">>>>>>"
    vdesti column-label "Desti" format ">>>>>>>>>>"
    vmovqtm format "->>>>9" column-label "Quant"
    movim.movpc format ">,>>9.99" column-label "Valor"
    sal-atu format "->>>>9" column-label "Saldo" 
                         with frame f-val 10 down overlay
                                 ROW 9 CENTERED color white/gray
                                 width 80.
                     
form sal-ant label "Saldo Anterior" format "->>>>9"
     t-ent   label "Ent" format ">>>>9"
     t-sai   label "Sai" format ">>>>9"
     estoq.estatual label "Saldo Atual" format "->>>>9"
                    with frame f-sal centered row 22 side-label no-box
                                        color white/red overlay.
vtotmovim = 0.
vtotgeral = 0.
sal-atu = 0.
sal-ant = 0.
vsalant = 0.
 

 
clear frame f-val all.
update vetbi label "Filial" to 30 "ate" vetbf no-label 
with frame f-pro.
update vdata1 label "Periodo" colon 25  vdata2 no-label 
with frame f-pro side-label width 80.

for each tt-estab: delete tt-estab. end.
   
for each estab no-lock.

    if estab.etbcod < vetbi or
        estab.etbcod > vetbf
    then next.
        
    create tt-estab.
    assign tt-estab.etbcod = estab.etbcod.             
end.
   
vdt = vdata1.

def var x as int.
for each tt-estab.


    do vdata = vdata1  to vdata2: 

        disp tt-estab.etbcod label "Filial"
             vdata no-label 
             with frame ftit side-labels centered. 
             pause 0.
             
        for each movim where /*movim.procod = 416776 and*/
                             movim.emite  = tt-estab.etbcod  and
                             movim.datexp = vdata no-lock 
                             break by movim.procod by movim.etbcod.
                             

            
            
            if first-of(movim.procod)
            then do:
                vvendaloja = 0.
            
            end.


            if movim.movtdc = 22 or movim.movtdc = 30
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if not avail plani then next.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next. 
                
                vnumero = string(plani.numero,"9999999").
                
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 5  or
               movim.movtdc = 3  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then. 
            else next.
            
            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 12
            then vdesti = movim.ocnum[7].
            else vdesti = movim.desti.  
            
            if movim.movtdc = 5 and plani.serie = "v"
            then do:
                vvendaloja = vvendaloja + movim.movqtm.
            end.
            

            find first tt-produ where tt-produ.procod = movim.procod and
                                      tt-produ.etbcod = tt-estab.etbcod  
                                      no-error. 
            
            if not avail tt-produ
            then do:
                create  tt-produ.
                assign  tt-produ.procod   = movim.procod
                        tt-produ.etbcod   = tt-estab.etbcod.
            end.
            assign tt-produ.qtdmov = tt-produ.qtdmov   + movim.movqtm.
                    
            if movim.movtdc = 5 
            then tt-produ.qtdvenlj =  tt-produ.qtdvenlj + movim.movqtm.


            /***
            display datasai format "99/99/9999" column-label "Data Saida"
                    VMOVTNOM column-label "Operacao" format "x(13)"
                    vnumero column-label "Numero" 
                    plani.serie when avail plani 
                             column-label "SE" format "x(02)"
                    movim.emite column-label "Emitente" format ">>>>>>"
                    vdesti column-label "Desti" format ">>>>>>>>>>"
                    vmovqtm format "->>>>9" column-label "Quant"
                    movim.movpc format ">,>>9.99" column-label "Valor"
                    sal-atu format "->>>>9" column-label "Saldo" 
                           with frame f-val 10 down overlay
                                 ROW 8 CENTERED color white/gray
                                 width 80.
            color display red/gray vmovqtm with frame f-val. 
            down with frame f-val.
            ***/
        end.

        for each movim where /*movim.procod = 416776 and*/
                             movim.desti  = tt-estab.etbcod  and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            if movim.movtdc = 22 or movim.movtdc = 30
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if not avail plani then next.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next.
                
                vnumero = string(plani.numero,"9999999").
                
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 07 or
               movim.movtdc = 08 or
               movim.movtdc = 09 
            then next.
            

            vmovqtm = movim.movqtm.
            
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
             datasai = movim.datexp.
            
            if movim.movtdc = 12
            then vdesti = movim.ocnum[7].
            else vdesti = movim.desti.

            if vdesti = tt-estab.etbcod
            then do:
                vtransferida = vtransferida + vmovqtm.
            end.
            find first tt-produ where tt-produ.procod = movim.procod and
                                      tt-produ.etbcod = tt-estab.etbcod
                                      no-error.                        
            if not avail tt-produ
            then do:
                create  tt-produ.
                assign  tt-produ.procod     = movim.procod
                        tt-produ.etbcod     = tt-estab.etbcod.
            end.
            assign 
                    tt-produ.qtdmov     = tt-produ.qtdmov + movqtm
                    tt-produ.qtdtrans   = tt-produ.qtdtrans + vmovqtm.
            
            /***
            display datasai format "99/99/9999" column-label "Data Saida"
                    VMOVTNOM column-label "Operacao" format "x(13)"
                    vnumero  column-label "Numero"
                    plani.serie when avail plani
                          column-label "SE" format "x(02)"
                    movim.emite column-label "Emitente" format ">>>>>>"
                    vdesti column-label "Desti" format ">>>>>>>>>>"
                    vmovqtm format "->>>>9" column-label "Quant"
                    movim.movpc format ">,>>9.99" column-label "Valor"
                    sal-atu format "->>>>9" column-label "Saldo" 
                           with frame f-val 10 down overlay
                                 ROW 8 CENTERED color white/gray.
            color display red/gray vmovqtm with frame f-val. 
            down with frame f-val. 
            ***/
        end. 
        
        for each movim where /*movim.procod = 416776 and*/
                             movim.desti  = tt-estab.etbcod and
                             movim.movdat = vdata no-lock:

            if movim.movtdc = 22 or movim.movtdc = 30
            then next.

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if not avail plani then next.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next.
                vnumero = string(plani.numero,"9999999").
                
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 7  or 
               movim.movtdc = 8 
            then.
            else next.
            

            
            find tipmov of movim no-lock.
            
            if movim.movtdc = 8  
            then sal-atu = sal-atu - movim.movqtm.
            if movim.movtdc = 7  
            then sal-atu = sal-atu + movim.movqtm.

            
             
            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
             datasai = movim.movdat.
 
            if movim.movtdc = 12
            then vdesti = movim.ocnum[7].
            else vdesti = movim.desti.

            
            
            find first tt-produ where tt-produ.procod = movim.procod and
                                      tt-produ.etbcod = tt-estab.etbcod
                                      no-error.                        
            if not avail tt-produ
            then do:
                create  tt-produ.
                assign  tt-produ.procod     = movim.procod
                        tt-produ.etbcod     = tt-estab.etbcod.
            end.
            assign 
                    tt-produ.qtdmov     = tt-produ.qtdmov   + vmovimentada
                    tt-produ.qtdtrans   = tt-produ.qtdtrans + vtransferida.
 
            
            /***
            display datasai 
                    format "99/99/9999" column-label "Data Saida"
                    VMOVTNOM column-label "Operacao" format "x(13)"
                    vnumero  column-label "Numero" 
                    plani.serie when avail plani
                          column-label "SE" format "x(02)"
                    movim.emite column-label "Emitente" format ">>>>>>"
                    vdesti column-label "Desti" format ">>>>>>>>>>"
                    vmovqtm format "->>>>9" column-label "Quant"
                    movim.movpc format ">,>>9.99" column-label "Valor"
                    sal-atu format "->>>>9" column-label "Saldo" 
                           with frame f-val 10 down overlay
                                 ROW 8 CENTERED color white/gray.
            color display red/gray vmovqtm with frame f-val. 
            down with frame f-val. 
            ***/
        end. 
        
    end. /*data*/    
 
end. /*tt-estab*/
def var vtotvenda as dec.
for each tt-produ break by tt-produ.procod.
    vtotvenda = vtotvenda + tt-produ.qtdvenlj.
    if last-of(tt-produ.procod)
    then do:
        assign tt-produ.qtdvenda = vtotvenda                            
        vtotvenda = 0.
    end.
end.
def var vvenda as dec.

varquivo = "../relat/ltaccessrel" + string(time).
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "121"
    &Page-Line = "66"
    &Nom-Rel   = ""CERRELINC""
    &Nom-Sis   = """BS"""
    &Tit-Rel   = """QUANTIDADE DE PRODUTOS MOVIMENTADOS Filial de "" +                  string(vetbi)  + "" ATE "" + string(vetbf)" 
    &Width     = "150"
    &Form      = "frame f-cabcab"}


for each tt-produ 
    break by tt-produ.etbcod 
    by tt-produ.procod.
    
    if first-of(tt-produ.etbcod)
    then do:
        find estab where estab.etbcod = tt-produ.etbcod no-lock.
        disp estab.etbcod label "Filial" estab.etbnom no-label
        with frame f-filial side-labels.
    end.
    
    
    vestatual = 0.
    aestatual = 0.
    bestatual = 0.
    
    find estoq where estoq.procod = tt-produ.procod and
                     estoq.etbcod = tt-produ.etbcod no-lock no-error.
                     
    if not avail estoq
    then vestatual = 0.
    else vestatual = estoq.estatual.
    
    find aestoq where aestoq.procod = tt-produ.procod and 
                      aestoq.etbcod = 993 no-lock no-error.

    if not avail aestoq
    then aestatual = 0.
    else aestatual = aestoq.estatual.
 
    find bestoq where bestoq.procod = tt-produ.procod and 
                      bestoq.etbcod = 995 no-lock no-error.

    if not avail bestoq
    then bestatual = 0.
    else bestatual = bestoq.estatual.

    assign tt-produ.estloja = vestatual + aestatual + bestatual.
     
    find produ where produ.procod = tt-produ.procod no-lock.
    
    disp produ.procod
         produ.pronom     
         tt-produ.etbcod     
         tt-produ.estloja  format "->>>>>9"
         tt-produ.qtdvenda
         tt-produ.qtdmov   
         tt-produ.qtdtrans 
         tt-produ.qtdvenlj 
         with frame f-produ width 180 down.
         down with frame f-produ.
    
    vtotestatual = vtotestatual + tt-produ.estloja.     
    vtotqtdmov   = vtotqtdmov   + tt-produ.qtdmov.
    vtotqtdtrans = vtotqtdtrans + tt-produ.qtdtrans.
    vtotqtdvenlj = vtotqtdvenlj + tt-produ.qtdvenlj.
        
    if last-of(tt-produ.etbcod)
    then do:
        down 2 with frame f-produ.
        disp    
                "TOTAL POR FILIAL" @ produ.procod
                vtotestatual  @ tt-produ.estloja
                vtotqtdmov    @ tt-produ.qtdmov
                vtotqtdtrans  @ tt-produ.qtdtrans
                vtotqtdvenlj  @ tt-produ.qtdvenlj
                with frame f-produ.
        
    end.    

end.

if opsys = "UNIX"
then do:
    output close.
    run visurel.p (varquivo,"").
end.
else do:
    {mrod.i}
end.    

