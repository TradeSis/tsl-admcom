/*
Projeto:  Seguro Prestamista
Data:     06/2016
Programa: manut_segur.p
Autor: Lucas Leote
*/
{admcab.i new}

def var vbusca as char format "xxxxxxx". 
def var primeiro as log.
def buffer xprodu for produ.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 6
    initial ["Consulta","Nota Fiscal","Certificado","Congela","Descongela",
             "Cancela"].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 6.
def var esqhel2         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.
	
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find vndseguro where recid(vndseguro) = recatu1 no-lock.
    if not available vndseguro
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(vndseguro).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    repeat:
        run leitura (input "seg").
        if not available vndseguro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find vndseguro where recid(vndseguro) = recatu1 no-lock.
            if setbcod < 200 or
               vndseguro.dtcanc <> ? or
               vndseguro.dtfvig < today
            then assign
                    esqcom1[4] = ""
                    esqcom1[5] = ""
                    esqcom1[6] = "".
            else assign
                    esqcom1[4] = "Congela"
                    esqcom1[5] = "Descongela"
                    esqcom1[6] = "Cancela".
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(vndseguro.certifi)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(vndseguro.certifi)
                                        else "".
            run color-message.
            choose field vndseguro.certifi help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail vndseguro
                    then leave.
                    recatu1 = recid(vndseguro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail vndseguro
                    then leave.
                    recatu1 = recid(vndseguro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail vndseguro
                then next.
                color display white/red vndseguro.certifi with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail vndseguro
                then next.
                color display white/red vndseguro.certifi with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form vndseguro except placod datexp
                 with frame f-vndseguro color black/cyan 2 col
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Consulta" or
                   esqcom1[esqpos1] = "Cancela"
                then do with frame f-vndseguro.
                    find clien of vndseguro no-lock.
                    disp vndseguro except placod datexp.
                    disp clien.clinom.
                end.
                if esqcom1[esqpos1] = "Nota Fiscal"
                then do:
                    find plani where plani.etbcod = vndseguro.etbcod
                                 and plani.placod = vndseguro.placod
                               no-lock no-error.
                    if avail plani
                    then do.
                        hide frame f-com1 no-pause.
                        run not_consnota.p (recid(plani)).
                        view frame f-com1.
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = "Congela" or
                   esqcom1[esqpos1] = "DesCongela"
                then do on error undo with frame f-congela.
                    disp
                        vndseguro.DtAnaliseEnt
                        vndseguro.DtAnaliseSai.
                    find current vndseguro exclusive.
                    if esqcom1[esqpos1] = "Congela"
                    then update vndseguro.DtAnaliseEnt.
                    else update vndseguro.DtAnaliseSai.

                    if esqcom1[esqpos1] = "Congela"
                    then vndseguro.situacao = no.
                    else vndseguro.situacao = yes.
                end.
                if esqcom1[esqpos1] = "Cancela"
                then run cancela.
                if esqcom1[esqpos1] = "Certificado"
                then run qbesegprest.p (recid(vndseguro), 1).
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
            run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(vndseguro).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
	/*** ***/
	if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or  
               keyfunction(lastkey) = "7" or  
               keyfunction(lastkey) = "8" or  
               keyfunction(lastkey) = "9" or  
               keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "P" or
               keyfunction(lastkey) = "p"
            then do with centered row 8 color message no-label
                                frame f-procura side-label overlay:
                if keyfunction(lastkey) <> "HELP" and
                   keyfunction(lastkey) <> "P" and
                   keyfunction(lastkey) <> "p"
                then assign
                        vbusca = keyfunction(lastkey)
                        primeiro = yes.
                pause 0.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                    end.
                /*find xprodu where xprodu.procod = int(vbusca) no-lock no-error.*/
                find vndseguro where recid(vndseguro) = int(vbusca) no-lock no-error.
                leave.
            end.
	/*** ***/
	
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    display
        vndseguro.etbcod
        vndseguro.certifi
        vndseguro.clicod
        vndseguro.prseguro
        vndseguro.dtincl
        vndseguro.dtcanc
        vndseguro.procod
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        vndseguro.certifi
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        vndseguro.certifi
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first vndseguro where vndseguro.tpseguro = 1 no-lock no-error.
    else  
        find last vndseguro  where vndseguro.tpseguro = 1 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next vndseguro  where vndseguro.tpseguro = 1 no-lock no-error.
    else  
        find prev vndseguro  where vndseguro.tpseguro = 1 no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev vndseguro where vndseguro.tpseguro = 1  no-lock no-error.
    else   
        find next vndseguro where vndseguro.tpseguro = 1  no-lock no-error.
        
end procedure.

procedure cancela.

    def var vmotivo as int.
    def var mmotivo as char extent 10 format "x(65)" init [
        "11   CANCELADO POR SOLICITAÇÃO",
        "12   CANCELAMENTO SOLICITADO PELO CLIENTE NO REPRESENTANTE",
        "13   CANCELADO POR SOLICITAÇÃO - DIFICULDADES FINANCEIRAS",
        "21   CANCELADO POR EXPIRAÇÃO DO CONTRATO",
        "31   CANCELADO POR INADIMPLÊNCIA",
        "32   CANCELADO POR INADIMPLÊNCIA PELA ROTINA DE FATURAMENTO",
        "41   CANCELADO POR OCORRENCIA DE SINISTRO",
        "51   CANCELADO POR PRODUTO NÃO ACEITO",
        "52   CANCELADO POR VALOR DO PREMIO NÃO CORRESPONDENTE AO PRODUTO",
        "91   OUTROS"].

    disp mmotivo
        with frame f-motivo no-label centered title " Tipo de Cancelamento ".
    choose field mmotivo with frame f-motivo.
    vmotivo = frame-index.

    sresp = no.
    message "Confirma cancelamento?" update sresp.
    hide frame f-motivo no-pause.
    if not sresp
    then return.

    do on error undo.
        find current vndseguro.
        assign
            vndseguro.dtcanc  = today
            vndseguro.motcanc = int(substr(mmotivo[vmotivo],1,2)).
    end.
end procedure.