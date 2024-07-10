

/*
*
*    plani.p    -    Esqueleto de Programacao    com esqvazio

*
*/

{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def new shared temp-table tt-movim like movim.
def new shared temp-table tt-plani like plani.

def var vetbcod         as int initial 200.
def var vmovtdc-ini     as int initial 990.

/*
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
*/

def var esqcom1         as char format "x(14)" extent 5
   initial ["Busca NF","Confirma Receb"," " , " ", " "].


def var esqcom2         as char format "x(12)" extent 5
            initial ["  "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["  ",
             " Liberar Pedido ",
             " Cancelar Pedido ",
             " Consulta  da plani ",
             " Listagem  Geral de plani "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bplani       for plani.
def buffer bpedid         for pedid.
def buffer bliped         for liped.
def var vplani         like plani.numero.

def var vval-boletopag-aux    as char .

def var vcont        as integer.
def var vcep-aux     as char.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
form 
     plani.numero   label "Pedido"                    colon 11          
     pedid.peddat     label "Data"                      colon 40         skip
     pedid.clfcod     label "Cliente"  format ">>>>>>>>>9"  colon 11            
     clien.clinom     label "Nome"     format "x(15)"       colon 40     skip
     vval-boletopag-aux   label "Vl.Pag Boleto"              colon 40 skip
         with frame f-libera side-labels centered row 05.

                 
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
        find plani where recid(plani) = recatu1 no-lock.
    if not available plani
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available plani
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
            
            find plani where recid(plani) = recatu1 no-lock.
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(plani.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(plani.numero)
                                        else "".
            run color-message.
            choose field plani.numero help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    if not avail plani
                    then leave.
                    recatu1 = recid(plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail plani
                    then leave.
                    recatu1 = recid(plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.                        
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if esqvazio
        then do:
        
            hide frame f-plani.

            display "(( Nao existem pedidos pendentes para o E-Commerce. ))"
                        with frame f-sem-pedidos color black/cyan
                                 no-box no-labels centered row 11.

            pause.
            return "end-error".
        
        end.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form plani.numero
                 with frame f-plani color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-plani on error undo.
                    create plani.
                    update plani.numero.
                    recatu1 = recid(plani).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-plani.
                    disp plani.numero
                         plani.movtdc.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-plani on error undo.
                    find plani where
                            recid(plani) = recatu1 
                        exclusive.
                    update plani.numero.
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de " plani.numero.
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next plani where true no-error.
                    if not available plani
                    then do:
                        find plani where recid(plani) = recatu1.
                        find prev plani where true no-error.
                    end.
                    recatu2 = if available plani
                              then recid(plani)
                              else ?.
                    find plani where recid(plani) = recatu1
                            exclusive.
                    delete plani.
                    recatu1 = recatu2.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lplani.p (input 0).
                    else run lplani.p (input plani.numero).
                    leave.
                end.
                
                if esqcom1[esqpos1] = "Busca NF"
                then do with frame f-busca-ped:
                
                    sresp = no.
                    message "Deseja Conectar no Ábacos e buscar"
                            "novas Notas Fiscais?"
                                          update sresp.
                                
                    if sresp
                    then do:
                
                        run /admcom/web/progr_e/busca_notas_disp.p.

                        next bl-princ.

                    end.
                
                end.
                
                if esqcom1[esqpos1] = "Confirma Receb"
                then do with frame f-conf-receb:
                
                    sresp = no.
                    message "Deseja confirmar o recebimento da Nota Fiscal  "
                            plani.numero  "?"    
                                update sresp.
                                
                    if sresp
                    then do:
                                       /*
                        run /admcom/web/progr_e/confirma_receb_ped.p
                                        (input plani.numero,
                                         input plani.movtdc).

                        next bl-princ.
                                         */
                    end.
                
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
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
        recatu1 = recid(plani).
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

define variable vcha-boleto-pago as character. /* guarda o asterisco dos boletos pagos*/

find first clien where clien.clicod = plani.desti no-lock no-error.

display plani.numero column-label "Ped."
        plani.desti format ">>>>>>>>>9" column-label "Cli Dest"
        clien.clinom format "x(20)" column-label "Nome"  when avail clien
        plani.pladat column-label "Data"
        plani.movtdc format ">>>9" column-label "Tipo"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        plani.numero
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        plani.numero
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first plani where plani.etbcod = vetbcod
                           and plani.movtdc >= vmovtdc-ini 
                                                  no-lock no-error.
    else  
        find last plani  where plani.etbcod = vetbcod
                           and plani.movtdc >= vmovtdc-ini
                                                   no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next plani where plani.etbcod = vetbcod
                          and plani.movtdc >= vmovtdc-ini
                                                  no-lock no-error.
    else  
        find prev plani where plani.etbcod = vetbcod
                          and plani.movtdc >= vmovtdc-ini
                                                  no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev plani where plani.etbcod = vetbcod
                          and plani.movtdc >= vmovtdc-ini
                                                  no-lock no-error.
    else   
        find next plani where plani.etbcod = vetbcod
                          and plani.movtdc >= vmovtdc-ini
                                                  no-lock no-error.
        
end procedure.
         
         
procedure p-libera-ped:

    find bpedid where rowid(bpedid) = rowid(pedid)
                      exclusive-lock no-error.
                    
    if available bpedid
    then do:
                      
        assign bpedid.sitped = "E"
               bpedid.vencod = sfuncod.
                        
    end.
                    
    run /admcom/progr/atu-status-plani.p (input plani.numero,
     
    input "Pagamento Confirmado, Pedido liberado para Separação.").
         
end procedure.         
