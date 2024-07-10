{admcab.i}
{setbrw.i} 
def input parameter p-etbcod like estab.etbcod.
find estab where estab.etbcod = p-etbcod no-lock.
def var vtabela as char.

form tabaux.nome_campo   column-label "UF"    format "!!"
     help "               I=inclui  A=altera  E=exclui"
     unfed.ufenom no-label
     tabaux.valor_campo  column-label "IE ST" format "x(20)"
     with frame f-lin down centered row 8
     title " IE ST ESTAB " + string(p-etbcod,"999").

def temp-table tt-tabaux like tabaux.

def var vsenha as char label "Senha".
vsenha = "".
                update vsenha blank with frame f-senh 
                            side-label centered row 10.
                if vsenha  <> "1951"
                then do:
                    message "Senha Invalido.".
                    undo, retry.
                end.
     
run ie-st(estab.etbcod).
 
procedure ie-st:
    def input parameter p-etbcod like estab.etbcod.
    vtabela = "ESTAB" + string(p-etbcod,"999") + "IEST".

    l1: repeat:
    hide frame f-lin no-pause.
    clear frame f-lin all.
    a-seeid = -1.
    {sklclstb.i  
        &color  = with/cyan
        &file   = tabaux  
        &cfield = tabaux.nome_campo
        &noncharacter = /* 
        &ofield = " unfed.ufenom when avail unfed
                    tabaux.valor_campo "  
        &aftfnd1 = " find unfed where
                          unfed.ufecod = tabaux.nome_campo no-lock
                          no-error.
        "
        &where  = " tabaux.tabela = vtabela "
        &aftselect1 = " " 
        &go-on = TAB e a i
        &naoexiste1 = " 
                run inclui.  
                if keyfunction(lastkey) = ""END-ERROR""
                then do:
                    leave keys-loop.
                end.
                else next l1.
                " 
        &otherkeys1 = " 
                        run other-keys(a-seerec[frame-line]).
                        next l1. "
        &locktype = " no-lock "
        &form   = " frame f-lin "
    } 
    if keyfunction(lastkey) = "END-ERROR"
    then leave l1. 
    end.
end procedure.

procedure inclui:
        prompt-for
            tabaux.nome_campo
            with frame f-lin.
        find unfed where 
                unfed.ufecod = input frame f-lin tabaux.nome_campo
                no-lock.
        disp unfed.ufenom with frame f-lin.
        prompt-for tabaux.valor_campo
                with frame f-lin.
        run val-ie.p(unfed.ufecod, 
            input frame f-lin tabaux.valor_campo, output sresp).
        if sresp = no
        then do:
            message "IE incorreta.". pause.
        end.    
        if input frame f-lin tabaux.valor_campo <> "" and sresp
        then do on error undo:
            create tabaux.
            assign
                tabaux.tabela = vtabela
                tabaux.nome_campo = input frame f-lin tabaux.nome_campo
                tabaux.valor_campo = input frame f-lin tabaux.valor_campo
                .
        end.
end procedure.
procedure other-keys:
    def input parameter p-recid as recid.
    if keyfunction(lastkey) = "a"
    then do:
        find tabaux where recid(tabaux) = p-recid exclusive no-error.
        if avail tabaux
        then do on error undo:
        update tabaux.valor_campo with frame f-lin.
        run val-ie.p(tabaux.nome_campo, tabaux.valor_campo, output sresp).
        if not sresp 
        then do:
            message "IE incorreta.". pause.
            undo.
        end.    
        end.
    end.
    else
    if keyfunction(lastkey) = "i"
    then do:
        scroll from-current down with frame f-lin.
        prompt-for
            tabaux.nome_campo
            with frame f-lin.
        find unfed where 
                unfed.ufecod = input frame f-lin tabaux.nome_campo
                no-lock.
        disp unfed.ufenom with frame f-lin.
        prompt-for tabaux.valor_campo
                with frame f-lin.
        run val-ie.p(unfed.ufecod, 
            input frame f-lin tabaux.valor_campo, output sresp).
        if sresp = no
        then do:
            message "IE incorreta.". pause.
        end.    
        if input frame f-lin tabaux.valor_campo <> "" and sresp
        then do on error undo:
            create tabaux.
            assign
                tabaux.tabela = vtabela
                tabaux.nome_campo = input frame f-lin tabaux.nome_campo
                tabaux.valor_campo = input frame f-lin tabaux.valor_campo
                .
        end.
    end.
    else 
    if keyfunction(lastkey) = "e"
    then do:
        sresp = no.
        message "Confirma excluir registro?" update sresp.
        if sresp
        then do:
            find tabaux where recid(tabaux) = p-recid exclusive no-error.
            if avail tabaux
            then delete tabaux.
            release tabaux.
        end.     
    end.
    return.
end procedure.
