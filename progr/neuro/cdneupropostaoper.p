/*
*
*    neupropostaoper.p    -    Esqueleto de Programacao
*    Projeto Motor - Agosto/2018
*/
{admcab.i}

def input parameter par-rec as recid.

def var vhora as char.

find neuproposta where recid(neuproposta) = par-rec no-lock.
disp neuproposta.etbcod
     neuproposta.neu_cdoperacao
     neuproposta.dtinclu
     with frame f-cpf row 8 no-box side-label color message.

FORM
    NeuPropostaOper.HrInclu
    NeuPropostaOper.Seq
    NeuPropostaOper.ret_cdoperacao
    NeuPropostaOper.CxaCod
    NeuPropostaOper.TipoConsulta
    NeuPropostaOper.neu_resultado
    NeuPropostaOper.VctoLimite
    NeuPropostaOper.VlrLimite
    with frame frame-a 06 down centered row 10.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," Consulta "," ",""].
def var esqhel1         as char format "x(80)" extent 5.

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels side-labels column 1 centered.
/* screen-lines */
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find neupropostaoper where recid(neupropostaoper) = recatu1 no-lock.
    if not available neupropostaoper
    then do.
        message "Sem registros para este cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(neupropostaoper).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available neupropostaoper
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find neupropostaoper where recid(neupropostaoper) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(neupropostaoper.seq)
                                        else "".
            run color-message.
            choose field neupropostaoper.seq help ""
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
                    if not avail neupropostaoper
                    then leave.
                    recatu1 = recid(neupropostaoper).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail neupropostaoper
                    then leave.
                    recatu1 = recid(neupropostaoper).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail neupropostaoper
                then next.
                color display white/red neupropostaoper.seq with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail neupropostaoper
                then next.
                color display white/red neupropostaoper.seq with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form neupropostaoper except etbcod RetProps
                 with frame f-neupropostaoper color black/cyan
                      centered row 10 side-labels 2 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-neupropostaoper.
                    disp neupropostaoper except etbcod RetProps.
                    disp string(neupropostaoper.hrincl, "hh:mm:ss") @
                         neupropostaoper.hrincl
                        neupropostaoper.NeuProps format "x(62)"
                        substr(neupropostaoper.NeuProps,63,62) format "x(62)"

                        neupropostaoper.RetProps format "x(62)"
                        substr(neupropostaoper.RetProps,63,62) format "x(62)".
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(neupropostaoper).
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
    vhora = string(neupropostaoper.hrinclu, "hh:mm:ss").
    display 
        vhora @ NeuPropostaOper.HrInclu
        NeuPropostaOper.Seq
        NeuPropostaOper.ret_cdoperacao
        NeuPropostaOper.CxaCod
        NeuPropostaOper.TipoConsulta
        NeuPropostaOper.neu_resultado
        NeuPropostaOper.VctoLimite
        NeuPropostaOper.VlrLimite
        with frame  frame-a.
        
    disp vhora @ neupropostaoper.hrincl with frame frame-a.
end procedure.


procedure color-message.
    color display message
        neupropostaoper.seq
        neupropostaoper.hrinclu
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        neupropostaoper.seq
        neupropostaoper.hrinclu
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first neupropostaoper
                            where neupropostaoper.EtbCod  = neuproposta.EtbCod
                              and neupropostaoper.CxaCod  = neuproposta.CxaCod
                              and neupropostaoper.DtInclu = neuproposta.DtInclu
                              and neupropostaoper.CpfCnpj = neuproposta.CpfCnpj
                              and neupropostaoper.neu_cdoperacao = 
                                                  neuproposta.neu_cdoperacao
                            no-lock no-error.
    else find last neupropostaoper
                            where neupropostaoper.EtbCod  = neuproposta.EtbCod
                              and neupropostaoper.CxaCod  = neuproposta.CxaCod
                              and neupropostaoper.DtInclu = neuproposta.DtInclu
                              and neupropostaoper.CpfCnpj = neuproposta.CpfCnpj
                              and neupropostaoper.neu_cdoperacao = 
                                                  neuproposta.neu_cdoperacao
                            no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next neupropostaoper
                            where neupropostaoper.EtbCod  = neuproposta.EtbCod
                              and neupropostaoper.CxaCod  = neuproposta.CxaCod
                              and neupropostaoper.DtInclu = neuproposta.DtInclu
                              and neupropostaoper.CpfCnpj = neuproposta.CpfCnpj
                              and neupropostaoper.neu_cdoperacao = 
                                                  neuproposta.neu_cdoperacao
                            no-lock no-error.
    else find prev neupropostaoper
                            where neupropostaoper.EtbCod  = neuproposta.EtbCod
                              and neupropostaoper.CxaCod  = neuproposta.CxaCod
                              and neupropostaoper.DtInclu = neuproposta.DtInclu
                              and neupropostaoper.CpfCnpj = neuproposta.CpfCnpj
                              and neupropostaoper.neu_cdoperacao = 
                                                  neuproposta.neu_cdoperacao
                            no-lock no-error.

if par-tipo = "up" 
then                  
    if esqascend   
    then find prev neupropostaoper
                            where neupropostaoper.EtbCod  = neuproposta.EtbCod
                              and neupropostaoper.CxaCod  = neuproposta.CxaCod
                              and neupropostaoper.DtInclu = neuproposta.DtInclu
                              and neupropostaoper.CpfCnpj = neuproposta.CpfCnpj
                              and neupropostaoper.neu_cdoperacao = 
                                                  neuproposta.neu_cdoperacao
                            no-lock no-error.

    else find next neupropostaoper
                            where neupropostaoper.EtbCod  = neuproposta.EtbCod
                              and neupropostaoper.CxaCod  = neuproposta.CxaCod
                              and neupropostaoper.DtInclu = neuproposta.DtInclu
                              and neupropostaoper.CpfCnpj = neuproposta.CpfCnpj
                              and neupropostaoper.neu_cdoperacao = 
                                                  neuproposta.neu_cdoperacao
                            no-lock no-error. 

end procedure.

