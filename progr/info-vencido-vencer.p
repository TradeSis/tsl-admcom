/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{/admcom/progr/admcab-batch.i}

def output parameter varqpdf as char.

def var vdatref as date.
vdatref = today - 1.

def var etb-tit like estab.etbcod.

def temp-table tt-clietb
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field vencido as dec
    field vencer as dec
    .
    
def var tot-vencido as dec format ">>>,>>>,>>9.99".
def var tot-vencer as dec format ">>>,>>>,>>9.99".

for each estab  no-lock:

    /*disp "Processando... Filial : " estab.etbcod with 1 down.
    pause 0.*/
    create tt-clietb.
    tt-clietb.etbcod = estab.etbcod.
    tt-clietb.etbnom = estab.etbnom.
    for each fin.titulo 
                 where fin.titulo.empcod = 19 and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = "CRE" and
                       fin.titulo.etbcod = estab.etbcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                         fin.titulo.titdtpag > vdatref))  
                       no-lock:
    
        if fin.titulo.titdtemi > vdatref
        then next.

        /* #1 */
        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
           titulo.tpcontrato = "L" 
        then next.
        
        /* #1
        if fin.titulo.tpcontrato = "L"
        then next.
        */
        
        etb-tit = fin.titulo.etbcod.
        
        run muda-etb-tit.

        if fin.titulo.etbcod = 10 and etb-tit = 23
        then next.
                
        if titdtven <= vdatref
        then tt-clietb.vencido = tt-clietb.vencido + fin.titulo.titvlcob.
        else tt-clietb.vencer  = tt-clietb.vencer  + fin.titulo.titvlcob.

    end.
end.

procedure muda-etb-tit.

    if etb-tit = 10 and
        fin.titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.

for each tt-clietb:
    tot-vencido = tot-vencido + tt-clietb.vencido.
    tot-vencer  = tot-vencer  + tt-clietb.vencer.
    
    if tt-clietb.vencido = 0 and
       tt-clietb.vencer = 0
    then delete tt-clietb.    
 
end.

/*
create tt-clietb.
tt-clietb.etbnom = "   T O T A L ".
tt-clietb.vencido = tot-vencido.
tt-clietb.vencer  = tot-vencer.
*/

def var varquivo as char format "x(20)".
varquivo = "/admcom/relat/vencidos_avencer_" + string(vdatref,"99999999") .

{mdad.i
    &Saida     = "value(varquivo)" 
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = """"
    &Nom-Sis   = """SISTEMA DE CREDIARIO 040418"""
    &Tit-Rel   = """ POSICAO FIN. VENCIDAS/A VENCER - FILIAL "" + 
                     "" DATA BASE: "" + string(vdatref,""99/99/9999"")" 
    &Width     = "80"
    &Form      = "frame f-cabcab"}

for each tt-clietb  no-lock:
    
    disp tt-clietb.etbcod column-label "Filial"
         tt-clietb.etbnom no-label
         tt-clietb.vencido(total)  format ">>>,>>>,>>9.99"
                column-label "Vencido"
         tt-clietb.vencer(total)   format ">>>,>>>,>>9.99"
                column-label "Vencer"
         with frame f1 down centered
         .
end.
 
output close.

/*
run visurel.p(varquivo, "").
*/
                                 
varqpdf = varquivo + ".pdf".

run /admcom/progr/ger-arq-PDF.p(input varquivo, input varqpdf).

def var vaspas as char.
def var vassunto as char.
def var vemail as char.

vaspas  = chr(34).
vassunto  = "Informativo vencido e a vencer".
vemail = "claudir.santolin@linx.com.br".






