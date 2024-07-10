/*************************************************************************
*
*    Programa de Importação de divergencias de Coletor NF Transferencia.
     trimnot.p 
     Criado: 14/10/2009
     Autor : Antonio Maranghello
*    Observaçao : Salvo em movim.ocnum[5]
*************************************************************************/
def var vtipocol   as char format "x(1)".
def var varqimpo   as char format "x(40)".
def var vnumero    like plani.numero.
def var vv-nota    like plani.numero.
def var vv-procod  like movim.procod.
def var vdata as date format "99/99/9999".
def var vetbcod    like estab.etbcod.
def var vregistro  as char format "x(200)".
def var v-tipo-imp as char format "x(15)" extent 2 initial
["  Arquivo  ", "Nota Especifica"]. 
def temp-table tt-coleta-diver
    field etbcod     like estab.etbcod
    field numero     like plani.numero
    field procod     like movim.procod
    field pronom     like produ.pronom
    field qtdinfo    like movim.movqtm
    field qtdcole    like movim.movqtm
    field diverg     as logical
    field div as logical.
    
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Importa "," Localiza "," Atualiza "," Listagem ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Importa  Coleta ",
             " Localiza Coleta ",
             " Atualiza Coleta ",
             " Listagem Coleta ", ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer btt-coleta-diver       for tt-coleta-diver.
def var vtt-coleta-diver         like tt-coleta-diver.procod.


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


for each tt-coleta-diver:
    delete tt-coleta-diver.
end.

disp skip(1) v-tipo-imp with frame fr-importa no-labels
         title "Importar Coleta de Digergencia" row 10 centered.
choose field v-tipo-imp with frame fr-importa width 36.

if frame-index = 1         /* Via Arquivo do Coletor */
then do:
     assign vtipocol = "a".
     update  varqimpo label "Diretorio/Arquivo Importacao " with frame farq
        centered.
     input from varqexpo.
     repeat:
            import vregistro.
            create tt-coleta-diver.
            assign tt-coleta-diver.etbcod  = int(substr(vregistro,1,3))
                   tt-coleta-diver.numero  = int(substr(vregistro,4,9))
                   tt-coleta-diver.procod  = int(substr(vregistro,13,8))
                   tt-coleta-diver.pronom  = substr(vregistro,21,40)
                   tt-coleta-diver.qtdinfo = int(substr(vregistro,41,4))
                   tt-coleta-diver.qtdcole = int(substr(vregistro,45,4)).
                   tt-coleta-diver.diverg  = (if tt-coleta-diver.qtdinfo <>
                                                 tt-coleta-diver.qtdcole 
                                              then yes else no).        
      end.
     input close.
end.
else do:  /* Via NF - Registro Gravado em Movim */
          vtipocol =  "n".
          update vetbcod label "Filial " 
                 vnumero label "Nota Fiscal"
                 vdata   label "Data da Nota"
          with frame f-parametro row 10 centered side-labels. 
          find first plani where plani.etbcod = vetbcod and 
                                 plani.pladat = vdata   and 
                                 plani.movtdc = 6 and
                                 plani.numero = vnumero
                                 no-lock no-error.
          if not avail plani
          then do:
              message "Nota Fiscal de Transferencia Inexistente"
              view-as alert-box.
              undo, retry.
          end.
         for each movim where movim.etbcod = vetbcod and
                            movim.placod = plani.placod and
                            movim.movtdc = 6 and
                            movim.movdat = plani.pladat
                                      no-lock:
                  find first produ where produ.procod = movim.procod
                                        no-lock no-error.
                  create tt-coleta-diver.
                  assign tt-coleta-diver.etbcod  = plani.etbcod
                         tt-coleta-diver.numero  = plani.numero
                         tt-coleta-diver.procod  = movim.procod
                         tt-coleta-diver.pronom  = produ.pronom
                         tt-coleta-diver.qtdinfo = movim.movqtm
                         tt-coleta-diver.qtdcole = movim.ocnum[5].                                 assign tt-coleta-diver.diverg  = 
                  (if tt-coleta-diver.qtdinfo <> tt-coleta-diver.qtdcole 
                   then yes else no).        
         end.
