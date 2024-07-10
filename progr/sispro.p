{admcab.i}
def var vsisdes like sispro.sisdes.
def var vsisgra like sispro.sisgra.
def var vtabcod like sispro.codest.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
 initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bsispro       for sispro.
def var vcodest         like sispro.codest.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    pause 0.    
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first sispro where sispro.sisgra = 5 no-error.
    else
        find sispro where recid(sispro) = recatu1.
    vinicio = yes.
    if not available sispro
    then do:
        message "Tabela Vazia".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                vsisdes = "".
                vsisgra = 0.
                create sispro.
                assign sispro.codest = vcodest.

                update sispro.codest
                       sispro.codred
                       vsisdes
                       vsisgra.

                find first bsispro where bsispro.sisdes = vsisdes and
                                         bsispro.sisgra = vsisgra
                                                no-lock no-error.
                if avail bsispro
                then do:
                    message "Tabela de lancamentos ja cadastrado".
                    undo, retry.
                end.

                assign sispro.sisdes = vsisdes
                       sispro.sisgra = vsisgra.


                vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display sispro.codest  column-label "Cod.Est" format "x(14)"
            sispro.codred  column-label "Cod.Red" format ">>>9"
            sispro.sisdes  column-label "Descricao" format "x(40)" 
            sispro.sisgra  column-label "Grau" 
                with frame frame-a 14 down centered.
    recatu1 = recid(sispro).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next sispro where
                sispro.sisgra = 5.
        if not available sispro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
      
        display sispro.codest
                sispro.codred  
                sispro.sisdes  
                sispro.sisgra  
                    with frame frame-a 14 down centered.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find sispro where recid(sispro) = recatu1.

        choose field sispro.codest
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
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
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 6
                          then 6
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
                find next sispro where sispro.sisgra = 5 no-error.
                if not avail sispro
                then leave.
                recatu1 = recid(sispro).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev sispro where sispro.sisgra = 5 no-error.
                if not avail sispro
                then leave.
                recatu1 = recid(sispro).
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
            find next sispro where
                sispro.sisgra = 5 no-error.
            if not avail sispro
            then next.
            color display normal
                sispro.codest.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev sispro where
                sispro.sisgra = 5 no-error.
            if not avail sispro
            then next.
            color display normal
                sispro.codest.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            /*
            scodest = sispro.codest.
            frame-value = scodest. */
            hide frame frame-a no-pause.
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
              
                vsisdes = "".
                vsisgra = 0.
                create sispro.
                assign sispro.codest = vcodest.

                update sispro.codest format "x(14)"
                       sispro.codred
                       vsisdes
                       vsisgra.
                assign sispro.sisdes = vsisdes
                       sispro.sisgra = vsisgra.


            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                update sispro /*.codest
                       sispro.codred   
                       sispro.sisdes   
                       sispro.sisgra*/  
                            with frame f-consulta /*frame-a*/ no-validate.
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp sispro with frame f-consulta no-validate.
            end.
            

            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" sispro.codred update sresp.
                if not sresp
                then leave.
                find next sispro where sispro.sisgra = 5 no-error.
                if not available sispro
                then do:
                    find sispro where recid(sispro) = recatu1.
                    find prev sispro where sispro.sisgra = 5 no-error.
                end.
                recatu2 = if available sispro
                          then recid(sispro)
                          else ?.
                find sispro where recid(sispro) = recatu1.
                delete sispro.
                recatu1 = recatu2.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Procura"
            then do with frame fprocura overlay row 9 side-label
                                color white/cyan centered:
                update vcodest format "x(20)".
                find bsispro where bsispro.codest = vcodest no-lock no-error.
                if not avail bsispro
                then leave.
                recatu1 = recid(bsispro).
                leave.
             end.

            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao ? " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                
                run imprime.
                
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        
        display sispro.codest
                sispro.codred  
                sispro.sisdes  
                sispro.sisgra  
                    with frame frame-a 14 down centered.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(sispro).
   end.
end.

procedure imprime.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/cheval" + string(time).
    else varquivo = "..\relat\cheval" + string(time).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "90"
        &Page-Line = "66"
        &Nom-Rel   = ""cfcheval""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """ PLANO DE CONTAS """
        &Width     = "90"
        &Form      = "frame f-cabcab"}
                        
                        
        FOR EACH SISPRO:
            disp sispro.codest
                 sispro.codred
                 sispro.sisdes  format "x(35)"
                 sispro.sisace
                 sispro.sisori
                 sispro.ativo
                 sispro.sisgra
                 with frame f-disp down width 90.
        end.                        
        output close.
        
        
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
        sresp = no.
        message "Confirma impressao ?" update sresp.
        if sresp
        then os-command silent /fiscal/lp value(varquivo).  
    end.
    else do:
        {mrod.i} .
    end.
end.
