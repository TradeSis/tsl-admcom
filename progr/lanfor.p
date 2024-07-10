/*
*
*    Esqueletao de Programacao
*
*/
{admcab_l.i}
def var varquivo        as char.
def var sresp           as log format "Sim/Nao".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.   
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Procura/NF","Procura/Tit","Alteracao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer blanfor       for lanfor.
def var vconta         like lanfor.conta.
def var vdti    like plani.pladat initial 01/01/2001.
def var vdtf    like plani.pladat initial 12/31/2001.


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
update vdti label "Periodo"
       vdtf no-label with frame f-1 side-label width 80.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first lanfor where lanfor.datope >= vdti and
                                lanfor.datope <= vdtf no-error.
    else
        find lanfor where recid(lanfor) = recatu1.
    vinicio = yes.
    if not available lanfor
    then do:
        message "Cadastro de lanforidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create lanfor.
                update datope
                       conta.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        lanfor.datope column-label "Dt.Oper"   format "99/99/9999"
        lanfor.histo  column-label "Historico" format "x(30)"
        lanfor.numdoc column-label "Documento"
        lanfor.datven column-label "Dt.Venc"   format "99/99/9999"
        lanfor.valope column-label "Valor"
        lanfor.tipope column-label "T" format "x(01)"
            with frame frame-a 14 down centered.

    recatu1 = recid(lanfor).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next lanfor where lanfor.datope >= vdti and
                               lanfor.datope <= vdtf.
        if not available lanfor
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            lanfor.datope 
            lanfor.histo  
            lanfor.numdoc 
            lanfor.datven
            lanfor.valope
            lanfor.tipope
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find lanfor where recid(lanfor) = recatu1.

        run color-message.
        choose field lanfor.datope
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
                find next lanfor where lanfor.datope >= vdti and
                                       lanfor.datope <= vdtf no-error.
                if not avail lanfor
                then leave.
                recatu1 = recid(lanfor).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev lanfor where lanfor.datope >= vdti and
                                       lanfor.datope <= vdtf no-error.
                if not avail lanfor
                then leave.
                recatu1 = recid(lanfor).
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
            find next lanfor where lanfor.datope >= vdti and 
                                   lanfor.datope <= vdtf no-error.
            if not avail lanfor
            then next.
            color display normal
                lanfor.datope.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev lanfor where lanfor.datope >= vdti and
                                   lanfor.datope <= vdtf no-error.
            if not avail lanfor
            then next.
            color display normal
                lanfor.datope.
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

            if esqcom1[esqpos1] = "Procura/Tit"
            then do:
             
                run tit_val.p.
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update lanfor.conta 
                       lanfor.clifor label "Fornecedor" 
                       lanfor.datope format "99/99/9999" 
                       lanfor.histo   
                       lanfor.valope  
                       lanfor.tipope  
                       lanfor.tipdoc  
                       lanfor.numdoc  
                       lanfor.valtit  
                       lanfor.datemi format "99/99/9999"  
                       lanfor.datven format "99/99/9999" 
                       lanfor.numarq 
                            with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                display  lanfor.conta 
                         lanfor.clifor label "Fornecedor"
                         lanfor.datope format "99/99/9999"
                         lanfor.histo  
                         lanfor.valope 
                         lanfor.tipope 
                         lanfor.tipdoc 
                         lanfor.numdoc 
                         lanfor.valtit 
                         lanfor.datemi format "99/99/9999" 
                         lanfor.datven format "99/99/9999"
                         lanfor.numarq 
                           with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Procura/NF"
            then do:
                run pla_val.p.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                recatu2 = recatu1.
                
                varquivo = "l:\relat\lanfor." + string(time).
    
                {mdad.i 
                    &Saida     = "value(varquivo)" 
                    &Page-Size = "0" 
                    &Cond-Var  = "147" 
                    &Page-Line = "0" 
                    &Nom-Rel   = ""lanfor"" 
                    &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                    &Tit-Rel   = """LANCAMENTOS - FORNECEDORES""
                                    + "" PERIODO DE "" +
                                    string(vdti,""99/99/9999"") + "" A "" +
                                     string(vdtf,""99/99/9999"") "
                    &Width     = "147"
                    &Form      = "frame f-cabcab"}
    
                for each lanfor where lanfor.datope >= vdti and
                                      lanfor.datope <= vdtf no-lock:
                                   
                    find forne where forne.forcod = int(lanfor.clifor)
                                                    no-lock no-error.
                                                    
                    display lanfor.datope column-label "Dt.Oper"
                                          format "99/99/9999"
                            lanfor.histo  column-label "Historico"
                                          format "x(30)" 
                            lanfor.clifor column-label "Codigo"
                            forne.fornom when avail forne
                                            format "x(30)"
                                          
                            lanfor.numdoc column-label "Documento" 
                            lanfor.datven column-label "Dt.Venc"
                                          format "99/99/9999"
                            lanfor.valope(total) column-label "Vl.Operacao"
                                          format ">>>,>>>,>>9.99"
                                with frame f-lista down width 160.
                    
                end.
                output close.
                {mrod.i}
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
          
        display lanfor.datope 
                lanfor.histo  
                lanfor.numdoc 
                lanfor.datven
                lanfor.valope
                lanfor.tipope
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(lanfor).
   end.
end.

procedure color-message.
color display message
        lanfor.datope 
        lanfor.histo  
        lanfor.numdoc
        lanfor.datven
        lanfor.valope
        lanfor.tipope
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        lanfor.datope
        lanfor.histo
        lanfor.numdoc
        lanfor.datven
        lanfor.valope
        lanfor.tipope
        with frame frame-a.
end procedure.

