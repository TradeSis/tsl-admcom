{admcab-palm.i}.
{anset.i}.

def input parameter vfabcod like fabri.fabcod.
def var v-data-aux1 as date format "99/99/9999".
def buffer sclase for clase.
def var v-totcom    as dec.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok as logical.
def var vquant like movim.movqtm.
def var flgetb      as log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var vetbcod     like plani.etbcod           no-undo.
def var v-totger    as dec.
def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.
def var p-vende     like func.funcod.
def shared var p-loja      like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-perdev    as dec label "% Dev" format ">9.99".

def shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    

def shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

vetbcod = p-loja.

find first ttvend where  ttvend.etbcod = vetbcod no-error.
if not avail ttvend
then do :
     {calcvvvv.i}.
end.    
hide frame f-opcao .
hide frame f-mostr2.
find first ttvend where ttvend.etbcod = p-loja no-error.
if not avail ttvend
then do:
    bell.
    message color red/with
        "Nenhum Registro Encontrado"
        view-as alert-box title " Mensagem ".
end.  
else  
run convgen9.p ( input p-loja ) .
