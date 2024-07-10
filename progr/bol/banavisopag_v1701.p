/*     bol/banavisopag.p
*
*/
{cabec.i}
def var vbusca as char.
def var vtotal as int.
def var vcusto as dec.

def var par-busca       as   char.
def buffer xestab for estab.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" avisopag ", "  ", "  ", "", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","","","",""].
def var esqhel1         as char format "x(80)" extent 5.
    def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.

def var vtime        as int.
def var vct          as int.

pause 0 before-hide.
form with frame f-proc.


def buffer bbanavisopag    for banavisopag.

def temp-table ttavisopag
    field marca   as log format "*/ "
    field rec     as recid
    field cdoperacao like banavisopag.cdoperacao
    field Situacao like banavisopag.Situacao
    index x cdoperacao desc
    index y Situacao cdoperacao desc.

def buffer bttavisopag for ttavisopag.    
def buffer xbanavisopag for banavisopag. 
def buffer xttavisopag for ttavisopag.
    
form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    
def var vchoose as char format "x(40)"  extent 5
            init [" TODOS",
                  " Pendentes Envio ao Banco   ",
                  " Enviados ao Banco, Pendentes de retorno ",
                  " Liquidados ",
                  " Baixados "].
                  
def var tchoose as char format "x(15)"  extent 5
            init ["GERAL",
                  "PEN", 
                  "ENV",
                  "LIQ",
                  "BAI"].
def var vindex as int.
def var ptitle as char.

def var pchoose as char label "Situacao".
def var par-cdoperacao like banavisopag.cdoperacao.
def var par-emissao as log format "Sim/Nao" label "Filtra Emissao".
    def var par-dtemiini as date format "99/99/99" label "de".
    def var par-dtemifim as date format "99/99/99" label "ate".
def var par-envio as log format "Sim/Nao" label "Filtra Envio".
    def var par-dtenvini as date format "99/99/99" label "de".
    def var par-dtenvfim as date format "99/99/99" label "ate".
def var par-pagamento as log format "Sim/Nao" label "Filtra Pagamento".
    def var par-dtpagini as date format "99/99/99" label "de".
    def var par-dtpagfim as date format "99/99/99" label "ate".
def var par-baixa as log format "Sim/Nao" label "Filtra Baixa".
    def var par-dtbaiini as date format "99/99/99" label "de".
    def var par-dtbaifim as date format "99/99/99" label "ate".
def var par-vencimento as log format "Sim/Nao" label "Filtra Vencimento".
    def var par-dtvenini as date format "99/99/99" label "de".
    def var par-dtvenfim as date format "99/99/99" label "ate".



    form
       /** ttavisopag.marca  format " / " column-label "" **/
        banavisopag.cdoperacao
        banavisopag.dtvencimento
        banavisopag.clifor
        banavisopag.vlcobrado
        banavisopag.dtbaixa
        banavisopag.situacao column-label "Sit"
        with frame frame-a 
        12 down centered color white/red row 4
                          title ptitle width 80.
                          

