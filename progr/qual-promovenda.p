{admcab.i new}
def var vpromocas as char.
def new shared var vdata-teste-promo as date.

def new shared workfile wf-movim
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod.

def temp-table tt-movim
    field procod like movim.procod.

def new shared temp-table tt-valpromo
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.


def var vetbcod like estab.etbcod.
def var vnumven like plani.numero.

def buffer bestab for estab.

form   vetbcod label "Filial"
       bestab.etbnom no-label
        with frame f-1 1 down width 80 side-label.

form  vnumven      at 1 label "Venda numero  "    format ">>>>>>>>9"
      plani.pladat      label "      Emissao "
      plani.pedcod      label "      Plano   "
      plani.vencod  at 1 label "      vendedor"
      func.funnom   no-label
      with frame f-2 1 down width 80 side-label no-box.

def input parameter par-rec as recid.
find plani where recid(plani) =  par-rec no-lock.

vdata-teste-promo = plani.pladat.

vetbcod = plani.etbcod.
disp vetbcod with frame f-1.
find bestab where bestab.etbcod = vetbcod no-lock.
disp bestab.etbnom with frame f-1.
vnumven = plani.numero. 
disp vnumven with frame f-2.

/**
find plani where plani.etbcod = vetbcod and
                 plani.movtdc = 5 and
                 plani.emite  = vetbcod and
                plani.serie = "V" and
                 plani.numero = vnumven
                 no-lock no-error.
if not avail plani
then find plani where plani.etbcod = vetbcod and
            plani.movtdc = 5 and
            plani.emite  = vetbcod and
            plani.serie = "3" and
            plani.numero = vnumven
            no-lock no-error.
if not avail plani
then do:
    message color red/with
    "Venda nao encontrada"
    view-as alert-box.
    return.
end.
**/

find func where func.etbcod = vetbcod and
                func.funcod = plani.vencod no-lock no-error.
disp plani.pladat
     plani.pedcod
     plani.vencod
     func.funnom when avail func
     with frame f-2.
 
for each movim where movim.etbcod = plani.etbcod and
                     movim.movtdc = plani.movtdc and
                     movim.placod = plani.placod
                     no-lock.
    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ then next.

    disp movim.procod format ">>>>>>9" column-label "Produto"
         produ.pronom format "x(17)"  no-label
         movim.movqtm format ">9"     column-label "Qt"
         movim.movpc  format ">>>9.99" column-label "Venda"
         with frame f-3 8 down width 40
         title " Produtos da venda "
         .
    
    create wf-movim.
    assign
        wf-movim.wrec = recid(produ)
        wf-movim.movqtm = movim.movqtm
        wf-movim.movpc = movim.movpc
        wf-movim.vencod = plani.vencod .
        
    create tt-movim.
        tt-movim.procod = movim.procod.

end.                      
def var vt-despesas as dec init 0.     
for each titluc where titluc.empcod = 19
                    and titluc.titnat = yes
                    and titluc.modcod = "COM"
                    and titluc.etbcod = vetbcod
                    and titluc.titdtven = plani.pladat
                    and titluc.titnum = string(plani.numero)
                    no-lock.
    /*
    find first foraut where foraut.forcod = titluc.clifor
        no-lock no-error.
    */
    disp titluc.clifor format ">>>>>>9" column-label "Despesa"
         " " format "x(20)"
         /*foraut.fornom when avail foraut  format "x(20)" no-label*/
         titluc.titvlcob column-label "Valor" format ">>>9.99" 
         with frame f-4 8 down width 40 column 41
         title " Despesas geradas "
         .
    vt-despesas = vt-despesas + titluc.titvlcob.
end.
disp vt-despesas label "Total Despesas" format ">>>9.99"
    with frame f-5 1 down no-box side-label column 58
    row 20.

find first finan where finan.fincod = plani.pedcod no-lock.

