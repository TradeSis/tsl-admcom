/*
*
*    clafis.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vativo as log init yes format "Ativo/Inativo" label "Situacao".
def var vfilcod as int.
def var vfilcod1 as int.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(15)" extent 5
    init[" Inclusao "," Alteracao "," Consulta "," Procura "," Filtro "].
def var esqcom2         as char format "x(15)" extent 5
    init["",""," Importa IBPT ", " Importa MVA ", " Importa CEST "].

{segregua.i}

def buffer bclafis       for clafis.
def var vcodfis         like clafis.codfis.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form clafis.codfis colon 14 validate(clafis.codfis > 999999,"")
     clafis.desfis colon 14 format "x(60)"
     clafis.pericm colon 14 label "%ICMS" format ">9.9999%" 
     clafis.peripi colon 43 label "%IPI"  format ">9.9999%" 
     clafis.perred label "%Red.Base" format ">9.9999%"
     clafis.sittri colon 14 label "CST ICMS" format "999"
     clafis.int3   colon 43 label "Natureza da Receita" format "999"
     clafis.pisent colon 14 format ">9.99%"
     clafis.pissai colon 43 format ">9.99%"
     clafis.cofinsent at 1 format ">9.99%"
     clafis.cofinssai colon 43 format ">9.99%"
     clafis.int2 colon 14 label "CST PIS/COF"
     clafis.log1 colon 14 label "Monofásico?"
     clafis.log2 colon 14 label "MP do Bem?"
     clafis.mva_estado1  colon 14 label "MVA Est"
     clafis.mva_oestado1 colon 43 label "MVA Out.Est"
     clafis.int1  colon 14 label "Cod.Abacos"
     "Imp.Nota =>" at 6
     clafis.dec1 label "Federal" format ">9.99%"
     clafis.dec2 colon 43 label "Estadual" format ">9.99%"
     clafis.char1 colon 14 label "CEST" format "x(7)"
            validate (clafis.char1 = "" or length(clafis.char1) = 7, "")
     clafis.datexp colon 14
     with frame f-clafis color black/cyan centered side-label row 5.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find clafis where recid(clafis) = recatu1 no-lock.
    if not available clafis
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(clafis).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available clafis
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find clafis where recid(clafis) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field clafis.codfis help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
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
                    if not avail clafis
                    then leave.
                    recatu1 = recid(clafis).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail clafis
                    then leave.
                    recatu1 = recid(clafis).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail clafis
                then next.
                color display white/red clafis.codfis with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail clafis
                then next.
                color display white/red clafis.codfis with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-clafis on error undo.
                    create clafis.
                    update clafis.codfis  validate(clafis.codfis > 999999,"")
                       clafis.desfis    
                       clafis.pericm     
                       clafis.peripi     
                       clafis.perred    
                       clafis.sittri    
                       clafis.int3
                       clafis.pisent    
                       clafis.pissai    
                       clafis.cofinsent 
                       clafis.cofinssai 
                       clafis.int2
                       clafis.log1 
                       clafis.log2     
                       clafis.mva_estado1  
                       clafis.mva_oestado1 
                       clafis.int1
                       clafis.char1
                       with frame f-clafis.
                    clafis.datexp = today.
                    if clafis.char1 <> ""
                    then clafis.char1 = string(int(clafis.char1),"9999999").
                    recatu1 = recid(clafis).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-clafis.
                    disp clafis.codfis 
                       clafis.desfis    
                       clafis.pericm     
                       clafis.peripi     
                       clafis.perred    
                       clafis.sittri    
                       clafis.int3
                       clafis.pisent    
                       clafis.pissai    
                       clafis.cofinsent 
                       clafis.cofinssai 
                       clafis.int2
                       clafis.log1
                       clafis.log2
                       clafis.mva_estado1
                       clafis.mva_oestado1
                       clafis.int1
                       clafis.char1
                       clafis.dec1
                       clafis.dec2
                       clafis.datexp
                       with frame f-clafis.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-clafis on error undo.
                    find clafis where recid(clafis) = recatu1 exclusive.
                    update
                       clafis.desfis    
                       clafis.pericm     
                       clafis.peripi     
                       clafis.perred    
                       clafis.sittri    
                       clafis.int3
                       clafis.pisent    
                       clafis.pissai    
                       clafis.cofinsent 
                       clafis.cofinssai 
                       clafis.int2
                       clafis.log1 
                       clafis.log2     
                       clafis.mva_estado1  
                       clafis.mva_oestado1 
                       clafis.int1
                       clafis.char1     /* CEST */
                       clafis.dec1
                       clafis.dec2
                       with frame f-clafis.

                    if clafis.char1 entered or
                       clafis.dec1  entered or
                       clafis.dec2  entered
                    then /*** Replicador para P2k */
                        for each produ where produ.codfis = clafis.codfis
                                         and produ.proseq <> 99
                                         and produ.datexp <> today.
                            produ.datexp = today - 1.
                        end.

                    clafis.datexp = today.
                    if clafis.char1 <> ""
                    then clafis.char1 = string(int(clafis.char1),"9999999").
                end.
                if esqcom1[esqpos1] = " Procura "
                then do:
                    vcodfis = 0.
                    update vcodfis label "Codigo"
                        with frame f-procura side-label row 10 centered.
                    find bclafis where bclafis.codfis = vcodfis
                                 no-lock no-error. 
                    if not avail bclafis
                    then do:
                        message "Classificacao Fiscal nao Cadastrada".
                        pause.
                        undo, retry.
                    end.
                    recatu1 = recid(bclafis).
                    hide frame f-procura no-pause.
                    leave.
                end.
                if esqcom1[esqpos1] = " Filtro "
                then do with frame f-filtro side-label.
                    update vativo
                           vfilcod " A " vfilcod1
                           .
                    recatu1 = ?.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Importa IBPT "
                then do.
                    run importa-ibpt.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = " Importa MVA "
                then do.
                    run importa-mva.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = " Importa CEST"
                then do.
                    run importa-cest.
                    recatu1 = ?.
                    leave.
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
        recatu1 = recid(clafis).
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

    display
        clafis.codfis format ">>>>>>>9"
        clafis.desfis format "x(30)"
        clafis.pericm column-label "%ICMS" format ">9.99"
        clafis.peripi column-label "%IPI"  format ">9.99"
        clafis.perred column-label "%Red!Base" format ">9.9999"
        clafis.mva_estado1  column-label "MVA%!Est"   format ">9.99"
        clafis.mva_oestado1 column-label "MVA%!O.Est" format ">9.99"
        clafis.dec1 + clafis.dec2 @ clafis.dec1 column-label "%Imp!Nota"
                    format ">9.99"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        clafis.codfis
        clafis.desfis 
        clafis.pericm  
        clafis.peripi  
        clafis.perred
        clafis.mva_estado1
        clafis.mva_oestado1
        clafis.dec1
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        clafis.codfis
        clafis.desfis 
        clafis.pericm  
        clafis.peripi  
        clafis.perred
        clafis.mva_estado1
        clafis.mva_oestado1
        clafis.dec1
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first clafis where 
         (if vativo <> ? then clafis.log3 = vativo else true) and
         (if vfilcod <> 0 then clafis.codfis > 
         vfilcod * int(substr("10000000",1,9 - length(string(vfilcod)))) and
                               clafis.codfis < 
         vfilcod1 * int(substr("10000000",1,9 - length(string(vfilcod1))))                            else true)
                               no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next clafis  where
        (if vativo <> ? then clafis.log3 = vativo else true) and
        (if vfilcod <> 0 then clafis.codfis >
        vfilcod * int(substr("10000000",1,9 - length(string(vfilcod)))) and
                               clafis.codfis < 
        vfilcod1 * int(substr("10000000",1,9 - length(string(vfilcod1))))
                                     else true)
        no-lock no-error.
             
