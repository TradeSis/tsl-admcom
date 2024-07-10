{admcab.i}
{setbrw.i}

def var v-cod as int.
def var v-cont as int.

def shared temp-table tt-lj  like estab.

for each tt-lj:
    delete tt-lj.
end.
    
form
    a-seelst format "x" column-label "*"
    estab.etbcod
    estab.etbnom
    with frame f-nome
        centered down title "LOJAS"
        color withe/red.

def buffer bestab for estab.

assign 
    a-seeid = -1 a-recid = -1 a-seerec = ? a-seelst = "".
            
{sklcls.i
    &File   = estab
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = estab.etbnom    
    &Ofield = " estab.etbcod"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "estab.etbcod" 
    &PickFrm = "99999" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            if a-seelst <> "" ""
            then a-seelst = "" "".
            else
            for each bestab no-lock:
                a-seelst = a-seelst + "","" + string(bestab.etbcod,""99999"").
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.             
repeat :
    v-cod = 0.
    v-cod = int(substr(a-seelst,v-cont,5)).
    v-cont = v-cont + 6.
    if v-cod = 0
    then leave.
    create tt-lj.
    tt-lj.etbcod = v-cod.
end.

