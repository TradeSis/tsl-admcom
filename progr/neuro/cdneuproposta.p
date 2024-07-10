/*                                                 
*
*    neuproposta.p    -    Esqueleto de Programacao
*
#1- 14/11/2018 - substituida opcao ELIMINA por MANUTENCAO 
*/
{admcab.i}

def input parameter par-rec as recid.

def var vhora as char.

find neuclien where recid(neuclien) = par-rec no-lock.
find clien where clien.clicod = neuclien.clicod no-lock no-error.

/*    disp 
        NeuClien.CpfCnpj
        NeuClien.Clicod
        clien.clinom when avail clien
        NeuClien.VlrLimite
        NeuClien.VctoLimite
        with frame f-neuclien
         side-label 2 col centered 1 down row 3.
  */
form
      neuproposta.EtbCod 
      neuproposta.cxacod
      neuproposta.DtInclu  format "999999" column-label "Data"
      neuproposta.hrinclu  
      neuproposta.TipoConsulta column-label "Pl" format "x(2)"
      neuproposta.valorcompra format ">>>>9.99" column-label "Compra"
      NeuProposta.neu_cdoperacao
      NeuProposta.neu_resultado
      NeuProposta.VctoLimite format "999999" column-label "Vcto"
      NeuProposta.VlrLimite format ">>>>9.99" column-label "Lim"
      with frame frame-a 11 down centered no-box row 9.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," Consulta "," Operacoes ",""].
def var esqhel1         as char format "x(80)" extent 5.

def buffer bneuproposta       for neuproposta.

form
    esqcom1
    with frame f-com1 row 8 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find neuproposta where recid(neuproposta) = recatu1 no-lock.
    if not available neuproposta
    then do.
        message "Sem registros para este cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(neuproposta).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available neuproposta
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find neuproposta where recid(neuproposta) = recatu1 no-lock.
            if neuproposta.neu_resultado = "P" and neuproposta.dtinclu = today
            then esqcom1[4] = " Manutencao ".
            else esqcom1[4] = "".
            disp esqcom1[4]
                with frame f-com1.
            
            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(neuproposta.dtinclu)
                                        else "".
            run color-message.
            
            choose field neuproposta.dtinclu help ""
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
                    if not avail neuproposta
                    then leave.
                    recatu1 = recid(neuproposta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail neuproposta
                    then leave.
                    recatu1 = recid(neuproposta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail neuproposta
                then next.
                color display white/red neuproposta.dtinclu with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail neuproposta
                then next.
                color display white/red neuproposta.dtinclu with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form neuproposta
                 with frame f-neuproposta color black/cyan
                      centered side-label row 9 with 2 col.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-neuproposta.
                    hide frame frame-a no-pause.
                    disp neuproposta.
                end.

                if esqcom1[esqpos1] = " Operacoes "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause.
                    hide frame frame-a no-pause.
                    run neuro/cdneupropostaoper.p (recid(neuproposta)).
                    view frame f-com1.
                    leave.
                end.
                /**************
                #1
                if esqcom1[esqpos1] = " Elimina "
                then do on error undo:
                    sresp = yes.
                    message "Mesmo???" update sresp.
                    if sresp
                    then do:
                        find current neuproposta exclusive.
                        neuproposta.neu_resultado = "X".
                    end.
                    leave.
                end.
                ************/
                /* #1 */
                if esqcom1[esqpos1] = " Manutencao "
                then do.
                    run manutencao.
                    leave.
                end.
                /* #1 */
            end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(neuproposta).
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
    vhora = string(neuproposta.hrinclu, "hh:mm:ss").
    display 
      neuproposta.EtbCod 
      neuproposta.cxacod
      neuproposta.DtInclu 
      vhora @ neuproposta.hrinclu  
      neuproposta.TipoConsulta 
      neuproposta.valorcompra when neuproposta.valorcompra <> 0
      NeuProposta.neu_cdoperacao
      NeuProposta.neu_resultado
      NeuProposta.VctoLimite
      NeuProposta.VlrLimite
      with frame frame-a.

end procedure.


procedure color-message.
    color display message
        neuproposta.dtinclu
        neuproposta.hrinclu
        neuproposta.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        neuproposta.dtinclu
        neuproposta.hrinclu
        neuproposta.etbcod
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then find first neuproposta of neuclien use-index cpfhora no-lock no-error.
    else find last neuproposta  of neuclien use-index cpfhora no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then find next neuproposta  of neuclien use-index cpfhora no-lock no-error.
    else find prev neuproposta  of neuclien use-index cpfhora no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then find prev neuproposta  of neuclien use-index cpfhora no-lock no-error.
    else find next neuproposta  of neuclien use-index cpfhora no-lock no-error.

end procedure.

procedure manutencao.

    def var vsenha like func.senha.
    def var vopcao as char format "x(1)".

    message
        "ATENCAO ANTES DE EXECUTAR A LOJA PRECISA SAIR DO CADASTRO DE CLIENTE"
        view-as alert-box.

    update vsenha blank with frame f-senha side-label centered.
    if vsenha <> "neuro"
    then do.
        message "Senha invalida" view-as alert-box.
        return.
    end.
    hide frame f-senha.

    update vopcao label "Opcao: Aprovar / Reprovar"
        validate (vopcao = "A" or vopcao = "R", "Invalido")
        with frame f-opcao side-label centered.    

    do transaction.
        find current neuproposta.
        find current neuclien.

        NeuProposta.neu_resultado = vopcao.
        neuclien.sit_credito = vopcao.
        
        find current neuproposta no-lock.
        find current neuclien.
    end.

    output to "../roberto/motor/logMataPendente.log" APPEND.
    export "[" + string(today) + "-" + STRING(TIME,"HH:MM:SS") + 
    "] Cliente " + string(neuclien.clicod) + " Sit_credito atualizada =" vopcao
    format "x~(90)".
    output close.

    message "Processo Concluido" view-as alert-box.

end procedure.