form with frame flinha down no-box.
form 
         par-cdoperacao   colon 30  
         pchoose    format "x(30)"      colon 30
         par-vencimento       colon 30
             par-dtvenini   
             par-dtvenfim

         par-emissao        colon 30
             par-dtemiini   
             par-dtemifim
         par-envio        colon 30
             par-dtenvini   
             par-dtenvfim
         par-pagamento        colon 30
             par-dtpagini   
             par-dtpagfim
         par-baixa        colon 30
             par-dtbaiini   
             par-dtbaifim
         with frame fcab
            row 3 centered side-labels
            title "Filtros Controle de avisopag".

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first ttavisopag no-lock no-error.
if not avail ttavisopag
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    leave.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttavisopag where recid(ttavisopag) = recatu1 no-lock.
    if not available ttavisopag
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttavisopag).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttavisopag
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
            find ttavisopag where recid(ttavisopag) = recatu1 no-lock.
            find banavisopag where recid(banavisopag) = ttavisopag.rec no-lock.

            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(banavisopag.cdoperacao)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(banavisopag.cdoperacao)
                                        else "".

            choose field banavisopag.cdoperacao help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 F8 PF8 I i
                      tab PF4 F4 ESC return).
            
            if keyfunction(lastkey) = "CLEAR"     or
               keyfunction(lastkey) = "I"
            then do: 
                recatu2 = ?.                
                hide frame frame-a no-pause.
                run mdfe/manviagem.p (input-output recatu2).  
                find banavisopag where recid(banavisopag) = recatu2 no-lock no-error.
                if avail banavisopag
                then do:
                    recatu1 = ?.
                    run montatt.
                    leave.
                end.
            end.
 
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca label "Busca"
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                find first bbanavisopag where bbanavisopag.cdoperacao = (vbusca)
                                    no-lock no-error.
                if avail bbanavisopag
                then do.
                    create ttavisopag.
                    ttavisopag.rec     = recid(bbanavisopag).
                    ttavisopag.cdoperacao = bbanavisopag.cdoperacao.
                    recatu1 = recid(ttavisopag).
                end.
                else do:
                    recatu1 = recatu2.
                    message "OS nao encontrada".
                    pause 1 no-message.
                end.    
                leave.
            end.

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
                    if not avail ttavisopag
                    then leave.
                    recatu1 = recid(ttavisopag).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttavisopag
                    then leave.
                    recatu1 = recid(ttavisopag).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttavisopag
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttavisopag
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-etiqest color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " avisopag "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = recid(banavisopag).
                    run bol/banavisopagman_v1701.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
                if esqcom1[esqpos1] = " Nova "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = ?.
                    run mdfe/manviagem.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
                

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Filtros" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pfiltros.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = "Relatorio" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run relatorio.
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
        recatu1 = recid(ttavisopag).
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
end.

procedure frame-a.
    find banavisopag where recid(banavisopag) = ttavisopag.rec no-lock.

    
    disp
        banavisopag.cdoperacao
        banavisopag.dtvencimento
        banavisopag.clifor
        banavisopag.vlcobrado
        banavisopag.dtbaixa
        banavisopag.situacao 
        with frame frame-a.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    find first ttavisopag use-index y no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    find next ttavisopag use-index y no-error.
if par-tipo = "up" 
then                  
    find prev ttavisopag use-index y no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    for each xttavisopag no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.
end procedure.


