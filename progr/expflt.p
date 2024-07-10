/*----------------------------------------------------------------------
*    Exporta Arquivo de Etiquetas de Produtos de Plano de telefonia
*    Esqueletao de Programacao
*    Antonio Maranghello Jr
-----------------------------------------------------------------------*/

{admcab.i}
/* def input parameter p-estilo-pro as int. /*  yes-batch n */o-menu */
def var p-estilo-pro as int.

p-estilo-pro = int(SESSION:PARAMETER).
 
def var vfornereduz as char format "x(15)".
def var valparcelas as char.
def var vliqui as dec format ">>>,>>9.99". 
def var ventra as dec format ">>>,>>9.99".                                     def var vparce as dec format ">>>,>>9.99".
def var vplanofi as int.
def var vplstfi  as char extent 6
initial ["42", "43", "87", "88", "35", "36"].
def var j               as int.  
def var vopecod like operadoras.opecod.
def var vtipviv like plaviv.tipviv.
def var vcodviv like plaviv.codviv.
def var vprocod like plaviv.procod initial 0.
def var varquivo        as char format "x(40)".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["   Marca ","  Desmarca","Inverte Tudo"," "," "].

def var esqcom2         as char format "x(25)" extent 3 /*5*/
            initial ["Gera Arquivo" , "" ," " /*,"",""*/].


def temp-table tt-restringe
    field plano    as int 
    field promocao as int
    field procod   as int.

def temp-table tt-plaviv like plaviv
    field marca     as logical 
    field vparcelas as char format "x(100)".

def buffer btt-plaviv       for tt-plaviv.


def var v-ativa  as   log format "Ativar/Desativar".
def var v-conf   as   log format "Sim/Nao" init yes.

def var v-tipviv like tt-plaviv.tipviv.
def var v-codviv like tt-plaviv.codviv.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
   
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.


run pi-cria-restringe.

find first tt-plaviv no-error.
if not avail tt-plaviv then next.

/* via menu */
if p-estilo-pro = 0
then do:

