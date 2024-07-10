{admcab.i}

def var vfil-ini like estab.etbcod.
def var vfil-fim like estab.etbcod.

def var vdti as date.
def var vdtf as date.

def var val-ini as dec.
def var val-fim as dec.

form vfil-ini at 2 label "Filial de"
     vfil-fim at 25 label "Ate"
     vdti at 1 label "Periodo de"   format "99/99/9999"
     vdtf at 25     label "Ate"     format "99/99/9999"
     val-ini at 3 label "Valor de"
     val-fim at 25 label "Ate"
     with frame f-1 side-label width 80 1 down.

update vfil-ini validate(vfil-ini > 0,"")
       vfil-fim 
       with frame f-1.

if vfil-fim = 0 then vfil-fim = vfil-ini.
disp vfil-fim with frame f-1.

update vdti validate(vdti <> ?, "") 
       vdtf
       with frame f-1.
if vdtf = ? then vdtf = vdti.
disp vdtf with frame f-1.
            
update val-ini
       val-fim
       with frame f-1.
                
def var vdata as date.                

def temp-table tt-voucher
    field etbcod like estab.etbcod
    field data   as date
    field id-voucher as char
    field valor as dec
    field nf-venda as int
    index i1 etbcod data id-voucher
    .
    
for each estab no-lock:
    if estab.etbcod < vfil-ini
    then next.
    if estab.etbcod > vfil-fim
    then next.
    do vdata = vdti to vdtf:
        for each tfopagvo where tfopagvo.etbcod = estab.etbcod and
                                tfopagvo.datmov   = vdata
                                no-lock:
            if  val-ini > 0 and
                tfopagvo.valor < val-ini
            then next.
            if  val-fim > 0 and
                tfopagvo.valor > val-fim
            then next.
            find plani where plani.etbcod = tfopagvo.etbcod and 
                             plani.placod = tfopagvo.placod
                    no-lock no-error.
            create tt-voucher.
            assign
                tt-voucher.etbcod = tfopagvo.etbcod
                tt-voucher.data   = tfopagvo.data
                tt-voucher.id-voucher = tfopagvo.voucher
                tt-voucher.valor  = tfopagvo.valor
                .
            if avail plani
            then tt-voucher.nf-venda = plani.numero.
        end.
    end.
end.             

def var varquivo as char.
                 
varquivo = "/admcom/relat/vouchers" + string(setbcod) + "."
                    + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rel-tfopagvo"" 
                &Nom-Sis   = """SISTEMA FINANCEIRA""" 
                &Tit-Rel   = """ VOUCHERS UTILIZADOS PARA PAGAMENTO """ 
                &Width     = "100"
                &Form      = "frame f-cabcab"}


disp with frame f-1.

for each tt-voucher:
    disp tt-voucher.
end.    

output close.

run visurel.p(varquivo,"").

