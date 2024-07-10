/* helio 15052023 - alterado logica vpag vatr*/
/* helio #12092022 - incluir campo com o codigo do vendedor */
/*
*
*           consulta de contratos por clientes
*/
{admcab.i}

def var reccont         as int.
def var recatu1         as recid.
def var esqpos1         as int.
def var esqcom1         as char format "x(18)" extent 4
    initial [" Parcelas "," Extrato ","Consulta/Extrato","    Nota Fiscal"].

def temp-table ttcon no-undo
    field ttrec as recid
    field contnum   like contrato.contnum
    field dtinicial like contrato.dtinicial
    field vencod        like plani.vencod /* #12092022 */
    index ind1 dtinicial desc.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.

form
    esqcom1 with frame f-com1 row 3 no-box no-labels centered.

repeat:
    for each ttcon.
        delete ttcon.
    end.
    
    prompt-for clien.clicod colon 25
               with frame fclien centered color white/cyan row 5 side-label.
    find clien using clicod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente Nao cadastrado".
        undo.
    end.
    display clien.clinom no-label
            with frame fclien.
    
    update v-consulta-parcelas-LP label " Considera apenas LP"
  help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"  colon 25
    with frame fclien  side-label .

    assign
        esqpos1  = 1
        recatu1  = ?.
    pause 0.
    
    for each contrato where contrato.clicod = clien.clicod no-lock.
        find first ttcon where ttcon.ttrec = recid(contrato) no-error.
        if not avail ttcon
        then do:
            create ttcon.
            assign ttcon.ttrec     = recid(contrato)
                   ttcon.dtinicial = contrato.dtinicial
                   ttcon.contnum   = contrato.contnum.
                   
            /* #12092022 */ 
            ttcon.vencod = 0.                  
            find first contnf  where contnf.etbcod  = contrato.etbcod and
                                     contnf.contnum = contrato.contnum
                no-lock no-error.
            if avail contnf
            then do:
                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod
                    no-lock no-error.
                if avail plani
                then do:
                    ttcon.vencod = plani.vencod.
                end.
            end.
            /* #12092022*/
                                                                 
        end.
    end.

def var vcartao-lebes as char.
assign
    recatu1 = ?
    esqpos1 = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcon where recid(ttcon) = recatu1 no-lock.
    if not available ttcon
    then do:
        message "Nenhum Contrato Para o Cliente".
        leave bl-princ.
    end. 
    clear frame frame-a all no-pause.

    run frame-a.

    recatu1 = recid(ttcon).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcon
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.

        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        find ttcon where recid(ttcon) = recatu1 no-lock.
        find contrato where recid(contrato) = ttcon.ttrec no-lock.

        choose field ttcon.contnum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  PF4 F4 ESC return).

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttcon
                    then leave.
                    recatu1 = recid(ttcon).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcon
                    then leave.
                    recatu1 = recid(ttcon).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcon
                then next.
                color display white/red ttcon.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcon
                then next.
                color display white/red ttcon.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "    Nota Fiscal"
            then do:
                for each contnf where contnf.etbcod  = contrato.etbcod and
                                      contnf.contnum = contrato.contnum 
                                                    no-lock:
                    vcartao-lebes = "".
                    
                    find first plani where 
                               plani.movtdc = 5 and
                               plani.etbcod = contrato.etbcod and
                               plani.placod = contnf.placod 
 /*** and
                               plani.serie = "V"
                               no-lock no-error.
                    if not avail plani
                    then find first plani where
                                    plani.movtdc = 5 and
                                    plani.etbcod = contrato.etbcod and
                                    plani.placod = contnf.placod and
                                    plani.serie = "3"
***/
                                    no-lock no-error.
                    if avail plani
                    then do:                
                        if acha("CARTAO-LEBES",PLANI.NOTOBS[1]) <> ?
                        then vcartao-lebes = 
                            acha("CARTAO-LEBES",plani.notobs[1]).
                        display plani.numero label "Numero" format "999999999"
                                             colon 20
                                plani.serie  label "Serie"
                                plani.pladat label "Data"
                                plani.platot label "Valor da Nota"   colon 20
                                vcartao-lebes label "Cartao Lebes"
                                        format "x(13)"
                                plani.vlserv label "Valor Servicos" colon 20
                                plani.biss   label "Valor C/ Acrescimo"
                                                        colon 20
                                    with frame fnota side-label centered
                                            color message.
                        find finan where finan.fincod = plani.pedcod no-lock
                                                        no-error.
                        display plani.pedcod label "Plano" colon 20
                                finan.finnom no-label when avail finan
                                        with frame fnota.
                        find func where func.etbcod = plani.etbcod and
                                        func.funcod = plani.vencod 
                                                no-lock no-error.
                        display plani.vencod label "Vendedor"colon 20
                                func.funnom no-label when avail func 
                                        with frame fnota side-label.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc and
                                             movim.movdat = plani.pladat
                                                        no-lock:
                            find produ where produ.procod = movim.procod 
                                                        no-lock no-error.
                            display movim.procod
                                    produ.pronom when avail produ 
                                            format "x(21)"
                                    movim.movqtm column-label "Qtd" 
                                            format ">>>>9"
                                    movim.movpc format ">>,>>9.99" 
                                            column-label "Preco" 
                                    (movim.movqtm * movim.movpc)
                                            column-label "Total"
                                        with frame fmov down centered
                                                        color blue/message.
                        end.                                
                    end.                     
                end.                                
            end.
            if esqcom1[esqpos1] = " Parcelas "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run parcco.p (input recid(contrato)).
                view frame f-com1.
                pause 0.
            end.

            if esqcom1[esqpos1] = " Extrato "
            then do:
                message "Confirma a emissao do extrato do cliente"
                        clien.clinom "?" update sresp.
                if not sresp
                then leave.
                
                /**   Programa extrato.p já trata anita ou admcom
                if opsys = "UNIX" then
                 run extrato1.p (input recid(clien)).
                else
                **/ 
                run extrato.p (input recid(clien)).
                leave.
            end.

            if esqcom1[esqpos1] = "Consulta/Extrato"
            then run extrato3.p (input recid(clien)).
        end.

        view frame frame-a.
        run frame-a.

        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcon).
    end.
