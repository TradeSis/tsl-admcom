{admcab.i}     
/*
sresp = no.
message color red/with
  "CLIENTE MANIFESTOU INTENCAO DE COMPRA ?" UPDATE SRESP.

if not sresp then return.
*/
def var vclicod like clien.clicod.
def var vclacod like clase.clacod.
def var vdata as date.
def var mes-ano as char.
def var mes-int as int.    
def var ano-int as int.
def var vven-cod as int.


def shared temp-table tt-intven
    field etbcod like estab.etbcod
    field clacod like clase.clacod
    field clicod like clien.clicod
    field peddat like pedid.peddat
    field peddti like pedid.peddti
    field qtdint like liped.lipqtd
    field vencod like pedid.vencod
    index i1 etbcod clacod clicod peddti.
                                

def shared temp-table tt-intaux
    field etbcod like estab.etbcod
    field clacod like clase.clacod
    field clicod like clien.clicod
    field peddat like pedid.peddat
    field peddti like pedid.peddti
    field qtdint like liped.lipqtd
    field vencod like pedid.vencod
    .
                                
def shared var qtd-sel as int.
def shared var qtd-tot as int.


/* vclicod = plani.desti.  */
form   vclicod at 1          label "Conta  do Cliente "
       clien.clinom no-label
       vclacod at 1          label "Classe do produto "
       clase.clanom no-label
       vven-cod at 1         label "Codigo do Vendedor"     format ">>>>9"
       vdata   at 1          label "Data  da inclusao " format "99/99/9999"
       mes-ano at 1          label "Intencao  Mes/Ano " format "xx/xxxx"
       with frame f1 1 down side-label width 80
       title " Intencao de compra ". 
  
do on error undo, retry:
update vclicod with frame f1.
if vclicod < 2
then do:
    bell.
        message color red/with
                "Obrigatorio informar a Conta do Cliente."
                        view-as alert-box
                                .
   undo, retry.
end.   
find clien where clien.clicod = vclicod no-lock no-error.
if not avail clien
then do:
    bell.
    message color red/with
        "Cliente nao cadastrado."
        view-as alert-box
        .
    undo, retry.
end.  
update vclacod with frame f1.
if vclacod = 0
then do:
    bell.
    message color red/with
        "Obrigatorio informar a Classe do Produto."
        view-as alert-box
        .
    undo, retry.
end.      
find clase where clase.clacod = vclacod no-lock no-error.
if not avail clase
then do:
    bell.
    message color red/with
        "Classe nao cadastrada."
        view-as alert-box
        .
    undo, retry.
end.
disp clase.clanom with frame f1.

update vven-cod with frame f1.
if vven-cod <= 0
then do:

    bell.
    message color red/with
    "Obrigatorio informar o Codigo do Vendedor."
          view-as alert-box.
    undo, retry.

end.
else do:

    find first vende where vende.vencod = vven-cod no-lock no-error.
    if not avail clien
    then do:
        bell.
        message color red/with
        "Vendedor nao cadastrado."
            view-as alert-box.
        undo, retry.
    end.
end.
vdata = today.
disp vdata with frame f1.
update mes-ano with frame f1.
if mes-ano = ""
then do:
    bell.
    message color red/with
        "Obrigatorio informar o Mes e Ano da intencao de compra."
        view-as alert-box
        .
    undo, retry .
end.
mes-int = int(substr(string(mes-ano),1,2)).
ano-int = int(substr(string(mes-ano),3,4)).
if mes-int = 0
then do:
    bell.
    message color red/with
        "Obrigatorio informar o Mes e Ano da intencao de compra."
        view-as alert-box
        .
    undo, retry.
end.
if ano-int = 0 
then do:
    bell.
    message color red/with
        "Obrigatorio informar o Mes e Ano da intencao de compra."
        view-as alert-box
        .
    undo, retry.
end.
if  ano-int <> year(today) and
    (12 - month(today) + mes-int) > 12
then do:
    bell.
    message color red/with
        "Maximo permitido ate 12 meses."
        view-as alert-box
        .
    undo, retry.
end.
end.

def buffer bpedid for pedid.
def var vpednum like pedid.pednum.
find last bpedid where bpedid.etbcod = setbcod and
                       bpedid.pedtdc = 21 no-error.
if avail bpedid 
then vpednum = int(substr(string(bpedid.pednum,">>>>>>>9"),1,5)) + 1. 
else vpednum = 1. 

vpednum = int(string(vpednum) + string(setbcod,"999")).
        
create pedid.  
assign pedid.pedtdc    = 21  
       pedid.pednum    = vpednum  
       pedid.regcod    = 0  
       pedid.peddat    = vdata
       pedid.pedsit    = yes  
       pedid.sitped    = "F"  
       pedid.modcod    = "PED"  
       pedid.condes    = 0
       pedid.etbcod    = setbcod  
       pedid.clfcod    = vclicod 
       pedid.vencod    = vven-cod  
     /*  pedid.frecod    = plani.numero   
       pedid.condat    = plani.pladat
    */   pedid.peddti    = date("01" + string(mes-int,"99") +
                                     string(ano-int,"9999"))
               .
create liped.  
assign 
    liped.procod = vclacod
    liped.pednum = pedid.pednum 
    liped.pedtdc = pedid.pedtdc  
    liped.predt  = pedid.peddat 
    liped.etbcod = pedid.etbcod  
    liped.lipqtd = 0
    liped.lipcor = ""
    liped.protip = ""
    liped.lipsit = "F"
    .
    
create tt-intven.
assign
    tt-intven.etbcod = pedid.etbcod
    tt-intven.clacod = liped.procod
    tt-intven.clicod = pedid.clfcod
    tt-intven.peddti = pedid.peddti
    tt-intven.vencod = pedid.vencod
    tt-intven.peddat = pedid.peddat
    tt-intven.qtdint = tt-intven.qtdint + 1
    .

create tt-intaux.
buffer-copy tt-intven to tt-intaux.
qtd-sel = qtd-sel + 1.
qtd-tot = qtd-tot + 1.
                
                
hide frame f1 no-pause.


