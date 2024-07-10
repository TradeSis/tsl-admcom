/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def input  parameter vetbcod like estab.etbcod.
def input  parameter vdt1    like plani.pladat.
def input  parameter vdt2    like plani.pladat.

def shared var vtotrec  like titulo.titvlcob format "zzz,zzz,zz9.99".
def shared var vtotjur  like titulo.titvlcob format "zzz,zzz,zz9.99".



def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 3
            initial ["Alteracao","Exclusao","Consulta"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btitold       for titold.
def var vclifor         like titold.clifor.


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

bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first titold where titold.etbcobra = vetbcod and
                                 titold.titdtpag >= vdt1   and
                                 titold.titdtpag <= vdt2   no-error.
    else find titold where recid(titold) = recatu1.
    vinicio = yes.
    if not available titold
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    
    display vtotrec no-label  to 53
            vtotjur no-label  to 64 format "zzzz,zz9.99"
                with frame f-tot 
                    side-label color 
                        message row 21 no-box width 74 centered.
    
    display
        titold.clifor   column-label "Cliente"
        titold.titnum   column-label "Titulo"
        titold.titpar   column-label "Pr"
        titold.titvlcob column-label "Recebimento"
        titold.titjuro  column-label "Juros" format ">>>,>>9.99"
            with frame frame-a 12 down centered.

    recatu1 = recid(titold).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next titold where titold.etbcobra = vetbcod and
                               titold.titdtpag >= vdt1   and
                               titold.titdtpag <= vdt2   no-error.

        if not available titold
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
        display vtotrec no-label 
                vtotjur no-label 
                    with frame f-tot. 
    
        display titold.clifor    
                titold.titnum   
                titold.titpar  
                titold.titvlcob
                titold.titjuro
                        with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find titold where recid(titold) = recatu1.

        choose field titold.clifor
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
                esqpos1 = if esqpos1 = 3
                          then 3
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
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
                find next titold where titold.etbcobra = vetbcod and
                                       titold.titdtpag >= vdt1   and
                                       titold.titdtpag <= vdt2   no-error.

                if not avail titold
                then leave.
                recatu1 = recid(titold).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev titold where titold.etbcobra = vetbcod and
                                       titold.titdtpag >= vdt1   and
                                       titold.titdtpag <= vdt2   no-error.
                if not avail titold
                then leave.
                recatu1 = recid(titold).
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
            find next titold where titold.etbcobra = vetbcod and
                                   titold.titdtpag >= vdt1   and
                                   titold.titdtpag <= vdt2   no-error.
            if not avail titold
            then next.
            color display normal
                titold.clifor.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev titold where titold.etbcobra = vetbcod and
                                   titold.titdtpag >= vdt1   and
                                   titold.titdtpag <= vdt2   no-error.
            if not avail titold
            then next.
            color display normal
                titold.clifor.
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

            if esqcom1[esqpos1] = "*Inclusao*"
            then do with frame f-inclui overlay row 6 1 column centered.
                create titold.
                update titold.titnum
                       titold.clifor.
                recatu1 = recid(titold).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                
                assign vtotjur = vtotjur - titold.titjuro
                       vtotrec = vtotrec - titold.titvlcob.
                
                update titold.titvlcob 
                       titold.titjuro 
                            with frame f-altera no-validate.
                
                assign vtotjur = vtotjur + titold.titjuro
                       vtotrec = vtotrec + titold.titvlcob.
                       
                titold.titvlpag = titold.titvlcob + titold.titjuro.
                
            
            end.
            
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                display titold.titdtpag
                        titold.titvlcob
                        titold.titvlpag
                        titold.titjuro with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" titold.titnum update sresp.
                if not sresp
                then leave.

                find next titold where titold.etbcobra = vetbcod and
                                       titold.titdtpag >= vdt1   and
                                       titold.titdtpag <= vdt2   no-error.
                if not available titold
                then do:
                    find titold where recid(titold) = recatu1.
          
                    find prev titold where titold.etbcobra = vetbcod and
                                           titold.titdtpag >= vdt1   and
                                           titold.titdtpag <= vdt2   no-error.

                end.
                recatu2 = if available titold
                          then recid(titold)
                          else ?.
                find titold where recid(titold) = recatu1.
                
                assign vtotjur = vtotjur - titold.titjuro
                       vtotrec = vtotrec - titold.titvlcob.
                 
                delete titold.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
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
          
        
        display vtotrec no-label  
                vtotjur no-label with frame f-tot. 
    
        display titold.clifor 
                titold.titnum 
                titold.titpar 
                titold.titvlcob
                titold.titjuro with frame frame-a.
                
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titold).
   end.
end.
