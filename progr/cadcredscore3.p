/*
*
*    credscore.p    -    Esqueleto de Programacao    com esqvazio


            substituir    credscore
                          <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de credscore ",
             " Alteracao da credscore ",
             " Exclusao  da credscore ",
             " Consulta  da credscore ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

/* Guarda conteudo das variaveis para comparar depois */
def var ant-campo           like credscore.campo.
def var ant-desc-campo      like credscore.desc-campo.
def var ant-vl-ini          like credscore.vl-ini.
def var ant-vl-fin          like credscore.vl-fin.
def var ant-vl-char         like credscore.vl-char.
def var ant-vl-log          like credscore.vl-log.
def var ant-tipo-vl         like credscore.tipo-vl.
def var ant-operacao        like credscore.operacao.
def var ant-valor           like credscore.valor.
def var ant-consnumparc     like credscore.consnumparc.
def var ant-observacoes     like credscore.observacoes.

def var dep-campo           like credscore.campo.
def var dep-desc-campo      like credscore.desc-campo.
def var dep-vl-ini          like credscore.vl-ini.
def var dep-vl-fin          like credscore.vl-fin.
def var dep-vl-char         like credscore.vl-char.
def var dep-vl-log          like credscore.vl-log.
def var dep-tipo-vl         like credscore.tipo-vl.
def var dep-operacao        like credscore.operacao.
def var dep-valor           like credscore.valor.
def var dep-consnumparc     like credscore.consnumparc.
def var dep-observacoes     like credscore.observacoes.

def buffer bcredscore       for credscore.
def var vcredscore         like credscore.campo.

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

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find credscore where recid(credscore) = recatu1 no-lock.
    if not available credscore
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(credscore).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available credscore
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
            find credscore where recid(credscore) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(credscore.campo)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(credscore.campo)
                                        else "".

            choose field credscore.campo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /***color white/black***/ .

            status default "".

        end.
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
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail credscore
                    then leave.
                    recatu1 = recid(credscore).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail credscore
                    then leave.
                    recatu1 = recid(credscore).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail credscore
                then next.
                color display white/red credscore.campo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail credscore
                then next.
                color display white/red credscore.campo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form credscore.campo  format "x(5)"
                 skip
                 credscore.tipo-vl
                 skip
                 credscore.operacao
                 skip
                 credscore.valor
                 skip
                 credscore.consnumparc
                 with frame f-credscore color black/cyan
                      centered side-label row 5 .
            pause 0.                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-credscore on error undo.
                    run p-guardaval (input "Inclusao").                
                    create credscore.
                    credscore.desc-campo = "notacli".
                    do on error undo.
                    update
                         credscore.campo  label "Nota Cliente" format "x(5)"
                         skip
                         with frame f-mostra.
                    end.                         
                    update                         
                         credscore.tipo-vl  label  "Perc/Val"
                         skip
                         credscore.operacao   label "Dim/Som"
                         skip
                         credscore.valor label "Valor"
                         skip
                         credscore.consnumparc  label "Cons.Num.Parc.Pg"                         with frame f-mostra centered side-labels
                             color white/red row 8.
                     recatu1 = recid(credscore).
                     
                     run p-compval (input "Inclusao",
                                    input "notacli",
                                    input recatu1).
                                      
                     leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-credscore.
                    pause 0.                
                     disp
                         credscore.campo  label "Nota Cliente"
                         skip
                         credscore.tipo-vl  label  "Perc/Val"
                         skip
                         credscore.operacao   label "Dim/Som"
                         skip
                         credscore.valor label "Valor"
                         skip
                         credscore.consnumparc  label "Cons.Num.Parc.Pg"
                         with frame f-mostra centered side-labels
                             color white/red row 8.
                        pause 0.                             
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-credscore on error undo.
                     run p-guardaval (input "Alteracao").
                     find credscore where
                            recid(credscore) = recatu1 
                        exclusive.
                     pause 0.                        
                     update
                         credscore.campo  label "Nota Cliente"
                         skip
                         credscore.tipo-vl  label  "Perc/Val"
                         skip
                         credscore.operacao   label "Dim/Som"
                         skip
                         credscore.valor label "Valor"
                         skip
                         credscore.consnumparc  label "Cons.Num.Parc.Pg"                         with frame f-mostra centered side-labels
                             color white/red row 8.
                             
                     recatu1 = recid(credscore).
                     
                     run p-compval (input "Alteracao",
                                    input "notacli",
                                    input recatu1).
                              
                 end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" credscore.campo
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next credscore use-index credint2
                        where credscore.desc-campo = "notacli"
                        no-error.
                    if not available credscore
                    then do:
                        find credscore where recid(credscore) = recatu1.
                        find prev credscore
                            where credscore.desc-campo = "notacli"
                            no-error.
                    end.
                    recatu2 = if available credscore
                              then recid(credscore)
                              else ?.
                    run p-guardaval (input "Exclusao").
                    find credscore where recid(credscore) = recatu1
                            exclusive.
                    delete credscore.
                    run p-compval (input "Exclusao",
                                   input "notacli",
                                   input recatu1).
                    
                    recatu1 = recatu2.
                    leave.
                end.
                /***
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                /***
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lcredscore.p (input 0).
                    else run lcredscore.p (input credscore.campo).
                    leave.
                ***/    
                end.
                ***/
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
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(credscore).
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
display credscore.campo  column-label "Nota" format "x(5)"
        credscore.tipo-vl 
        credscore.operacao 
        credscore.valor
        credscore.consnumparc
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first credscore use-index credint2
            where credscore.desc-campo = "notacli"
                                                no-lock no-error.
    else  
        find last credscore use-index credint2
            where credscore.desc-campo = "notacli"
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next credscore use-index credint2
            where credscore.desc-campo = "notacli"
                                                no-lock no-error.
    else  
        find prev credscore use-index credint2
            where credscore.desc-campo = "notacli"
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev credscore use-index credint2
            where credscore.desc-campo = "notacli"  
                                        no-lock no-error.
    else   
        find next credscore use-index credint2
            where credscore.desc-campo = "notacli"
                                        no-lock no-error.
        
