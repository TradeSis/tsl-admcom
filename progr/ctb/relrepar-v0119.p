{admcab.i}

def temp-table tt-repar
    field clicod like contrato.clicod 
    field contnum like contrato.contnum
    field dtinicial like contrato.dtinicial
    field etbcod like contrato.etbcod
    field titnum like titulo.titnum
    field vltotal like contrato.vltotal
    field vlentra like contrato.vlentra
    field titvlcob like titulo.titvlcob
    field etbcobra like titulo.etbcobra
    field o-finan as dec
    field o-lebes as dec
    field acrescimo as dec
    field desconto as dec
    index i1 clicod contnum titnum
    .

def var vtotal as dec format ">>>,>>>,>>9.99".
def var vdti as date.
def var vdtf as date.
def var vdata as date.

update vdti label "Data inicial"
       vdtf label "Data final"
       with frame f1 1 down side-label width 80.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.       

do vdata = vdti to vdtf:
    disp vdata label "Processando" with 1 down side-label. pause 0.
    for each contrato where
             contrato.dtinicial = vdata and
             contrato.banco = 99
             no-lock:

        find first titulo where 
                   titulo.clifor =  contrato.clicod and
                   titulo.titnum = string(contrato.contnum) and
                   titulo.titpar > 30
                   no-lock no-error.
        if not avail titulo then next.
                   
        vtotal = vtotal + contrato.vltotal.
        for each titulo where
                 titulo.clifor = contrato.clicod and
                 titulo.titdtpag = contrato.dtinicial and
                 titulo.etbcobra = 903
                 no-lock:
            find first tt-repar where
                       tt-repar.clicod  = contrato.clicod and
                       tt-repar.contnum = contrato.contnum and
                       tt-repar.titnum  = titulo.titnum
                       no-error.
            if not avail tt-repar
            then do:
                create tt-repar.
                assign
                    tt-repar.clicod  = contrato.clicod
                    tt-repar.contnum = contrato.contnum
                    tt-repar.titnum  = titulo.titnum
                    tt-repar.dtinicial = contrato.dtinicial
                    tt-repar.vltotal = contrato.vltotal
                    tt-repar.vlentra = contrato.vlentra
                    tt-repar.etbcod = contrato.etbcod
                    .        
            end.
            assign
                tt-repar.etbcobra = titulo.etbcobra
                tt-repar.titvlcob = tt-repar.titvlcob + titulo.titvlcob.
                
            if titulo.cobcod = 10
            then tt-repar.o-finan = tt-repar.o-finan + titulo.titvlcob.
            else tt-repar.o-lebes = tt-repar.o-lebes + titulo.titvlcob.
        end.         
    end.
end.
def var varquivo as char.
varquivo = "/admcom/Contabilidade/relat/reparcelamentos." + string(time)
            + ".csv".
/*
form header
            wempre.emprazsoc
                    space(6) "PAGRE"   at 60
                    "Pag.: " at 71 page-number format ">>9" skip
                    "   REPARCELAMENTOS   "   at 1
                    today format "99/99/9999" at 60
                    string(time,"hh:mm:ss") at 73
                    skip fill("-",80) format "x(80)" skip
                    with frame fcab1 no-label page-top no-box width 140.

def var vlin as int.
def var vacrescimo as dec.
def var vdesconto as dec.
def var vtotal_contrato as dec.
def var vtotal_origem as dec.

output to value(varquivo).
view frame fcab1.
disp with frame f1. 
for each tt-repar break by tt-repar.contnum:

    disp tt-repar.clicod 
         tt-repar.contnum format ">>>>>>>>>9"
         tt-repar.etbcod     column-label "Filial"
         tt-repar.dtinicial  column-label "Emissao"
         with frame f-disp.
         .
    if first-of(tt-repar.contnum)
    then do:
        disp tt-repar.vltotal  column-label "Valor Contrato"
              tt-repar.vlentra  column-label "Valor Entrada"
              with frame f-disp.
    end.
    else disp 0 @ tt-repar.vltotal
              0 @ tt-repar.vlentra
              with frame f-disp.
                
    disp tt-repar.titnum           column-label "Contrato Baixa" 
         tt-repar.titvlcob(total)  column-label "Valor Baixa"
         tt-repar.etbcobra         column-label "Local Baixa"
         tt-repar.o-finan          column-label "Origem Finan"
         tt-repar.o-lebes          column-label "Origem Lebes"
         with frame f-disp width 150 down.
                
end.
output close.
run visurel.p (input varquivo, input "").
*/
def var vacrescimo as dec decimals 2 format ">>>,>>9.99".
def var vdesconto as dec decimals 2 format ">>>,>>9.99".
def var vtotal_contrato as dec.
def var vtotal_entrada as dec.
def var vtotal_origem as dec.
def var characr as dec.
def var chardes as dec.
output to value(varquivo).
put "Cliente;Contrato;Filial;Emissao;Valor Contrato;Valor Entrada;Contrato Baixa;Valor Baixa;Local Baixa;Origem Financeira;Origem Lebes;Acrescimo;Desconto" skip.
for each tt-repar break by tt-repar.contnum:
    put unformatted 
        tt-repar.clicod ";"
        tt-repar.contnum format ">>>>>>>>>9"  ";"
        tt-repar.etbcod   ";"
        tt-repar.dtinicial  ";"
        .
    if first-of(tt-repar.contnum)
    then do:
        put unformatted
            replace(string(tt-repar.vltotal,">>>>>>>>9.99"),".",",") ";"
            replace(string(tt-repar.vlentra,">>>>>>>>9.99"),".",",") ";" 
            .
        vtotal_contrato = vtotal_contrato + tt-repar.vltotal.   
        vtotal_entrada  = vtotal_entrada + tt-repar.vlentra.  
    end.
    else put unformatted
            "; ;".
                
    put unformatted
        tt-repar.titnum ";"
        replace(string(tt-repar.titvlcob,">>>>>>>>9.99"),".",",") ";"
        tt-repar.etbcobra ";"
        replace(string(tt-repar.o-finan,">>>>>>>>9.99"),".",",") ";"
        replace(string(tt-repar.o-lebes,">>>>>>>>9.99"),".",",")
        .          
    vtotal_origem = vtotal_origem + 
                    tt-repar.o-finan + tt-repar.o-lebes.
    if last-of(tt-repar.contnum)
    then do:                
        if vtotal_contrato > (vtotal_origem - vtotal_entrada)
        then vacrescimo = vtotal_contrato - (vtotal_origem - vtotal_entrada).
        else vdesconto  = (vtotal_origem - vtotal_entrada) - vtotal_contrato.
        put unformatted
            ";" replace(string(vacrescimo,">>>>>>>>9.99"),".",",") 
            ";" replace(string(vdesconto,">>>>>>>>9.99"),".",",")
                       .
        assign
        vtotal_contrato = 0
        vtotal_origem = 0
        vtotal_entrada = 0
        vacrescimo = 0
        vdesconto = 0
        .
    end.            
    else put unformatted "; ;".
    put skip.
end.
output close.

message color red/with
    "Arquivo gerado" skip
    varquivo
    view-as alert-box.
    
    
