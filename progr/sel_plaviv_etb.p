{admcab.i}
{setbrw.i}

def input parameter par-tipviv as integer.
def input parameter par-codviv as integer.
def input parameter par-procod as integer.

def var v-cod as int.
def var v-cont as int.

def shared temp-table tt-lj  like estab.

def temp-table tt-lj-anterior like tt-lj.

form
    a-seelst format "x" column-label "*"
    estab.etbcod
    estab.etbnom
    with frame f-nome
        centered down title "LOJAS"
        color withe/red overlay.

def buffer bestab for estab.

assign 
    a-seeid = -1 a-recid = -1 a-seerec = ? a-seelst = "".

empty temp-table tt-lj.
empty temp-table tt-lj-anterior.

for each plaviv_filial where plaviv_filial.tipviv = par-tipviv 
                         and plaviv_filial.codviv = par-codviv 
                         and plaviv_filial.procod = par-procod no-lock.
    create tt-lj.
    assign tt-lj.etbcod = plaviv_filial.etbcod.

    create tt-lj-anterior.
    assign tt-lj-anterior.etbcod = tt-lj.etbcod.
            
    assign a-seelst = a-seelst + "," + string(tt-lj.etbcod,"99999").
end.
            
{sklcls.i
    &File   = estab
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = estab.etbnom    
    &Ofield = " estab.etbcod"
    &Where  = "estab.tipo = ""LJ"" "
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "estab.etbcod" 
    &PickFrm = "99999" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each bestab where estab.tipo = ""LJ""
                               no-lock:
                a-seelst = a-seelst + "","" + string(bestab.etbcod,""99999"").
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   "".
            a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 
 
hide frame f-nome.
empty temp-table tt-lj.
do v-cont = 2 to num-entries(a-seelst).
    v-cod = int(entry(v-cont, a-seelst)).
    if v-cod > 0
    then do.
        create tt-lj.
        tt-lj.etbcod = v-cod.
    end.
end.

for each tt-lj no-lock.
    find first plaviv_filial
         where plaviv_filial.tipviv = par-tipviv
           and plaviv_filial.codviv = par-codviv
           and plaviv_filial.procod = par-procod
           and plaviv_filial.etbcod = tt-lj.etbcod
         no-lock no-error.
    if not avail plaviv_filial
    then do:
        create plaviv_filial.
        assign plaviv_filial.tipviv = par-tipviv
               plaviv_filial.codviv = par-codviv
               plaviv_filial.procod = par-procod
               plaviv_filial.etbcod = tt-lj.etbcod.
    end.
end.

for each tt-lj-anterior no-lock.
    find first tt-lj where tt-lj.etbcod = tt-lj-anterior.etbcod
                no-lock no-error.
    if avail tt-lj then next.
    
    run p-deleta-plaviv-filial(input par-tipviv,
                               input par-codviv,
                               input par-procod,
                               input tt-lj-anterior.etbcod).
end.


procedure p-deleta-plaviv-filial:

    def input parameter p-del-tipviv as integer.
    def input parameter p-del-codviv as integer.
    def input parameter p-del-procod as integer.
    def input parameter p-del-etbcod as integer.

   find first plaviv_filial
        where plaviv_filial.tipviv = p-del-tipviv
          and plaviv_filial.codviv = p-del-codviv
          and plaviv_filial.procod = p-del-procod
          and plaviv_filial.etbcod = p-del-etbcod  exclusive-lock no-error.

    if avail plaviv_filial
    then delete plaviv_filial.

end procedure.