end.
hide frame f-com1 no-pause.
hide frame frame-a no-pause.
end.


procedure frame-a.

    def var vsit as char format "x(06)".
    def var vatr as log.
    def var vpag as log.

    vpag = yes.
    vatr = no.
    find contrato where recid(contrato) = ttcon.ttrec no-lock.

    for each titulo where titulo.empcod = wempre.empcod             and /* helio 15052023 */
                          titulo.titnum = string(contrato.contnum)  and
                          titulo.titnat = no                        and
                          titulo.etbcod = contrato.etbcod           and
                          titulo.clifor = contrato.clicod           and
                          titulo.modcod = contrato.modcod
            and titulo.titpar > 0                          
            and titulo.titsit = "LIB"
                    no-lock by titulo.titpar.

        /* helio 15052023
        if titulo.tpcontrato = "L"
        then assign v-parcela-lp = yes.
        else assign v-parcela-lp = no.
                                       
        if v-consulta-parcelas-LP = no
            and v-parcela-lp = yes
        then next.
                            
        if v-consulta-parcelas-LP = yes
           and v-parcela-lp = no
        then next.
        */
                          
        if titulo.titsit = "LIB"
        then do:
            vpag = no.
            if titulo.titdtven < today
            then vatr = yes.
            leave.
        end.
    end.

    find estab where estab.etbcod = contrato.etbcod no-lock.
    
    vsit = "".
    if vpag
    then vsit = "PAG".
    if vatr
    then vsit = "ATR".
    pause 0.
    display
        ttcon.contnum     FORMAT ">>>>>>>>>9"        LABEL "Contrato"
        /* #12092022 */
        contrato.etbcod  column-label "Fil" format ">>>9"
        contrato.modcod column-label "Mod" format "x(3)"        
        ttcon.vencod    format ">>>>>9" column-label "vend"  
        /* #12092022 */
        contrato.dtinicial   FORMAT "99/99/9999"     column-LABEL "Data Emis"
        contrato.vltotal     FORMAT ">>,>>9.99" LABEL "Valor total"
        contrato.vlentra     FORMAT ">>,>>9.99" LABEL "Vl Entrada"
        vsit            no-label    
        with frame frame-a 14 down centered 
            title " Cod. " + string(clien.clicod) + " " + clien.clinom + " ".

end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first ttcon where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next ttcon  where true no-lock no-error.
             
if par-tipo = "up" 
then   find prev ttcon where true   no-lock no-error.
        
end procedure.
 
