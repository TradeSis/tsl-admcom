/*
* #1 Em 01/11/19 - Claudir - TP 34021151
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var vdt like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.

def var f-titdtemi like titulo.titdtemi.
def var f-titdtven like titulo.titdtven.
def var f-titnum like titulo.titnum.
def var f-titvlcob like titulo.titvlcob.
def var vindex as int.

def var esqpos1         as int.
/*def var esqpos2         as int.
*/
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Altera"," GERA CTB","Alt.Setor",
            " Filtro",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def var s-filtro as char format "x(15)" extent 5
        init["Todos","Emissao","Vencimento","Numero","Valor"]
        .

def shared temp-table tt-plani like plani.

def shared temp-table tt-titulo
    field titnum   like titulo.titnum format "x(10)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field titdtemi like titulo.titdtemi format "99/99/99"
                                column-label "Dt.Emis."
    field titdtven like titulo.titdtven format "99/99/99"
                                column-label "Dt.Venc."
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">,>>>,>>9.99"
    field titvlpag like titulo.titvlpag format ">,>>>,>>9.99"
    field titdtpag like titulo.titdtpag format "99/99/99"
                                column-label "Dt.Paga."
    field titvljur like titulo.titvljur 
    field titvldes like titulo.titvldes
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod column-label "FL" format ">>9"
    field clifor   like titulo.clifor 
    field titbanpag like titulo.titbanpag
    field marca as char
    index ind-1 titdtemi desc.

def temp-table tt-filtro like tt-titulo.

def buffer btt-titulo       for tt-titulo.
def buffer ctt-titulo       for tt-titulo.
def var vmodcod         like tt-titulo.modcod.

    
    form
        esqcom1
            with frame f-com1
                 row 5 no-box no-labels side-labels column 1.
    /*form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    */
    esqregua  = yes.
    
    esqpos1  = 1.
    /*esqpos2  = 1.
    */
for each tt-titulo:
    tt-titulo.marca = "*".
