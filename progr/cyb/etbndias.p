/* cyber/etbndias.p
CYBER_REGRA_NDIAS
*/

{admcab.i}
{setbrw.i}

def var par-parametro  like tab_ini.parametro init "CYBER_REGRA_NDIAS".

def var vopcao as log format "Sim/Nao" label "Estab Participa N Dias".
def var vmenu as log init yes.
def temp-table tt-codigo
    field parametro    like tab_ini.parametro format "x(30)"
    
    index parametro parametro.

form tt-codigo.parametro
     with frame f-linha down centered row 04 
        title " Codigos " color withe/brown.

for each tt-codigo.
    delete tt-codigo.
end.

if par-parametro = "Menu"
then do.
    par-parametro = "".
    vmenu = no.

    create tt-codigo.
    assign
        tt-codigo.parametro    = "_TODOS".
    for each tab_ini no-lock.
        find tt-codigo where tt-codigo.parametro = tab_ini.parametro
                       no-lock no-error.
        if not avail tt-codigo
        then do.
            create tt-codigo.
            tt-codigo.parametro = tab_ini.parametro.
        end.
    end.

    {sklcls.i
            &file         = tt-codigo
            &cfield       = tt-codigo.parametro
            &noncharacter = /* 
            &ofield       = "tt-codigo.parametro" 
            &where        = "true"
            &color        = with
            &color1       = brown
            &locktype     = "no-lock" 
            &naoexiste1   = "message ""Nenhum ocorrencia Cadastrada""
                                     view-as alert-box.
                            leave."
            &aftselect1   = "
                    if keyfunction(lastkey) = ""return""
                    then do:
                        if tt-codigo.parametro <> ""_TODOS""
                        then par-parametro = tt-codigo.parametro.
                        leave keys-loop.
                    end.    
                    else next keys-loop."
            &form         = " frame f-linha " } 
end.

/*

*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Inclusao "," Alteracao ","","",""].

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tab_ini where recid(tab_ini) = recatu1 no-lock.
    if not available tab_ini
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tab_ini).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tab_ini
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tab_ini where recid(tab_ini) = recatu1 no-lock.

            status default "".

            choose field tab_ini.parametro help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
        end.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tab_ini
                    then leave.
                    recatu1 = recid(tab_ini).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tab_ini
                    then leave.
                    recatu1 = recid(tab_ini).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tab_ini
                then next.
                color display white/red tab_ini.parametro with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tab_ini
                then next.
                color display white/red tab_ini.parametro with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form
                tab_ini.etbcod colon 30 label "Estabelecimento"
                estab.etbnom        no-label
                tab_ini.valor  colon 30 format "x(2)"
                with frame f-tab_ini color black/cyan
                      centered side-label row 10 .
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-tab_ini on error undo.
                create tab_ini.
                assign tab_ini.parametro = par-parametro
                       tab_ini.dtinclu = today.
                update tab_ini.etbcod.
                 
                vopcao = tab_ini.valor = "SIM".
                update vopcao colon 30.
                if vopcao
                then tab_ini.valor = "SIM".
                else tab_ini.valor = "NAO".
                recatu1 = recid(tab_ini).
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do  with frame f-tab_ini.
                find tab_ini where recid(tab_ini) = recatu1.
                update tab_ini.etbcod.
                vopcao = tab_ini.valor = "SIM".
                update vopcao colon 30.
                if vopcao
                then tab_ini.valor = "SIM".
                else tab_ini.valor = "NAO".
            end.
            if esqcom1[esqpos1] = "Copia tab_ini"
            then run copia.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tab_ini).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-sub   no-pause.

procedure frame-a.
    display
        tab_ini.etbcod    column-label "Etb"
        tab_ini.parametro format "x(25)"
        tab_ini.valor     format "x(15)"
        with frame frame-a 12 down centered color white/red row 10 no-box.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tab_ini where (if par-parametro = ""
                                       then true
                                       else tab_ini.parametro = par-parametro)
                                no-lock no-error.
    else  
        find last tab_ini  where (if par-parametro = ""
                                       then true
                                       else tab_ini.parametro = par-parametro)
                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tab_ini  where (if par-parametro = ""
                                       then true
                                       else tab_ini.parametro = par-parametro)
                                no-lock no-error.
    else  
        find prev tab_ini  where (if par-parametro = ""
                                       then true
                                       else tab_ini.parametro = par-parametro)
                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tab_ini  where (if par-parametro = ""
                                       then true
                                       else tab_ini.parametro = par-parametro)
                                        no-lock no-error.
    else   
        find next tab_ini  where (if par-parametro = ""
                                       then true
                                       else tab_ini.parametro = par-parametro)
                                        no-lock no-error.
end procedure.