procedure montatt.

    for each ttavisopag.
        delete ttavisopag.
    end.

    if par-cdoperacao <> ""
    then do:
        for each banavisopag where 
            banavisopag.cdoperacao = par-cdoperacao no-lock.
            run criatt.
        end.
        leave.
    end.

    hide message no-pause.

    if pchoose = "GERAL" or
       pchoose = "PEN"      /* Pendentes de Envio ao Banco */
    then 
        for each banavisopag where
            banavisopag.dtenvio = ?
            no-lock. 
            
            if par-emissao
            then if banavisopag.dtemissao >= par-dtemiini and
                    banavisopag.dtemissao <= par-dtemifim
                 then. else next.
            if par-envio
            then if banavisopag.dtenvio >= par-dtenvini and
                    banavisopag.dtenvio <= par-dtenvfim
                 then. else next.
            if par-pagamento
            then if banavisopag.dtpagamento >= par-dtpagini and
                    banavisopag.dtpagamento <= par-dtpagfim
                 then. else next.
            if par-baixa
            then if banavisopag.dtbaixa >= par-dtbaiini and
                    banavisopag.dtbaixa <= par-dtbaifim
                 then. else next.
            if par-vencimento
            then if banavisopag.dtvencimento >= par-dtvenini and
                    banavisopag.dtvencimento <= par-dtvenfim
                 then. else next.

        run criatt.
    
    end. /** PEN **/
    if pchoose = "GERAL" or
       pchoose = "ENV"      /* Pendentes de Retorno do Banco **/
    then 
        for each banavisopag where
            banavisopag.dtbaixa = ?
            no-lock. 
            
            if par-emissao
            then if banavisopag.dtemissao >= par-dtemiini and
                    banavisopag.dtemissao <= par-dtemifim
                 then. else next.
            if par-envio
            then if banavisopag.dtenvio >= par-dtenvini and
                    banavisopag.dtenvio <= par-dtenvfim
                 then. else next.
            if par-pagamento
            then if banavisopag.dtpagamento >= par-dtpagini and
                    banavisopag.dtpagamento <= par-dtpagfim
                 then. else next.
            if par-baixa
            then if banavisopag.dtbaixa >= par-dtbaiini and
                    banavisopag.dtbaixa <= par-dtbaifim
                 then. else next.
            if par-vencimento
            then if banavisopag.dtvencimento >= par-dtvenini and
                    banavisopag.dtvencimento <= par-dtvenfim
                 then. else next.

        run criatt.
    
    end. /** ENV **/
    if pchoose = "GERAL" or
       pchoose = "LIQ"      /* Liquidados, precisa Periodo **/
    then 
        for each banavisopag where
            banavisopag.dtpagamento >= par-dtpagini and
            banavisopag.dtpagamento <= par-dtpagfim
            no-lock. 
            
            if par-emissao
            then if banavisopag.dtemissao >= par-dtemiini and
                    banavisopag.dtemissao <= par-dtemifim
                 then. else next.
            if par-envio
            then if banavisopag.dtenvio >= par-dtenvini and
                    banavisopag.dtenvio <= par-dtenvfim
                 then. else next.
            if par-pagamento
            then if banavisopag.dtpagamento >= par-dtpagini and
                    banavisopag.dtpagamento <= par-dtpagfim
                 then. else next.
            if par-baixa
            then if banavisopag.dtbaixa >= par-dtbaiini and
                    banavisopag.dtbaixa <= par-dtbaifim
                 then. else next.
            if par-vencimento
            then if banavisopag.dtvencimento >= par-dtvenini and
                    banavisopag.dtvencimento <= par-dtvenfim
                 then. else next.

        run criatt.
    
    end. /** LIQ **/
    if pchoose = "GERAL" or
       pchoose = "BAI"      /* Baixados, precisa Periodo **/
    then 
        for each banavisopag where
            banavisopag.dtbaixa >= par-dtbaiini and
            banavisopag.dtbaixa <= par-dtbaifim
            no-lock. 
            
            if par-emissao
            then if banavisopag.dtemissao >= par-dtemiini and
                    banavisopag.dtemissao <= par-dtemifim
                 then. else next.
            if par-envio
            then if banavisopag.dtenvio >= par-dtenvini and
                    banavisopag.dtenvio <= par-dtenvfim
                 then. else next.
            if par-pagamento
            then if banavisopag.dtpagamento >= par-dtpagini and
                    banavisopag.dtpagamento <= par-dtpagfim
                 then. else next.
            if par-baixa
            then if banavisopag.dtbaixa >= par-dtbaiini and
                    banavisopag.dtbaixa <= par-dtbaifim
                 then. else next.
            if par-vencimento
            then if banavisopag.dtvencimento >= par-dtvenini and
                    banavisopag.dtvencimento <= par-dtvenfim
                 then. else next.

        run criatt.
    
    end. /** ENV **/
       
    run ptotal.
                             
end procedure.


procedure criatt.

 
    /**
    if vfretpcod <> "GERAL" and frete.fretpcod <> vfretpcod 
    then next.
    **/

    create ttavisopag.
    ttavisopag.rec   = recid(banavisopag).
    ttavisopag.cdoperacao = banavisopag.cdoperacao.
    ttavisopag.Situacao = banavisopag.Situacao.
    
end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.

procedure pfiltros.

