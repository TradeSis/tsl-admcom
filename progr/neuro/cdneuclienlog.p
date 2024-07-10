/*
*
*    neuclienlog.p    -    Esqueleto de Programacao
*
*/
{admcab.i}

def input parameter par-rec as recid.

def var vhrini as int.
def var vhrfim as int.

find neuclien where recid(neuclien) = par-rec no-lock.
find clien where clien.clicod = neuclien.clicod no-lock no-error.
/*         
disp 
    NeuClien.CpfCnpj
    NeuClien.Clicod
    clien.clinom when avail clien
    NeuClien.VlrLimite
    NeuClien.VctoLimite
    with frame f-neuclien side-label 2 col centered 1 down row 3.
*/
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," Consulta ","",""].
def var esqhel1         as char format "x(80)" extent 5.

def buffer bneuclienlog       for neuclienlog.

form
    esqcom1
    with frame f-com1 row 8 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

form
    neuclienlog.EtbCod 
    neuclienlog.CxaCod 
    neuclienlog.DtInclu  format "999999" column-label "Data"
    neuclienlog.hrini  
             /*
      neuclienlog.hrfim  
      vhrtempo column-label "Hora"
      */
    neuclienlog.TipoConsulta column-label "Tipo" format "x(7)"
    neuclienlog.Descricao format "x(45)"
      /*
      neuclienlog.Sit_Credito 
      */
    with frame frame-a 11 down centered no-box row 9.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find neuclienlog where recid(neuclienlog) = recatu1 no-lock.
    if not available neuclienlog
    then do.
        message "Sem registros para este cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(neuclienlog).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available neuclienlog
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find neuclienlog where recid(neuclienlog) = recatu1 no-lock.

        status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                      esqhel1[esqpos1] <> ""
                                   then  string(neuclienlog.dtinclu)
                                   else "".
        run color-message.
        choose field neuclienlog.dtinclu help ""
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
                    if not avail neuclienlog
                    then leave.
                    recatu1 = recid(neuclienlog).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail neuclienlog
                    then leave.
                    recatu1 = recid(neuclienlog).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail neuclienlog
                then next.
                color display white/red neuclienlog.dtinclu with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail neuclienlog
                then next.
                color display white/red neuclienlog.dtinclu with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form neuclienlog
                 with frame f-neuclienlog color black/cyan
                      centered side-label row 9 with 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-neuclienlog.
                    /* gravado com mtime */
                    if neuclienlog.hrini < 90000
                    then vhrini = neuclienlog.hrini.
                    else vhrini = trunc(neuclienlog.hrini / 1000, 0).

                    if neuclienlog.hrfim < 90000
                    then vhrfim = neuclienlog.hrfim.
                    else vhrfim = trunc(neuclienlog.hrfim / 1000, 0).

                    disp neuclienlog except hrini hrfim.
                    disp string(vhrini, "hh:mm:ss") @ neuclienlog.hrini
                         string(vhrfim, "hh:mm:ss") @ neuclienlog.hrfim.
                end.
                /***
                if esqcom1[esqpos1] = " Operacoes "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause.
                    run neuro/cdneuclienlogoper.p (recid(neuclienlog)).
                    view frame f-com1.
                    leave.
                end.
                ***/
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(neuclienlog).
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

    def var vhora as int.
    if neuclienlog.hrini < 90000
    then vhora = neuclienlog.hrini.
    else vhora = trunc(neuclienlog.hrini / 1000, 0). /* gravado com mtime */

    display 
        neuclienlog.EtbCod 
        neuclienlog.CxaCod 
        neuclienlog.TipoConsulta 
        neuclienlog.Descricao 
        neuclienlog.DtInclu 
        string(vhora, "hh:mm:ss") @ neuclienlog.hrini 
        /*
         string(neuclienlog.hrfim, "hh:mm:ss") @ neuclienlog.hrfim 
         string(neuclienlog.hrfim - neuclienlog.hrini) + "s" @ vhrtempo
        */    
    with frame frame-a.

end procedure.


procedure color-message.
color display message
        neuclienlog.dtinclu
        neuclienlog.hrini
        neuclienlog.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        neuclienlog.dtinclu
        neuclienlog.hrini
        neuclienlog.etbcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first neuclienlog of neuclien no-lock no-error.
    else find last neuclienlog  of neuclien no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next neuclienlog  of neuclien no-lock no-error.
    else find prev neuclienlog  of neuclien no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev neuclienlog of neuclien no-lock no-error.
    else find next neuclienlog of neuclien no-lock no-error.
        
end procedure.
         
