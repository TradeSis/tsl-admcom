{admcab.i}

def input parameter vdti like plani.pladat.
def input parameter vdtf like plani.pladat.

def shared temp-table tt-map
    field t-datmov like mapctb.datmov
    field t-sit    as char format "x(15)"
    field t-etbcod like estab.etbcod
    field t-equipa as int format "99"
    field t-cxacod as int format "99"
    field t-cxa    as char format "x(15)" 
        index ind-1 t-etbcod
                    t-cxacod.


def var varquivo        as char.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 1
            initial ["Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-map       for tt-map.
def var vetbcod          like estab.etbcod.


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

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-map where
            true no-error.
    else
        find tt-map where recid(tt-map) = recatu1.
    vinicio = yes.
    if not available tt-map
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display
        tt-map.t-etbcod format ">>9" column-label "Filial"
        tt-map.t-cxacod format "99" column-label "Caixa"
        tt-map.t-equipa format "99" column-label "Ecf"
        tt-map.t-cxa    column-label "Situacao!Caixa" 
        tt-map.t-sit    column-label "Status"
            with frame frame-a 14 down centered
                 title "Periodo: " + string(vdti) + " - " + 
                      string(vdtf).
.

    recatu1 = recid(tt-map).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-map where
                true.
        if not available tt-map
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        
        display tt-map.t-etbcod 
                tt-map.t-cxacod 
                tt-map.t-equipa 
                tt-map.t-cxa  
                tt-map.t-sit  
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-map where recid(tt-map) = recatu1.

        run color-message.
        choose field tt-map.t-etbcod
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
                esqpos1 = if esqpos1 = 1
                          then 1
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
                find next tt-map where true no-error.
                if not avail tt-map
                then leave.
                recatu1 = recid(tt-map).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-map where true no-error.
                if not avail tt-map
                then leave.
                recatu1 = recid(tt-map).
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
            find next tt-map where
                true no-error.
            if not avail tt-map
            then next.
            color display normal
                tt-map.t-etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-map where
                true no-error.
            if not avail tt-map
            then next.
            color display normal
                tt-map.t-etbcod.
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
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-map.
                update tt-map.t-etbcod format ">99" label "Filial"
                       tt-map.t-equipa
                recatu1 = recid(tt-map).
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                recatu2 = recatu1.
                if opsys = "unix"
                then
                    varquivo = "/admcom/relat/mapux" + string(day(vdti),"99") +
                                string(month(vdtf),"99").
                else
                    varquivo = "l:\relat\map" + string(day(vdti),"99") +
                                string(month(vdtf),"99").
                                
                {mdad.i
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "150"
                    &Page-Line = "66"
                    &Nom-Rel   = ""lismpa5""
                    &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                    &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                                 string(vdti,""99/99/9999"") + "" A "" +
                                 string(vdtf,""99/99/9999"") "
                    &Width     = "150"
                    &Form      = "frame f-cabcab"}


    
                
                for each tt-map by tt-map.t-etbcod 
                                by tt-map.t-equipa:
     
                    display tt-map.t-etbcod column-label "Filial"
                            tt-map.t-equipa column-label "Ecf"
                            tt-map.t-cxacod column-label "Caixa"
                            tt-map.t-cxa    column-label "Situacao!Caixa"
                            tt-map.t-sit    column-label "Status"
                                    with frame f-lista down width 120.
         
         
                end.
   
                output close.
                if opsys = "unix"
                then do:
                    run visurel.p (input varquivo,
                                   input "").
                end.
                else do:
                    {mrod.i} 
                end.     
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
        
                
        display tt-map.t-etbcod 
                tt-map.t-cxacod 
                tt-map.t-equipa 
                tt-map.t-cxa  
                tt-map.t-sit  
                    with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-map).
   end.
end.

procedure color-message.
color display message 
      tt-map.t-etbcod  
      tt-map.t-cxacod  
      tt-map.t-equipa  
      tt-map.t-cxa   
      tt-map.t-sit with frame frame-a.
end procedure.
procedure color-normal. 
color display normal 
    tt-map.t-etbcod  
    tt-map.t-cxacod  
    tt-map.t-equipa  
    tt-map.t-cxa   
    tt-map.t-sit   
        with frame frame-a.
end procedure.

