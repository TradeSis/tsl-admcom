/* helio #24102022 ID 154210 */
/* helio 19072022 - projeto Criar Produtos - ADM - tipoontratoSicred */
/* helio 13072022 - projeto Criar Produtos - ADM */

{admcab.i}

def buffer bsicred_planos for sicred_planos.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao","  "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
        
        with frame frame-a 8 down centered row 8.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find sicred_planos where recid(sicred_planos) = recatu1 no-lock.
    if not available sicred_planos
    then do.
        run pinclui (output recatu1).
        run pparametros.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(sicred_planos).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available sicred_planos
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find sicred_planos where recid(sicred_planos) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field sicred_planos.fincod

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail sicred_planos
                    then leave.
                    recatu1 = recid(sicred_planos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail sicred_planos
                    then leave.
                    recatu1 = recid(sicred_planos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail sicred_planos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail sicred_planos
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
            then do:
                hide frame f-com1 no-pause.

                run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                run pparametros.
                leave.
                
            end. 
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(sicred_planos).
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
    display  
        sicred_planos.fincod
  /*lista_produtos*/
  sicred_planos.qtd_vezes
  dtvigencia
  sicred_planos.produto_sicred
  sicred_planos.tipocontratosicred
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        sicred_planos.fincod
          /*lista_produtos*/
  sicred_planos.qtd_vezes
  dtvigencia
  sicred_planos.produto_sicred

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        sicred_planos.fincod
  /*lista_produtos*/
  sicred_planos.qtd_vezes
  dtvigencia
            sicred_planos.produto_sicred
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        sicred_planos.fincod
          /*lista_produtos*/
  sicred_planos.qtd_vezes
  dtvigencia
  sicred_planos.produto_sicred

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first sicred_planos
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next sicred_planos 
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev sicred_planos 
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current sicred_planos exclusive.
    disp sicred_planos.fincod sicred_planos.produto_sicred sicred_planos.tipocontratosicred dias_max_primeira qtd_vezes 
        /*lista_produtos */
        taxa_minima taxa_maxima dias_valido_emissao dias_min_privenc dias_max_venc dtvigencia
          sicred_planos.produto_sicred .
    update sicred_planos.fincod colon 20.
    update   sicred_planos.produto_sicred colon 20.
    update sicred_planos.tipocontratosicred colon 20.
        update dias_max_primeira colon 20.
  update qtd_vezes colon 20.
/*. update   lista_produtos   colon 20.  */
update   taxa_minima colon 20 
. update   taxa_maxima 
. update  dias_valido_emissao colon 20
. update  dias_min_privenc colon 20
. update   dias_max_venc 
. update  dtvigencia  colon 20
. update acrescimo_minimo colon 20 acrescimo_maximo
        with side-labels 
            row 9
            centered
               overlay.
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create sicred_planos.
    
    update
        sicred_planos.fincod
        with row 9 
        centered
        overlay.


end.


end procedure.