if par-tipo = "up" 
then find prev clafis where 
        (if vativo <> ? then clafis.log3 = vativo else true) and 
        (if vfilcod <> 0 then clafis.codfis >
        vfilcod * int(substr("10000000",1,9 - length(string(vfilcod)))) and
                               clafis.codfis < 
        vfilcod1 * int(substr("10000000",1,9 - length(string(vfilcod1))))
                                     else true)
                                     
        no-lock no-error.
        
end procedure.


def temp-table tt-ibpt
    field ncm     as int
    field ex      as char
    field tabela  as char
    field descric as char
    field aliqnac as dec
    field aliqimp as dec
    field aliqest as dec.

def temp-table tt-mva
    field ncm     as int
    field estado  as dec
    field oestado as dec.

def temp-table tt-cest
    field cest    as int
    field ncm     as int.
    
procedure importa-ibpt.

    def var vpasta   as char init "/admcom/import/".
    def var varquivo as char.
    def var vct      as int.

    disp "Layout: NCM(*); Excecao; Tipo; Descricao; "
         "Aliq.Nacional(*); Aliq.Importados; Aliq.Estadual(*)"
         "(*) Campos importados" skip(1) with frame f-os.
    update
        vpasta   label "Pasta"   format "x(40)"
        varquivo label "Arquivo" format "x(20)"
        with frame f-os side-label.

    empty temp-table tt-ibpt.
    input from value(vpasta + varquivo).
    repeat.
        create tt-ibpt.
        import delimiter ";" tt-ibpt.
    end.
    input close.

    for each tt-ibpt where tt-ibpt.ncm > 0.
        find clafis where clafis.codfis = tt-ibpt.ncm no-error.
        if avail clafis
        then assign
                vct = vct + 1
                clafis.dec1   = tt-ibpt.aliqnac
                clafis.dec2   = tt-ibpt.aliqest
                clafis.datexp = today.
    end.
    message "Registros importados:" vct view-as alert-box.

