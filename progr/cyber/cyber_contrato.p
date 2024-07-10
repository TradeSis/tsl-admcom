/* cyber/cyber_contrato.p                            */
{admcab.i}

def input parameter par-rec as recid.

def var vchave_contrato     as char.

find cyber_clien where recid(cyber_clien) = par-rec no-lock.
find clien of cyber_clien no-lock.    
find last cyber_clien_h of cyber_clien no-lock no-error.
display cyber_clien.clicod   label "Cliente"
        clien.clinom    no-label
        clien.ciccgc    no-label
        with frame frame-vab side-label
                row 3 color message width 81 no-box.

if avail cyber_clien_h
then disp
        cyber_clien_h.DtEnvio   label "Ult.Envio"
        string(cyber_clien_h.hrEnvio,"HH:MM") no-label
        with frame frame-vab.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Parcelas ","Consulta Contrato"," Historico ", " Simula ",
             " Consulta "].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cyber_contrato where recid(cyber_contrato) = recatu1 no-lock.
    if not available cyber_contrato
    then do.
        message "Sem contratos para o cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cyber_contrato).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cyber_contrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cyber_contrato where recid(cyber_contrato) = recatu1 no-lock.
        run cyber/chave_contrato.p (input  recid(cyber_contrato),
                                output vchave_contrato).
        disp vchave_contrato format "x(15)"
             with frame f-sub no-label row screen-lines no-box.

            status default "".
            run color-message.
            choose field cyber_contrato.contnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail cyber_contrato
                    then leave.
                    recatu1 = recid(cyber_contrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cyber_contrato
                    then leave.
                    recatu1 = recid(cyber_contrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cyber_contrato
                then next.
                color display white/red cyber_contrato.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cyber_contrato
                then next.
                color display white/red cyber_contrato.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form cyber_contrato
                 with frame f-cyber_contrato color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Parcelas "
                then do with frame f-cyber_clien.
                    hide frame f-com1  no-pause.
                    run cyber/cyber_parcela.p (recid(cyber_contrato)).
                    view frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Consulta Contrato"
                then do with frame fsss-cyber_clien.
                    find contrato of cyber_contrato no-lock no-error.
                    if not avail contrato
                    then do.
                        message "Contrato nao encontrado" view-as alert-box.
                        leave.
                    end.
                    find first contnf where contnf.etbcod  = contrato.etbcod
                                        and contnf.contnum = contrato.contnum 
                                        no-error.
                    if avail contnf
                    then do.
                        find first plani where plani.placod = contnf.placod and
                                               plani.etbcod = contnf.etbcod
                                               no-lock no-error.
                        if avail plani
                        then do.
                            hide frame f-com1  no-pause.
                            run notcofat.p (input recid(plani)).
                            view frame f-com1.
                        end.
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = " Historico "
                then do:
                    hide frame f-com1  no-pause.
                    run cyber/cyber_contrato_h.p (recid(cyber_contrato)).
                    view frame f-com1.
                end.
            if esqcom1[esqpos1] = " Consulta "
            then do.
                hide frame frame-a.
                disp cyber_contrato with frame f-cyber_contrato 1 col row 7.
                pause.
                hide frame f-cyber_contrato no-pause.
            end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cyber_contrato).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

find last cyber_contrato_h of cyber_contrato no-lock.
/***
find first cyber_parcela of cyber_contrato where cyber_parcela.regra no-lock
                    no-error.
***/
display cyber_contrato.etbcod
        cyber_contrato.contnum format ">>>>>>>>>>>>"
        cyber_contrato.dtinicial  label "Data Emissao"
        cyber_contrato_h.DtEnvio
        string(cyber_contrato_h.hrEnvio,"HH:MM") no-label format "x(5)"
        cyber_contrato.situacao
        cyber_contrato.banco
        with frame frame-a 9 down centered color white/red row 6
                title " Contrato ".
end procedure.

procedure color-message.
color display message
        cyber_contrato.contnum
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        cyber_contrato.contnum
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first cyber_contrato where cyber_contrato.clicod = cyber_clien.clicod                    no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next cyber_contrato  where cyber_contrato.clicod = cyber_clien.clicod
                   no-lock no-error.
             
if par-tipo = "up" 
then find prev cyber_contrato where cyber_contrato.clicod = cyber_clien.clicod
                   no-lock no-error.
        
end procedure.

procedure simula.




end procedure.