recatu1 = ?.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    pause 0.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first tt-plaviv where
            true no-error.
    else
        find tt-plaviv where recid(tt-plaviv) = recatu1.

    if not available tt-plaviv
    then do:
        message "Cadastro de Planos Vivo Vazio".
        undo.
    end.
    clear frame frame-a all no-pause.
    find produ where produ.procod = tt-plaviv.procod no-lock no-error.
    display tt-plaviv.tipviv column-label "Prom" format ">>>9"
            tt-plaviv.codviv column-label "Plan" format ">>>9"
            tt-plaviv.procod 
            produ.pronom format "x(25)" when avail produ
                column-label "Descricao"
            tt-plaviv.pretab format ">,>>9.99" column-label "Pc.Tabe."
            tt-plaviv.prepro format ">,>>9.99" column-label "Pc.Prom." 
            tt-plaviv.exportado column-label "Situacao" format "Ativo/Inativo"
            tt-plaviv.marca     column-label "Sel." format "Sim/Nao"
                with frame frame-a 12 down .
    down with frame frame-a.
    
    recatu1 = recid(tt-plaviv).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    bl-secun:
    repeat:
        find next tt-plaviv where true.
        if not available tt-plaviv
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        find produ where produ.procod = tt-plaviv.procod no-lock no-error.
        display tt-plaviv.tipviv   format ">>>9"
                tt-plaviv.codviv   format ">>>9"
                tt-plaviv.procod 
                produ.pronom when avail produ format "x(25)"
                tt-plaviv.pretab 
                tt-plaviv.prepro
                tt-plaviv.exportado column-label "Situacao" 
                                format "Ativo/Inativo"
                tt-plaviv.marca column-label "Sel."
                    with frame frame-a width 78.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a down:

        find tt-plaviv where recid(tt-plaviv) = recatu1.

        run color-message.
        choose field tt-plaviv.tipviv tt-plaviv.codviv tt-plaviv.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-plaviv where true no-error.
                if not avail tt-plaviv
                then leave.
                recatu1 = recid(tt-plaviv).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-plaviv where true no-error.
                if not avail tt-plaviv
                then leave.
                recatu1 = recid(tt-plaviv).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-plaviv where
                true no-error.
            if not avail tt-plaviv
            then next.
            color display normal
                tt-plaviv.tipviv tt-plaviv.codviv tt-plaviv.procod .
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-plaviv where
                true no-error.
            if not avail tt-plaviv
            then next.
            color display normal
                   tt-plaviv.tipviv tt-plaviv.codviv tt-plaviv.procod .
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "   Marca "
            then do :
                if tt-plaviv.marca = no then assign tt-plaviv.marca = yes.
                disp tt-plaviv.marca with frame frame-a.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "  Desmarca"
            then do :
                if tt-plaviv.marca = yes then assign tt-plaviv.marca = no.
                disp tt-plaviv.marca with frame frame-a.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Inverte Tudo"
            then do:
                for each btt-plaviv:
                    if btt-plaviv.marca = yes
                    then assign btt-plaviv.marca = no.
                    else assign btt-plaviv.marca = yes.
                end.
                recatu1 = ?.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Gera Arquivo"
            then do:
                assign varquivo = "/admcom/relat/arqtelprom" + string(time)
                                    + ".txt".
                message "Confirma Arquivo ou <F4> : " update varquivo.         ~                  if keyfunction(lastkey) <> "end-error"
                then do:
                   for each tt-plaviv where tt-plaviv.marca = yes:
                       assign valparcelas = "".
                       do j = 1 to 6 :
                              assign vplanofi = int(vplstfi[j]).
                              assign vliqui = 0
                                     ventra = 0
                                     vparce = 0.
                                     
                              run /var/www/drebes/progress/gercpg20.p( input vplanofi, 
                                           input tt-plaviv.prepro, 
                                           input 0, 
                                           input 0, 
                                           output vliqui, 
                                           output ventra,
                                           output vparce) . 
                            valparcelas = valparcelas +                        ~                                        string(vparce,">>>,>>9.99") + ";".
                       end.
                       assign tt-plaviv.vparcelas = valparcelas.
                   end.

                   output to value(varquivo).
 
                   for each tt-plaviv where tt-plaviv.marca = yes:
                       find first produ where
                                  produ.procod = tt-plaviv.procod  
                                        no-lock no-error.
                       vfornereduz = "desconhecido".
                       find first fabri where 
                               fabri.fabcod = produ.fabcod no-lock no-error.
                       if avail fabri
                       then vfornereduz = entry(1, fabri.fabnom, " ").                                put tt-plaviv.procod format ">>>>>>>9" ";"
                           tt-plaviv.tipviv format ">>>>9" ";"
                           tt-plaviv.codviv format ">>>>9" ";"
                           vfornereduz ";"
                           tt-plaviv.prepro ";"
                           tt-plaviv.vparcelas skip.
                   
                   end.
                   output close.
                   message "Arquivo Gerado -> " varquivo
                   view-as alert-box.
                 end.
             end.
          end.  
          view frame frame-a .
        end.

        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        find produ where produ.procod = tt-plaviv.procod no-lock no-error.
        display tt-plaviv.tipviv format ">>>9"
                tt-plaviv.codviv format ">>>9"
                tt-plaviv.procod 
                produ.pronom when avail produ format "x(20)"
                tt-plaviv.pretab 
                tt-plaviv.prepro  
                tt-plaviv.exportado column-label "Situacao" 
                            format "Ativo/Inativo"
                tt-plaviv.marca column-label "Sel."        
                    with frame frame-a down.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-plaviv).
   end.
end.

end. /* via menu */
else do: /* via Batch */
   assign varquivo = "/var/www/drebes/progress/telefonia.txt".
   for each tt-plaviv where tt-plaviv.marca = yes:
                       assign valparcelas = "".
                       do j = 1 to 6 :
                              assign vplanofi = int(vplstfi[j]).
                              assign vliqui = 0
                                     ventra = 0
                                     vparce = 0.
                                     
                              run /var/www/drebes/progress/gercpg20.p( 
                              input vplanofi, 
                                           input tt-plaviv.prepro, 
                                           input 0, 
                                           input 0, 
                                           output vliqui, 
                                           output ventra,
                                           output vparce) . 
                            valparcelas = valparcelas +                                                                string(vparce,">>>,>>9.99") + ";".
                       end.
                       assign tt-plaviv.vparcelas = valparcelas.
   end.

   output to value(varquivo).
 
   for each tt-plaviv where tt-plaviv.marca = yes:
                       find first produ where
                                  produ.procod = tt-plaviv.procod  
                                        no-lock no-error.
                       vfornereduz = "desconhecido".
                       find first fabri where 
                               fabri.fabcod = produ.fabcod no-lock no-error.
                       if avail fabri
                       then vfornereduz = entry(1, fabri.fabnom, " ").                  
                       put tt-plaviv.procod format ">>>>>>>9" ";"
                           tt-plaviv.tipviv format ">>>>9" ";"
                           tt-plaviv.codviv format ">>>>9" ";"
                           vfornereduz ";"
                           tt-plaviv.prepro ";"
                           tt-plaviv.vparcelas skip.
                   
     end.
     output close.
end.


procedure color-message.
pause 0.
color display message
        tt-plaviv.tipviv format ">>>9"
        tt-plaviv.codviv format ">>>9"
        tt-plaviv.procod
        produ.pronom        column-label "Descricao"
        tt-plaviv.pretab
        tt-plaviv.prepro  
        tt-plaviv.exportado column-label "Situacao" format "Ativo/Inativo"
        tt-plaviv.marca format "Sim/Nao"
            with frame frame-a .
