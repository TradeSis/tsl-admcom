/* 05012022 helio iepro */

{admcab.i}

def input param poperacao   as char.
def input param pacao       as char.
def input param pativo      as char.
def input param ctitle      as char.

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcelas","",""].

def temp-table ttcomarca no-undo
    field cidcod    like munic.cidcod
    field qtd       as int.
    
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer btitulo for titulo.
def var vsel as int.
def var vabe as dec.

def var vvlcobrado   as dec.
    form  
        titprotesto.clicod 
/*        titprotesto.clicod                         column-label "cliente"*/
    
        clien.clinom  format "x(10)"
        titprotesto.nossonumero 
        titprotesto.vlcobrado  
        titprotesto.vlcustas
        titprotesto.pagacustas column-label "C"

        titprotesto.dtacao      column-label "acao"   format "999999"
        titprotesto.codocorrencia column-label "O" format "x"
        titprotesto.codirreg        
        titprotesto.situacao format "x(9)" column-label "Sit"
        
        with frame frame-a 9 down centered row 7
        no-box.



ctitle = ctitle + " / " + pacao + " " + pativo.
disp 
    ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.





disp 
    vvlcobrado    label "Filtrado"      format "zzzzzzzz9.99" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.



bl-princ:
repeat:
    
   vvlcobrado = 0.
   for each titprotesto where titprotesto.acao = pacao no-lock.
        vvlcobrado = vvlcobrado + titprotesto.vlcobrado.

   end.
    disp
        vvlcobrado
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

        esqcom1[1] = "parcelas". 
        esqcom1[2] = "".
        esqcom1[3] = "".
        esqcom1[4] = "historico".
        esqcom1[5] = "comarcas".

        if titprotesto.situacao = "DEVOLVIDO"
        THEN ESQCOM1[2] = "reenviar".
        
        if (titprotesto.acao = "REMESSA" or titprotesto.acao = "ARQUIVO")
                and titprotesto.dtacao = ?
        then esqcom1[2] = "eliminar".

        if titprotesto.acao = "ENVIADO"
        then esqcom1[2] = "desistir".
        
        if titprotesto.acao = "EM PROTESTO"
        then esqcom1[2] = "retirar".
        
        if  titprotesto.acao = "ARQUIVO" and  titprotesto.dtacao = ? and pacao = "ARQUIVO"
        then esqcom1[6] = "arquivo".        
                        
                     
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
        if titprotesto.pagacustas = no
        then vhelp = "Custas cliente - " .
        if titprotesto.situacao <> ""
        then vhelp = vhelp + titprotesto.situacao.    
        
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
        choose field clien.clinom
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
             if esqcom1[esqpos1] = "comarcas"
             then do: 
                run comarcas.
            end.

             if esqcom1[esqpos1] = "historico"
             then do: 
                run iep/tprothist.p            (recid(titprotesto)).
            end.
            
            if esqcom1[esqpos1] = "parcelas"
            then do:
                run iep/tprotparc.p (recid(titprotesto)).
                
                
                disp 
                    ctitle format "x(60)" no-label
                        with frame ftit.

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
                    message 
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
            if trim(esqcom1[esqpos1]) = "arquivo"
            then do:
               message 
                    "confirma gerar arquivos de REMESSA?" update sresp.
               if sresp
                then do:
                    run iep/biepremessaarquivo.p.                
                    return.
                end.     
            end.
            if trim(esqcom1[esqpos1]) = "reenviar"
            then do:
                if titprotesto.operacao = "IEPRO" and 
                   titprotesto.situacao = "DEVOLVIDO" and  
                   titprotesto.dtacao <> ?
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message 
                    "confirma REENVIAR o contrato selecionado proxima REMESSA?" update sresp.
                    if sresp
                    then  do on error undo: 
                        find current titprotesto exclusive.
                        titprotesto.remessa = ?.
                        titprotesto.ativo = "".
                        titprotesto.situacao = "".
                        titprotesto.acao = "REMESSA".
                        titprotesto.dtacao = ?.
                        titprotesto.codocorrencia = "".
                        titprotesto.codirreg = "".
                        titprotesto.protocolo = ?.
                        recatu1 = ?.
                        leave.
                    end.
                end.
            end.
            
            
            if trim(esqcom1[esqpos1]) = "desistir"
            then do:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.acao  = "ENVIADO" 
                then do:   
                    sresp = no.
                        hide message no-pause.
                    message "confirma desistir do contrato selecionado?" update sresp.
                    if sresp
                    then  do :
                        run iep/bproatualiza.p (recid(titprotesto),caps(trim(esqcom1[esqpos1]))).
                        recatu1 = ?.
                        leave.
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
  
    find clien where clien.clicod = titprotesto.clicod no-lock.
        
    display  
        
        clien.clinom
        titprotesto.clicod  

        titprotesto.nossonumero
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.situacao
        titprotesto.codocorrencia
        titprotesto.codirreg        

 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        clien.clinom

        
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.codocorrencia
        titprotesto.codirreg        

                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        clien.clinom

        
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        titprotesto.dtacao
        titprotesto.codocorrencia
        titprotesto.codirreg        
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        clien.clinom

        
        titprotesto.vlcobrado 
        titprotesto.vlcustas
        titprotesto.pagacustas
        
        titprotesto.dtacao  
        titprotesto.codocorrencia
        titprotesto.codirreg        
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if pacao = "ATUALIZAR"
then do:
    if par-tipo = "pri" 
    then do:
        find first titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.remessa <> ?       and  
                                      titprotesto.dtacao   = ?
            no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.remessa <> ?       and  

                                      titprotesto.dtacao   = ?
            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.remessa <> ?       and  

                                      titprotesto.dtacao   = ?
            no-lock no-error.
    end.    

