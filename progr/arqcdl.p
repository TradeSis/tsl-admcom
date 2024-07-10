/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var varquivo as char.
def var vseq as int.
def var varqcdl as char format "x(20)".
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var valor   like plani.platot.
def var vmotivo as char format "x(50)".
def var aviso-1 like arqcdl.p-aviso.
def var aviso-2 like arqcdl.p-aviso.
def var aviso-3 like arqcdl.p-aviso.
def var vqtdenv like arqcdl.qtdenv.
def var venviado like arqcdl.enviado.

def var vsenha  like func.senha.
def var vetbini like estab.etbcod.
def var vetbfin like estab.etbcod.
def var vdatenv like arqcdl.datenv.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer barqcdl       for arqcdl.


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
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first arqcdl where true no-error.
    else find arqcdl where recid(arqcdl) = recatu1.
    vinicio = yes.
    if not available arqcdl
    then do:
        vsenha = "".
        valor  = 0.
        update vetbini label "Filial" colon 15
               vetbfin no-label
                    with frame f-inc side-label centered width 80.
        
        update vdatenv label "Data Envio" colon 15 with frame f-inc.
        
        update aviso-1 label "1o Aviso" colon 15 
               aviso-2 label "2o Aviso" colon 15
               aviso-3 label "Extra Jud." colon 15
               vdtini  label "Periodo"  colon 15
               vdtfin  no-label 
               vqtdenv label "Qdt Enviado"
               venviado label "Enviado" with frame f-inc.
        
        
        create arqcdl.
        assign arqcdl.etbini  = vetbini
               arqcdl.etbfin  = vetbfin
               arqcdl.datenv  = vdatenv
               arqcdl.p-aviso = aviso-1
               arqcdl.s-aviso = aviso-2
               arqcdl.extra   = aviso-3
               arqcdl.dtini   = vdtini
               arqcdl.dtfin   = vdtfin
               arqcdl.qtdenv  = vqtdenv
               arqcdl.enviado = venviado.
        

        vinicio = no.
        
    end.
    clear frame frame-a all no-pause.
    
    display arqcdl.etbini column-label "Fl"
            arqcdl.etbfin column-label "Fl"
            arqcdl.datenv 
            arqcdl.p-aviso
            arqcdl.s-aviso 
            arqcdl.extra  column-label "Extra Jud."
            arqcdl.enviado
                with frame frame-a 14 down centered.

    recatu1 = recid(arqcdl).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next arqcdl where
                true.
        if not available arqcdl
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        display arqcdl.etbini
                arqcdl.etbfin
                arqcdl.datenv 
                arqcdl.p-aviso
                arqcdl.s-aviso 
                arqcdl.extra
                arqcdl.enviado  with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find arqcdl where recid(arqcdl) = recatu1.

        choose field arqcdl.etbini
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
                find next arqcdl where true no-error.
                if not avail arqcdl
                then leave.
                recatu1 = recid(arqcdl).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev arqcdl where true no-error.
                if not avail arqcdl
                then leave.
                recatu1 = recid(arqcdl).
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
            find next arqcdl where
                true no-error.
            if not avail arqcdl
            then next.
            color display normal
                arqcdl.etbini.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev arqcdl where
                true no-error.
            if not avail arqcdl
            then next.
            color display normal
                arqcdl.etbini.
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
                vsenha = "".
                valor  = 0. 
                update vetbini label "Filial" colon 15
                       vetbfin no-label
                    with frame f-inc side-label centered width 80.
           
                update vdatenv label "Data Envio" colon 15
                                    with frame f-inc.
                
                update aviso-1 label "1o Aviso" colon 15 
                       aviso-2 label "2o Aviso" colon 15
                       aviso-3 label "Extra Jud." colon 15
                       vdtini  label "Periodo"  colon 15
                       vdtfin  no-label 
                       vqtdenv label "Qdt Enviado"
                       venviado label "Enviado" with frame f-inc.
        
        
                create arqcdl.
                assign arqcdl.etbini  = vetbini
                       arqcdl.etbfin  = vetbfin
                       arqcdl.datenv  = vdatenv
                       arqcdl.p-aviso = aviso-1
                       arqcdl.s-aviso = aviso-2
                       arqcdl.extra   = aviso-3
                       arqcdl.dtini   = vdtini
                       arqcdl.dtfin   = vdtfin
                       arqcdl.qtdenv  = vqtdenv
                       arqcdl.enviado = venviado.
        

                recatu1 = recid(arqcdl).
                leave.
            end.
            if esqcom1[esqpos1] = "*Alteracao*"
            then do with frame f-altera overlay row 6 1 column centered.
                update arqcdl with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp arqcdl.etbini
                     arqcdl.etbfin
                     arqcdl.datenv
                     arqcdl.p-aviso
                     arqcdl.s-aviso
                     arqcdl.extra label "Extra Jud."
                     arqcdl.dtini
                     arqcdl.dtfin
                     arqcdl.qtdenv
                     arqcdl.enviado
                        with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" arqcdl.datenv update sresp.
                if not sresp
                then leave.
                find next arqcdl where true no-error.
                if not available arqcdl
                then do:
                    find arqcdl where recid(arqcdl) = recatu1.
                    find prev arqcdl where true no-error.
                end.
                recatu2 = if available arqcdl
                          then recid(arqcdl)
                          else ?.
                find arqcdl where recid(arqcdl) = recatu1.
                delete arqcdl.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao" update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                         
                varquivo = "..\relat\arqcdl." + string(day(today)). 

                {mdad.i
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "130"
                    &Page-Line = "66"
                    &Nom-Rel   = ""arqcdl""
                    &Nom-Sis   = """SISTEMA DE CREDIARIO"""
                    &Tit-Rel   = """RELACAO DE ARQUIVOS CDL/CARTAS""" 
                    &Width     = "130"
                    &Form      = "frame f-cabcab"}
    
    

                for each arqcdl no-lock by arqcdl.datenv:
                    display arqcdl.etbini column-label "Fl"
                            arqcdl.etbfin column-label "Fl"
                            arqcdl.datenv 
                            arqcdl.p-aviso  column-label "Primeiro!Aviso"
                            arqcdl.s-aviso  column-label "Segundo!Aviso"
                            arqcdl.extra    column-label "Extra!Judicial"
                            arqcdl.qtdenv
                            arqcdl.enviado with frame f-print down width 120.
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
         display arqcdl.etbini                                 
                 arqcdl.etbfin
                 arqcdl.datenv 
                 arqcdl.p-aviso
                 arqcdl.s-aviso 
                 arqcdl.extra
                 arqcdl.enviado with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(arqcdl).
   end.
end.