repeat.
    ptitle = "".

    par-cdoperacao = "".
    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    update par-cdoperacao when keyfunction(lastkey) <> "I" and
                      keyfunction(lastkey) <> "CLEAR"
        go-on(F8 PF8)
    with frame fcab.
    if keyfunction(lastkey) = "CLEAR" or 
       keyfunction(lastkey) = "I"
    then     do: 
        recatu2 = ?. 
        /*run mdfe/manviagem.p (input-output recatu2).  */
        find banavisopag where recid(banavisopag) = recatu2 no-lock no-error.
        if avail banavisopag
        then do:
            par-cdoperacao = banavisopag.cdoperacao.
            return.
        end.
        else do:
            undo.
        end.
    end.

    find banavisopag where banavisopag.cdoperacao = par-cdoperacao 
        no-lock no-error.
    if par-cdoperacao <> ""
    then do:
        if not avail banavisopag
        then do:
            message "avisopag Inexistente".
            undo.
        end.
        else do.
            if avail banavisopag
            then do:
                
                ptitle = string(banavisopag.cdoperacao).
                
                recatu1 = ?.
                run montatt.
                return.
            end.        
        end.
    end.

    display vchoose
        with frame fff centered row 5 no-label overlay 1 col.
    choose field vchoose with frame fff.                         
    pchoose =  tchoose[frame-index].
    vindex = frame-index.
    
    hide frame fff no-pause.
    ptitle =  pchoose + "-" + vchoose[vindex] .
    
    disp pchoose + "-" + vchoose[vindex] @ pchoose with frame fcab.

    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    do:
        update par-vencimento with frame fcab.
        if keyfunction(lastkey) = "GO" and 
           par-vencimento = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        if par-vencimento
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtvenini = ?
            then assign
                    par-dtvenini = today
                    par-dtvenfim = today.
            
            update par-dtvenini
                   par-dtvenfim
                with frame fcab.
            if par-dtvenini = ? or 
               par-dtvenfim = ? or
               par-dtvenfim < par-dtvenini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
    end.
    
     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    
    update par-emissao  with frame fcab.
    if keyfunction(lastkey) = "GO" and 
       par-emissao = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.

    if par-emissao
    then do:
        hide message no-pause.
        message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
        if par-dtemiini = ?
        then assign
                par-dtemiini = today
                par-dtemifim = today.
        
        update par-dtemiini
               par-dtemifim
            with frame fcab.
        if par-dtemiini = ? or 
           par-dtemifim = ? or
           par-dtemifim < par-dtemiini
        then do:
            message "Datas Invalidas".
            undo.
        end.
    end.
    if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.

     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    
    if pchoose = "PEN"
    then par-envio = no.
    else do:
        update par-envio with frame fcab.
        if keyfunction(lastkey) = "GO" and 
           par-envio = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        if par-envio
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando~ F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtenvini = ?
            then assign
                    par-dtenvini = today
                    par-dtenvfim = today.
            
            update par-dtenvini
                   par-dtenvfim
                with frame fcab.
            if par-dtenvini = ? or 
               par-dtenvfim = ? or
               par-dtenvfim < par-dtenvini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
    end.
    
    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
     
    if pchoose = "PEN" or
       pchoose = "ENV"
    then par-pagamento = no.
    else do:
        if pchoose = "LIQ"
        then do:
            par-pagamento = yes.
            disp par-pagamento with frame fcab.
        end.
        else update par-pagamento with frame fcab.
        
        if keyfunction(lastkey) = "GO" and 
           par-pagamento = no and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        if par-pagamento
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtpagini = ?
            then assign
                    par-dtpagini = today
                    par-dtpagfim = today.
            update par-dtpagini
                   par-dtpagfim
                with frame fcab.
            if par-dtpagini = ? or 
               par-dtpagfim = ? or
               par-dtpagfim < par-dtpagini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        if keyfunction(lastkey) = "GO" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
    end.
    
     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
     if pchoose = "PEN" or
       pchoose = "ENV" or
       pchoose = "LIQ"
    then par-baixa = no.
    else do:
        if pchoose = "BAI"
        then do:
            par-baixa = yes.
            disp par-baixa with frame fcab.
        end.    
        else
            update par-baixa with frame fcab.
        if keyfunction(lastkey) = "GO" and 
           par-baixa = no
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        if par-baixa
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtbaiini = ?
            then assign
                    par-dtbaiini = today
                    par-dtbaifim = today.
            
            update par-dtbaiini
                   par-dtbaifim
                with frame fcab.
            if par-dtbaiini = ? or 
               par-dtbaifim = ? or
               par-dtbaifim < par-dtbaiini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        if keyfunction(lastkey) = "GO"
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
    end.
    

    leave.

end.
recatu1 = ?.

run montatt.


end procedure.