def var parametro-out as char.
def var parametro-in as char.
def var vlibera as log.
def var vpreco as dec.
def var libera-plano as log.
def var p-dtentra as date.
def var p-dtparcela as date.

def var detbcod like setbcod.
detbcod = setbcod.
setbcod = vetbcod.

/**
for each tt-movim.
**/
do:
   /**
    find produ where produ.procod = tt-movim.procod no-lock.
    **/
    
/*** LIBERA PRECO ****/

/**
vlibera = no.
do:
    parametro-in = "LIBERA-PRECO=S|PRODUTO=" +
                    string(produ.procod) + "|".
    run promo-venda.p(input parametro-in ,
                      output parametro-out).
    if acha("LIBERA-PRECO",parametro-out) <> ?
    then vlibera = yes.
end.

/*** PRECO ESPECIAL ***/
vlibera = no.
/*if search("/admcom/progr/promo-venda.p") <> ?
then*/ do:
    parametro-in = "PRECO-ESPECIAL=S|PRODUTO=" +
                    string(produ.procod) + "|".
    run promo-venda.p(input parametro-in ,
                      output parametro-out).
    if acha("LIBERA-PRECO",parametro-out) <> ?
    then vlibera = yes.
    if acha("PRECO-ESPECIAL",parametro-out) <> ? and
       dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
    then vpreco = dec(acha("PRECO-ESPECIAL",parametro-out)).
end.
/***
/*** DESCONTO ITEM ***/
if wf-movim.movqtm = 1
/*then if search("/admcom/progr/promo-venda.p") <> ?
then*/ do:
    parametro-in = "DESCONTO-ITEM=S|PRODUTO=" +
                    string(produ.procod) + "|".
    run promo-venda.p(input parametro-in ,
                      output parametro-out).
end.
**/
**/

/*** CPG 
/*if search("/admcom/progr/promo-venda.p") <> ?
then*/ do:
    parametro-in = "LIBERA-PLANO=S|CASADINHA=S|GERA-CPG=S|"
                   + "PLANO=" + string(finan.fincod) + "|".
    run promo-venda.p(input parametro-in ,
                      output parametro-out).
    if acha("LIBERA-PLANO",parametro-out) <> ?
    then libera-plano = yes.
    if acha("DATA-ENTRADA",parametro-out) <> ?
    then p-dtentra = date(acha("DATA-ENTRADA",parametro-out)).
    if acha("DATA-PARCELA",parametro-out) <> ?
    then p-dtparcela = date(acha("DATA-PARCELA",parametro-out)).
end.
**/

/*** CASADINHA ***/ 
/*if search("/admcom/progr/promo-venda.p") <> ?
then*/ do:
    parametro-in = "CASADINHA=S|PLANO=" + string(finan.fincod) + "|"
                + "ALTERA-PRECO=N|".
    run promo-venda.p(input parametro-in,
                      output parametro-out).
    vpromocas = parametro-out.
end.
/**
if plani.usercod = ""
then**/
 do:                   
/*** DINHEIRO-NA-MAO ***/ 
parametro-out = "". 
/*if search("/admcom/progr/promo-venda.p") <> ?
then*/ do:
    parametro-in = "DINHEIRO-NA-MAO=S|PLANO=" + string(finan.fincod) + "|"
            + "ALTERA-PRECO=N|".
    run promo-venda.p(input parametro-in ,
                      output parametro-out).
    
end.
end.
setbcod = detbcod.                                      
def var vpromo as char.                
for each tt-valpromo.
    disp tt-valpromo.
end.    
for each tt-valpromo where tt-valpromo.tipo = 9 no-lock.
    vpromo = vpromo + string(tt-valpromo.forcod) + " ; ".
end.
/**if plani.usercod <> ""
then**/
 do:
    vpromo = vpromo + plani.usercod.
end. 
if vpromo <> ""
 then
message tt-movim.procod skip  vpromo skip
vpromocas skip
parametro-out view-as alert-box.

if vpromo <> "" then pause.    
end.
                                            
  