end.    
bl-princ:
repeat:
     
    disp esqcom1 with frame f-com1.
    /*
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        find first tt-titulo where tt-titulo.marca = "*" no-error.
    else
        find tt-titulo where recid(tt-titulo) = recatu1.
    vinicio = yes.
    if not available tt-titulo
    then do:
        message "Cadastro Vazio".
        return.
    end.
    clear frame frame-a all no-pause.
    
    display tt-titulo.titnum    format "x(10)"
            tt-titulo.titpar    format "99" 
            tt-titulo.modcod    
            tt-titulo.titdtemi  format "99/99/99" 
                            column-label "Dt.Emis."
            tt-titulo.titdtven  format "99/99/99" 
                            column-label "Dt.Venc."
            tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                                format ">,>>>,>>9.99" 
            tt-titulo.titvlpag  format ">,>>>,>>9.99" 
            tt-titulo.titdtpag  format "99/99/99" column-label "Dt.Paga."
            tt-titulo.titsit    
            tt-titulo.etbcod   column-label "FL" format ">>9"
                with frame frame-a 12 down centered
                row 6.

    recatu1 = recid(tt-titulo).
    
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    
    repeat:
        find next tt-titulo where tt-titulo.marca = "*"
                .
        if not available tt-titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
            
        display tt-titulo.titnum    format "x(10)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/99" 
                tt-titulo.titdtven  format "99/99/99" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                                     
                tt-titulo.titvlpag  
                tt-titulo.titdtpag  format "99/99/99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titulo where recid(tt-titulo) = recatu1.

        on f7 recall.
        choose field tt-titulo.titnum 
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
        if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
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
                next.
            end.



        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-titulo where tt-titulo.marca = "*"  no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titulo where tt-titulo.marca = "*" no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-titulo where tt-titulo.marca = "*"
                 no-error.
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
            find prev tt-titulo where tt-titulo.marca = "*"
                no-error.
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
        hide frame frame-a no-pause.
          
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            /**
            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-titulo.
                update tt-titulo.
                recatu1 = recid(tt-titulo).
                leave.
            end.
            **/
            if esqcom1[esqpos1] = " Filtro"
            then do with frame f-filtro overlay row 6 1 column centered:
                vindex = 0.
                disp s-filtro no-label.
                choose field s-filtro.

                vindex = frame-index.
                
                if vindex = 1
                then do:
                end.
                else if vindex = 2
                then update  f-titdtemi.
                else if vindex = 3
                    then update f-titdtven.
                    else if vindex = 4
                        then update f-titnum.
                        else if vindex = 5
                            then update f-titvlcob.
                
                for each tt-titulo:
                    tt-titulo.marca = "".
                    if vindex = 1
                    then tt-titulo.marca = "*".
                    else if vindex = 2 and
                        tt-titulo.titdtemi = f-titdtemi
                        then tt-titulo.marca = "*". 
                    else if vindex = 3 and
                        tt-titulo.titdtven = f-titdtven
                        then tt-titulo.marca = "*".  
                    else if vindex = 4 and
                        tt-titulo.titnum = f-titnum
                        then tt-titulo.marca = "*".  
                    else if vindex = 5 and
                        tt-titulo.titvlcob = f-titvlcob
                        then tt-titulo.marca = "*".  


                end.
                recatu1 = ?.
                next bl-princ.
            end.
            if esqcom1[esqpos1] = "Altera"
            then do with frame f-altera overlay row 6 1 column centered.
                find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar and
                                  titulo.titdtven = tt-titulo.titdtven
                                  no-error.
                if avail titulo
                then do transaction:
                    update tt-titulo.titnum
                           tt-titulo.modcod 
                           tt-titulo.titdtven
                           /*tt-titulo.titvlcob*/
                           tt-titulo.titvlpag
                           tt-titulo.titdtpag
                       tt-titulo.titsit validate (tt-titulo.titsit = "CON" or
                                                  tt-titulo.titsit = "LIB" or
                                                  tt-titulo.titsit = "PAG",
                                                  "Situacao Invalida.")
                           with frame frame-a.
                    /*       
                    update tt-titulo.titvljur  colon 13 label "Vl.Juro"
                           tt-titulo.titvldes  colon 13 label "Vl.Desc"
                                format ">>>,>>9.99"
                                            with frame fdadpg side-label
                                    overlay row 12 color white/cyan width 40
                                          title " Titulo " no-validate centered.
                    */
                    if tt-titulo.modcod <> titulo.modcod
                    then do:
                        for each titudesp where
                             titudesp.empcod  = 19 and
                             titudesp.titnat = yes and
                             titudesp.modcod = titulo.modcod and
                             titudesp.clifor  = titulo.clifor and
                             titudesp.titnum  = titulo.titnum and
                             titudesp.titpar  = titulo.titpar
                             :
                            titudesp.modcod = tt-titulo.modcod.
                        end.
                        titulo.modcod = tt-titulo.modcod.
                    end.
                    if tt-titulo.titdtpag <> titulo.titdtpag
                    then do:
                        for each titudesp where
                             /*titudesp.empcod  = 19 and
                             titudesp.titnat = yes and
                             titudesp.modcod = titulo.modcod and*/
                             titudesp.clifor  = titulo.clifor and
                             titudesp.titnum  = titulo.titnum and
                             titudesp.titdtemi = titulo.titdtemi and
                             titudesp.titpar  = titulo.titpar
                             :
                            /*#1titudesp.titvlpag = tt-titulo.titvlpag.#1*/
                            titudesp.titvlpag = titudesp.titvlcob.
                            titudesp.titdtpag = tt-titulo.titdtpag.
                            titudesp.titsit   = tt-titulo.titsit.
                        end.
                    end.
                    if tt-titulo.titdtven <> titulo.titdtven
                    then do:
                        for each titudesp where
                             /*titudesp.empcod  = 19 and
                             titudesp.titnat = yes and
                             titudesp.modcod = titulo.modcod and*/
                             titudesp.clifor  = titulo.clifor and
                             titudesp.titnum  = titulo.titnum and
                             titudesp.titdtemi = titulo.titdtemi and
                             titudesp.titpar  = titulo.titpar
                             :
                            titudesp.titdtven = tt-titulo.titdtven.
                        end.
                    end.

                    titulo.titdtven = tt-titulo.titdtven.
                    /*titulo.titvlcob = tt-titulo.titvlcob.*/
                    titulo.titvlpag = tt-titulo.titvlpag.
                    titulo.titdtpag = tt-titulo.titdtpag.
                    /*titulo.titvljur = tt-titulo.titvljur.
                    titulo.titvldes = tt-titulo.titvldes.*/
                    titulo.titsit   = tt-titulo.titsit.
                end.    
                recatu1 = recid(tt-titulo).
                leave.
                /*
                update tt-titulo with frame f-altera no-validate.
                */
            end.
            if esqcom1[esqpos1] = "Alt.Setor"
            then do : 
                

                display tt-titulo.titnum    format "x(10)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/99" 
                                    column-label "Dt.Emis."
                tt-titulo.titdtven  format "99/99/99" 
                                    column-label "Dt.Venc."
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                                    format ">,>>>,>>9.99"
                tt-titulo.titvlpag   format ">,>>>,>>9.99" 
                tt-titulo.titdtpag  format "99/99/99" 
                                    tt-titulo.titdtemi "Dt.Paga."
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a1 1 down row 7.
 
                def var ant-titbanpag like tt-titulo.titbanpag.
                ant-titbanpag = tt-titulo.titbanpag.
                
                update tt-titulo.titbanpag label "Setor"
                 with frame f-alset overlay 
                 no-validate centered row 12 side-label.
 
                if tt-titulo.titbanpag <> ant-titbanpag
                then do:
                find titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar
                                  no-error.
                if avail titulo
                then do transaction:
                    titulo.titbanpag = tt-titulo.titbanpag.
                    for each titudesp where
                             titudesp.empcod  = 19 and
                             titudesp.titnat = yes and
                             titudesp.clifor  = titulo.clifor and
                             titudesp.titnum  = titulo.titnum and
                             titudesp.titpar  = titulo.titpar and
                             titudesp.titbanpag = ant-titbanpag
                             :
                        titudesp.titbanpag = titulo.titbanpag.
                    end.
                end. 
                end.
                hide frame frame-a1 no-pause.
                hide frame f-alset no-pause.                
            end.
            if esqcom1[esqpos1] = "Documento"
            then do:
                find first tt-plani where  
                           tt-plani.etbcod = tt-titulo.etbcod and
                           tt-plani.emite  = tt-titulo.clifor and
                           tt-plani.numero = int(tt-titulo.titnum) and
                           tt-plani.pladat = tt-titulo.titdtemi
                           no-lock no-error.
                if avail tt-plani
                then do:
                    disp tt-plani.pladat label  "Emissao        "
                     tt-plani.dtinclu label "Recebimento    "
                     tt-plani.platot  label "Valor Documento" 
                     with frame f-plani 1 down centered row 10 overlay
                          side-label 1 column .
                          pause.
                    hide frame f-plani no-pause.      
                end.
                else do:
                    message color re/with
                    "Documento nao encontrato."
                    view-as alert-box.
            
                end.
                           
            end.
            /*
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

            **/
            
            if esqcom1[esqpos1] = " GERA CTB"
            then do:
                find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar and
                                  titulo.titdtpag = tt-titulo.titdtpag
                                  no-lock no-error.
                if avail titulo
                then do:
                    run gera-lan-caixa.p(input "TITULO",
                                         input recid(titulo)).
                end.
            end.
            
          end.
          /*
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end. */
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
                
        display tt-titulo.titnum    format "x(10)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/99" 
                tt-titulo.titdtven  format "99/99/99" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                                     
                tt-titulo.titvlpag   
                tt-titulo.titdtpag  format "99/99/99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a.
        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(tt-titulo).
   end.
end.
