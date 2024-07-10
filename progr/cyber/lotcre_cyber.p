/* cyber/lotcre_cyber.p */

function troca-label returns character
    (input par-handle as handle,
         input par-label  as char).
         
         
         if par-label = "NO-LABEL"
         then par-handle:label    = ?.
         else par-handle:label    = par-label.
         
end function.
         

def var vtipo as char format "x(10)". 
def var vlabel as char format "x(10)".

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["  "," Clientes "," "," Consulta "," Relatorio "].
def var esqcom2         as char format "x(14)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}

def buffer blotcre       for lotcre.
def var vlotcre          as recid.
def var vtotcli as int format ">>>>>>9".
def var vtottit as int format ">>>>>>9".
def new shared buffer lotcretp for lotcretp.

/*def shared frame f-cab.*/

def input parameter par-lotcretp as char.

find first lotcre where recid(lotcre) = int(par-lotcretp) no-lock no-error.

if not avail lotcre
then do.
    find lotcretp where lotcretp.ltcretcod = par-lotcretp no-lock.
end.
else do.
    find lotcretp of lotcre no-lock.
    recatu1 = recid(lotcre).
end.    
pause 0.

if lotcretp.titnat
then esqcom1[2] = " Fornecedores ".
else esqcom1[2] = " Clientes ".

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    /*
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.*/

    if recatu1 = ?
    then
        if esqascend
        then
            find first lotcre of lotcretp no-lock no-error.
        else
            find last lotcre of lotcretp no-lock no-error.
    else do:
        find lotcre where recid(lotcre) = recatu1 no-lock no-error.
    end.
    if not available lotcre
    then esqvazio = yes.
    else do:
        esqvazio = no.
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
    end.
    if esqvazio then leave.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(lotcre).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.

    if not esqvazio
    then repeat:
        if esqascend
        then
            find next lotcre of lotcretp no-lock.
        else
            find prev lotcre of lotcretp no-lock.
        if not available lotcre
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
            if lotcretp.permitenovolote = no
            then do:
                find first lotcre of lotcretp where lotcre.ltdtenvio = ?
                                                 or lotcre.ltdtretorno = ?
                                  no-lock no-error.
                if avail lotcre
                then esqcom1[1] = "".
                else esqcom1[1] = " Novo Lote".
            end.
            
            find lotcre where recid(lotcre) = recatu1 no-lock.
            
            if lotcre.ltdtenvio = ?
            then do:
                esqcom1[3] = " Exclui ".
                esqhel1[3] = " Exclui Lote ".
            end.
            else if lotcre.ltdtretorno = ?
            then assign
                esqcom1[3] = " Cancela "
                esqhel1[3] = " Cancela Lote ".
            else assign
                esqcom1[3] = " "
                esqhel1[3] = " ".
            disp esqcom1 with frame f-com1.

            if lotcre.ltdtenvio = ?
            then assign
                    esqcom2[1] = " Validacao"
                    esqhel2[1] = " Validacao do Lote ".
            else assign
                    esqcom2[1] = ""
                    esqhel2[1] = "".

            if lotcre.ltdtvalida <> ? and lotcre.ltdtenvio = ?
            then assign
                    esqcom2[2] = " Gera Remessa"
                    esqhel2[2] = " Gera Arquivo de Remessa".
            else assign
                    esqcom2[2] = ""
                    esqhel2[2] = "".

            if lotcre.ltdtvalida <> ? and
               lotcre.ltdtenvio <> ?  and
               lotcre.ltdtretorno = ?
            then esqcom2[3] = " Retorno ".
            else esqcom2[3] = "".
            
            /* Exluir lotes enviados  */
            if lotcre.ltdtvalida <> ? and
               lotcre.ltdtenvio <> ?  and
               lotcre.ltdtretorno = ?
            then do:
                esqcom2[1] = " Excluir Envio ".
                esqhel2[1] = " Excluir lote enviado ".  
            end.
            else esqcom2[1] = "".

            
            assign
                    esqcom2[5] = ""
                    esqhel2[5] = "".
                    
            esqcom1[2] = " Clientes ".
            esqcom1[3] = " Contratos ".
            esqcom1[4] = " ".
            esqcom1[5] = "".
            esqcom1[1] = " Consulta ".
            
            esqhel1[2] = " Consulta Clientes do Lote ".
            esqhel1[3] = " Consulta Contratos do Lote".
            esqhel1[4] = " ".
            esqhel1[5] = "".
            esqhel1[1] = " Consulta dados do Lote".
            
            
            find first LotCreContrato of lotcre no-lock no-error.
            if not avail LotCreContrato
            then do.
                esqcom1[3] = "".
                find first LotCreTit of lotcre no-lock no-error.
                if avail LotCreTit
                then assign esqcom1[3] = " Parcelas "
                            esqhel1[3] = "Consulta Parcelas do lote " .
            end.                
            
            esqcom2 = "".
            
            disp esqcom1 with frame f-com1.
            disp esqcom2 with frame f-com2.
    
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(lotcre.ltcrecod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(lotcre.ltcrecod)
                                        else "".

            choose field lotcre.ltcrecod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            status default "".

        end.
        {esquema.i &tabela = "lotcre"
                   &campo  = "lotcre.ltcrecod"
                   &where  = "of lotcretp"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
               /* display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.*/
                if esqcom1[esqpos1] = " Novo Lote " or esqvazio
                then do with frame f-lotcr.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    vlotcre = ?. 

                   run value(lotcretp.selecao + ".p")
                               (input-output vlotcre,
                                  input recid(lotcretp),
                                  input " Selecao ").

                    if vlotcre = ?
                    then do:
                        recatu1 = ?.
                        leave.
                    end.
                    find lotcre where recid(lotcre) = vlotcre no-lock no-error.
                    if avail lotcre
                    then do.
                        recatu1 = recid(lotcre).
                        run lotcreag.p (input recid(lotcre)).
                    end.
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Exclui " or
                   esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Cancela "
                then do with frame f-lot centered row 5 side-label:
                    find func where func.funcod = lotcre.funcod
                              no-lock no-error.
                    disp
                       lotcre.ltcrecod format ">>>>>>>>9" label "Lote"  colon 12
                       skip(1)           /*
                       lotcre.ltselecao colon 12
                       skip(1)             */
                       lotcre.ltcredt  label "Gerado em"  colon 12
                       string(lotcre.ltcrehr, "HH:MM:SS") label "Hr" colon 28
                       lotcre.funcod   label "Funcionario"
                       func.funape     no-label format "x(15)" when avail func
                       skip(1)          /*
                       lotcre.ltdtvalida   colon 12
                       string(lotcre.lthrvalida,"HH:MM:SS") label "Hr" colon 28
                       lotcre.ltfnvalida   label "Func."
                       skip(1)            */ 
                       lotcre.ltdtenvio    colon 12
                       string(lotcre.lthrenvio,"HH:MM:SS") label "Hr" colon 28
                       lotcre.ltfnenvio    label "Func."
                       lotcre.arqenvio     colon 12 no-label format "x(60)"
                       skip(1)        /*
                       lotcre.ltdtretorno  colon 12
                       string(lotcre.lthrretorno,"HH:MM:SS") label "Hr" colon 28
                       lotcre.ltfnretorno  label "Func."
                       lotcre.arqretorno   colon 12 no-label
                       */ .
                       
                   if esqcom1[esqpos1] = " Consulta "
                   then pause.
                end.

                if esqcom1[esqpos1] = " Exclui "
                then do with frame f-exclui  row 5 1 column centered
                            on error undo.
                    if lotcre.ltdtenvio <> ?
                    then do:
                        message "Lote Fechado, nao pode ser Excluido.".
                        leave.
                    end.

                    message "Confirma Exclusao do Lote" lotcre.ltcrecod
                    update sresp.
                    if not sresp
                    then undo, leave.
                    find next lotcre of lotcretp no-error.
                    if not available lotcre
                    then do:
                        find lotcre where recid(lotcre) = recatu1.
                        find prev lotcre of lotcretp no-error.
                    end.
                    recatu2 = if available lotcre
                              then recid(lotcre)
                              else ?.
                    find lotcre where recid(lotcre) = recatu1.
                    for each lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod.
                        for each lotcretit where
                                     lotcretit.ltcrecod = lotcreag.ltcrecod and
                                     lotcretit.clfcod = lotcreag.clfcod.
                            delete lotcretit.
                        end.
                        delete lotcreag.
                    end.
                    delete lotcre.
                    recatu1 = recatu2.
                    leave.
                end.

                if esqcom1[esqpos1] = " Cancela "
                then do with frame f-cancela  row 5 1 column centered
                            on error undo.
                    if lotcre.ltdtenvio <> ? and
                       lotcre.ltdtretorno <> ?
                    then do:
                        message "Lote Fechado, nao pode ser Cancelado.".
                        leave.
                    end.

                    message "Confirma Cancelamento do Lote" lotcre.ltcrecod
                    update sresp.
                    if not sresp
                    then undo, leave.

/***
                    find next lotcre of lotcretp no-error.
                    if not available lotcre
                    then do:
                        find lotcre where recid(lotcre) = recatu1.
                        find prev lotcre of lotcretp no-error.
                    end.
                    recatu2 = if available lotcre
                              then recid(lotcre)
                              else ?.
***/
                    find lotcre where recid(lotcre) = recatu1 exclusive.
/***
                    for each lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod.
                        for each lotcretit where
                                     lotcretit.ltcrecod = lotcreag.ltcrecod and
                                     lotcretit.clfcod = lotcreag.clfcod.
                            delete lotcretit.
                        end.
                        delete lotcreag.
                    end.
                    delete lotcre.
***/
                    assign
                        lotcre.ltdtretorno = today
                        lotcre.lthrretorno = time
                        lotcre.arqretorno  = "Cancelado"
                        lotcre.ltfnretorno = sfuncod.
                    recatu1 = recatu2.
                    leave.
                end.

                if esqcom1[esqpos1] = " Clientes " or
                   esqcom1[esqpos1] = " Fornecedores " 
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* hide frame f-cab no-pause.*/
                    run cyber/lotcreag_cyber.p (input recid(lotcre)).
                    /***recatu1 = ?.***/
                    leave.
                end.

                if esqcom1[esqpos1] = " Contratos " 
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* hide frame f-cab no-pause.*/
                    run cyber/lotcrectr_cyber.p (input recid(lotcre)).
                    /***recatu1 = ?.***/
                    leave.
                end.
                if esqcom1[esqpos1] = " Parcelas " 
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* hide frame f-cab no-pause.*/
                    run cyber/lotcretit_cyber.p (input recid(lotcre)).
                    /***recatu1 = ?.***/
                    leave.
                end.

                if esqcom1[esqpos1] = " Relatorio "
                then do.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    if lotcretp.relatorio <> ""
                    then run value(lotcretp.relatorio + ".p") (recid(lotcre)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = " Validacao "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run value(lotcretp.valida + ".p") (input recid(lotcre)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.

                if esqcom2[esqpos2] = " Gera Remessa "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    find lotcre where recid(lotcre) = recatu1 no-lock.
                    find lotcretp of lotcre no-lock.
                    if search(lotcretp.remessa + ".p") = ?
                    then do on endkey undo:
                        message "Nao foi Encontrado o Programa de Remessa"
                                trim(lotcretp.remessa + ".p").
                        pause.
                        leave.
                    end.

                    run message.p (input-output sresp,
                                input "   Confirma a Geracao do Arquivo do" +
                                        " Lote " + string(lotcre.ltcrecod) +
                                " para " + lotcretp.ltcretnom,
                                input " !! ATENCAO !! ").

                    if sresp
                    then do on error undo:
                        run value(lotcretp.valida + ".p") (recid(lotcre)).
                        run value(lotcretp.remessa + ".p") (recid(lotcre)).
                    end.
                    recatu1 = ?.
                    leave.
                end.

                if esqcom2[esqpos2] = " Retorno "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run value(lotcretp.retorno + ".p") (input recid(lotcre)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.

                if esqcom2[esqpos2] = " Rel.Retorno "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run value(lotcretp.relretorno + ".p") (input recid(lotcre)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.

                if esqcom2[esqpos2] = " Excluir Envio "
                then do.
                    message 
                    "Lote" lotcre.ltcrecod "enviado. Deseja excluir o lote ?"
                    update sresp.
                    if not sresp
                    then undo, leave.
                    
                    run ltdellote.p (input recid(lotcre)).
                    recatu1 = recatu2.
                    leave.
                end.

                if esqcom2[esqpos2] = "Atuali.Cadastro"
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run impaccesscad.p (input recid(lotcre)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(lotcre).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    find func where func.funcod = lotcre.funcod no-lock no-error.
    find lotcretp of lotcre no-lock.
    /*vtotcli = 0.
     vtottit = 0.
    for each lotcreag of lotcre no-lock.
        vtotcli = vtotcli + 1.
        for each lotcretit of lotcreag no-lock.
            vtottit = vtottit + 1.
        end.
    end.*/

    vtipo = "".
    if lotcre.LtCreTCod = "ACCESS" or lotcre.ltcreTcod = "GLOBAL" or
    lotcre.ltcretcod = "ACCESS_P" or lotcre.ltcretcod = "ACCESS_A"
    then do:
        vlabel = "Status    ".
        if lotcre.arqretorno = "Cancelado"
        then vtipo = "Cancelado".
        else if lotcre.arqretorno <> "Cancelado" and lotcre.arqenvio <> ""
        and lotcre.ltdtenvio <> ? 
        then vtipo = "Enviado".
        else if lotcre.arqenvio = "" 
        then vtipo = "".
        /*
        if lotcre.Arqretorno <> ""        
        then vtipo = "C/Retorno".
        */
    end.
    else do:
        vlabel = "Gerado por".
        if avail func 
        then vtipo = func.funape. 
        else vtipo = "".
    end.

    display
        lotcre.ltcrecod format ">>>>>>>>9"  label "Lote"
        lotcre.ltcredt
        string(lotcre.ltcrehr, "HH:MM:SS") @ lotcre.ltcrehr
        /*vtipo */
        /*func.funape label "Gerado por" format "x(10)" when avail func*/
        lotcre.ltdtenvio
        lotcre.ltseqcyber column-label "Seq Cyber"
        
        with frame frame-a 11 down centered row 5 title lotcretp.LtCreTNom.
     /*
     troca-label(vtipo:handle,
                         if lotcre.LtCreTCod = "ACCESS"
                         then "Status    "                                                              else if lotcre.LtCreTCod = "BANRISUL"
                         then "Gerado por"
                         else "Status    ").
      */                                            

end.