end.
else do:
    if par-tipo = "pri" 
    then do:
        find first titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.acao = pacao and  
                                      titprotesto.ativo    = pativo  
            no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next titprotesto where  titprotesto.operacao = poperacao and
                                              titprotesto.acao = pacao and  
                                      titprotesto.ativo    = pativo        
            no-lock no-error.
    end.    

    if par-tipo = "up" 
    then do:
        find prev titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.acao = pacao and  
                                      titprotesto.ativo    = pativo      
            no-lock no-error.
    end.    
end.
        
end procedure.


    

procedure comarcas.
    def var vcidcod as int.
    def var vtot as int format ">>>>9" column-label "tot".

    if pacao = "ATUALIZAR"
    then do:
        for each titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.remessa <> ?       and  
                                      titprotesto.dtacao   = ?
            no-lock:
            if (titprotesto.protocolo = ? and titprotesto.acao = "REMESSA") or titprotesto.protocolo <> ?
            then.
            else next.

            find clien of titprotesto no-lock.
            
            find first munic where munic.cidnom = clien.cidade[1] no-lock no-error.
            if not avail munic
            then find first munic where munic.cidnom = "PORTO ALEGRE" no-lock no-error.
        
            if avail munic and munic.cidcod <> ? 
            then vcidcod = munic.cidcod.
            else vcidcod = 4314902.
    
            find first ttcomarca where ttcomarca.cidcod = vcidcod no-error.
            if not avail ttcomarca    
            then do:
                create ttcomarca.
                ttcomarca.cidcod = vcidcod.
            end.    
            ttcomarca.qtd = ttcomarca.qtd + 1.
            
        end.
    end.
    else do:    
        
        for each titprotesto where  titprotesto.operacao = poperacao and
                                      titprotesto.ativo    = pativo      
            no-lock:
            if (titprotesto.protocolo = ? and titprotesto.acao = "REMESSA") or titprotesto.protocolo <> ?
            then.
            else next.

            find clien of titprotesto no-lock.
            
            find first munic where munic.cidnom = clien.cidade[1] no-lock no-error.
            if not avail munic
            then find first munic where munic.cidnom = "PORTO ALEGRE" no-lock no-error.
        
            if avail munic and munic.cidcod <> ? 
            then vcidcod = munic.cidcod.
            else vcidcod = 4314902.
    
            find first ttcomarca where ttcomarca.cidcod = vcidcod no-error.
            if not avail ttcomarca    
            then do:
                create ttcomarca.
                ttcomarca.cidcod = vcidcod.
            end.    
            ttcomarca.qtd = ttcomarca.qtd + 1.
            
        end.
    end.
    pause before-hide.
    for each ttcomarca break by ttcomarca.qtd.
        find first munic where munic.cidcod = ttcomarca.cidcod no-lock.
        vtot = vtot + ttcomarca.qtd.
        disp munic.cidcod munic.cidnom format "x(20)"
            ttcomarca.qtd (total) vtot
            with title "COMARCAS" centered row 6 8 down.
    end.    
    pause.
                

end procedure.
