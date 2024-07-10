/*
*
*    tt-dados.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec-asstec    as recid.

find asstec where recid(asstec) = par-rec-asstec no-lock.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5.
def var esqcom2         as char format "x(15)" extent 5
            initial [" "," "," ","4-Retorna",""].

def var vvalor_campo like asstec_aux.valor_campo format "x(60)".

def temp-table tt-dados
    field seq    as int
    field campo  as char
    field clabel as char format "x(14)"
    field alterar as log

    index seq seq asc.

def var mcampo as char extent 11 init[
    "OBSSSC1",
    "REGISTRO-TROCA", "Produto", "Cancela", "Encerra", "Auditoria", ""].
/***
    "JAAT", "Aparencia", "ACES", "SENHAG", "OBSCOMP1",
    "OBSCOMP2", "OBSCOMP3", "AUTTROCA", "Cancela", "MotivTra",
    "Encerra"].
***/
def var mlabel as char extent 11 init[
    "Observacao SSC",
    "Registro de troca", "Prod.na nota","Cancelamento", "Encerramento",
    "Auditoria",""].
/***
    "Ja Esteve AT","Aparencia", "Acessorios", "Senha Garantech", "Obs.Compl1",
    "Obs.Compl2", "Obs.Compl3", "Aut.Troca", "Cancelamento", "Motivo Trans",
    "Encerramento"].
***/
def var vct as int.
def var vtabini    as char.
def var vetbassist as int.

run le_tabini.p (0, 0, "SSC-ESTABASSIST", OUTPUT vtabini).
vetbassist = int(vtabini).

do vct = 1 to 11.
    create tt-dados. 
    tt-dados.seq    = vct.
    tt-dados.campo  = mcampo[vct].
    tt-dados.clabel = mlabel[vct].

    if vct >= 2 or
       asstec.dtsaida <> ? or
       setbcod <> vetbassist
    then tt-dados.alterar = no.
    else tt-dados.alterar = yes.
end.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered overlay.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 3.

pause 0.
bl-princ:
repeat:
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first tt-dados no-lock no-error.
    else find tt-dados where recid(tt-dados) = recatu1 no-lock.
    if not available tt-dados
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else leave.

    recatu1 = recid(tt-dados).
    color display input esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then find next tt-dados  no-lock no-error.
        else find prev tt-dados  no-lock no-error.
        if not available tt-dados
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
            find tt-dados where recid(tt-dados) = recatu1 no-lock.

            status default "".

            choose field tt-dados.clabel help ""
                go-on(cursor-down cursor-up
                      page-down   page-up 4
                      PF4 F4 ESC return).

            status default "".
        end.
        
        {esquema.i &tabela = "tt-dados"
                   &campo  = "tt-dados.clabel"
                   &where = "true" 
                   &frame  = "frame-a"}
        
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "4" 
        then do.
           sresp = yes.
           for each asstec_aux where asstec_aux.oscod = asstec.oscod 
                               no-lock.
              if asstec_aux.valor_campo = ""
              then do.
                 run message.p (input-output sresp, 
                                input "Descricao nao informada." +
                                      "Confirma retorno ?",  
                                input "Dados Adicionais").
                 if sresp
                 then leave bl-princ.
                 else leave.
              end.
           end.
           if sresp
           then leave bl-princ.
        end.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo:
            if tt-dados.altera = no
            then do. 
               message "Alteração não permitida." view-as alert-box.
               next. 
            end.

            if asstec.dtsaida <> ?
            then next.
/***
            if tt-dados.campo = "AUTTROCA"
            then do.
                sretorno = "FUNCIONARIOMATRIZ".
                run versenha.p ("assisttecnic",  
                                "Senha Funcionario",  
                                output sresp). 
                if sresp = no
                then next. 
            end.
***/

            find asstec_aux of asstec
                            where asstec_aux.nome_campo = tt-dados.campo
                            no-error.
            if avail asstec_aux
            then do.
                if acha("Descricao", asstec_aux.valor_campo) <> ?
                then vvalor_campo = acha("Descricao", asstec_aux.valor_campo).
                else vvalor_campo = asstec_aux.valor_campo.
            end.
            
            update vvalor_campo validate(vvalor_campo <> "","")
                   with frame frame-a.

            if not avail asstec_aux
            then do:
                create asstec_aux.
                assign 
                    asstec_aux.oscod = asstec.oscod 
                    asstec_aux.nome_campo = tt-dados.campo.
            end.
            if tt-dados.campo = "AUTTROCA"
            then asstec_aux.valor_campo = "Descricao=" + vvalor_campo +
                                        "|Funcod="   + string(sfuncod) +
                                        "|Data="     + string(today).
            else asstec_aux.valor_campo = vvalor_campo.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-dados).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    vvalor_campo = "".
    find asstec_aux where asstec_aux.oscod = asstec.oscod and
                          asstec_aux.nome_campo = tt-dados.campo
                    no-lock no-error.
    if avail asstec_aux
    then do.
        if acha("Descricao", asstec_aux.valor_campo) <> ?
        then vvalor_campo = acha("Descricao", asstec_aux.valor_campo).
        else vvalor_campo = asstec_aux.valor_campo.
    end.

    display
        tt-dados.clabel format "x(17)"
        vvalor_campo    format "x(60)"
        with frame frame-a 11 down centered row 9 no-label overlay
             title " Dados adicionais - OS " + string(asstec.oscod).
end.