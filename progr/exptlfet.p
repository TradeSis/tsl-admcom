/*----------------------------------------------------------------------
*    Exporta Arquivo de Etiquetas de Produtos de Plano de telefonia
*    Esqueletao de Programacao
*    Antonio Maranghello Jr
-----------------------------------------------------------------------*/

{admcab.i new}

def var vopecod like operadoras.opecod.
def var vtipviv like plaviv.tipviv.
def var vcodviv like plaviv.codviv.
def var vprocod like plaviv.procod initial 0.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["   Marca ","  Desmarca","Reverte Tudo","Listagem","Procura"].

def var esqcom2         as char format "x(25)" extent 3 /*5*/
            initial ["Gera Arquivo" , ""
                    ," " /*,"",""*/].


def temp-table tt-restringe
    field plano    as int 
    field promocao as int
    field procod   as int.

def temp-table tt-plaviv like plaviv
    field marca as logical. 


def buffer btt-plaviv       for tt-plaviv.


def var v-ativa  as   log format "Ativar/Desativar".
def var v-conf   as   log format "Sim/Nao" init no.

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


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-plaviv where
            true no-error.
    else
        find tt-plaviv where recid(tt-plaviv) = recatu1.

    vinicio = yes.
    
    if not available tt-plaviv
    then do:
        message "Cadastro de Planos Vivo Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6  centered side-labels.
            create tt-plaviv.
                update tt-plaviv.tipviv    label "Promocao." format ">>>9".
                find promoviv where
                     promoviv.tipviv = tt-plaviv.tipviv no-lock no-error.
                disp promoviv.provivnom no-label when avail promoviv at 21 skip.
                
                update tt-plaviv.codviv    label "Plano...." format ">>>9".
                find planoviv where
                     planoviv.codviv = tt-plaviv.codviv no-lock no-error.
                disp planoviv.planomviv no-label when avail planoviv at 21 skip.
                
                
                
                tt-plaviv.exportado = yes.
                
                update
                       tt-plaviv.modelo    label "Modelo..." skip
                       tt-plaviv.pretab    label "Pc.Tabe.." skip
                       tt-plaviv.prepro    label "Pc.Prom.." skip
                       tt-plaviv.dtini     label "Dt.Inicio" skip
                       tt-plaviv.dtfin     label "Dt.Final." skip
                       tt-plaviv.exportado label "Situacao."
                        format "Ativo/Inativo". 
                              
            vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find produ where produ.procod = tt-plaviv.procod no-lock no-error.
    display tt-plaviv.tipviv column-label "Prom" format ">>>9"
            tt-plaviv.codviv column-label "Plan" format ">>>9"
            tt-plaviv.procod 
            produ.pronom format "x(32)" when avail produ
                column-label "Descricao"
            tt-plaviv.pretab format ">,>>9.99" column-label "Pc.Tabe."
            tt-plaviv.prepro format ">,>>9.99" column-label "Pc.Prom." 
            tt-plaviv.exportado column-label "Situacao"
                        format "Ativo/Inativo"
                with frame frame-a 13 down centered.

    recatu1 = recid(tt-plaviv).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-plaviv where
                true.
        if not available tt-plaviv
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find produ where produ.procod = tt-plaviv.procod no-lock no-error.
        display tt-plaviv.tipviv   format ">>>9"
                tt-plaviv.codviv   format ">>>9"
                tt-plaviv.procod 
                produ.pronom when avail produ
                tt-plaviv.pretab 
                tt-plaviv.prepro
                tt-plaviv.exportado column-label "Situacao"
                        format "Ativo/Inativo"

                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

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

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 side-labels centered.
                create tt-plaviv.

                update tt-plaviv.tipviv    label "Promocao." format ">>>9".
                find promoviv where
                     promoviv.tipviv = tt-plaviv.tipviv no-lock no-error.
                disp promoviv.provivnom no-label when avail promoviv at 21 skip.
                
                update tt-plaviv.codviv    label "Plano...." format ">>>9".
                find planoviv where
                     planoviv.codviv = tt-plaviv.codviv no-lock no-error.
                disp planoviv.planomviv no-label when avail planoviv at 21 skip.
                
                
                update tt-plaviv.procod    label "Celular.." .
                find produ where produ.procod = tt-plaviv.procod no-lock no-error.
                disp produ.pronom no-label when avail produ at 21 skip.
                
                tt-plaviv.exportado = yes.
                
                update
                       tt-plaviv.modelo    label "Modelo..." skip
                       tt-plaviv.pretab    label "Pc.Tabe.." skip
                       tt-plaviv.prepro    label "Pc.Prom.." skip
                       tt-plaviv.dtini     label "Dt.Inicio" skip
                       tt-plaviv.dtfin     label "Dt.Final." skip
                       tt-plaviv.exportado label "Situacao."
                        format "Ativo/Inativo". 
                        
                recatu1 = recid(tt-plaviv).
                leave.
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 centered side-labels.

                find promoviv where
                     promoviv.tipviv = tt-plaviv.tipviv no-lock no-error.
                disp tt-plaviv.tipviv  label "Promocao." format ">>>9"
                     promoviv.provivnom no-label when avail promoviv
                     at 21 skip.
                find planoviv where 
                     planoviv.codviv = tt-plaviv.codviv no-lock no-error.
                disp tt-plaviv.codviv  label "Plano...." format ">>>9"
                     planoviv.planomviv no-label when avail planoviv 
                     at 21 skip.
                find produ where produ.procod = tt-plaviv.procod no-lock no-error.
                disp tt-plaviv.procod  label "Celular.."
                     produ.pronom no-label when avail produ 
                     at 21 skip.
                disp tt-plaviv.modelo    label "Modelo..." skip
                     tt-plaviv.pretab    label "Pc.Tabe.." skip
                     tt-plaviv.prepro    label "Pc.Prom.." skip
                     tt-plaviv.dtini     label "Dt.Inicio" skip
                     tt-plaviv.dtfin     label "Dt.Final." skip
                     tt-plaviv.exportado label "Situacao."
                        format "Ativo/Inativo".
                 

                /***
                update tt-plaviv.tipviv    label "Promocao." .
                find promoviv where
                     promoviv.tipviv = tt-plaviv.tipviv no-lock no-error.
                disp promoviv.provivnom no-label when avail promoviv skip.
                
                update tt-plaviv.codviv    label "Plano...." .
                find planoviv where
                     planoviv.codviv = tt-plaviv.codviv no-lock no-error.
                disp planoviv.planomviv no-label when avail planoviv skip.

                update tt-plaviv.procod    label "Celular.." .
                find produ where produ.procod = tt-plaviv.procod no-lock no-error.
                disp produ.pronom no-label when avail produ skip.
                
                update
                       tt-plaviv.modelo    label "Modelo..." skip
                ***/
                       
                update        
                       tt-plaviv.pretab    label "Pc.Tabe.." skip
                       tt-plaviv.prepro    label "Pc.Prom.." skip
                       tt-plaviv.dtini     label "Dt.Inicio" skip
                       tt-plaviv.dtfin     label "Dt.Final." skip
                       tt-plaviv.exportado label "Situacao."
                        format "Ativo/Inativo"
                            help "[A] Ativo  [I] Inativo"
                            with frame f-altera no-validate.
                            
            end.

            
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 centered side-labels.
                find promoviv where
                     promoviv.tipviv = tt-plaviv.tipviv no-lock no-error.
                disp tt-plaviv.tipviv  label "Promocao." format ">>>9"
                     promoviv.provivnom no-label when avail promoviv
                     at 21 skip.
                find planoviv where 
                     planoviv.codviv = tt-plaviv.codviv no-lock no-error.
                disp tt-plaviv.codviv  label "Plano...." format ">>>9"
                     planoviv.planomviv no-label when avail planoviv 
                     at 21 skip.
                find produ where produ.procod = tt-plaviv.procod no-lock no-error.
                disp tt-plaviv.procod  label "Celular.."
                     produ.pronom no-label when avail produ 
                     at 21 skip.
                disp tt-plaviv.modelo    label "Modelo..." skip
                     tt-plaviv.pretab    label "Pc.Tabe.." skip
                     tt-plaviv.prepro    label "Pc.Prom.." skip
                     tt-plaviv.dtini     label "Dt.Inicio" skip
                     tt-plaviv.dtfin     label "Dt.Final." skip
                     tt-plaviv.exportado label "Situacao."
                        format "Ativo/Inativo" with frame f-consulta.
                 

            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-plaviv.procod update sresp.
                if not sresp
                then leave.
                find next tt-plaviv where true no-error.
                if not available tt-plaviv
                then do:
                    find tt-plaviv where recid(tt-plaviv) = recatu1.
                    find prev tt-plaviv where true no-error.
                end.
                recatu2 = if available tt-plaviv
                          then recid(tt-plaviv)
                          else ?.
                find tt-plaviv where recid(tt-plaviv) = recatu1.
                delete tt-plaviv.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered.
                 view frame frame-a. pause 0.
                 assign vtipviv = 0
                        vcodviv = 0
                        vprocod = 0
                        vopecod = 0.

                 update vopecod label "Operadora." format ">9" skip
                        vtipviv label "Promocao.." format ">>>9" skip
                        vcodviv label "Plano....." format ">>>9" skip
                        vprocod label "Produto..."
                        with frame f-proc centered side-labels overlay row 10.
                        
                 if vopecod = 0
                 then do:
                     find first btt-plaviv where
                                (if vtipviv <> 0
                                 then btt-plaviv.tipviv = vtipviv
                                 else true) and
                                (if vcodviv <> 0
                                 then btt-plaviv.codviv = vcodviv
                                 else true) and
                                (if vprocod <> 0
                                 then btt-plaviv.procod = vprocod
                                 else true) no-lock no-error.
                 end.
                 else do:

                    if vopecod = 1
                    then do:
                         find first btt-plaviv where
                                    (if vtipviv <> 0
                                     then btt-plaviv.tipviv = vtipviv
                                     else true) and
                                    (if vcodviv <> 0
                                     then btt-plaviv.codviv = vcodviv
                                     else true) and
                                    (if vprocod <> 0
                                     then btt-plaviv.procod = vprocod
                                     else true) and
                                     
                                     (btt-plaviv.tipviv <> 1001 and
                                      btt-plaviv.tipviv <> 1002 and
                                      btt-plaviv.tipviv <> 1072)
                                     
                                     no-lock no-error.
                    end.
                    else if vopecod = 3
                    then do:
                    
                         find first btt-plaviv where
                                    (if vtipviv <> 0
                                     then btt-plaviv.tipviv = vtipviv
                                     else true) and
                                    (if vcodviv <> 0
                                     then btt-plaviv.codviv = vcodviv
                                     else true) and
                                    (if vprocod <> 0
                                     then btt-plaviv.procod = vprocod
                                     else true) and
                                     
                                    (btt-plaviv.tipviv = 1001 or
                                     btt-plaviv.tipviv = 1002 or
                                     btt-plaviv.tipviv = 1072)

                                     
                                     no-lock no-error.
                    
                    
                    end.
                    else do:
                            find first btt-plaviv where
                                    (if vtipviv <> 0
                                     then btt-plaviv.tipviv = vtipviv
                                     else true) and
                                    (if vcodviv <> 0
                                     then btt-plaviv.codviv = vcodviv
                                     else true) and
                                    (if vprocod <> 0
                                     then btt-plaviv.procod = vprocod
                                     else true) and
                                     
                                    (btt-plaviv.tipviv = 2001 or
                                     btt-plaviv.tipviv = 2002)

                            no-lock no-error.
                    end.
                 end.
        
                 if not avail btt-plaviv
                 then do:
                    recatu1 = ?.
                    leave.
                 end.    
                 
                 recatu1 = recid(btt-plaviv). 
                 leave.
                
            end.
            
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-plavividades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-plaviv:
                    display tt-plaviv.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            /*message esqregua esqpos2 esqcom2[esqpos2].*/

            if esqcom2[esqpos2] = "Altera Situacao"
            then do:

                    do on error undo:
                        v-tipviv = 0.
                        update v-tipviv label "Promocao" format ">>>9"
                            with frame f-alsit overlay
                                centered side-labels.
                        
                        if v-tipviv = 0
                        then undo.
                        
                        find promoviv where 
                             promoviv.tipviv = v-tipviv no-lock no-error.
                        if not avail promoviv
                        then do:
                            message "Promocao nao cadastrada".
                            undo.
                        end.
                        else disp promoviv.provivnom no-label
                                  skip
                                  with frame f-alsit.
                    end.
                        
                    do on error undo:
                        v-codviv = 0.
                        update v-codviv label "Plano..." format ">>>9"
                            with frame f-alsit.
                        
                        if v-codviv = 0
                        then undo.
                        
                        find planoviv where
                             planoviv.codviv = v-codviv no-lock no-error.
                        if not avail planoviv
                        then do:
                            message "Plano nao cadastrado".
                            undo.
                        end.
                        else disp planoviv.planomviv no-label 
                                  with frame f-alsit.
                    end.
                    
                    v-ativa = no.
                    update skip v-ativa label "Situacao" with frame f-alsit.

                    v-conf = no.
                    update skip v-conf  label "Confirma" with frame f-alsit.
                    
                    if not v-conf
                    then leave.
                    else do:
                        for each tt-plaviv where tt-plaviv.tipviv = v-tipviv
                                          and tt-plaviv.codviv = v-codviv:
                            assign tt-plaviv.exportado = v-ativa.
                        end.
                    end.
                    
                    hide frame f-alsit no-pause.    
                    hide message no-pause.
            
            end.
                        
            if esqcom2[esqpos2] = "Atualiza Pc.Tabela"
            then do:               /*
                message "Atualizando...".
                for each btt-plaviv:
                    find first estoq where
                               estoq.procod = btt-plaviv.procod no-lock no-error.
                    if avail estoq
                    then do transaction:
                        if btt-plaviv.tipviv = 3
                        then
                            btt-plaviv.prepro = estoq.estvenda.
                            
                        btt-plaviv.pretab = estoq.estvenda.
                    end.
                end.
                hide message no-pause.*/
            end.
            
                    
            
            /**pause.**/
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        find produ where produ.procod = tt-plaviv.procod no-lock no-error.
        display tt-plaviv.tipviv format ">>>9"
                tt-plaviv.codviv format ">>>9"
                tt-plaviv.procod 
                produ.pronom when avail produ 
                tt-plaviv.pretab 
                tt-plaviv.prepro  
                tt-plaviv.exportado column-label "Situacao"
                        format "Ativo/Inativo"
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-plaviv).
   end.