end procedure.


procedure importa-mva.

    def var vpasta   as char init "/admcom/import/".
    def var varquivo as char.
    def var vct      as int.

    disp "Layout: NCM(*); % MVA Interno(*); MVA Outros(*)" skip
         "(*) Campos importados" skip(1) with frame f-os.
    update
        vpasta   label "Pasta"   format "x(40)"
        varquivo label "Arquivo" format "x(20)"
        with frame f-os side-label.

    empty temp-table tt-mva.
    input from value(vpasta + varquivo).
    repeat.
        create tt-mva.
        import delimiter ";" tt-mva.
    end.
    input close.

    for each tt-mva where tt-mva.ncm > 0
                      and tt-mva.estado > 0
                      and tt-mva.oestado > 0.
        find clafis where clafis.codfis = tt-mva.ncm no-error.
        if avail clafis
        then assign
                vct = vct + 1
                clafis.mva_estado1  = tt-mva.estado
                clafis.mva_oestado1 = tt-mva.oestado
                clafis.datexp = today.
    end.
    message "Registros importados:" vct view-as alert-box.

end procedure.


procedure importa-cest.

    def var vpasta   as char init "/admcom/import/".
    def var varquivo as char.
    def var vct      as int.

    disp "Layout: Codigo CEST; NCM;" skip
         with frame f-cest.
    update
        vpasta   label "Pasta"   format "x(40)"
        varquivo label "Arquivo" format "x(20)"
        with frame f-os side-label.

    empty temp-table tt-cest.
    input from value(vpasta + varquivo).
    repeat.
        create tt-cest.
        import delimiter ";" tt-cest.
    end.
    input close.

    for each tt-cest where tt-cest.ncm  > 0
                       and tt-cest.cest > 0.
        find clafis where clafis.codfis = tt-cest.ncm no-error.
        if avail clafis
        then assign
                vct = vct + 1
                clafis.char1  = string(tt-cest.cest, "9999999")
                clafis.datexp = today.
    end.
    message "Registros importados:" vct view-as alert-box.

end procedure.

