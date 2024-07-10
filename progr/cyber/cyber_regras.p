/** #1 **/ /** Proj Boletos 18.09.2017 
               Parametro para Titulo associado a Boleto 
           **/ 
/** #2 **/ /** Proj Parametros CP - Cyber 19.129.2017 
               Parametro para Contrato CP
           **/ 
           
/*
*
*    Cyber_regras.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 6
    init ["Estab Proc","Estab Nov","Estab LP","Dias Nov",
          "Dias LP","Dias Boleto"].

def var esqcom2         as char format "x(15)" extent 5
    init [" X Dias ","Estab X Dias ","Estab CP", "Dias CP"," Consulta Estab"].

def buffer bCyber_regras       for Cyber_regras.

def var vtoday as date.
vtoday = today.
/*vtoday = 01/01/2014.*/

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    "=== Regras para X Dias ====" skip
    esqcom2[1]      esqcom2[2]
    esqcom2[3]      esqcom2[4]
    with frame f-com2 row screen-lines - 1 no-box no-labels column 1 centered.

def var vmes1   as char format "x(10)".
def var vmes2   as char format "x(3)".
def var vregra  as char format "x(16)". 
form
    Cyber_regras.Cyber_Mes      
    vmes1 no-label
    space(5)
    vregra              column-label "Dia"
    Cyber_regras.Cyber_MesVecto column-label "Mes"
    vmes2 no-label
    Cyber_regras.Cyber_AnoVecto column-label "Ano"
        with frame frame-a 12 down centered color white/red row 5.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find Cyber_regras where recid(Cyber_regras) = recatu1 no-lock.
    if not available Cyber_regras
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(Cyber_regras).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available Cyber_regras
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find Cyber_regras where recid(Cyber_regras) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field Cyber_regras.Cyber_Mes help ""
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
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail Cyber_regras
                    then leave.
                    recatu1 = recid(Cyber_regras).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail Cyber_regras
                    then leave.
                    recatu1 = recid(Cyber_regras).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail Cyber_regras
                then next.
                color display white/red Cyber_regras.Cyber_Mes with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail Cyber_regras
                then next.
                color display white/red Cyber_regras.Cyber_Mes with frame frame-a.
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

                hide frame f-com1  no-pause.
                hide frame f-com2  no-pause.

                if esqcom1[esqpos1] = "Estab Proc"
                then run cyber/etbprocessa.p ("CYBER_REGRA_GERAL").

                if esqcom1[esqpos1] = "Estab Nov"
                then run cyber/etbprocessa.p ("CYBER_REGRA_NOVACAO").

                if esqcom1[esqpos1] = "Estab LP"
                then run cyber/etbprocessa.p ("CYBER_REGRA_LP").

                if esqcom1[esqpos1] = "Dias Nov"
                then run cyber/ndias.p ("CYBER_NDIAS_NOVACAO").
                
                if esqcom1[esqpos1] = "Dias LP"
                then run cyber/ndias.p ("CYBER_NDIAS_LP").

                /** #1 **/
                if esqcom1[esqpos1] = "Dias Boleto"
                then run cyber/ndias.p ("CYBER_NDIAS_BOLETO").

                view frame f-com1.
                view frame f-com2.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " X Dias "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cyber/ndias.p ("CYBER_NDIAS").
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Estab X Dias "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cyber/etbndias.p.
                    view frame f-com1.
                    view frame f-com2.
                end.
                /* #2 */
                if esqcom2[esqpos2] = "Estab CP"
                then run cyber/etbprocessa.p ("CYBER_REGRA_CP").
                if esqcom2[esqpos2] = "Dias CP"
                then run cyber/ndias.p ("CYBER_NDIAS_CP").
                /* #2 */
                if esqcom2[esqpos2] = " Consulta Estab"
                then run cyb/cons_estab.p.

                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(Cyber_regras).
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

def var xdtven as date.

procedure frame-a.

    def var qdtven as date.
    qdtven = date(Cyber_regras.Cyber_MesVecto,
                      21,
                      year(vtoday) + Cyber_regras.Cyber_AnoVecto ).

    run cyber/busca_data_vencimento.p (input  qdtven,   
                                       output xdtven).
    display 
        Cyber_regras.Cyber_Mes      
        vmescomp[Cyber_regras.Cyber_Mes] @ vmes1 
        (if Cyber_regras.Cyber_DiaVecto = 99
        then "Primeiro Dia Mes"
        else string(Cyber_regras.Cyber_DiaVecto)) @ vregra 
        Cyber_regras.Cyber_MesVecto 
        vmesabr[Cyber_regras.Cyber_MesVecto] @ vmes2
        year(vtoday) + Cyber_regras.Cyber_AnoVecto @ Cyber_regras.Cyber_AnoVecto
        xdtven   column-label "Vencimento" format "99/99/9999"
        with frame frame-a 12 down centered color white/red row 5 no-underline.
end procedure.

procedure color-message.
color display message
        Cyber_regras.Cyber_Mes
        Cyber_regras.Cyber_Mes       
        vmes1
        vregra
        Cyber_regras.Cyber_MesVecto  
        vmes2
        Cyber_regras.Cyber_AnoVecto         xdtven
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        Cyber_regras.Cyber_Mes      
        vmes1
        vregra
        Cyber_regras.Cyber_MesVecto 
        vmes2
        Cyber_regras.Cyber_AnoVecto         xdtven
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first Cyber_regras where true
                                                no-lock no-error.
    else  
        find last Cyber_regras  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next Cyber_regras  where true
                                                no-lock no-error.
    else  
        find prev Cyber_regras   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev Cyber_regras where true  
                                        no-lock no-error.
    else   
        find next Cyber_regras where true 
                                        no-lock no-error.
        
end procedure.

