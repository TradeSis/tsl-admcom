{admcab.i new}
setbcod = 189.            
def var cod-vendedor as int.
def var cod-filial as int.

def var vga as char extent 5 format "x(30)".
def var vgp as int extent 5.
vga[1] = "GAMA BAIXA VENDEDOR".
vga[2] = "GAMA MEDIA VENDEDOR".
vga[3] = "GAMA ALTA  VENDEDOR".
vga[4] = "GAMA MEDIA/ALTA PROMOTOR VIVO".
vga[5] = "GAMA MEDIA/ALTA PROMOTOR CLARO".

vgp[1] = 404.
vgp[2] = 407.
vgp[3] = 410.
vgp[4] = 415.
vgp[5] = 417.

/**
update  cod-filial   label "Filial"
        cod-vendedor label "Vendedor"
        with frame f-1 side-label .
def var ea as int.
def var eb as int.
def var ei as int.
def var vindex as int.
if cod-vendedor > 0
then do:
    assign ea = 1 eb = 3.
    disp vga[1] vga[2] vga[3]
        with frame f-3 1 column no-label.
    choose field vga[1] vga[2] vga[3] with frame f-3.    
    vindex = frame-index.
end.    
else do:
    assign ea = 4 eb = 5.
    disp vga[4] vga[5]
        with frame f-2 1 column no-label.
    choose field vga[4] vga[5]  with frame f-2.    
    vindex = frame-index.
end.
***/

def var va as dec.
def var vb as dec.
def var vm as dec.

def var qvb as int init 0.
def var qvm as int init 0.
def var qva as int init 0.
            
vb = 1.
vm = 200.
va = 500.

def var qtd-vendida as int.

def buffer tctpromoc for ctpromoc.
def temp-table tt-vendedor
    field etbcod like estab.etbcod 
    field vencod as int
    field gb as int
    field gm as int
    field ga as int
    index i1 etbcod vencod
    .
     

for each ctpromoc where 
         ctpromoc.sequencia >= vgp[1]  and
         ctpromoc.sequencia <= vgp[3]  and
         ctpromoc.linha = 0           and
         ctpromoc.vendaacimade > 0 and
         ctpromoc.campodec2[4] > 0 and
         ctpromoc.situacao = "L"
         no-lock:
    /*
    if ctpromoc.sequencia <> 404 and
       ctpromoc.sequencia <> 407 and
       ctpromoc.sequencia <> 410
    then next.
    */     
    for each tctpromoc where
                    tctpromoc.sequencia = ctpromoc.sequencia and
                    tctpromoc.linha > 0  and
                    tctpromoc.clacod > 0
                    no-lock .
        find clase where clase.clacod = tctpromoc.clacod no-lock no-error.
        if avail clase and
           (clase.clanom begins "CHIP" or
            clase.clanom matches "*CHIP*")
        then next.    
        
        for each produ where produ.clacod = tctpromoc.clacod no-lock.   
        for each estab no-lock: 
            disp ctpromoc.sequencia
                 produ.procod
                 estab.etbcod
                 with frame f-d1 centered row 10 no-label.
            pause 0.     
            for each movim where 
                     movim.etbcod = estab.etbcod and
                     movim.movtdc = 5 and
                     movim.procod = produ.procod and
                     movim.movdat >= ctpromoc.dtinicio and
                     movim.movdat <= ctpromoc.dtfim
                     no-lock,
                first plani where plani.etbcod = movim.etbcod and
                                  plani.placod = movim.placod and
                                  plani.movtdc = movim.movtdc and
                                  plani.pladat = movim.movdat and
                                 (if cod-vendedor > 0
                                  then plani.vencod = cod-vendedor 
                                  else true)
                                  no-lock:
                                  
                /*
                if cod-vendedor > 0 and
                   plani.vencod <> cod-vendedor 
                then next.
                */
                if movim.movpc >= ctpromoc.vendaacimade and
                        movim.movpc <= ctpromoc.campodec2[3]
                then do:
                    find first tt-vendedor where
                               tt-vendedor.etbcod = plani.etbcod and
                               tt-vendedor.vencod = plani.vencod
                               no-error.
                    if not avail tt-vendedor
                    then do:
                        create tt-vendedor.
                        tt-vendedor.etbcod = plani.etbcod.
                        tt-vendedor.vencod = plani.vencod.       
                    end.
                    if movim.movpc >= va
                    then tt-vendedor.ga = tt-vendedor.ga + 1.
                    else if movim.movpc >= vm
                        then tt-vendedor.gm = tt-vendedor.gm + 1.
                        else if movim.movpc >= vb
                            then tt-vendedor.gb = tt-vendedor.gb + 1.

                end.
            end.
        end.
        end.
    end.
end.

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "../relat/conta-venda-telefonia." + string(time).
else varquivo = "..\relat\conta-venda-telefonia." + string(time).

output to value(varquivo).
for each tt-vendedor  where tt-vendedor.etbcod > 0
            break by tt-vendedor.etbcod
                  by tt-vendedor.vencod
                     .
    find func where func.funcod = tt-vendedor.vencod and
                    func.etbcod = tt-vendedor.etbcod
                    no-lock no-error.

    disp tt-vendedor.etbcod   column-label "FIL"
         tt-vendedor.vencod   column-label "VENDEDOR"
         func.funnom no-label when avail func 
         tt-vendedor.gb column-label "GAMA BAIXA"  
                    (total by tt-vendedor.etbcod)
         tt-vendedor.gm column-label "GAMA MEDIA"
                    (total by tt-vendedor.etbcod)
         tt-vendedor.ga column-label "GAMA ALTA"
                    (total by tt-vendedor.etbcod)
         with frame f-disp down width 120.

end.
output close.
if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.
