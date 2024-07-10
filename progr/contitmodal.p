/***
    Fev/2018 - Projeto Garantia: Troca Garantida
***/
{admcab.i}

def var vmodcod   like titulo.modcod initial "".
def var vsituacao as log format "Abertos/Liquidados" init yes.

do on error undo with frame f-filtro side-label no-box.
    update vmodcod validate (vmodcod <> "", "").
    find modal where modal.modcod = vmodcod no-lock.
    disp modal.modnom no-label.
    update vsituacao label "Situacao" help "(A)bertos/(L)iquidados".
end.

/*
*
*    titulo.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [""," Consulta ",""].
def var esqhel1         as char format "x(80)" extent 5.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

if vmodcod = "BTR" and
   vsituacao
then esqcom1[5] = "Importa Pagto".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titulo where recid(titulo) = recatu1 no-lock.
    if not available titulo
    then do.
        message "Sem titulos para a modalidade" vmodcod view-as alert-box.
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(titulo).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find titulo where recid(titulo) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then titulo.titnum
                                        else "".
            run color-message.
            choose field titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
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
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titulo
                    then leave.
                    recatu1 = recid(titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titulo
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titulo
                then next.
                color display white/red titulo.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do.
                hide frame f-com1 no-pause.
                run bsfqtitulo.p (recid(titulo)).
            end.
            if esqcom1[esqpos1] = "Importa Pagto"
            then do.
                run importa-pagto.
                leave.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(titulo).
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
    display
        titulo.etbcod
        titulo.clifor
        titulo.titnum
        titulo.titpar
        titulo.titdtemi
        titulo.titvlcob
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        titulo.titnum
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        titulo.titnum
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first titulo where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = vmodcod
                            and (if vsituacao
                                 then titulo.titsit = "LIB"
                                 else titulo.titsit = "PAG")
                                                no-lock no-error.
    else  
        find last titulo  where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = vmodcod
                            and (if vsituacao
                                 then titulo.titsit = "LIB"
                                 else titulo.titsit = "PAG")
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next titulo  where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = vmodcod
                            and (if vsituacao
                                 then titulo.titsit = "LIB"
                                 else titulo.titsit = "PAG")
                                                no-lock no-error.
    else  
        find prev titulo  where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = vmodcod
                            and (if vsituacao
                                 then titulo.titsit = "LIB"
                                 else titulo.titsit = "PAG")
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev titulo where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = vmodcod
                            and (if vsituacao
                                 then titulo.titsit = "LIB"
                                 else titulo.titsit = "PAG")
                                        no-lock no-error.
    else   
        find next titulo where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = vmodcod
                            and (if vsituacao
                                 then titulo.titsit = "LIB"
                                 else titulo.titsit = "PAG")
                                        no-lock no-error.
        
end procedure.


def temp-table tt-titulo no-undo
    field clifor   as int
    field titnum   as char
    field titpar   as int
    field titvlcob as dec.

procedure importa-pagto.

    def var varquivo  as char format "x(45)".
    def var vlidos    as int.
    def var vcomerro  as int.

    do on error undo with frame f-importa side-label centered.
        disp
            "Importar pagamentos de troca garantida"  skip
            "Layout (format CSV): Codigo Cliente;Numero Titulo (Voucher);"
            "Parcela;Valor Titulo".
        update varquivo label "Arquivo".
        if search(varquivo) = ?
        then do.
            message "Arquivo nao encontrato" view-as alert-box.
            next.
        end.
    end.
    empty temp-table tt-titulo.
    unix silent dos2unix -q value(varquivo).

    /*
        Fsse 1 Validacao
    */
    input from value(varquivo).
    repeat.
        create tt-titulo.
        import delimiter ";" tt-titulo.
        if tt-titulo.titnum = ""
        then next.
        vlidos = vlidos + 1.
        find first titulo where titulo.empcod   = 19
                            and titulo.titnat   = no
                            and titulo.modcod   = vmodcod
                            and titulo.titnum   = tt-titulo.titnum
                            and titulo.clifor   = tt-titulo.clifor
                            and titulo.titvlcob = tt-titulo.titvlcob
                            and titulo.titsit   = "LIB"
                    no-lock no-error.
        if not avail titulo
        then do.
            message "Titulo nao encontrado:" tt-titulo.titnum
                view-as alert-box.
            vcomerro = vcomerro + 1.
            leave.
        end.

    end.
    input close.

    if vcomerro > 0
    then return.

    /*
        Fase 2 - Liquidacao
    */
    for each tt-titulo where tt-titulo.titnum <> "" no-lock.
        vlidos = vlidos + 1.
        find first titulo where titulo.empcod   = 19
                            and titulo.titnat   = no
                            and titulo.modcod   = vmodcod
                            and titulo.titnum   = tt-titulo.titnum
                            and titulo.clifor   = tt-titulo.clifor
                            and titulo.titvlcob = tt-titulo.titvlcob
                            and titulo.titsit   = "LIB".
        assign
            titulo.titsit   = "PAG"
            titulo.titdtpag = today
            titulo.cxmdata  = today
            titulo.cxmhora  = string(time)
            titulo.etbcobra = setbcod
            titulo.titvlpag = titulo.titvlcob
            titulo.titobs[2] = varquivo.
    end.

    message "Arquivo processado: =" vlidos view-as alert-box.

end procedure.

