{admcab.i}
def var vprocod like produ.procod.
def var vdti as date.
def var vdtf as date.
def var ctom-ant as dec.
def var qtde-ant as dec.
def var cton-liq as dec.
def var vpis as dec.
def var vcofins as dec.

update vprocod at 6 label "Produto"
        with frame f1 1 down width 80 side-label.


if vprocod > 0
then do:
find produ where produ.procod = vprocod no-lock.

disp produ.pronom no-label with frame f1.
end.

vdti = date(01,01,2009).
update vdti at 1 label "Data Inicial" format "99/99/9999"
        with frame f1.

def temp-table tt-movim like movim.
for each movim where movim.movtdc  = 4 and
                     movim.movdat >= vdti
                     no-lock break by movdat:
    if vprocod > 0 and
        vprocod <> movim.procod
    then next.    
    find plani where plani.etbcod = movim.etbcod and
                     plani.placod = movim.placod and
                     plani.movtdc = movim.movtdc
                     no-lock no-error.
    if not avail plani or
       plani.notsit = yes
    then next.
    find first  tt-movim where 
                tt-movim.procod =  movim.procod no-error.
    if not avail tt-movim
    then do:            
        create tt-movim.
        buffer-copy movim to tt-movim.
    end.
    else if tt-movim.movdat < movim.movdat or
        (tt-movim.movdat = movim.movdat and
         tt-movim.movhr < movim.movhr)
        then do:
            message tt-movim.movdat movim.movdat tt-movim.movctm. pause.
            buffer-copy movim to tt-movim.
        end.
end.

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""extctom0"" 
                &Nom-Sis   = """Contabil Fiscal""" 
                &Tit-Rel   = """   CUSTO MEDIO CONTABIL """ 
                &Width     = "130"
                &Form      = "frame f-cabcab"}


for each tt-movim no-lock:
    find produ where produ.procod = tt-movim.procod no-lock.
    ctom-ant = 0.
    qtde-ant = 0.

    find last ctbhie use-index ind-2 where 
                  ctbhie.procod = produ.procod and
                  ctbhie.etbcod = 0 and
                  ctbhie.ctbano <= year(tt-movim.movdat) /*and
                  ctbhie.ctbmes < month(tt-movim.movdat)*/
                  no-lock no-error.
    ctom-ant = ctbhie.ctbest.
    qtde-ant = ctbhie.ctbven.
    
    message ctom-ant qtde-ant. pause.
    if qtde-ant < 0
    then qtde-ant = 0.
    vpis = 0.
    vcofins = 0.
    run piscofal.p( input no, 
                    input tt-movim.movtdc, 
                    input tt-movim.procod, 
                    output vpis,
                    output vcofins).
        
    if vpis > 0
    then vpis = (tt-movim.movpc * tt-movim.movqtm) * (vpis / 100).
    if vcofins > 0
    then vcofins = (tt-movim.movpc * tt-movim.movqtm) * 
                        (vcofins / 100).
   /*                     
   message tt-movim.movpc tt-movim.movipi (tt-movim.movipi / tt-movim.movqtm)
            (tt-movim.movpc * (tt-movim.movalicms / 100))
             tt-movim.movdes ((vpis + vcofins) / tt-movim.movqtm)
             tt-movim.movicms.
            pause.
   **/
    cton-liq = (tt-movim.movpc + (tt-movim.movipi / tt-movim.movqtm)) -
                ((tt-movim.movpc * (tt-movim.movalicms / 100)) 
                  + tt-movim.movdes 
                  + ((vpis + vcofins) / tt-movim.movqtm)) 
                  .

    disp produ.procod label "Produto"
         produ.pronom no-label
         with frame f-produ 1 down side-label no-box.
    disp tt-movim.movdat 
         tt-movim.movpc  column-label "Custo!Nota" format ">>>>>,>>9.99"
         tt-movim.movalicms column-label "Aliq"  format ">>9.99%"
         (tt-movim.movpc * (tt-movim.movalicms / 100))
                        column-label "ICMS"  format ">>,>>9.99"
         tt-movim.movdes  column-label "Desconto" format ">>,>>9.99"
         tt-movim.movipi / tt-movim.movqtm
            column-label "IPI"      format ">>,>>9.99"
         (vpis + vcofins) / tt-movim.movqtm column-label "Pis/Cof"
         cton-liq  column-label "Custo!Liquido"
         tt-movim.movqtm column-label "Quant!Nota"
         ctom-ant column-label "Custo!Anterior"
         qtde-ant     column-label "Quant!Anterior"        
         tt-movim.movctm column-label "Custo!Atual"
         qtde-ant + tt-movim.movqtm column-label "Quant!Atual"
                        format ">>>,>>9.99"
         with frame f-imp down width 140.
    down(1) with frame f-imp.
end.

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
