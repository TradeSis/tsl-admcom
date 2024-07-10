{admcab.i}

def temp-table tt-instala
    field etbcod like estab.etbcod label "Filial"
    field clifor like clien.clicod label "Cliente"
    field numero like plani.numero label "Numero"
    field pladat like plani.pladat label "Emissao"
    field platot like plani.platot label "Total"
    field frete  like plani.platot label "Frete"
    field split  like plani.vlserv label "Inatala"
    field serie   like plani.serie label "Serie"
    field icms    like plani.icms  label "ICMS"
    field notpis  like plani.notpis label "PIS"
    field notcof  like plani.notcof label "COFINS"
    index i1 etbcod pladat numero 
    .
    
def var vblackfriday  as dec.
def var vi as int.
def var vetbcod1 like estab.etbcod.
def var vetbcod2 like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vqcheqp as int.
def var vvcheqp as dec.
def var vbonus as dec.

update vetbcod1 label "Filial de"
       vetbcod2 label "Ate"          skip
       vdti label "Periodo de"
       vdtf label "Ate"
       with frame f1 side-label width 80.

def var vindex as int init 1.

/*
def var vesc as char extent 2 format "x(15)"
    init["ANALITICO","SINTETICO"].
disp vesc with frame f-esc 1 down centered side-label no-label.
choose field vesc with frame f-esc.
vindex = frame-index.
         */
def temp-table tt-produ like produ.
for each produ where pronom matches "*freteiro*" and
                     pronom matches "*filial*" no-lock:
    if produ.pronom  matches "*brick*"
    then next.
    create tt-produ.
    buffer-copy produ to tt-produ.
end.
for each produ where pronom matches "*split*" and
                     pronom matches "*instal*" no-lock:
    create tt-produ.
    buffer-copy produ to tt-produ.
end.

format "Aguarde processamento... "
    with frame f-disp width 80 color message no-box.

for each estab where estab.etbcod >= vetbcod1 and
                     estab.etbcod <= vetbcod2 no-lock:
    disp estab.etbcod with frame f-disp no-label.
    pause 0.
    for each tt-produ no-lock:
        for each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5 and
                             movim.procod = tt-produ.procod and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf
                             no-lock:
            find first plani where plani.movtdc = movim.movtdc and
                         plani.etbcod = movim.etbcod and
                         plani.placod = movim.placod and
                         plani.pladat = movim.movdat
                         no-lock no-error.
            if not avail plani then next.             
            disp plani.numero format ">>>>>>>>9"
                         plani.pladat with frame f-disp.
    
            find first tt-instala where
                       tt-instala.etbcod = plani.etbcod and
                       tt-instala.pladat = plani.pladat and
                       tt-instala.numero = plani.numero 
                       no-error.
            if not avail tt-instala
            then do:           
                create tt-instala.        
                assign
                    tt-instala.etbcod = plani.etbcod
                    tt-instala.pladat = plani.pladat
                    tt-instala.numero = plani.numero
                    tt-instala.platot = plani.platot
                    tt-instala.clifor = plani.desti
                    tt-instala.serie  = plani.serie
                    tt-instala.icms   = plani.icms
                    tt-instala.notpis = plani.notpis
                    tt-instala.notcof = plani.notcof
                    .
            end.
                    
            if tt-produ.pronom matches "*FRETEIRO*"
            then tt-instala.frete = tt-instala.frete +
                                     (movim.movpc * movim.movqtm).
            if tt-produ.pronom matches "*split*"
            then tt-instala.split = tt-instala.split +
                    (movim.movpc * movim.movqtm).
        end.
    end.
end.
def var vclinom like clien.clinom.
def var varquivo as char.
varquivo = "/admcom/relat/vendisntalfrete." + string(time).
{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA CONTABILIDADE"""
            &Tit-Rel   = """RELATORIO "" + /*VESC[VINDEX] +*/
                            "" VALOR FRETE E INSTALA SPLIT """
            &Width     = "150"
            &Form      = "frame f-cabcab"}
disp with frame f1.
for each tt-instala break by tt-instala.etbcod.
    find clien where clien.clicod = tt-instala.clifor no-lock no-error.
    vclinom = "".
    if avail clien 
    then vclinom = clien.clinom.
        
    disp tt-instala.etbcod column-label "Filial"
         tt-instala.clifor when vindex = 1 column-label "Codigo!Cliente"
         vclinom    when vindex = 1 
         column-label "Nome!Cliente" format "x(30)"
         tt-instala.numero when vindex = 1 column-label "Numero!venda"
            format ">>>>>>>>9"
         tt-instala.serie column-label "Serie"
         tt-instala.pladat when vindex = 1 column-label "Data!Emissao"
         tt-instala.platot(total by tt-instala.etbcod) 
                    column-label "Total!Venda"
         tt-instala.frete(total by tt-instala.etbcod) 
                    column-label "Valor!Frete"
         tt-instala.split(total by tt-instala.etbcod)   
                    column-label "Valor!Instala"
         tt-instala.icms(total by tt-instala.etbcod) 
                    column-label "Valor!ICMS"
         tt-instala.notpis(total by tt-instala.etbcod)
                    column-label "Valor!PIS"
         tt-instala.notcof(total by tt-instala.etbcod)
                    column-label "Valor!COFINS"
         with frame ff down width 170
         .
end.

output close.

def var varq1 as char.
varq1 = varquivo + ".csv".
output to value(varq1).
put "Filial;Cliente;Nome;Numero;Serie;Emissao;Total;Frete;Instala;ICMS;IPI;COFINS"
skip.
for each tt-instala: 
    find clien where clien.clicod = tt-instala.clifor no-lock no-error.
    vclinom = "".
    if avail clien 
    then vclinom = clien.clinom.
        
    put tt-instala.etbcod ";"
        tt-instala.clifor format ">>>>>>>>>9" ";"
        vclinom  format "x(40)"  ";" 
        tt-instala.numero format ">>>>>>>>9"  ";"
        tt-instala.serie ";"
        tt-instala.pladat ";"
        tt-instala.platot format ">>>>>>>9.99" ";"
        tt-instala.frete  format ">>>>>>>9.99" ";"
        tt-instala.split  format ">>>>>>>9.99" ";"
        tt-instala.icms   format ">>>>>>>9.99" ";"
        tt-instala.notpis format ">>>>>>>9.99" ";"
        tt-instala.notcof format ">>>>>>>9.99"
        skip.

end.
output close.

message color red/with
    "Arquivo CSV gerado:" skip
    varq1
    view-as alert-box.
    
run visurel.p(varquivo,"").
