{admcab.i}.
{setbrw.i}.

def input parameter p-procod like tabmix.promix.
def input parameter p-tipo like tabmix.tipomix.
def var v-cod as int.
def var v-cont as int.

def shared temp-table tt-mix 
    field marca as char
    field codmix like tabmix.codmix
    field descmix like tabmix.descmix
    index i1 descmix
    .

for each tt-mix:
    delete tt-mix.
end.
    
form
    a-seelst format "x" column-label "*"
    tt-mix.descmix   format "x(20)"
    tt-mix.codmix
    with frame f-nome
        centered down title "LOJAS"
        color withe/red overlay row 8.

def buffer btabmix for tabmix.

for each tabmix where tabmix.tipomix = "M" no-lock.
     if tabmix.codmix = 99
     then next.
     if p-procod > 0 and p-tipo = "P" and
        not can-find(first btabmix where
                        btabmix.codmix = tabmix.codmix and
                        btabmix.tipomix = p-tipo and
                        btabmix.promix = p-procod)
     then next.
                        
     create tt-mix.
     assign
         tt-mix.codmix = tabmix.codmix
         tt-mix.descmix = string(tabmix.descmix /*+ "    Fil:"*/).
         .
         /**
     for each btabmix where
              btabmix.codmix = tabmix.codmix and
              btabmix.tipomix = "F"          and
              btabmix.etbcod > 0
              no-lock.
        tt-mix.descmix = tt-mix.descmix + string(btabmix.etbcod,">>9") + ", ".
     end.   **/      
end.

assign 
    a-seeid = -1 a-recid = -1 a-seerec = ? a-seelst = "".
/*
if p-codmix > 0
then a-seelst = a-seelst + "," + string(p-codmix,"99999").
*/            
{sklcls.i
    &File   = tt-mix
    &help   = "         F4=Retorna ENTER=Marca/Desmarca F8=Marca/Desmarca Tudo"
    &CField = tt-mix.descmix    
    &Ofield = " tt-mix.codmix "
    &noncharacter = /*
    &Where  = " true
                use-index i1 no-lock
                "
    &UsePick = "*"          
    &PickFld = " tt-mix.codmix " 
    &PickFrm = "99999" 
    &NaoExiste1 = " bell.
        message ""Nenhum registro encontrato.""
                view-as alert-box.
        leave keys-loop.        
        "
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            if a-seelst <> "" ""
            then a-seelst = "" "".
            else
            for each tt-mix no-lock:
                a-seelst = a-seelst + "","" + string(tt-mix.codmix,""99999"").
                v-cont = v-cont + 1.
            end.
            
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
    find first tt-mix where tt-mix.codmix = v-cod no-error.
    tt-mix.marca = "*".
end.
for each tt-mix where tt-mix.marca = "":
delete tt-mix.
end.