end procedure.

procedure color-normal.
pause 0.
color display normal
        tt-plaviv.tipviv format ">>>9"
        tt-plaviv.codviv format ">>>9"
        tt-plaviv.procod
        produ.pronom column-label "Descricao"
        tt-plaviv.pretab
        tt-plaviv.prepro
        tt-plaviv.exportado column-label "Situacao" format "Ativo/Inativo"
        tt-plaviv.marca format "Sim/Nao"
        with frame frame-a .
end procedure.

procedure pi-cria-restringe.

def var j           as int.
def var vocor       as int.
def var v-auxil     as char format "x(30)".
def var v-plano     as int.
def var v-promo     as int.
def var vaux-restri as char. 
def var v-planos    as char format "x(400)" initial
"pla0050pro0021,pla0052pro0021,pla2001pro2001,pla2003pro2001,
pla1009pro1001,pla1012pro1001".

for each tt-restringe:
    delete tt-restringe.
end.

    assign vocor = num-entries(v-planos).


    /* Padrao Inicial - planos e promocoes determinadas - todos os produtos */
    do j = 1 to vocor :
        assign vaux-restri = entry(j,v-planos,",")
           v-auxil     = substring(vaux-restri,1,7)
           v-plano     = int(string(substring(v-auxil,4,4))).
           v-auxil     = substring(vaux-restri,8 ,7).
           v-promo     = int(string(substring(v-auxil,4,4))).

        create  tt-restringe.
        assign  tt-restringe.plano    = v-plano
                tt-restringe.promocao = v-promo
                tt-restringe.procod   = 0.
    end.

    for each tt-plaviv:
        delete tt-plaviv.
    end.

if p-estilo-pro = 0

then do:

    update skip  vtipviv label "Promocao." format ">>>9"
                       help "Informe o codigo da promocao ou zero para todas."
                       with frame f-at centered side-labels overlay
                                       row 10 color white/red.
    if vtipviv <> 0
    then do:
      find promoviv where 
           promoviv.tipviv = vtipviv no-lock no-error.
      if not avail promoviv
      then do:
            message "Promocao nao cadastrada.".
            undo.
      end.
            else disp promoviv.provivnom no-label with frame f-at.
    end.
    else disp "TODOS" @ promoviv.provivnom with frame f-at.
                
    update skip vcodviv label "Plano...." format ">>>9"
            help "Informe o codigo do plano ou zero para todos."
                   with frame f-at.
                       
    if vcodviv <> 0
    then do:
      find planoviv where 
           planoviv.codviv = vcodviv no-lock no-error.
      if not avail planoviv
      then do:
            message "Plano nao cadastrado.".
                  undo.
       end.
      else disp planoviv.planomviv no-label with frame f-at.
    end.
    else disp "TODOS" @ planoviv.planomviv with frame f-at.

    update skip vprocod label "Aparelho " with frame f-at.
    if vprocod <> 0
    then do:
        find produ where produ.procod = vprocod no-lock no-error.
        if avail produ
        then disp produ.pronom no-label when avail produ at 21 with frame f-at.
        else do:
            message "Produto nao cadastrado.".
            undo.
        end.
    end.
    else disp "TODOS" @ vprocod with frame f-at.


    hide frame f-at no-pause.
    sresp = no.
    message "Confirma a os Parametros ?" update sresp.

end. /* estilo menu */
else do: /* estilo batch */
    sresp = yes.
    vprocod = 0.
    vcodviv = 0.
    vtipviv = 0.
end.

if sresp = yes
then 
for each plaviv no-lock:
    
    if vcodviv <> 0
    then if plaviv.codviv <> vcodviv then next.
    if vprocod <> 0
    then  if plaviv.procod <> vprocod then next.
    if vtipviv <> 0
    then if plaviv.tipviv <> vtipviv then next.
    /*
    message plaviv.codviv plaviv.tipviv. pause.
    */
    find first tt-restringe where tt-restringe.plano    = plaviv.codviv and
                                  tt-restringe.promocao = plaviv.tipviv  
                                  no-error.

    
    if not avail tt-restringe then next.
    if vprocod <> 0 then if vprocod <> plaviv.procod then next.

    create tt-plaviv.
    buffer-copy plaviv to tt-plaviv.
    if tt-restringe.promocao = 21
    then tt-plaviv.prepro = tt-plaviv.prepro + 10.
    else if tt-restringe.promocao = 2001
    then tt-plaviv.prepro = tt-plaviv.prepro + 10.
    
    assign tt-plaviv.marca = yes.
end.

end procedure.                                
