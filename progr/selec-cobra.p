
{setbrw.i}

def temp-table tt-carteira-padrao
    field cobcod as int format ">>9"
    field cobnom like cobra.cobnom.
 
def SHARED temp-table tt-carteira-selec
    field cobcod  as int format ">>9".

def var vcobcod as char.
def var v-cont  as integer.
def var v-cod   as int.

form
   a-seelst format "x" column-label "*"
   tt-carteira-padrao.cobcod no-label
   tt-carteira-padrao.cobnom no-label
   with frame f-nome centered down title "carteiras"
       color withe/red overlay.     

for each cobra where cobra.cobcod  = 1 or cobra.cobcod  = 2 or cobra.cobcod  = 10 or cobra.cobcod  = 14 or cobra.cobcod  = 16
        no-lock.
    create tt-carteira-padrao.
    tt-carteira-padrao.cobcod = cobra.cobcod.
    tt-carteira-padrao.cobnom = cobra.cobnom.

end.
            
{sklcls.i
    &File   = tt-carteira-padrao
    &help   = "                ENTER=Marca F1=Retorna F8=Marca Tudo"
    &CField = tt-carteira-padrao.cobcod    
    &Ofield = " tt-carteira-padrao.cobcod tt-carteira-padrao.cobnom"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-carteira-padrao.cobcod" 
    &PickFrm = ">>9" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            a-seelst = """".
            for each tt-carteira-padrao no-lock:
                a-seelst = a-seelst + "","" + string(tt-carteira-padrao.cobcod).
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""carteiraS                               "".
            a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end."
    &Form = " frame f-nome" 
}

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = 0.
    if num-entries(a-seelst) >= v-cont
    then v-cod = int(entry(v-cont,a-seelst)).

    v-cont = v-cont + 1.
    if v-cod = 0
    then leave.
    create tt-carteira-selec.
    assign tt-carteira-selec.cobcod = int(v-cod).
end.


