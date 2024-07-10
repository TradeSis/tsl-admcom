/*
*
*    ttarq.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}
{tpalcis-wms.i}

def var par-tipo as char.
def new shared temp-table ttarq
    field Arquivo   as char format "x(25)"
    field tm        like tipo-alcis.tm format "x(45)" label "Tipo"
    field seq       as int.
    
def var vtm like ttarq.tm.
vtm = "".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Acao ","",""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def new shared temp-table ttheader
    field Tipo              as char format "x(4)"
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)"
    field Fornecedor        as char format "x(12)"
    field Arquivo           as char format "x(20)"
    index i1 proprietario fornecedor notafiscal
    .

def new shared temp-table ttitem 
    field Tipo              as char format "x(4)"
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)" 
    field Fornecedor        as char format "x(12)"
    field bloq              as char format "xx"
    field Qtde_no_Pack      as char format "x(18)"
    index i1 proprietario fornecedor notafiscal
    .

run diretorio.
    
bl-princ:
repeat:
    for each ttarq:
        find first ttheader where ttheader.arquivo = ttarq.arquivo no-error.
        if not avail ttheader
        then delete ttarq.
    end.        
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttarq where recid(ttarq) = recatu1 no-lock.
    if not available ttarq
    then do.
        message "Nenhum arquivos encontrado " par-tipo view-as alert-box.
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
        find first tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4) 
            no-lock no-error.
        if not avail tipo-alcis
        then next.    
            status default "".

            run color-message.
            choose field ttarq.Arquivo 
                help "Refresh de 15 segundos"
                pause 15
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            pause 0. 
            if lastkey = -1 
            then do:  
                hide frame frame-a no-pause.
                run diretorio.
                recatu1 = ?.
                next bl-princ. 
            end.
                                                                
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
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Acao "
            then do.
                sresp = no.
                message "Confirma gerar ORDV ?" update sresp.
                if sresp and search(tipo-alcis.acao) <> ?
                then do.
                    /*    
                    run value(tipo-alcis.acao) (ttarq.arquivo).
                    */
                    run ordv-PE-man.p(ttarq.arquivo).
                    pause 1 no-message.
                    run diretorio.
                    recatu1 = ?. 
                    next bl-princ.
                end.
            end.
            if esqcom1[esqpos1] = " Consulta "
            then run consulta-confrec-PE.p (ttarq.arquivo).
            if esqcom1[esqpos1] = " Filtro"
            then do:
                disp v-filtro format "x(40)"
                    with frame f-filtro centered no-label 1 column
                    overlay.
                choose field v-filtro with frame f-filtro.
                vtm = v-filtro[frame-index].
                recatu1 = ?.
                next bl-princ.
            end.
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
    display ttarq except seq
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        ttarq.Arquivo
        ttarq.tm
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        ttarq.Arquivo
        ttarq.tm
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttarq where (if vtm <> "" 
                             then ttarq.tm = vtm else true)
                    no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  ttarq where (if vtm <> "" 
                             then ttarq.tm = vtm else true)
                    no-lock no-error.
             
if par-tipo = "up" 
then find prev  ttarq where (if vtm <> "" 
                             then ttarq.tm = vtm else true)
                         no-lock no-error.
        
end procedure.