end.                                           

find first tt-coleta-diver no-error.

if not avail tt-coleta-diver
then do:
   message "Registros de Coleta de N.Fiscal nao encontrado"
            view-as alert-box.
   undo, retry.
end. 

if vtipocol = "n"
then do:
    find first tt-coleta-diver where tt-coleta-diver.qtdcole > 0 no-error.
    if not avail tt-coleta-diver
    then do:
        message "Nao foi realizada coleta para esta nota"
        view-as alert-box.
        undo,retry.
    end.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
    find tt-coleta-diver where recid(tt-coleta-diver) = recatu1 no-lock.
    if not available tt-coleta-diver
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-coleta-diver).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-coleta-diver
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
            find tt-coleta-diver where recid(tt-coleta-diver) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then string(tt-coleta-diver.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-coleta-diver.etbcod)
                                        else "".
            run color-message.
            choose field tt-coleta-diver.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) . /* color white/black. */
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
                    if not avail tt-coleta-diver
                    then leave.
                    recatu1 = recid(tt-coleta-diver).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-coleta-diver
                    then leave.
                    recatu1 = recid(tt-coleta-diver).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-coleta-diver
                then next.
                color display white/red tt-coleta-diver.etbcod 
                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-coleta-diver
                then next.
                color display white/red tt-coleta-diver.etbcod 
                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-coleta-diver.etbcod
                 tt-coleta-diver.procod
                 tt-coleta-diver.pronom
                 tt-coleta-diver.qtdinfo
                 tt-coleta-diver.qtdcole
                 tt-coleta-diver.diverg format "*/ "
                 with frame f-tt-coleta-diver color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Importa " or
                   esqcom1[esqpos1] = " Atualiza " 
                then do with frame f-tt-coleta-diver.
                    disp tt-coleta-diver.
                end.
                if esqcom1[esqpos1] = " Atualiza "
                then do with frame f-tt-coleta-diver on error undo:
                   find first plani where plani.etbcod = tt-coleta-diver.etbcod
                   and plani.numero = tt-coleta-diver.numero 
                   and plani.movtdc = 6 no-lock no-error.
                   if not avail plani
                   then do:
                        message "Nota Fiscal nao Encontrada" view-as alert-box.
                        undo ,retry.
                   end.
                   for each tt-coleta-diver :
                       find first movim
                            where movim.etbcod = tt-coleta-diver.etbcod
                        and movim.placod = plani.placod no-error.
                        if avail movim
                        then assign movim.ocnum[5] = tt-coleta-diver.qtdcole.
                   end.
                   message "Quantidades Coletadas gravadas!" view-as alert-box.
                   leave.
                end.
                if esqcom1[esqpos1] = " Localiza "
                then do :
                    update vv-nota label   "Informe N.Nota   : " skip
                           vv-procod label "Informe N.Produto: " 
                    with frame f-pede-param centered overlay.
                    find first tt-coleta-diver 
                    where tt-coleta-diver.numero = vv-nota and                           tt-coleta-diver.procod = vv-procod no-error.
                    if not avail tt-coleta-diver
                    then do:
                        message 
                        "Registro de Divergencia nao Encontrada !" 
                                    view-as alert-box. 
                        undo, retry.
                    end.
                    recatu1 = recid(tt-coleta-diver).
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    run Pi-lis-coleta.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
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
        recatu1 = recid(tt-coleta-diver).
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
display tt-coleta-diver.etbcod 
        tt-coleta-diver.numero
        tt-coleta-diver.procod
        tt-coleta-diver.pronom format "x(30)"
        tt-coleta-diver.qtdinfo column-label "Qtd.Infor"                tt-coleta-diver.qtdcole column-label "Qtd.Coleta"
        tt-coleta-diver.diverg format "*/ " column-label "Diverg"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-coleta-diver.etbcod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-coleta-diver.etbcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-coleta-diver where true
                                                no-lock no-error.
    else  
        find last tt-coleta-diver  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-coleta-diver  where true
                                                no-lock no-error.
    else  
        find prev tt-coleta-diver   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-coleta-diver where true  
                                        no-lock no-error.
    else   
        find next tt-coleta-diver where true 
                                        no-lock no-error.
        
