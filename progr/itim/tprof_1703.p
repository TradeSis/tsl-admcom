/*
*
*    prof_1703.p    -    Esqueleto de Programacao    com esqvazio


            substituir    prof_1703
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
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," ADMCOM ", 
            " Integra "," Desintegra ", "  "].
def var esqcom2         as char format "x(15)" extent 5
            initial ["1720Etb/Prod","1763 Planos","1701 AprovPrices","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def input parameter par-rec as char.

find prof_1521 where recid(prof_1521) = int(par-rec) no-lock no-error.
if avail prof_1521
then
    display prof_1521.SUB_EVENT_ID format "x(15)"
                LINKED_SUB_EVENT_ID format "x(30)"
            with frame frame-xxa 1 down centered row 3
                    no-underline no-label no-box color message
                            width 81 .

def buffer bprof_1703       for prof_1703.
def var vprof_1703         like prof_1703.OFFER_ID.


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
        find prof_1703 where recid(prof_1703) = recatu1 no-lock.
    if not available prof_1703
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else leave.

    recatu1 = recid(prof_1703).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prof_1703
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
            find prof_1703 where recid(prof_1703) = recatu1 no-lock.


            esqcom1[1] = " Consulta ".
            esqcom1[2] = " ADMCOM ". 
            esqcom1[3] = " Integra ".
            esqcom1[4] = " Desintegra ". 
            esqcom1[5] = "  ".

            if  prof_1703.OFFER_TYPE_ID = "SIMPLE" or
                prof_1703.dtintegracao <> ?
            then   
                assign esqcom1[3] = ""
                       esqcom1[4] = "".
            
            if  prof_1703.OFFER_TYPE_ID = "COMPLEX" and
                prof_1703.dtintegracao <> ?
            then do.    
                find first ctpromoc  where
                    ctpromoc.OFFER_ID = prof_1703.OFFER_ID and
                    ctpromoc.linha = 0 
                    no-lock no-error.
                if avail ctpromoc and
                   ctpromoc.situacao = "L"
                then assign esqcom1[3] = ""
                            esqcom1[4] = "".
                if avail ctpromoc and
                   ctpromoc.situacao = "M"
                then assign esqcom1[3] = ""
                            esqcom1[4] = " Desintegra ".            
                if avail ctpromoc and
                   ctpromoc.situacao = "ERR"
                then assign esqcom1[3] = " Erro "
                            esqcom1[4] = " Desintegra ".                
            end.
            if prof_1703.dtintegracao = ?
            then esqcom1[4] = "".       /*esqcom1[3] = " Integra ".
                                        esqcom1[4] = " Desintegra ".
                                        */
            esqcom1[3] = "".
            esqcom1[4] = "".
            
            display esqcom1
                    with frame f-com1.
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prof_1703.OFFER_ID)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prof_1703.OFFER_ID)
                                        else "".
            run color-message.
            choose field prof_1703.OFFER_ID help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
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
                    if not avail prof_1703
                    then leave.
                    recatu1 = recid(prof_1703).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prof_1703
                    then leave.
                    recatu1 = recid(prof_1703).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prof_1703
                then next.
                color display white/red prof_1703.OFFER_ID with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prof_1703
                then next.
                color display white/red prof_1703.OFFER_ID with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form    
            OFFER_DESC format "x(60)"
                    ACTIVITY_DESC format "x(50)"
                    OFFER_COMMENTS format "x(50)"
                    SPECIAL_INSTRUCTIONS format "x(50)"
                    MENSAGEM_NA_TELA format "x(50)"
                 INTERVALO_VAL_DE
                 INTERVALO_VAL_ATE
                 INTERVALO_QTD_DE
                 INTERVALO_QTD_ATE
                 INTERVALO_A_VISTA
                 
                 with frame f-prof_1703 color black/cyan
                      centered side-label row 5 4 column.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Erro "
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    display 
                        substr(prof_1703.ErroIntegra,  1,78) format "x(78)" skip
                        substr(prof_1703.ErroIntegra, 79,78) format "x(78)" skip
                        substr(prof_1703.ErroIntegra,157,78) format "x(78)" 

                        with frame ferro no-box color message
                                        no-label
                                    row 10.
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = " ADMCOM "
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run itim/CTpromoc.p (input prof_1703.offer_id).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = " Integra "
                then do with frame f-prof_170311111 on error undo.
                    run itim/integra_1703.p (input recid(prof_1703)).
                    leave.
                end.
                if esqcom1[esqpos1] = " desIntegra "
                then do with frame f-prof_170311eee111 on error undo.
                    sresp = no.
                    update sresp.
                    if sresp 
                    then do.
                        def var par-sequencia like ctpromoc.sequencia.
                        par-sequencia = 0.
                        find current prof_1703.
                        def buffer bctpromoc for ctpromoc.
                        if prof_1703.offer_id <> ""
                        then do.
                            for each ctpromoc where 
                                        ctpromoc.offer_id = prof_1703.offer_id.
                                par-sequencia = ctpromoc.sequencia.
                                delete ctpromoc.
                                /*
                                for each bctpromoc where 
                                         bctpromoc.sequencia = par-sequencia.
                                    delete bctpromoc.
                                end.
                                */
                            end.
                            for each ctpromoc where 
                                     ctpromoc.sequencia = par-sequencia.
                                delete ctpromoc.
                            end.
                        end.
                        prof_1703.dtint = ?.
