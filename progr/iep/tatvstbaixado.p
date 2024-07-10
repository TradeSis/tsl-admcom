/* 05012022 helio iepro */                                          

{admcab.i}

def input param poperacao   as char.
def input param ctitle      as char.

def var pativo      as char init "BAIXADO".

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcelas","","","historico",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vsel as int.
def var vabe as dec.

def var vtitvlcob   as dec.
        
    form  
        titprotesto.clicod                         column-label "cliente"
    
        clien.clinom  format "x(10)"
        titprotesto.nossonumero 
        titprotesto.vlcobrado  
        titprotesto.vlcustas
        titprotesto.pagacustas

        titprotesto.dtacao      column-label "data"   format "999999"
        titprotesto.situacao
 
        
        with frame frame-a 9 down centered row 7
        no-box.


    ctitle = ctitle + " / " + caps(pativo).
disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.





disp 
    vtitvlcob    label "Filtrado"      format "zzzzzzzz9.99" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.



bl-princ:
repeat:
    
   vtitvlcob = 0.
       for each titprotesto where titprotesto.operacao = poperacao and
                                  titprotesto.ativo    = pativo no-lock.
            vtitvlcob = vtitvlcob + titprotesto.vlcobrado.
       end.
           
    disp
        vtitvlcob
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titprotesto where recid(titprotesto) = recatu1 no-lock.
    if not available titprotesto
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(titprotesto).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available titprotesto
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find titprotesto where recid(titprotesto) = recatu1 no-lock.

        find contrato of titprotesto no-lock.    
        esqcom1[2] = "".
        esqcom1[3] = "".
        esqcom1[4] = "historico". 

        if titprotesto.situacao = "CONFIRMADO" and 
           titprotesto.dtacao <> ? and
           titprotesto.acao <> "DESISTENCIA" and
           titprotesto.pagacustas
        then esqcom1[2] = "desistencia".
        if titprotesto.situacao = "CONFIRMADO" and 
           titprotesto.dtacao <> ? and
           titprotesto.acao <> "AUT.DESISTENCIA" and
           titprotesto.pagacustas = no
        then esqcom1[2] = "aut.desistencia".
        
        if titprotesto.situacao = "PROTESTADO" and 
           titprotesto.dtacao <> ? and
           titprotesto.acao <> "CANCELAMENTO" and
           titprotesto.pagacustas
        then esqcom1[2] = "cancelamento".
        if titprotesto.situacao = "PROTESTADO" and 
           titprotesto.dtacao <> ? and
           titprotesto.acao <> "AUT.CANCELAMENTO" and
           titprotesto.pagacustas = no
        then esqcom1[2] = "aut.cancelamento".

        
        
        if (titprotesto.situacao = "CONFIRMADO" or 
            titprotesto.situacao = "PROTESTADO") and 
           titprotesto.dtacao <> ? and titprotesto.acao = ""
        then esqcom1[3] = "pg custas".
        
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
        
    hide message no-pause.
    /*    
    if titprotesto.titdescjur <> 0
    then do:
        if titprotesto.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" titprotesto.dtinc "de R$" trim(string(titprotesto.titvljur + titprotesto.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(titprotesto.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" titprotesto.dtinc "de R$" trim(string(titprotesto.titvljur + titprotesto.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(titprotesto.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        if titprotesto.remessa <> ?
        then vhelp = "remessa " + string(titprotesto.remessa).
        
        if titprotesto.pagacustas = no
        then vhelp = vhelp + " Custas cliente - " .

        if titprotesto.situacao <> ""
        then vhelp = vhelp + " " + titprotesto.situacao.    
        
        if titprotesto.acao <> "" and titprotesto.dtacao = ?
        then vhelp = vhelp + " prox acao".
        if titprotesto.acao <> "" and titprotesto.dtacao <> ?
        then vhelp = vhelp + " ultima acao".
        
        if titprotesto.acao <> ""
        then vhelp = vhelp + " " + titprotesto.acao.    

        if titprotesto.acaooper <> ""
        then vhelp = vhelp + " / acao " + titprotesto.operacao +  " " + titprotesto.acaooper.    
        
        if titprotesto.dtacao <> ?
        then vhelp = vhelp + " em " + string(titprotesto.dtacao,"99/99/9999").    
        
        
        status default vhelp.
        choose field titprotesto.nossonumero
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
                    if not avail titprotesto
                    then leave.
                    recatu1 = recid(titprotesto).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titprotesto
                    then leave.
                    recatu1 = recid(titprotesto).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titprotesto
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titprotesto
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             if esqcom1[esqpos1] = "historico"
             then do: 
                run iep/tprothist.p            (recid(titprotesto)).
            end.

            if esqcom1[esqpos1] = "parcelas"
            then do:
                pause 0.
                run iep/tprotparc.p (recid(titprotesto)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
            
            if trim(esqcom1[esqpos1]) = "eliminar"
            then do:
                if titprotesto.operacao = "IEPRO" and 
                   titprotesto.acao = "REMESSA" and  
                   titprotesto.dtacao = ?
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "contrato" titprotesto.contnum 
                    "confirma eliminar o contrato selecionado da REMESSA?" update sresp.
                    if sresp
                    then  do on error undo: 
                        find current titprotesto exclusive.
                        delete titprotesto.
                        recatu1 = ?.
                        leave.
                    end.
                end.
            end.
            
            if trim(esqcom1[esqpos1]) = "desistencia"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "CONFIRMADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "contrato" titprotesto.contnum 
                    "confirma a desistencia do contrato selecionado?" update sresp.
                    if sresp
                    then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.dtacao = ?.
                            titprotesto.acao   = "DESISTENCIA".
                            titprotesto.acaooper = "".
                        end.    
                        recatu1 = ?.
                        leave.
                    end.
                end.
            end.
            if trim(esqcom1[esqpos1]) = "aut.desistencia"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "CONFIRMADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas = no
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "contrato" titprotesto.contnum 
                    "confirma autorizar a desistencia do contrato selecionado?" update sresp.
                    if sresp
                    then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.dtacao = ?.
                            titprotesto.acao   = "AUT.DESISTENCIA".
                            titprotesto.acaooper = "".
                            
                        end.    
                        recatu1 = ?.
                        leave.
                    end.
                end.
            end.
            if trim(esqcom1[esqpos1]) = "cancelamento"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "PROTESTADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "contrato" titprotesto.contnum 
                    "confirma o cancelamento do contrato selecionado?" update sresp.
                    if sresp
                    then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.dtacao = ?.
                            titprotesto.acao   = "CANCELAMENTO".
                            titprotesto.acaooper = "".
                            
                        end.    
                        recatu1 = ?.
                        leave.
                    end.
                end.
            end.
            if trim(esqcom1[esqpos1]) = "aut.cancelamento"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "PROTESTADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas = no
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "contrato" titprotesto.contnum 
                    "confirma autorizar o cancelamento do contrato selecionado?" update sresp.
                    if sresp
                    then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.dtacao = ?.
                            titprotesto.acao   = "AUT.CANCELAMENTO".
                            titprotesto.acaooper = "".
                            
                        end.    
                        recatu1 = ?.
                        leave.
                    end.
                end.
            end.
            

            if trim(esqcom1[esqpos1]) = "pg custas"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   (titprotesto.situacao = "CONFIRMADO" or titprotesto.situacao = "PROTESTADO")  and
                   titprotesto.dtacao   <> ?
                then do on error undo:   
                    find current titprotesto exclusive no-wait no-error.
                    if avail titprotesto
                    then do:
                        update titprotesto.pagacustas
                            help "C custas cliente - L custas Lebes"
                            with frame frame-a.
                    end.
                end.
            end.
            

            if trim(esqcom1[esqpos1]) = "retirar"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.acao  = "EM PROTESTO" 
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "contrato" titprotesto.contnum .
                    message "confirma autorizar a retirada do contrato selecionado?" update sresp.
                    if sresp
                    then  do :
                        run iep/bproatualiza.p (recid(titprotesto),caps(trim(esqcom1[esqpos1]))).
                        recatu1 = ?.
                        leave.
                    end.
                end.
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
        recatu1 = recid(titprotesto).
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
    find clien of titprotesto no-lock.  
    display  
        clien.clinom
        titprotesto.clicod  

        titprotesto.nossonumero
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.situacao


        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        clien.clinom
        titprotesto.clicod  

        titprotesto.nossonumero
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.situacao


                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        clien.clinom
        titprotesto.clicod  

        titprotesto.nossonumero
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.situacao

                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        clien.clinom
        titprotesto.clicod  

        titprotesto.nossonumero
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.situacao

 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find first titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.ativo    = pativo       
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.ativo    = pativo  

            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find prev titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.ativo    = pativo                                        
            no-lock no-error.

    end.  
        
end procedure.





