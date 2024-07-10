{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vetbcod like estab.etbcod.

update vetbcod label "Filial"
            with frame f1 side-label 1 down width 80.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Verifique a codigo informado para filial."
         view-as alert-box.
        undo.
    end.
    disp estab.etbnom no-label with frame f1.     
end.            
update vdti at 1 label "Periodo de"
       vdtf label "Ate"
       with frame f1.
       
if  vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
    "Verifique as datas informadas para periodo."
    view-as alert-box.
    undo.
end.

def temp-table tt-seguro
    field etbcod like estab.etbcod
    field data   as date
    field vendido as dec
    field cancelado as dec
    index i1 etbcod data.
    
for each estab where ( if vetbcod > 0
                       then estab.etbcod = vetbcod else true)
                       no-lock:

    for each vndseguro where
                 vndseguro.tpseguro = 1 and
                 vndseguro.etbcod = estab.etbcod and
                 vndseguro.pladat >= vdti and
                 vndseguro.pladat <= vdtf
                 no-lock:
        find first tt-seguro where
                   tt-seguro.etbcod = vndseguro.etbcod and
                   tt-seguro.data   = vndseguro.pladat
                   no-error.
        if not avail tt-seguro
        then do:
            create tt-seguro.
            assign
                tt-seguro.etbcod = vndseguro.etbcod
                tt-seguro.data   = vndseguro.pladat
                .
        end.
        tt-seguro.vendido = tt-seguro.vendido + vndseguro.prseguro.
    end.
    for each vndseguro where
                 vndseguro.tpseguro = 1 and
                 vndseguro.etbcod = estab.etbcod and
                 vndseguro.dtcanc >= vdti and
                 vndseguro.dtcanc <= vdtf
                 /*vndseguro.pladat >= vdti */
                 no-lock:
        find first tt-seguro where
                   tt-seguro.etbcod = vndseguro.etbcod and
                   tt-seguro.data   = vndseguro.dtcanc
                   no-error.
        if not avail tt-seguro
        then do:
            create tt-seguro.
            assign
                tt-seguro.etbcod = vndseguro.etbcod
                tt-seguro.data   = vndseguro.dtcanc
                .
        end.
        tt-seguro.cancelado = tt-seguro.cancelado + vndseguro.prseguro. 
    end.
end.    

def temp-table tt-dtseguro
    field data as date
    field vendido as dec
    field cancelado as dec
    index i1 data.
    
for each tt-seguro:
    find first tt-dtseguro where tt-dtseguro.data = tt-seguro.data no-error.
    if not avail tt-dtseguro
    then do:
        create tt-dtseguro.
        tt-dtseguro.data = tt-seguro.data.
    end.
    assign
        tt-dtseguro.vendido = tt-dtseguro.vendido + tt-seguro.vendido
        tt-dtseguro.cancelado = tt-dtseguro.cancelado + tt-seguro.cancelado.
end.
def var varquivo as char.        
varquivo = "/admcom/relat/rel_seguro_ctb." + string(time).

{mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "64" 
                        &Cond-Var  = "80" 
                        &Page-Line = "64" 
                        &Nom-Rel   = ""rel_seguro_ctb"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM VENDA SEGUROS"""
                        &Width     = "80"  
                        &Form      = "frame f-cabcab"}
                        .
DISP WITH FRAME F1. 

for each tt-dtseguro.
    disp tt-dtseguro.data
         tt-dtseguro.vendido(total)
         tt-dtseguro.cancelado(total)
         with frame f-disp down
         .
end.

OUTPUT CLOSE.
run visurel.p(varquivo,"").