end procedure.

procedure p-compval.

def input parameter p-tipoalt as char.
def input parameter p-param   as char.
def input parameter p-recid   as recid.

if p-tipoalt <> "Exclusao"
then do:
    find first credscore where recid(credscore) = recatu1 no-lock. 
    dep-campo           = credscore.campo.
    dep-desc-campo      = credscore.desc-campo.
    dep-vl-ini          = credscore.vl-ini.
    dep-vl-fin          = credscore.vl-fin.
    dep-vl-char         = credscore.vl-char.
    dep-vl-log          = credscore.vl-log.
    dep-tipo-vl         = credscore.tipo-vl.
    dep-operacao        = credscore.operacao.
    dep-valor           = credscore.valor.
    dep-consnumparc     = credscore.consnumparc.
    dep-observacoes     = credscore.observacoes.
end.    
else do:
    dep-campo           = "".
    dep-desc-campo      = "".
    dep-vl-ini          = 0.
    dep-vl-fin          = 0.
    dep-vl-char         = "".
    dep-vl-log          = ?.
    dep-tipo-vl         = ?.
    dep-operacao        = ?.
    dep-valor           = 0.
    dep-consnumparc     = ?.
    dep-observacoes     = "".
end.

/***
if dep-campo <> ant-campo
then run p-gravalog (input p-param,
                     input "campo",
                     input ant-campo,
                     input dep-campo,
                     input p-tipoalt,
                     input p-recid). 

if dep-desc-campo <> ant-desc-campo
then run p-gravalog (input p-param,
                     input "desc-campo",
                     input ant-desc-campo,
                     input dep-desc-campo,
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-ini <> ant-vl-ini
then run p-gravalog (input p-param,
                     input "vl-ini" ,
                     input string(ant-vl-ini),
                     input string(dep-vl-ini),
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-fin <> ant-vl-fin
then run p-gravalog (input p-param,
                     input "vl-fin" ,
                     input string(ant-vl-fin),
                     input string(dep-vl-fin),
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-char <> ant-vl-char
then run p-gravalog (input p-param,
                     input "vl-char" ,
                     input ant-vl-char,
                     input dep-vl-char,
                     input p-tipoalt,
                     input p-recid). 

if dep-vl-log <> ant-vl-log
then run p-gravalog (input p-param,
                     input "vl-log" ,
                     input string(ant-vl-log),
                     input string(dep-vl-log),
                     input p-tipoalt,
                     input p-recid). 

if dep-tipo-vl <> ant-tipo-vl
then run p-gravalog (input p-param,
                     input "tipo-vl" ,
                     input string(ant-tipo-vl,"Perc/Val"),
                     input string(dep-tipo-vl,"Perc/Val"),
                     input p-tipoalt,
                     input p-recid). 

if dep-operacao <> ant-operacao
then run p-gravalog (input p-param,
                     input "operacao" ,
                     input string(ant-operacao,"Dim/Som"),
                     input string(dep-operacao,"Dim/Som"),
                     input p-tipoalt,
                     input p-recid). 

if dep-valor <> ant-valor
then run p-gravalog (input p-param,
                     input "valor" ,
                     input string(ant-valor),
                     input string(dep-valor),
                     input p-tipoalt,
                     input p-recid). 

if dep-consnumparc <> ant-consnumparc
then run p-gravalog (input p-param,
                     input "consnumparc" ,
                     input string(ant-consnumparc,"Sim/Nao"),
                     input string(dep-consnumparc,"Sim/Nao"),
                     input p-tipoalt,
                     input p-recid). 

if dep-observacoes <> ant-observacoes
then run p-gravalog (input p-param,
                     input "observacoes" ,
                     input ant-observacoes,
                     input dep-observacoes,
                     input p-tipoalt,
                     input p-recid). 
***/

