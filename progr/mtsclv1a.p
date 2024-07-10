{admcab.i new}.

def new shared      var vdti        as date format "99/99/9999" no-undo.
def new shared      var vdtf        as date format "99/99/9999" no-undo.
def new shared var p-loja      like estab.etbcod.

assign vdti  = 04/10/2007
       vdtf  = 04/15/2007
       p-loja = 8.

def new shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def new shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
 
run mtsvnd1a.p (input 0).


for each ttvend no-lock:

  disp ttvend.

end.