end procedure.

         
Procedure Pi-Lis-Coleta.
         
def var recimp    as recid.
def var fila      as char.
def var varquivo  as char.
def var vk-diverg as int.
def var vdescdiver as char.

assign vk-diverg = 0.
 
if opsys = "unix"
then do:
       find first impress where impress.codimp = setbcod 
                    no-lock no-error. 
       if avail impress
       then do:
                  run acha_imp.p (input recid(impress), 
                                  output recimp).
                  find impress where recid(impress) = recimp 
                            no-lock no-error.
                  if avail impress
                  then assign fila = string(impress.dfimp). 
                  else assign fila = "".
       end.
       else do:
                 fila = "".
                 message "Impressora nao cadastrada".
       end.
   
       varquivo = "../relat/devdep" + string(time).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "80" 
            &Page-Line = "66" 
            &Nom-Rel   = ""devdep"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """DIVERGENCIAS NF TRANSFERENCIA x COLETOR"""
            &Width     = "80"
            &Form      = "frame f-cabcab"}
   end.                    
   else do:
        assign fila = "" 
               varquivo = "l:\relat\devdep" + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "76"
            &Page-Line = "66"
            &Nom-Rel   = ""devdep"" 
            &Nom-Sis   = """SISTEMA DEPOSITO""" 
            &Tit-Rel   = """DIVERGENCIAS NF TRANSFERENCIA x COLETOR"""
            &Width     = "80"
            &Form      = "frame f-cabcab1"}

     end.
   
    for each tt-coleta-diver break by tt-coleta-diver.numero
                                   by tt-coleta-diver.procod:
                                         
         if first-of(tt-coleta-diver.procod)
         then do:
             assign vk-diverg = 0.
            find first plani where plani.etbcod = tt-coleta-diver.etbcod
                             and   plani.numero = tt-coleta-diver.numero
                             and plani.movtdc = 6 no-lock no-error.    
            disp plani.numero plani.etbcod plani.pladat 
                    with frame f-relato down centered width 132.
         end.
         else disp "" @ plani.numero
                   "" @ plani.etbcod
                   "" @ plani.pladat 
                    with frame f-relato down centered.        
    
         find first movim where movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.procod = tt-coleta-diver.procod
                                no-lock no-error.

         assign vdescdiver = "".
         
         if not avail movim 
         then assign vdescdiver = "Produto nao consta na Nota Fiscal"
                     vk-diverg  = vk-diverg + 1.
         
         if tt-coleta-diver.diverg = yes
         then assign vdescdiver = "Qtde Coletada difere Qtde N.Fiscal"
                     vk-diverg = vk-diverg + 1.
         disp 
             tt-coleta-diver.procod 
             tt-coleta-diver.pronom format "x(30)" column-label "P r o d u t o"
             tt-coleta-diver.qtdcole column-label "Qtde!Coleta"
             tt-coleta-diver.qtdinfo column-label "Qtde!N.Fiscal"
             vdescdiver with frame frelato down.
    
         if last-of(tt-coleta-diver.procod)
         then do:
             disp "" @ plani.numero
                   "" @ plani.etbcod
                   "" @ plani.pladat 
                   "" @ tt-coleta-diver.procod
                   if vk-diverg > 0
                   then "Coleta apresentou divergencias em Relacao a N.Fiscal"
                   else "Coleta em conformidade com Nota Fiscal"
                   @ tt-coleta-diver.pronom
                   "" @ tt-coleta-diver.qtdcole
                   "" @ tt-coleta-diver.qtdinfo
                    with frame f-relato down .
              put skip(1).              
              vk-diverg = 0.
         end.
    end.     
    
    put skip(2).

    output close.
    
   if opsys = "unix"
   then do:
        if fila = ""
        then run visurel.p (input varquivo, input ""). 
        else os-command silent lpr value(fila + " " + varquivo).

    end.
    else do:
        {mrod.i}
    end.
  
end procedure.




