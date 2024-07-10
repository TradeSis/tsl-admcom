/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}


def var tit-cab as char format "x(60)".

def shared temp-table tt-produ
    field fabcod like fabri.fabcod
    field procod like produ.procod
    field pronom like produ.pronom
    field estemp like estoq.estatual
    field estatual like estoq.estatual
    field estvenda like estoq.estvenda
    field clacod   like clase.clacod
        index ind-1 pronom.
 
  
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


def buffer btt-produ       for tt-produ.
def var vprocod         like tt-produ.procod.


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
    
    if recatu1 = ?
    then
        find first tt-produ where
            true no-error.
    else
        find tt-produ where recid(tt-produ) = recatu1.
    vinicio = yes.
    if not available tt-produ
    then do:
        message "Nenhum registro encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.

    if tt-produ.clacod = 0
    then do:
    
        find fabri where fabri.fabcod = tt-produ.fabcod no-lock.
        tit-cab = fabri.fabfant.
    end.

    else do:
        find clase where clase.clacod = tt-produ.clacod no-lock.
        tit-cab = clase.clanom.
    end.
    if tt-produ.clacod <> 0 and
       tt-produ.fabcod <> 0
    then do:

        find fabri where fabri.fabcod = tt-produ.fabcod no-lock.
        find clase where clase.clacod = tt-produ.clacod no-lock.

        tit-cab = fabri.fabfant + "  " + clase.clanom.
    end.    
    
    display
        tt-produ.procod
        tt-produ.pronom   format "x(30)"
        tt-produ.estvenda format ">>,>>9.99" column-label "Preco!Venda"
        tt-produ.estatual format "->>>>>>9"  column-label "Estoque!Filial"
        tt-produ.estemp   format "->>>>>>9"  column-label "Estoque!Geral"
            with frame frame-a 14 down centered
                title tit-cab.

    recatu1 = recid(tt-produ).
    repeat:
        find next tt-produ where
                true.
        if not available tt-produ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tt-produ.procod
            tt-produ.pronom
            tt-produ.estvenda
            tt-produ.estatual
            tt-produ.estemp
                with frame frame-a title tit-cab.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-produ where recid(tt-produ) = recatu1.

        choose field tt-produ.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-produ where true no-error.
                if not avail tt-produ
                then leave.
                recatu1 = recid(tt-produ).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-produ where true no-error.
                if not avail tt-produ
                then leave.
                recatu1 = recid(tt-produ).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-produ where
                true no-error.
            if not avail tt-produ
            then next.
            color display normal
                tt-produ.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-produ where
                true no-error.
            if not avail tt-produ
            then next.
            color display normal
                tt-produ.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        
        display tt-produ.procod
                tt-produ.pronom
                tt-produ.estvenda
                tt-produ.estatual
                tt-produ.estemp with frame frame-a title tit-cab.
                
        recatu1 = recid(tt-produ).
   end.
end.
