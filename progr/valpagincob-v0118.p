{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-paga 
    field data as date format "99/99/9999"
    field valor as dec format ">>>,>>>,>>9.99"
    index i1 data.
    
update 
       vdti at 1 format "99/99/9999" label "Periodo pagamento"
       vdtf      format "99/99/9999" label "a"
       with frame f1 1 down width 80 side-label.

if vdtf = ? or vdti = ? then undo.
if vdtf < vdti then undo.

def var vdtaux as date.
vdtaux = vdtf - 180.
def var vdata as date.
do vdata = vdti to vdtf:
    for each titulo where   titulo.titnat = no and
                            titulo.titdtpag = vdata and
                            titulo.titdtven < vdtaux 
                            no-lock:
        find first tt-paga where
                   tt-paga.data = titulo.titdtpag no-error.
        if not avail tt-paga
        then do:
            create tt-paga.
            tt-paga.data = titulo.titdtpag.
        end.
        tt-paga.valor = tt-paga.valor + titulo.titvlpag.           
    end.
end.                            
           
def var varquivo as char.

varquivo = "/admcom/relat/valpagincob." + string(time).

{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "60" 
                &Page-Line = "66" 
                &Nom-Rel   = ""valpagincob"" 
                &Nom-Sis   = """CONTABILIDADE""" 
                &Tit-Rel   = """VALORES PAGOS REFERENTE INCOBRAVEIS""" 
                &Width     = "60"
                &Form      = "frame f-cabcab"}

disp with frame f1.

for each tt-paga:
    disp tt-paga.data
         tt-paga.valor(total).
end. 

output close.

run visurel.p(varquivo,"").
