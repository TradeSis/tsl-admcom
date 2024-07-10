/* helio 10082022 - acordo online */ 

{admcab.i}
def input param ptpnegociacao as char.
def input param par-clicod like clien.clicod .

/**def var vhostname as char.
input through hostname.
import vhostname.
input close.**/


 
 
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" acordos"," condicoes "," contratos","  "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vmessage as log.
vmessage = yes.

{aco/acordo.i new}

def buffer bttnegociacao for ttnegociacao.


    form  
        aconegoc.negcod column-label "ID"  format ">>9"
        aconegoc.negnom column-label "companha" format "x(22)"
        ttnegociacao.qtd format ">>>>"    column-label "qtd"  
        ttnegociacao.vlr_aberto     format    ">>>>>>9.99" column-label "aberto"
        ttnegociacao.vlr_divida     format    ">>>>>>9.99" column-label "divida"

        /*ttnegociacao.dt_venc  column-label "venc"     format    "999999"
        ttnegociacao.dias_atraso column-label "dias"     format    "->>>9"
        **/
        ttnegociacao.qtd_selecionado format ">>>>"    column-label "sel"  
        ttnegociacao.vlr_selaberto   format    ">>>>>>9.99" column-label "sel aberto"

        ttnegociacao.vlr_selecionado format    ">>>>>>9.99" column-label "sel total"
        
        with frame frame-a 8 down centered row 8
        no-box.

find clien where clien.clicod = par-clicod no-lock.
def var ptitle as char.
ptitle = "NEGOCIACOES " + ptpnegociacao .
          
    disp clien.clicod label "Cli" clien.clinom no-label format "x(36)"
         clien.dtcad no-label format "99/99/9999"
         clien.etbcad label "Fil Cad "
            with frame fcli row 3 side-labels width 80 
        title ptitle 1 down.


run cob/ajustanovacordo.p (input clien.clicod, output p-temacordo).

if not p-temacordo
then esqcom1[1] = "".
 
run calcelegiveis (input ptpnegociacao, input par-clicod, ?).



bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttnegociacao where recid(ttnegociacao) = recatu1 no-lock.
    if not available ttnegociacao
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttnegociacao).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttnegociacao
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttnegociacao where recid(ttnegociacao) = recatu1 no-lock.
        find aconegoc of ttnegociacao no-lock.

        status default "".
        
                        
                     
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field aconegoc.negnom

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
                    if not avail ttnegociacao
                    then leave.
                    recatu1 = recid(ttnegociacao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttnegociacao
                    then leave.
                    recatu1 = recid(ttnegociacao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttnegociacao
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttnegociacao
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            if esqcom1[esqpos1] = " acordos "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.  
                run cob/mostraacordo.p(input clien.clicod, input "PENDENTE").
            end.
            if esqcom1[esqpos1] = " contratos "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                recatu2 = recatu1.
                run aco/tnegctr.p (ttnegociacao.negcod). 
                run montacampanha.
                recatu1 = recatu2. 
                leave.
                
            end.
            if esqcom1[esqpos1] = " condicoes "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                recatu2 = recatu1.
                run aco/tnegcond.p (ttnegociacao.negcod, par-clicod). 
                recatu1 = recatu2. 
                leave.
                
            end. 
            if esqcom1[esqpos1] = " parametros "
            then do:
                disp
                    aconegoc with 1 col row 9 centered
                    overlay
                    frame fpar.
                pause.
                hide frame fpar no-pause.    
            end.
            
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttnegociacao).
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
    find aconegoc of ttnegociacao no-lock.
    display  
        aconegoc.negcod
        aconegoc.negnom
        ttnegociacao.qtd 
        ttnegociacao.vlr_divida
        ttnegociacao.vlr_aberto  
/*        ttnegociacao.dt_venc
        ttnegociacao.dias_atraso*/
        ttnegociacao.qtd_selecionado
        ttnegociacao.vlr_selecionado
        ttnegociacao.vlr_selaberto
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    aconegoc.negcod
        aconegoc.negnom
        ttnegociacao.qtd 
        ttnegociacao.vlr_divida
        ttnegociacao.vlr_aberto  
/*        ttnegociacao.dt_venc
        ttnegociacao.dias_atraso*/
        
        ttnegociacao.qtd_selecionado
        ttnegociacao.vlr_selecionado
        ttnegociacao.vlr_selaberto
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
    aconegoc.negcod
        aconegoc.negnom
        ttnegociacao.qtd 
        ttnegociacao.vlr_divida
        ttnegociacao.vlr_aberto  
/*                ttnegociacao.dt_venc
        ttnegociacao.dias_atraso*/

        ttnegociacao.qtd_selecionado
        ttnegociacao.vlr_selecionado
        ttnegociacao.vlr_selaberto
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
    aconegoc.negcod
        aconegoc.negnom
        ttnegociacao.qtd 
        ttnegociacao.vlr_divida
        ttnegociacao.vlr_aberto   
/*                ttnegociacao.dt_venc
        ttnegociacao.dias_atraso*/

        ttnegociacao.qtd_selecionado
        ttnegociacao.vlr_selecionado
        ttnegociacao.vlr_selaberto
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttnegociacao  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttnegociacao  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev ttnegociacao  where
                no-lock no-error.

end.    
        
end procedure.


/* procedure foram para dentro do fin/novcamp.i */


