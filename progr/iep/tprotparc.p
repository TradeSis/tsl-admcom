/* 05012022 helio iepro */

{admcab.i}
def input param precid as recid.
def var vhrinc as char column-label "hora".
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcela","",""].

form
    esqcom1
    with frame f-com1 row 7 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer btitulo for titulo.
def var vsel as int.
def var vabe as dec.

def var  vtitvlcob like titprotparc.titvlcob.
def var  vtitvljur like titprotparc.titvljur.
def var  vtitdescjur like titprotparc.titdescjur.
def var  vtitvlrcustas like titprotparc.titvlrcustas.

def var vvlcobrado   as dec.
    form  
        titprotparc.contnum
        titprotparc.titpar
        titprotparc.dtinc column-label "inclusao"
        vhrinc format "99999"
        titprotparc.titvlcob
        titprotparc.titvljur
        titprotparc.titdescjur
        titprotparc.titvlrcustas
         vvlcobrado    column-label "total"       format ">>>>>9.99" 

        with frame frame-a 7 down  row 8.



find titprotesto where recid(titprotesto) = precid no-lock.

disp 
    titprotesto.clicod titprotesto.contnum
        with frame ftit
            side-labels
            row 5
            centered
            no-box
            color messages.





disp 
    space(33)
    vtitvlcob      
    vtitvljur   
    vtitdescjur    
    vtitvlrcustas   

    
    vvlcobrado    column-label "total"       format ">>>>>9.99" 
        with frame ftot
             no-underline
            row screen-lines - 2            width 80
            no-box.



bl-princ:
repeat:
    
   vvlcobrado = 0.
       vtitvlcob = 0.
    vtitvljur = 0.
    vtitdescjur = 0.
    vtitvlrcustas = 0.

   for each titprotparc of titprotesto no-lock.
        vvlcobrado = vvlcobrado + (titprotparc.titvlcob + titprotparc.titvljur + titprotparc.titvlrcustas).
        vtitvlcob = vtitvlcob + titprotparc.titvlcob.
        vtitvljur = vtitvljur +  titprotparc.titvljur.
        vtitdescjur = vtitdescjur +  titprotparc.titdescjur.
        vtitvlrcustas = vtitvlrcustas +  titprotparc.titvlrcustas.

   end.

    disp
    vtitvlcob
    vtitvljur
    vtitdescjur
    vtitvlrcustas

        vvlcobrado
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titprotparc where recid(titprotparc) = recatu1 no-lock.
    if not available titprotparc
    then do.
        message "nenhum registro encontrato".
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(titprotparc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available titprotparc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find titprotparc where recid(titprotparc) = recatu1 no-lock.

        esqcom1[2] = "".

        
                        
                     
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
        
    hide message no-pause.

        
    if titprotparc.titdescjur <> 0
    then do:
        if titprotparc.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" titprotparc.dtinc "de R$" trim(string(titprotparc.titvljur + titprotparc.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(titprotparc.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" titprotparc.dtinc "de R$" trim(string(titprotparc.titvljur + titprotparc.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(titprotparc.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
/*        vhelp = "".
        
        status default vhelp. */
        choose field titprotparc.contnum
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

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
                    if not avail titprotparc
                    then leave.
                    recatu1 = recid(titprotparc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titprotparc
                    then leave.
                    recatu1 = recid(titprotparc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titprotparc
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titprotparc
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            

            if esqcom1[esqpos1] = "parcela"
            then do:
                find contrato of titprotparc no-lock.
                find titulo where titulo.empcod = 19 and titulo.titnat = no and
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
                    titulo.titpar = titprotparc.titpar
                no-lock.       

                 run bsfqtitulo.p (recid(titulo)).

                disp 
                        with frame ftit.
                
            end.
            
            
            
           /*     
            if esqcom1[esqpos1] = " <enviar>"
            then do: 
                disp caps(esqcom1[esqpos1]) @ esqcom1[esqpos1] with frame f-com1.

                do with frame fcab
                        row 6 centered
                    side-labels overlay
                    title " acao ".

                    update  skip(1)
                            ttfiltros.arrastaparcelasvencidas        label "ARRASTO NO MESMO CONTRATO - todas as parcelas          ?"    colon 60.
                    if ttfiltros.arrastaparcelasvencidas = yes
                    then ttfiltros.arrastaparcelas = no.
                    else do:
                        update            
                            ttfiltros.arrastaparcelas                label "                          - todas as parcelas vencidas ?"    colon 60.
                    end.
                    update  skip(1)
                            ttfiltros.arrastacontratosvencidos        label "ARRASTO OUTROS CONTRATOS  - todos os contratos         ?"    colon 60.
                    if ttfiltros.arrastacontratosvencidos = yes
                    then ttfiltros.arrastacontratos = no.
                    else do:
                        update            
                            ttfiltros.arrastacontratos               label "                             todos os contratos vencidos?"    colon 60
                            skip(1).
                    end.
                
                    message "confirma enviar registros macados para " poperacao "?" update sresp.
                    if sresp
                    then  run iep/ptitpenvia.p (input poperacao).
                    
                    return.
                end.
            end.
           */
                
             
        end. 
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(titprotparc).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
  
    find clien where clien.clicod = titprotparc.clicod no-lock.
        
    display  
        
        titprotparc.contnum
        titprotparc.titpar
        titprotparc.dtinc
      string(titprotparc.hrinc,"HH:MM") @ vhrinc
        titprotparc.titvlcob
        titprotparc.titvljur
        titprotparc.titdescjur
        titprotparc.titvlrcustas
        titprotparc.titvlcob + titprotparc.titvljur + titprotparc.titvlrcustas  @ vvlcobrado  
 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        titprotparc.contnum
        titprotparc.titpar
        titprotparc.dtinc
        vhrinc
        titprotparc.titvlcob
        titprotparc.titvljur
        titprotparc.titdescjur
        titprotparc.titvlrcustas
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        titprotparc.contnum
        titprotparc.titpar
        titprotparc.dtinc
        vhrinc
        titprotparc.titvlcob
        titprotparc.titvljur
        titprotparc.titdescjur
        titprotparc.titvlrcustas
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        titprotparc.contnum
        titprotparc.titpar
        titprotparc.dtinc
        vhrinc
        titprotparc.titvlcob
        titprotparc.titvljur
        titprotparc.titdescjur
        titprotparc.titvlrcustas
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find first titprotparc of titprotesto
            no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next titprotparc of titprotesto
            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev titprotparc of titprotesto
            no-lock no-error.
    end.    

        
end procedure.