find first credscorelog where credscorelog.funcod     = sfuncod
                          and credscorelog.datalog    = today
                          and credscorelog.hora       = time
                              exclusive-lock no-error.
if not avail credscorelog
then do:
    create credscorelog.
    credscorelog.funcod         = sfuncod.
    credscorelog.datalog        = today.
    credscorelog.hora           = time.
end.

credscorelog.tipoalt        = p-tipoalt.
credscorelog.campo          = ant-campo + " notacli".
credscorelog.desc-campo     = ant-desc-campo.
credscorelog.vl-ini         = ant-vl-ini.
credscorelog.vl-fin         = ant-vl-fin.
credscorelog.vl-char        = ant-vl-char.
credscorelog.vl-log         = ant-vl-log.
credscorelog.tipo-vl        = ant-vl-log.
credscorelog.operacao       = ant-operacao.
credscorelog.valor          = ant-valor.
credscorelog.consnumparc    = ant-consnumparc.
credscorelog.observacoes    = ant-observacoes.

end procedure.

procedure p-guardaval.

def input parameter p-tipoalt as char.

if p-tipoalt = "Inclusao"
then do:
    ant-campo           = "".
    ant-desc-campo      = "".
    ant-vl-ini          = 0.
    ant-vl-fin          = 0.
    ant-vl-char         = "".
    ant-vl-log          = ?.
    ant-tipo-vl         = ?.
    ant-operacao        = ?.
    ant-valor           = 0.
    ant-consnumparc     = ?.
    ant-observacoes     = "".
end.
else do:

    find credscore where recid(credscore) = recatu1 no-lock.
    
    ant-campo           = credscore.campo.
    ant-desc-campo      = credscore.desc-campo.
    ant-vl-ini          = credscore.vl-ini.
    ant-vl-fin          = credscore.vl-fin.
    ant-vl-char         = credscore.vl-char.
    ant-vl-log          = credscore.vl-log.
    ant-tipo-vl         = credscore.tipo-vl.
    ant-operacao        = credscore.operacao.
    ant-valor           = credscore.valor.
    ant-consnumparc     = credscore.consnumparc.
    ant-observacoes     = credscore.observacoes.
end.
end.
