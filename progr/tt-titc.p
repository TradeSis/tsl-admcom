/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var vdt like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
/*
def var esqpos1         as int.
def var esqpos2         as int.
*/
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["","","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer blancxa for lancxa.

def shared temp-table tt-titulo
    field marca as char format "x"
    field titobs   like titulo.titobs    
    field titnum   like titulo.titnum format "x(7)"
    field titpar   like titulo.titpar format "9999"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi format "99/99/9999"
    field titdtven like titulo.titdtven format "99/99/9999"
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titvlpag like titulo.titvlpag format ">>>,>>9.99"
    field titdtpag like titulo.titdtpag column-label "DatPag"
                       format "99/99/99"
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod column-label "FL" format ">>9"
    field clifor   like titulo.clifor
    index ind-1 titdtemi desc.


def buffer btt-titulo   for tt-titulo.
def var vmodcod         like tt-titulo.modcod.


    /*
    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    */
    esqregua  = yes.
    /*
    esqpos1  = 1.
    esqpos2  = 1.
    */
bl-princ:
repeat:
     /*
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        find first tt-titulo where
            true no-error.
    else
        find tt-titulo where recid(tt-titulo) = recatu1.
    vinicio = yes.
    if not available tt-titulo
    then do:
        message "Cadastro Vazio".
        return.
    end.
    clear frame frame-a all no-pause.
    
    
    display tt-titulo.titobs[1] no-label
            tt-titulo.titobs[2] no-label
                with frame f-obs side-label row 20 centered no-box.

    display tt-titulo.marca no-label
            tt-titulo.titnum    format "x(7)"
            tt-titulo.titpar    format "9999" 
            tt-titulo.modcod    
            tt-titulo.titdtemi  format "99/99/99" 
            tt-titulo.titdtven  format "99/99/99" column-label "DTVcto" 
            tt-titulo.titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
            tt-titulo.titvlpag  format ">>>,>>9.99" 
            tt-titulo.titdtpag  label "DatPag" format "99/99/99" 
            tt-titulo.titsit    
            tt-titulo.etbcod   column-label "FL" format ">>9"
                with frame frame-a 12 down centered row 4 overlay
                width 80.

    recatu1 = recid(tt-titulo).
    /*
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    */
    repeat:
        find next tt-titulo where
                true.
        if not available tt-titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
        display tt-titulo.titobs[1] no-label
                tt-titulo.titobs[2] no-label
                with frame f-obs color message.

     
        display tt-titulo.marca no-label
                tt-titulo.titnum    
                tt-titulo.titpar  
                tt-titulo.modcod    
                tt-titulo.titdtemi 
                tt-titulo.titdtven 
                tt-titulo.titvlcob  
                tt-titulo.titvlpag  
                tt-titulo.titdtpag  
                tt-titulo.titsit    
                tt-titulo.etbcod   
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titulo where recid(tt-titulo) = recatu1.

        on f7 recall.
        choose field tt-titulo.titnum 
            help "ENTER=Marca/Desmarca  F1=Gera Extra-caixa"
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
       
       
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            
            prompt-for tt-titulo.titnum colon 10.
            
            find first tt-titulo where tt-titulo.titnum = 
                                       input tt-titulo.titnum no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave. 
            
       end. 
       on f7 help.
       
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first tt-titulo where tt-titulo.titdtven <= vdt no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave.
        end. 
        


        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-titulo where
                true no-error.
            if not avail tt-titulo
            then next.
            color display normal
                tt-titulo.titnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-titulo where
                true no-error.
            if not avail tt-titulo
            then next.
            color display normal
                tt-titulo.titnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.


        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          if tt-titulo.marca = ""
          then tt-titulo.marca = "*".
          else tt-titulo.marca = "".
          disp tt-titulo.marca with frame frame-a.
          
          /*
          hide frame frame-a no-pause.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            
            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-titulo.
                update tt-titulo.
                recatu1 = recid(tt-titulo).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-titulo with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-titulo with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-titulo.titnum update sresp.
                if not sresp
                then leave.
                find next tt-titulo where true no-error.
                if not available tt-titulo
                then do:
                    find tt-titulo where recid(tt-titulo) = recatu1.
                    find prev tt-titulo where true no-error.
                end.
                recatu2 = if available tt-titulo
                          then recid(tt-titulo)
                          else ?.
                find tt-titulo where recid(tt-titulo) = recatu1.
                delete tt-titulo.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-tituloidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-titulo:
                    display tt-titulo.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end. */
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "GO"
        then do:
            sresp = no.
            message "Confirma GERAR EXTRA-CAIXA " update sresp.
            if not sresp then next bl-princ.

            for each tt-titulo where 
                     tt-titulo.marca = "*":

                find first lancxa where 
                   lancxa.datlan = tt-titulo.titdtemi and
                   lancxa.titnum = tt-titulo.titnum and
                   lancxa.forcod = tt-titulo.clifor and
                   lancxa.etbcod = tt-titulo.etbcod and
                   lancxa.lantip = "X"
                   no-lock no-error.
                if not avail lancxa
                then do:
                find last blancxa no-lock no-error.

                create lancxa.
                assign
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = tt-titulo.titdtemi
                    lancxa.cxacod = 0
                    lancxa.lancod = 91
                    lancxa.vallan = tt-titulo.titvlcob
                    lancxa.lanhis = 42
                    lancxa.forcod = tt-titulo.clifor
                    lancxa.titnum = tt-titulo.titnum
                    lancxa.etbcod = tt-titulo.etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = string(lancxa.titnum) 
                    .
                
                find forne where forne.forcod = lancxa.forcod 
                                    no-lock no-error.        
                if avail forne
                then lancxa.comhis = lancxa.comhis 
                                     + "-" + string(forne.fornom).

                end.
            end.         
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
                
        
         display tt-titulo.titobs[1] no-label
                 tt-titulo.titobs[2] no-label
                     with frame f-obs.

         display tt-titulo.marca no-label
                tt-titulo.titnum    
                tt-titulo.titpar    
                tt-titulo.modcod    
                tt-titulo.titdtemi  
                tt-titulo.titdtven  
                tt-titulo.titvlcob  
                tt-titulo.titvlpag  
                tt-titulo.titdtpag  
                tt-titulo.titsit    
                tt-titulo.etbcod  
                    with frame frame-a.
        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(tt-titulo).
   end.
end.
