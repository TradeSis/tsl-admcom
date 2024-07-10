/* Gerson - Alterei a Procedure litura - Troquei a ordem da leitura 
            deve aparecer de forma decendente
   Data   - 24/11/2006
*/    

{admcab.i}   

def var scar as log.
def var iacaocod    like acao.acaocod.

find first acao no-lock no-error.
if not avail acao
then do:
    message "Nenhuma acao gerada".
    pause 2 no-message.
    leave.
end.

def buffer bacao for acao.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Participantes ", " Metrica "," Etiquetas "," Manutencao  "," Busca "].

def var esc-fil as char format "x(20)" extent 4
    initial [" 1. Geral       ",
             " 2. Detalhada   ",
             " 3. Teste       ",
             " 4. Int.Compras "].
             
def var esc-fil1 as char format "x(24)" extent 3
    initial [" 1. Exclui Acao ",
             " 2. Altera Acao ",
             " 3. Exclui Participante "].             

def var esqcom2         as char format "x(15)" extent 5
            initial [" Arquivo Cartão"," Import. Arq.","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def var vacao         like acao.acaocod.

def var vint-fabcod as integer no-undo.

def shared var vetbcod like estab.etbcod.

def buffer crm for ncrm.

def temp-table tt-etiqueta                                    no-undo
    field xrecid    as recid
    field codigo    as inte   form ">>>>>>>>>>999"
    field seq as int 
    field cep as int format "99999999"
    field local as char
    .

def temp-table tt-etqu
    field clicod like clien.clicod
    field clinom like clien.clinom format "x(30)"
    field recencia as date format "99/99/9999"
    field frequencia as int label "Freq" format ">>>9"
    field valor as dec format ">>>,>>9.99"
    field rfv as int format "999"
    index iclicod as primary unique clicod
    index irec    recencia   descending
    index ifre    frequencia descending
    index ival    valor      descending
    index iclinom clinom
    index icod    clicod.

/* ------------------------------------------------------------------------- */

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
        find acao where recid(acao) = recatu1 no-lock.
    if not available acao
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(acao).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available acao
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
            find acao where recid(acao) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(acao.descricao)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(acao.descricao)
                                        else "".
            run color-message.
            choose field acao.acaocod acao.descricao help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
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
                    if not avail acao
                    then leave.
                    recatu1 = recid(acao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail acao
                    then leave.
                    recatu1 = recid(acao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail acao
                then next.
                color display white/red acao.acaocod
                                        acao.descricao
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail acao
                then next.
                color display white/red acao.acaocod
                                        acao.descricao with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.            

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Participantes "
                then do on error undo:

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                   
                    run crm20-part2.p(acao.acaocod).
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                    
                    recatu1 = ?.
                    leave.

                end.
                
                if esqcom1[esqpos1] = " Metrica "
                then do on error undo:
                    
                    view frame frame-a. pause 0.

                    disp  skip(1)
                          esc-fil[1] skip 
                          esc-fil[2] skip
                          esc-fil[3] skip
                          esc-fil[4] skip
                          with frame f-esc-fil title " Metrica " row 7
                             centered color with/black no-label overlay. 
    
                    choose field esc-fil auto-return with frame f-esc-fil.
                    
                    clear frame f-esc-fil no-pause.
                    hide frame f-esc-fil no-pause.
                    
                    if frame-index = 1
                    then do:
                   
                        /************************************************** 
                           Se dentro do programa for acionado o filtro por                                  fabricante o programa retorna informando o fabricante                            para ser executado novamente. 
                         **************************************************/
                        
                        assign vint-fabcod = 0.
                        
                        bloco_metricas:   
                        repeat:
                            
                            run crm20-metr.p(input        acao.acaocod,
                                             input-output vint-fabcod).
                            
                            if vint-fabcod = 0
                                or keyfunction(lastkey) = "END-ERROR"
                            then do:
                            
                                leave bloco_metricas.
                            
                            end.
                            
                        end.

                    end.
                    else 
                    if frame-index = 2
                    then do:
                        run crm20-metr2.p (acao.acaocod).
                    end.
                    if frame-index = 3
                    then do:
                        run crm20-metr3.p (acao.acaocod).
                    end.
                    if frame-index = 4
                    then do:
                        run crm20-metr4.p (acao.acaocod).
                    end.
                    
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                    recatu1 = ?.
                    leave.
                    
                end.
                if esqcom1[esqpos1] = " Etiquetas "
                then do on error undo:
                    
                    view frame frame-a. pause 0.
                    /*
                    disp  skip(1)
                          esc-fil[1] skip 
                          esc-fil[2] skip(1)
                          with frame f-esc-fil title " Etiquetas " row 7
                             centered color with/black no-label overlay. 
    
                    choose field esc-fil auto-return with frame f-esc-fil.
                    */
                    clear frame f-esc-fil no-pause.
                    hide frame f-esc-fil no-pause.
                    /*
                    if frame-index = 1
                    then
                        run crm20-metr.p(acao.acaocod).
                    else
                    if frame-index = 2
                    then
                        run crm20-metr2.p(acao.acaocod).
                    */
                    
                    run pi-etiquetas.
                    
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                    recatu1 = ?.
                    leave.
                    
                end.
                if esqcom1[esqpos1] = " Manutencao "
                then do on error undo:
                    
                    view frame frame-a. pause 0.
                    
                    disp  skip(1)
                          esc-fil1[1] skip 
                          esc-fil1[2] skip
                          esc-fil1[3] skip(1)
                          with frame f-esc-fil1 title " Manutencao " row 7
                             centered color with/black no-label overlay. 
    
                    choose field esc-fil1 auto-return with frame f-esc-fil1.
                    
                    clear frame f-esc-fil1 no-pause.
                    hide frame f-esc-fil1 no-pause.
                    
                    if frame-index = 1
                    then
                        run crm20-excac.p.
                    else
                    if frame-index = 2
                    then
                        run crm20-altac.p.
                    else
                    if frame-index = 3
                    then 
                        run crm20-excpa.p.
                
                    
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                    recatu1 = ?.
                    leave.
                    
                end.
                
                if esqcom1[esqpos1] = " Busca "
                then do on error undo:
                      run leitura (input "pri").
                      assign iacaocod = 0.
                      pause 0 no-message.
                      update iacaocod label "Acao"
                             with side-label width 30 title "BUSCA"
                                  at row 10 col 10 frame f-bus overlay.
                      find last acao where true and
                                acao.acaocod = iacaocod no-lock no-error.
                      if not avail acao
                      then do:
                              message "Acao nao encontrada!" view-as alert-box.
                              
                              run leitura (input "pri").
                              
                              find last acao where true no-lock no-error.                             end.
                      hide frame f-bus.
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                pause 0.        
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Arquivo Cartao"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    scar = no.

                    run mensagem.p(input-output scar,
                    input "!SIM = GERAR PARA TODOS OS PARTICIPANTES " +
                     "!NAO = GERAR PARA QUEM NAO TEM ",
                    input " Arquivo para CARTAO ",
                    input "   SIM",
                    input "   NAO").

                    run arqcar01.p(input acao.acaocod, scar).

                    view frame f-com1.
                    view frame f-com2.
                    
                    leave.
                    
                end.
                
                if esqcom2[esqpos2] = " Import. Arq."            
                then do:
                
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.    
                    scar = no.
                                        
                    run p-importa-clientes(input acao.acaocod).
                    
                    view frame f-com1.
                    view frame f-com2.

                end.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(acao).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        find first acao where acao.acaocod = 0 no-error.
        if avail acao
        then
            delete acao.
        recatu1 = ?.    
            
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
display acao.acaocod   column-label "Acao"    format ">>>>>9"
        acao.descricao column-label "Descricao" format "x(34)"
        acao.dtini     column-label "Inicio"
        acao.dtfin     column-label "Final"
        acao.valor     column-label "Valor"
        with frame frame-a 11 down centered color white/red row 5
                title " Acoes ".
end procedure.
procedure color-message.
    color display message
            acao.acaocod
            acao.descricao
            acao.dtini
            acao.dtfin
            acao.valor
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        acao.acaocod
        acao.descricao
        acao.dtini
        acao.dtfin
        acao.valor
        with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.

/*       
assign iacaocod = 0.        
update iacaocod  label "Busca"
       with frame f-busca width 20 at col 10 row 10
            title "BUSCA ACAO".
              
if iacaocod = 0
then do:
*/
    if par-tipo = "pri" 
    then  
        if esqascend  
        then  
            find last acao where true
                                                no-lock no-error.
        else  
           find first acao  where true
                                                 no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then  
       if esqascend  
       then  
            find next acao  where true
                                                no-lock no-error.
       else  
            find prev acao   where true
                                                no-lock no-error.
             
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev acao where true  
                                                no-lock no-error.
        else   
            find next acao where true 
                                                no-lock no-error.
/*
end.
else do:
        find first acao where
                   acao.acaocod = iacaocod no-lock no-error.
end.
*/        
end procedure.
         
procedure pi-etiquetas:


for each tt-etqu: 
    delete tt-etqu. 
end.

for each tt-etiqueta:
    delete tt-etiqueta.
end.    

def var vacaocod   like acao.acaocod.
def var rd-selecao as inte 
    view-as radio-set horizontal radio-buttons
            "Acao", 1,
            "Filtro", 2
            size 59 by 1.19.  

     
update rd-selecao label "TIPO ETIQUETA"
       with frame f-etqUpd side-labels 1 col 1 down
            title "<F1> - Confirma - <BARRA ESPACO> - Marca".
       

hide frame f-etqUpd.

if input rd-selecao = 1
then do:
        update vacaocod  at 01
               with frame f-updacao side-labels 1 col 1 down
                    width 80 title "SELECAO ACAO".

        find first acao where
                   acao.acaocod = input vacaocod no-lock no-error.
        if not avail acao
        then do:
                message "Acao nao encontrada, favor verificar!"
                        view-as alert-box.
                undo, retry.         
        end.
        else do:

                for each acao-cli where
                         acao-cli.acaocod = acao.acaocod no-lock:

                    find tt-etqu where 
                         tt-etqu.clicod = acao-cli.clicod no-error.
                    if not avail tt-etqu
                    then do:
                            create tt-etqu.
                            assign tt-etqu.clicod     = acao-cli.clicod.
                    end.
                    
                end.   
           
        end.
        hide frame f-updacao.
end.
if input rd-selecao = 2
then do:
        for each crm where 
                 crm.etbcod = (if vetbcod = 0
                               then crm.etbcod 
                               else vetbcod) no-lock:
                          
                if crm.mostra = no then next.
                find tt-etqu where 
                     tt-etqu.clicod = crm.clicod no-error.
                if not avail tt-etqu
                then do:
                        create tt-etqu.
                        assign tt-etqu.clicod     = crm.clicod
                               tt-etqu.clinom     = crm.nome
                               tt-etqu.recencia   = crm.recencia
                               tt-etqu.frequencia = crm.frequencia
                               tt-etqu.valor      = crm.valor
                               tt-etqu.rfv        = crm.rfv.
       
                end.
        end.
end. /* fecha 2. if rd-selecao */

def var p-nomarq  as char form "x(8)".

def var chora    as char form "x(06)".
    
assign chora = substring(string(time,"HH:MM:SS"),1,2) +
               substring(string(time,"HH:MM:SS"),4,2) +
               substring(string(time,"HH:MM:SS"),7,2).

assign p-nomarq = "crmmal" + chora.   
 
def var vcep as int format "99999999".

for each tt-etqu no-lock:

   for each clien where 
            clien.clicod = tt-etqu.clicod no-lock:
       find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
       if avail cpclien and cpclien.correspondencia = no
       then next.
       create tt-etiqueta.
       assign tt-etiqueta.xrecid = recid(clien)
              tt-etiqueta.codigo = clien.clicod.
        /*
        if num-entries(clien.cep[1],"-") = 1
        then do:
            message clien.cep[1]. pause.
            vcep = int(entry(1,clien.cep[1],"-") +
                   entry(2,clien.cep[1],"-")).
            message vcep. pause.       
        end.*/
        vcep = int(substr(clien.cep[1],1,8)).
        if length(string(vcep)) < 8 and
        vcep <> 0
        then repeat:
            vcep = int(string(vcep) + "0").
            if length(string(vcep)) = 8
            then leave.
        end.
       
       find first ordemcep where
                  ordemcep.ufecod = clien.ufecod[1] and
                  ordemcep.inicial <= vcep and
                  ordemcep.final >= vcep
                  no-lock no-error.
       if avail ordemcep
       then assign
              tt-etiqueta.seq = ordemcep.sequencia
              tt-etiqueta.cep = vcep
              tt-etiqueta.local = ordemcep.amarrado.
    end.
end.
run  etqmal1a.p (input table tt-etiqueta,
                 input p-nomarq).


end procedure.

procedure p-importa-clientes:

    def input parameter ipint-acao as integer no-undo.
    
    def var vcha-nomearq    as character format "x(40)"  no-undo.
    def var vint-codcli-aux as integer no-undo.
    
    if not can-find (first acao where acao.acaocod = ipint-acao)
    then do:
    
        message "Acao nao encontrada.".
        pause.
        
        undo, retry.
    
    end.
    
    if can-find (first acao-cli where acao-cli.acaocod = ipint-acao)
    then do:
    
       message "A Acao selecionada ja possui participantes, importacao cancelada".
       pause.
       undo, retry.
    
    end.
    else do: 
        
        if opsys = "UNIX"
        then assign vcha-nomearq = "/admcom/relat-cartao/".
        else assign vcha-nomearq = "l:~\relat-cartao~\".
        
        update vcha-nomearq
            with no-label title "Digite o nome do arquivo"
                at row 12 col 23 frame f-nome-arq overlay.
       
        input from value(vcha-nomearq).
      
        hide frame f-nome-arq no-pause.

        repeat:

            assign vint-codcli-aux = 0. 
        
            import vint-codcli-aux.

            if can-find(first clien where clien.clicod = vint-codcli-aux)
                and vint-codcli-aux > 0
            then do:

                run p-executa-import (input vint-codcli-aux,
                                      input ipint-acao).  
                       
                disp acao-cli.clicod
                       with no-label title "Importando Cliente..."
                                at row 12 col 23 frame f-imp-cliente overlay.

                pause 0.
                
            end.       
        end.      
              
        hide frame f-imp-cliente no-pause.      
        
    end. 
         
end procedure.

procedure p-executa-import:

   def input parameter ipint-clicod   as integer no-undo.
   def input parameter ipint-acao-cod as integer no-undo.
   
   create acao-cli.
   assign acao-cli.acaocod = ipint-acao-cod
          acao-cli.clicod  = ipint-clicod.

end procedure.
