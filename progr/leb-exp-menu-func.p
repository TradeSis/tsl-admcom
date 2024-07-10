/********************************************************
 Programa: leb-exp-menu-func.p
 Autor: Rafael A (Kbase IT)
 Descricao: Menu do extrator de funcionarios
 Historico: 25/05/2015 - Rafael A (Kbase IT) - Criacao
********************************************************/

def output param varq as char no-undo.

def var recatu1 as recid no-undo.

def var vdtini as date no-undo label "Ini".
def var vdtfin as date no-undo label "Fin".

def temp-table tt-cadMenuFunc
    field id    as int
    field nome  as char
    field sel   as log
    field ativo as log.

def buffer bf-tt-cadMenuFunc for tt-cadMenuFunc.

create tt-cadMenuFunc.
assign tt-cadMenuFunc.id    = 1
       tt-cadMenuFunc.nome  = "Gerente"
       tt-cadMenuFunc.sel   = no
       tt-cadMenuFunc.ativo = yes.

create tt-cadMenuFunc.
assign tt-cadMenuFunc.id    = 2
       tt-cadMenuFunc.nome  = "Vend. Moda"
       tt-cadMenuFunc.sel   = no
       tt-cadMenuFunc.ativo = yes.

create tt-cadMenuFunc.
assign tt-cadMenuFunc.id    = 3
       tt-cadMenuFunc.nome  = "Vend. Moveis"
       tt-cadMenuFunc.sel   = no
       tt-cadMenuFunc.ativo = yes.

message "[Enter]=Selecionar  [F4]=Executar Extracao".

bl-princ:
repeat:

    if recatu1 = ? then
        run leitura(input "pri").
    else
        find tt-cadMenuFunc
             where recid(tt-cadMenuFunc) = recatu1 no-lock no-error.

    if not avail tt-cadMenuFunc then
        leave.

    clear frame frame-a all no-pause.

    run frame-a.

    recatu1 = recid(tt-cadMenuFunc).
    repeat:
        run leitura (input "seg").
        if not avail tt-cadMenuFunc then
            leave.

        if frame-line(frame-a) = frame-down(frame-a) then
            leave.

        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        find first tt-cadMenuFunc
             where recid(tt-cadMenuFunc) = recatu1 no-lock no-error.

        color display message
            tt-cadMenuFunc.sel
            tt-cadMenuFunc.nome
            with frame frame-a.

        choose field tt-cadMenuFunc.sel
            go-on(cursor-down cursor-up PF4 F4 ESC return).

        color display normal
            tt-cadMenuFunc.sel
            tt-cadMenuFunc.nome
            with frame frame-a.

        if keyfunction(lastkey) = "cursor-down" then do:
            run leitura (input "down").
            if not avail tt-cadMenuFunc then
                next.

            color display white/red tt-cadMenuFunc.sel with frame frame-a.

            if frame-line(frame-a) = frame-down(frame-a) then
                scroll with frame frame-a.
            else
                down with frame frame-a.
        end.

        if keyfunction(lastkey) = "cursor-up" then do:
            run leitura (input "up").
            if not avail tt-cadMenuFunc then
                next.

            color display white/red tt-cadMenuFunc.sel with frame frame-a.

            if frame-line(frame-a) = 1 then
                scroll down with frame frame-a.
            else
                up with frame frame-a.
        end.

        if keyfunction(lastkey) = "end-error" then do:
            
            if can-find(first bf-tt-cadMenuFunc
                        where bf-tt-cadMenuFunc.sel = yes) then do:
                
                if can-find(first bf-tt-cadMenuFunc
                            where bf-tt-cadMenuFunc.nome <> "Gerente"
                              and bf-tt-cadMenuFunc.sel = yes) then
                do on error undo:
                    hide frame frame-a no-pause.
            
                    update vdtini format "99/99/9999"
                           vdtfin format "99/99/9999"
                           with
                           frame frame-b
                           centered color white/red row 8
                           side-label
                           title "Periodo"
                           .
                           
                    if vdtfin - vdtini > 60 then do:
                        message color red/with
                            "Informe periodo maximo de 60 dias."
                            view-as alert-box.
                        undo.
                    end.
                end.                
            
                message "Exportando funcionarios, aguarde...".
                run leb-exp-funcionarios.p(output varq, 
                                           input table tt-cadMenuFunc,
                                           input vdtini,
                                           input vdtfin).
            
            end.
            
            leave bl-princ.
        end.
       
        if keyfunction(lastkey) = "return" then do:
            if tt-cadMenuFunc.sel then
                assign tt-cadMenuFunc.sel = no.
            else
                assign tt-cadMenuFunc.sel = yes.
        end.

        run frame-a.
        recatu1 = recid(tt-cadMenuFunc).
    end.

    if keyfunction(lastkey) = "end-error" then do:
        view frame fc1.
        view frame fc2.
    end.

    if keylabel(lastkey) = "F4" then do:
        leave bl-princ.
    end.
end.
hide frame frame-a no-pause.

procedure frame-a:
    disp tt-cadMenuFunc.sel format " *"
         tt-cadMenuFunc.nome format "x(15)"
         with frame frame-a 3 down centered color white/red row 4 no-label
         title " EXPORTAR ".
end procedure.

procedure leitura:

    def input param p-tipo as char.
    
    if p-tipo = "pri" then
        find first tt-cadMenuFunc where tt-cadMenuFunc.ativo no-lock no-error.

    if p-tipo = "seg" or p-tipo = "down" then
        find next tt-cadMenuFunc where tt-cadMenuFunc.ativo no-lock no-error.
            
    if p-tipo = "up" then
        find prev tt-cadMenuFunc where tt-cadMenuFunc.ativo no-lock no-error.
end procedure.