end.

procedure color-message.
color display message
        tt-plaviv.tipviv format ">>>9"
        tt-plaviv.codviv format ">>>9"
        tt-plaviv.procod
        produ.pronom column-label "Descricao"
        tt-plaviv.pretab
        tt-plaviv.prepro  
        tt-plaviv.exportado column-label "Situacao"  format "Ativo/Inativo"
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-plaviv.tipviv format ">>>9"
        tt-plaviv.codviv format ">>>9"
        tt-plaviv.procod
        produ.pronom column-label "Descricao"
        tt-plaviv.pretab
        tt-plaviv.prepro
        tt-plaviv.exportado column-label "Situacao" format "Ativo/Inativo"
        with frame frame-a.
end procedure.

procedure pi-cria-restringe.

def var j           as int.
def var vocor       as int.
def var v-auxil     as char format "x(30)".
def var v-plano     as int.
def var v-promo     as int.
def var vaux-restri as char. 
def var v-planos    as char format "x(400)" initial
"pla0021pro0050,pla0021pro0052,pla2001pro2001,pla2001pro2003".


for each tt-restringe:
    delete tt-restringe.
end.


repeat :

    assign vocor = num-entries(v-planos).


    /* Padrao Inicial - planos e promocoes determinadas - todos os produtos */
    do j = 1 to vocor :
        assign vaux-restri = entry(j,v-planos,",")
           v-auxil     = substring(vaux-restri,1,7)
           v-plano     = int(string(substring(v-auxil,4,4))).
           v-auxil     = substring(vaux-restri,8 ,7).
           v-promo     = int(string(substring(v-auxil,4,4))).
        create tt-restringe.
        assign  tt-restringe.plano    = v-plano
                tt-restringe.promocao = v-promo
                tt-restringe.procod   = 100000.
    end.

for each tt-plaviv:
    delete tt-plaviv.
end.


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

update skip vprocod label "Aparelho" with frame f-at.
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



sresp = no.
message "Confirma a os Parametros ?" update sresp.
if sresp <> no then undo.

for each plaviv no-lock:
    
    if vcodviv <> 0
    then if plaviv.codviv <> vcodviv then next.
    if vprocod <> 1000000 
    then  if plaviv.procod <> vprocod then next.
    if vtipviv <> 0
    then if plaviv.tipviv <> vtipviv then next.
    find first tt-restringe where tt-restringe.plano    = plaviv.codviv and
                                  tt-restringe.promocao = plaviv.tipviv  
                                  no-error.
    
    if not avail tt-restringe then next.
    if tt-restringe.procod <> 1000000 and tt-restringe.procod <> plaviv.procod
    then next.
    
    create tt-plaviv.
    buffer-copy plaviv to tt-plaviv.
    assign tt-plaviv.marca = no.
end.


end.

end procedure.
