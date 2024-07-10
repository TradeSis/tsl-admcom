

/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

/*
*
*    ttarq.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}
{alcis/tpalcis.i}

return. /* virou tudo para projeto neogrid , abas/ */

/****
setbcod = 900.

def var vtipo as char init "FCGL".

def temp-table ttarq
    field Arquivo   as char format "x(15)"
    field etbori    like wmsarq.etbori
    field etbdes    like wmsarq.etbdes
    field itens     like wmsarq.itens
    field gaiola    like wmsarq.gaiola
    field Origem    as char format "x(7)".
    
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Consulta ", " Emissao NFE", ""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

find tipo-alcis where tipo-alcis.tp = vtipo no-lock.
run diretorio.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttarq where recid(ttarq) = recatu1 no-lock.
    if not available ttarq
    then do.
        message "Sem arquivos" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttarq).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttarq
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttarq where recid(ttarq) = recatu1 no-lock.
        find tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4) no-lock.

        status default "".

        run color-message.

        choose field ttarq.Arquivo 
                help "Refresh de 30 segundos"
                pause 30
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 

        if lastkey = -1 
        then do:  
            run diretorio.
            next bl-princ. 
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
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

/***
            if esqcom1[esqpos1] = " Acao "
            then do.
                sresp = no.
                message "Confirma" tipo-alcis.tm "?" update sresp.
                if sresp
                then do.
                    run alcis/fcgl_acao.p (ttarq.arquivo).
                    pause 1 no-message.
                    run diretorio.
                    next bl-princ.
                end.
            end.
***/
            if esqcom1[esqpos1] = " Emissao NFE "
            then do.
                run alcis/fcgl_acao_it.p (ttarq.arquivo).
                run diretorio.
                next bl-princ.
            end.
            if esqcom1[esqpos1] = " Consulta "
            then run value(tipo-alcis.consulta) (ttarq.arquivo).
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttarq).
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
    display ttarq
        with frame frame-a 11 down centered color white/red row 5
            title tipo-alcis.tm.
end procedure.

procedure color-message.
    color display message
        ttarq.Arquivo
        ttarq.etbori
        ttarq.etbdes
        ttarq.itens
        ttarq.gaiola
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        ttarq.Arquivo
        ttarq.etbori
        ttarq.etbdes
        ttarq.itens
        ttarq.gaiola
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttarq  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  ttarq  no-lock no-error.
             
if par-tipo = "up" 
then find prev  ttarq  no-lock no-error.
        
end procedure.


procedure diretorio.

    def var varq_aux as char.
    def var vlinha   as char.
    def var vAdmcom  as log.
    def var vItim    as log.

    recatu1 = ?.
    for each ttarq.
        delete ttarq.
    end.

    varq_aux = "/admcom/relat/lealcis." + string(time).
    unix silent value("ls " + alcis-diretorio + " > " + varq_aux).
    input from value(varq_aux).
    repeat transaction.
        create ttarq.
        import ttarq.

        if vtipo <> substr(ttarq.arquivo,1,4)
        then do.
            delete ttarq.
            next.
        end.
    end.
    input close.
    unix silent value("rm -f " + varq_aux).

    for each ttarq.
        assign
            vAdmcom = no
            vItim   = no.

        input from value(alcis-diretorio + "/" + ttarq.arquivo).
        repeat.
            import unformatted vlinha.
            if substr(vlinha,15,8 ) = "FCGLH"
            then
                assign
                    ttarq.etbori = int( substr(vlinha,26,12) )
                    ttarq.etbdes = int( substr(vlinha,38,12) )
                    ttarq.gaiola = int( substr(vlinha,50,11) )
                    ttarq.Itens  = int( substr(vlinha,61, 3) ).
            if substr(vlinha,15,8 ) = "FCGLI"
            then do.
                if substr(vlinha,128,32) = "" or
                   substr(vlinha,128,32) = "99999" or
                   substr(vlinha,128,32) = fill("0", 20)
                then vAdmcom = yes.
                if length( substr(vlinha,128,32) ) = 20 and
                   (substr(vlinha,128,32) <> "" and
                    substr(vlinha,128,32) <> "99999" and
                    substr(vlinha,128,32) <> fill("0", 20))
                then vItim = yes.
                vAdmcom = yes.
            end.
        end.

        if vAdmcom and vItim
        then ttarq.origem = "Adm/Iti".
        else if vAdmcom
        then ttarq.origem = "Admcom".
        else ttarq.origem = "Itim".

        input close.
    end.    
    
    /*neo*/    
    for each ttarq.
                /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = ttarq.etbdes and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today >= wfilvirada
                   or avail ttpiloto  /* Troca a Situacao para  Lojas Piloto */
                then do:
                    delete ttarq.    
                end.            
    end.
    /*neo*/
end procedure.


****/