procedure diretorio.
    def var vi as int.
    def var varquivo as char.

    for each ttarq. delete ttarq. end.
    for each ttheader: delete ttheader. end.
    for each ttitem: delete ttitem. end.

    varquivo = "/admcom/relat/lealcis." + string(time).
    unix silent value("ls " + alcis-diretorio + " > " + varquivo).
    input from value(varquivo).
    
    repeat transaction.
        create ttarq.
        import ttarq.
        
        if substr(ttarq.arquivo,1,4) <> "CREC"
        then do.
            delete ttarq.
            next.
        end.
        
        find first tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4)
                        no-lock no-error.
        if avail tipo-alcis and
            (if vtm <> "" then tipo-alcis.tm = vtm else true)
        then do:                
            ttarq.tm  = tipo-alcis.tm.
            ttarq.seq = int(substr(ttarq.arquivo,5,5)).
            do vi = 1 to 5:
                if v-filtro[vi] = ""
                then do:
                    v-filtro[vi] = ttarq.tm.
                    leave.
                end.
                else if v-filtro[vi] = ttarq.tm
                     then leave.
            end.
        end.
        else do:
            delete ttarq.
        end.
    end.
    input close.
    unix silent value("rm -f " + varquivo).

    for each ttarq:
        run valida-arquivo-PE (ttarq.arquivo).    
        find first ttheader where ttheader.arquivo = ttarq.arquivo no-error.
        if avail ttheader 
        then do:
            if ttheader.tipo = "PE"
            then do:
                find first ttitem no-error.
                if not avail ttitem
                then do:
                    delete ttheader.
                    delete ttarq.
                end.    
            end.
            else do:
                for each ttitem where
                     ttitem.proprietario = ttheader.proprietario and
                     ttitem.fornecedor   = ttheader.fornecedor and
                     ttitem.notafiscal   = ttheader.notafiscal
                     .
                    delete ttitem.
                end.     
                delete ttheader.
                delete ttarq.
            end.
        end.
        else do:
            for each ttitem where
                     ttitem.proprietario = ttheader.proprietario and
                     ttitem.fornecedor   = ttheader.fornecedor and
                     ttitem.notafiscal   = ttheader.notafiscal
                     .
                delete ttitem.
            end.     
            delete ttarq.
        end.    
    end.    
end procedure.

procedure valida-arquivo-PE:

    def input parameter par-arq as char.
    def var varquivo as char.

    varquivo = alcis-diretorio + "/" + par-arq.
    unix silent value("quoter " + varquivo + " > ./consulta-crec.arq" ). 

    def var v as int.
    def var vlinha as char.
    /*
    for each ttheader: delete ttheader. end.
    for each ttitem: delete ttitem. end.
    */
    input from ./consulta-crec.arq.
    repeat.
        v = v + 1.
        import vlinha.
        if v = 1 then do.
            create ttheader.
            assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.NotaFiscal     = substr(vlinha,26,12)
               ttheader.Proprietario   = substr(vlinha,38,12)
               ttheader.Fornecedor     = substr(vlinha,50,12)
               ttheader.arquivo        = par-arq
               .
            next.
        end.
        create ttitem.
        assign ttitem.Remetente      = substr(vlinha,  1,10)
           ttitem.Nome_arquivo   = substr(vlinha, 11,04)
           ttitem.Nome_interface = substr(vlinha, 15,08)
           ttitem.Produto        = substr(vlinha, 23,40)
           ttitem.Quantidade     = substr(vlinha, 63,18)
           ttitem.NotaFiscal     = substr(vlinha, 81,12)
           ttitem.Proprietario   = substr(vlinha, 93,12)
           ttitem.Fornecedor     = substr(vlinha,105,12)
           ttitem.bloq           = substr(vlinha,117, 2)
           ttitem.Qtde_no_Pack   = substr(vlinha,119,18).
    end.
    input close.
    def var vitok as log.
    vitok = no.
    for each ttheader where ttheader.arquivo = par-arq:
        for each ttitem where
                 ttitem.proprietario = ttheader.proprietario and
                 ttitem.fornecedor   = ttheader.fornecedor and
                 ttitem.notafiscal   = ttheader.notafiscal
                 .
            find produ where produ.procod = int(ttitem.produto) 
                        no-lock no-error.
            if avail produ and produ.proipival = 1
            then assign
                    ttitem.tipo = "PE"
                    ttheader.tipo = "PE" .
            vitok = yes.
        end.        
        /*if not vitok
        then delete ttheader.     
        */
    end.
end procedure.
