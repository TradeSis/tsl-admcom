def input parameter par-modal as char.

{setbrw.i}

def temp-table tt-modalidade-padrao
    field modcod as char
    field modnom like modal.modnom.
 
def SHARED temp-table tt-modalidade-selec
    field modcod as char.

def var vmodais as char.
def var vmodcod as char.
def var v-cont  as integer.
def var v-cod   as char.

form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   tt-modalidade-padrao.modnom no-label
   with frame f-nome centered down title "Modalidades"
       color withe/red overlay.     

run le_tabini.p (0, 0, "Filtro-Modal-" + par-modal, OUTPUT vmodais).

do v-cont = 1 to num-entries(vmodais).
/*
    for each modal where modal.filtro = par-modal no-lock.
*/
    vmodcod = entry(v-cont, vmodais).
    find modal where modcod = vmodcod no-lock.
    create tt-modalidade-padrao.
    tt-modalidade-padrao.modcod = modal.modcod.
    tt-modalidade-padrao.modnom = modal.modnom.
end.
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F1=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod tt-modalidade-padrao.modnom"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            a-seelst = """".
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""MODALIDADES                               "".
            a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end."
    &Form = " frame f-nome" 
}

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


/*** Versao antiga
{setbrw.i}

create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.        
end.


    assign sresp = false.
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label width 80 frame f1.              
    if sresp
    then do:
        bl_sel_filiais:
        repeat:                      
            run p-seleciona-modal.
            if keyfunction(lastkey) = "end-error"
            then do: 
                pause.
                leave bl_sel_filiais.
             end.   
        end.
    end.
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end. 



procedure p-seleciona-modal:

def var v-cont as integer.
def var v-cod as char.
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = / *  <<<<====
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
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
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.


***/
