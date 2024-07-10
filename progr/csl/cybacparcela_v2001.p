/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}


def var par-rec as recid.
def var recatu1         as recid.

def var recatu2 as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Consulta "," Boleto ","  ","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def input parameter par-rec-cybacordo as recid.

find cybacordo where recid(cybacordo) = par-rec-cybacordo no-lock.
find estab  where estab.etbcod = cybacordo.etbcod no-lock.

recatu1 = ?.
    

form    cybacparcela.parcela 
        cybacparcela.dtvencimento
        cybacparcela.vlcobrado
        cybacparcela.contnum
        cybacparcela.dtbaixa
        cybacparcela.situacao format "x(03)" column-label "Sit"
        " | "
        with frame frame-a 9 down centered row 09
        title " Parcelas Acordo " no-underline width 80.



    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find cybacparcela where recid(cybacparcela) = recatu1 no-lock.
    if not available cybacparcela
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
        recatu1 = ?.
        leave.
    end.

    recatu1 = recid(cybacparcela).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cybacparcela
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find cybacparcela where recid(cybacparcela) = recatu1 no-lock.

        color disp messages
        cybacparcela.parcela.
                    

            disp esqcom1 with frame f-com1.
            
            choose field cybacparcela.parcela
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            hide message no-pause.
            status default "".
 
        color disp normal
        cybacparcela.parcela.
 
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
                    if not avail cybacparcela
                    then leave.
                    recatu1 = recid(cybacparcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cybacparcela
                    then leave.
                    recatu1 = recid(cybacparcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cybacparcela
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cybacparcela
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta"
            then do:
                find contrato where 
                    contrato.contnum = cybacparcela.contnum
                    no-lock no-error.
                if avail contrato
                then do:    
                    find first titulo where 
                        titulo.empcod = 19 and 
                        titulo.titnat = no and 
                        titulo.modcod = contrato.modcod and 
                        titulo.etbcod = contrato.etbcod and 
                        titulo.clifor = contrato.clicod and 
                        titulo.titnum = string(contrato.contnum) and
                        titulo.titpar = cybacparcela.parcela
                       no-lock no-error.
                    if avail titulo
                    then     
                        run bsfqtitulo.p (input recid(titulo)).
                    else do:
                        hide message no-pause.
                        message "Parcela ainda nao gerada".
                    end.
                                            
                end.    
                else do:
                    hide message no-pause.
                    message "Contrato ainda nao Gerado".
                end.
            end.    
            
            if esqcom1[esqpos1] = " Boleto"
            then do:

                find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "cybacparcela" and             
            banbolorigem.chaveOrigem  = "idacordo,parcela" and 
             banbolorigem.dadosOrigem = string(cybacordo.idacordo) + "," +
                           string(cybacparcela.parcela)
            no-lock no-error.
            if not avail banbolorigem
            then
        find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "promessa" and
            banbolorigem.chaveOrigem  = "idacordo,contnum,parcela" and
            banbolorigem.dadosOrigem  = string(cybacordo.idacordo) + "," + string(cybacparcela.contnum) + "," +
                           string(cybacparcela.parcela)
            no-lock no-error.
            
            if avail banbolorigem
            then do:
                find banboleto of banbolorigem no-lock no-error.
                if avail banboleto
                then do:
                    par-rec = recid(banboleto).
                    run bol/banboletoman_v1701.p (input-output
                                    par-rec).
                 end.
                 else do:
                    hide message no-pause.
                    message "Boleto ainda nao gerado".
                 end.
            end.                    

            else do:
                hide message no-pause.
                message "Boleto nao gerado".
            end.
            end.  
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cybacparcela).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.


    if cybacordo.situacao <> "A"
    then do:

        find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "cybacparcela" and             banbolorigem.chaveOrigem  = "idacordo,parcela" and                         banbolorigem.dadosOrigem  = string(cybacordo.idacordo) + "," +
                           string(cybacparcela.parcela)
            no-lock no-error.
    if not avail banbolorigem
    then
            find first banbolOrigem  where 
            banbolorigem.tabelaOrigem = "promessa" and
            banbolorigem.chaveOrigem  = "idacordo,contnum,parcela" and
            banbolorigem.dadosOrigem  = string(cybacordo.idacordo) + "," + string(cybacparcela.contnum) + "," +
                           string(cybacparcela.parcela)
            no-lock no-error.
        if avail banbolorigem
        then do:
            find banboleto of banbolorigem no-lock no-error.
        end.                    
    end.
    display 
        cybacparcela.parcela 
        cybacparcela.dtvencimento
        cybacparcela.vlcobrado
        cybacparcela.contnum
        cybacparcela.dtbaixa
        cybacparcela.situacao 
        
        banbolorigem.nossonumero column-label "Boleto"
                when avail banbolorigem
        banboleto.dtenvio 
                when avail banboleto
        banboleto.situacao 
                when avail banboleto

                
        with frame frame-a.
     

end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first cybacparcela of cybacordo no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  cybacparcela of cybacordo  no-lock no-error.
             
if par-tipo = "up" 
then find prev  cybacparcela of cybacordo no-lock no-error.

end procedure.