/******************
connect -db adm.db -S 1904 -N tcp -H filial189 -ld adm_189 no-error.

if connected("adm_189")
then do.
    run envia_189.p ( input par-sequencia , input "DEL" ).
    if connected("adm_189")
    then do.
        disconnect adm_189.
    end.
end.
*****************/
                                            
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-prof_1703.
                    update prof_1703 except OFFER_ID
                                          SUB_EVENT_ID
                                          EVENT_ID
                                          ORIGIN_ID
                                          EVENT_DESC
                                          SUB_EVENT_DE
                                          ACTIVITY_DES
                                          BASE_PRICE_TYPE
                                          ACTIVITY_ID
                                          ACTIVITY_DES.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "1720Etb/Prod"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run itim/prof_1720.p (input recid(prof_1703)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "1763 Planos"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run itim/prof_1763.p (input recid(prof_1703)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "1701 AprovPrices"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run itim/prof_1701.p (input recid(prof_1703)).
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
        recatu1 = recid(prof_1703).
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
{itim/OFFER_TYPE.i}

    find first ctpromoc  where
                    ctpromoc.OFFER_ID = prof_1703.OFFER_ID and
                    ctpromoc.linha = 0 
                    no-lock no-error.

display prof_1703.OFFER_ID 
        OFFER_DESC format "x(14)"
        ctpromoc.sequencia when avail ctpromoc format ">>>>>"
                                            column-label "Promocao"
        ctpromoc.situacao when avail ctpromoc label "Sit" format "xxx"
        OFFER_TYPE_I format "x(18)" 
        OFFER_TYPE format "x(16)"
       /*     vOFFER_TYPE format "x(22)"*/
       /*TIPO_OFERTA_ADMCOM column-label "Tipo" format "x(5)"*/
        dtintegracao = ? no-label format "/I"
        with frame frame-a 11 down centered color white/red row 5
                title " 1703 - Offer  "  .
end procedure.
procedure color-message.
color display message
        prof_1703.OFFER_ID
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        prof_1703.OFFER_ID
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prof_1703 where  
                        (if par-rec = "MENU" 
                         then true 
                         else prof_1703.SUB_EVENT_ID = prof_1521.SUB_EVENT_ID)
                                                no-lock no-error.
    else  
        find last prof_1703  where 
                        (if par-rec = "MENU" 
                         then true 
                         else prof_1703.SUB_EVENT_ID = prof_1521.SUB_EVENT_ID)
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prof_1703  where 
                        (if par-rec = "MENU" 
                         then true 
                         else prof_1703.SUB_EVENT_ID = prof_1521.SUB_EVENT_ID)
                                                no-lock no-error.
    else  
        find prev prof_1703   where 
                    (if par-rec = "MENU"  
                     then true   
                     else prof_1703.SUB_EVENT_ID = prof_1521.SUB_EVENT_ID)
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prof_1703 where 
                        (if par-rec = "MENU" 
                         then true 
                         else prof_1703.SUB_EVENT_ID = prof_1521.SUB_EVENT_ID)  
                                        no-lock no-error.
    else   
        find next prof_1703 where 
                        (if par-rec = "MENU" 
                         then true 
                         else prof_1703.SUB_EVENT_ID = prof_1521.SUB_EVENT_ID) 
                                        no-lock no-error.
        
end procedure.
         
