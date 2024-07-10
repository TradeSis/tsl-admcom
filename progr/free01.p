/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var totsal like free.fresal.
def var val-10 like free.fresal.
def var val-15 like free.fresal.
def var val-20 like free.fresal.
def var val-25 like free.fresal.
def var cont-10 as int.
def var cont-15 as int.
def var cont-20 as int.
def var cont-25 as int.
def var i as int.
def var vpromocao like free.fresal.
def var vcont as int.
def temp-table tt-free
    field etbcod like func.etbcod
    field funnom like func.funnom
    field cheque as char
    field valor  like free.freval.

def var vval as char format "x(25)" extent 150.
def var vmes as char format "x(09)" extent 12.
def buffer cfree for free. 
def var varquivo as char format "x(20)".
def var vpag like free.freant.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 4 initial
        ["Pagamento","Cheque","Listagem","alteracao"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def var vetbcod like estab.etbcod.
def buffer bfree       for free.
def var vvencod         like free.vencod.

    vval[10]  = "DEZ REAIS".
    vval[15]  = "QUINZE REAIS".
    vval[20]  = "VINTE REAIS".
    vval[25]  = "VINTE E CINCO REAIS".
    vval[30]  = "TRINTA REAIS".
    vval[35]  = "TRINTA E CINCO REAIS".
    vval[40]  = "QUARENTA REAIS".
    vval[45]  = "QUARENTA E CINCO REAIS".
    vval[50]  = "CINQUENTA REAIS".
    vval[55]  = "CINQUENTA E CINCO REAIS".
    vval[60]  = "SESSENTA REAIS".
    vval[65]  = "SESSENTA E CINCO REAIS".
    vval[70]  = "SETENTA REAIS".
    vval[75]  = "SETENTA E CINCO REAIS".
    vval[80]  = "OITENTA REAIS".
    vval[85]  = "OITENTA E CINCO REAIS".
    vval[90]  = "NOVENTA REAIS".
    vval[95]  = "NOVENTA E CINCO REAIS".
    vval[100] = "CEM REAIS".
    vval[105]  = "CENTO E CINCO REAIS".
    vval[110]  = "CENTO E DEZ REAIS".
    vval[115]  = "CENTO E QUINZE REAIS".
    vval[120]  = "CENTO E VINTE REAIS".
    vval[125]  = "CENTO E VINTE E CINCO REAIS".
    vval[130]  = "CENTO E TRINTA REAIS".
    vval[135]  = "CENTO E TRINTA E CINCO REAIS".
    vval[140]  = "CENTO E QUARENTA REAIS".
    vval[145]  = "CENTO E QUARENTA E CINCO REAIS".
    vval[150]  = "CENTO E CINQUENTA REAIS".


    vmes[1]  = "Janeiro".
    vmes[2]  = "Fevereiro".
    vmes[3]  = "Marco".
    vmes[4]  = "Abril".
    vmes[5]  = "Maio".
    vmes[6]  = "Junho".
    vmes[7]  = "Julho".
    vmes[8]  = "Agosto".
    vmes[9]  = "Setembro".
    vmes[10] = "Outubro".
    vmes[11] = "Novembro".
    vmes[12] = "Dezembro".




    form
        esqcom1
            with frame f-com1
                row 3 no-box no-labels side-labels  column 1.

    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    
    find first free no-lock no-error.
    if avail free
    then display free.fredtin label "Periodo" colon 30
                 free.fredtfi label "" with frame f-fil2 row 05
                        no-box centered width 80 side-label.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first free where true no-error.
    else
        find free where recid(free) = recatu1.
    vinicio = yes.
    if not available free
    then do:
        message "Cadastro de Comissao Vazio".
        undo, retry.
    end.
    
    clear frame frame-a all no-pause.
    pause 0.
    find func where func.funcod = free.vencod and
                    func.etbcod = free.etbcod no-lock no-error.
    vpag = free.fresal - free.freant.
    display
        free.etbcod column-label "Fl"
        free.vencod column-label "Vend"
        func.funnom when avail func format "x(20)"
        free.freval column-label "Pecas"  format ">>>>>>9"
        free.fresal column-label "Total"  format ">>>>>9"
        free.freant column-label "Pago"   format ">>>>>9"
        vpag        column-label "Premio" format ">>>>>9"
            with frame frame-a row  7 down centered color black/cyan.

    recatu1 = recid(free).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next free where
                true.
        if not available free
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find func where func.etbcod = free.etbcod and
                        func.funcod = free.vencod no-lock no-error.

        vpag = free.fresal - free.freant.

        display
            free.etbcod
            free.vencod
            func.funnom when avail func
            free.freval
            free.fresal 
            free.freant
            vpag 
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find free where recid(free) = recatu1.

        choose field free.vencod
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
                color display white/cyan
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display white/cyan esqcom1[esqpos1]
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
                esqpos1 = if esqpos1 = 4
                          then 4
                          else esqpos1 + 1.
                color display message
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
                color display white/cyan
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next free where true no-error.
                if not avail free
                then leave.
                recatu1 = recid(free).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev free where true no-error.
                if not avail free
                then leave.
                recatu1 = recid(free).
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
            find next free where
                true no-error.
            if not avail free
            then next.
            color display black/cyan
                free.vencod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev free where
                true no-error.
            if not avail free
            then next.
            color display black/cyan
                free.vencod.
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


            if esqcom1[esqpos1] = "Pagamento"
            then do transaction:
                vpag = free.fresal - free.freant. 

                if vpag = 0
                then do:
                    message "Vendedor sem premio".
                    undo, retry.
                end.
                update vpag
                    with frame frame-a.   
                if vpag > (free.fresal - free.freant) or vpag < 0
                then do:
                    message "Valor invalido".
                    undo, retry.
                end.
                free.freant = free.freant + vpag.  
            end.

            if esqcom1[esqpos1] = "Cheque"
            then do:
                
                varquivo = "i:\admcom\relat\fre" + 
                            string(day(free.fredtfin)) +
                            string(month(free.fredtfin)).

                {mdadmcab.i
                    &Saida     = "value(varquivo)" 
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""free01""
                    &Nom-Sis   = """SISTEMA FINANCEIRO"""
                    &Tit-Rel   = """LISTAGEM DE CHEQUE NEW FREE "" +
                          "" ATE "" + string(free.fredtfi,""99/99/9999"")"
                    &Width     = "160"
                    &Form      = "frame f-cabcab"}
                
                find first cfree where cfree.etbcod = 999 and
                                       cfree.vencod = 99 no-error.
                if not avail cfree
                then do transaction:
                    create cfree.
                    assign cfree.vencod = 99
                           cfree.etbcod = 999
                           cfree.freval = 1000.
                end.
                for each tt-free:
                    delete tt-free.
                end.
                for each bfree break by bfree.etbcod
                                     by bfree.vencod:
                    if bfree.vencod <> 99
                    then totsal = totsal + bfree.fresal.    

                    if bfree.fresal - bfree.freant = 0 and bfree.vencod = 99
                    then do:
                        assign cont-25  = 0
                               cont-20  = 0
                               cont-15  = 0
                               cont-10  = 0
                               val-10 = 0
                               val-15 = 0
                               val-20 = 0
                               val-25 = 0
                               totsal = 0.

                        next. 
                    end.
                    
                    if bfree.fresal - bfree.freant = 0
                    then next.
                    find func where func.etbcod = bfree.etbcod and
                                    func.funcod = bfree.vencod 
                                            no-lock no-error.
                    if not avail func
                    then next.
                    create tt-free.
                    assign tt-free.etbcod = func.etbcod
                           tt-free.funnom = func.funnom
                           tt-free.cheque = string(cfree.freval,"9999")
                           tt-free.valor  = (bfree.fresal - bfree.freant) * 10.
                    
                    /* 
                    /******* PROMOCAO NEW FREE ********/
                    vpromocao = 0.
                    if func.funcod <> 99  
                    then do:
                        i = 0.  
                        do i = (bfree.freant + 1) to bfree.fresal:
                            if i <= 3
                            then do:
                                cont-10 = cont-10 + 1.
                                val-10  = val-10 + 10.
                            end.
                        
                            if i = 4 or
                            i = 5
                            then do:
                                vpromocao = vpromocao + 5.
                                val-15   = val-15  + 5.
                                cont-15  = cont-15 + 1.
                            end.
                            if i = 6 or
                               i = 7
                            then do:
                                vpromocao = vpromocao + 10.
                                val-20   = val-20  + 10.
                                cont-20  = cont-20 + 1.
                            end.

                            if i >= 8
                            then do:
                                vpromocao = vpromocao + 15.
                                val-25    = val-25  + 15.
                                cont-25   = cont-25 + 1.
                            end.
                        end.
                        if vpromocao > 0
                        then tt-free.valor  = tt-free.valor + vpromocao.
                    end.
                    

                    if last-of(bfree.etbcod) and bfree.vencod = 99
                    then do:
                        tt-free.valor = 0.
                        if (int(((totsal / 4) - 0.50)) - bfree.freant) > 0
                        then do:
                            tt-free.valor = (int(((totsal / 4) - 0.50)) - 
                                              bfree.freant) * 10.
                        end.
                        else tt-free.valor = 0.

                        if cont-15 > 0
                        then tt-free.valor = tt-free.valor + 
                             (int(((cont-15 / 4) - 0.50)) * 5).

                        if cont-20 > 0
                        then tt-free.valor = tt-free.valor + 
                            (int(((cont-20 / 4) - 0.50)) * 10).
                        if cont-25 > 0
                        then tt-free.valor = tt-free.valor + 
                             (int(((cont-25 / 4) - 0.50)) * 15).

                        cont-25  = 0.
                        cont-20  = 0.
                        cont-15  = 0.
                        cont-10  = 0.
                        val-10 = 0.
                        val-15 = 0.
                        val-20 = 0.
                        val-25 = 0.
                        totsal = 0.
                    end.
                    /*********************************/
                    */
                    
                    display bfree.vencod column-label "Codigo"
                            func.funnom when avail func column-label "Nome"
                            tt-free.valor(total) column-label "Valor"
                            bfree.etbcod column-label "Filial"
                            cfree.freval column-label "Cheque" format "9999"
                                with frame f-che down width 200.
                    do transaction:
                        bfree.freant = bfree.freant + 
                                       (bfree.fresal - bfree.freant).
                        bfree.fresit = string(cfree.freval,"9999").
                    end.
                    find first cfree where cfree.etbcod = 999 and
                                           cfree.vencod = 99 no-error.
                    do transaction:
                        cfree.freval = cfree.freval + 1.
                    end.
                end.
                output close.
                dos silent value("type " + varquivo + " > prn").
                
                varquivo = "i:\admcom\relat\che" + 
                            string(day(free.fredtfin)) +
                            string(month(free.fredtfin)).
                output to value(varquivo).
                vcont = 0.
                for each tt-free:
                    vcont = vcont + 1.
                    find estab where estab.etbcod = tt-free.etbcod no-lock.
                    put skip
                        "NUMERO.....  " to 20 string(tt-free.cheque,"9999")
                        "FILIAL.....  " to 50 tt-free.etbcod
                        "R$ "           to 100 tt-free.valor skip(1)
                        "Pague por este" at 10 skip
                        "Cheque a quantia de     " at 10
                        vval[int(tt-free.valor)] 
                        "*******************************"
                        skip
                        "***************************************************"
                        at 10
                        "       A  " tt-free.funnom
                        "OU A SUA ORDEM" skip(1)
                        string(estab.munic) format "x(18)" to 80 ","
                        string(day(today),"99") " DE " 
                        vmes[month(today)] " DE " 
                        string(year(today),"9999") skip(3)

                        "____________________________________" to 100 skip
                        "         DREBES E CIA LTDA.         " to 100 skip(2)

                        "_____________________________" to 50 
                        "______________________________" to 90 skip
                        "         Ass.Gerente         " to 50 
                        "        Ass.Funcionario      " to 90 
                        skip(1)
                        fill("-",120) format "x(120)" .
                    if vcont = 3
                    then do:
                        vcont = 0.
                        put skip(12).
                    end.
                end.
                page.
                output close.
                dos silent value("type " + varquivo + " > prn").
                find first free no-lock.
                recatu1 = recid(free).
                
            end.    

            if esqcom1[esqpos1] = "Alteracao"
            then do transaction
                with frame f-altera overlay row 6 1 column centered.
                update free with frame f-altera no-validate.
                hide frame f-altera.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp free with frame f-consulta no-validate.
                hide frame f-consulta.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction
                with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" free.freval update sresp.
                if not sresp
                then leave.
                find next free where true no-error.
                if not available free
                then do:
                    find free where recid(free) = recatu1.
                    find prev free where true no-error.
                end.
                recatu2 = if available free
                          then recid(free)
                          else ?.
                find free where recid(free) = recatu1.
                delete free.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de freeidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each free where free.etbcod < 99
                                    no-lock break by free.etbcod:
                    find func where func.funcod = free.vencod and
                                    func.etbcod = free.etbcod
                                                     no-lock no-error.
                    display free.etbcod column-label "Fl"
                            free.vencod column-label "Vend"
                            func.funnom when avail func format "x(20)"
                            free.freval(total by free.etbcod) 
                                column-label "Pecas"  format ">>>>9"
                            free.fresal(total by free.etbcod) 
                                column-label "Total"  format ">>>>9"
                            free.freant(total by free.etbcod) 
                                column-label "Pago"   format ">>>9"
                            (free.fresal - free.freant)(total by free.etbcod)
                                 column-label "Premio" format ">>>9"
                                            with frame lista down width 200.
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
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        find func where func.funcod = free.venco and
                        func.etbcod = free.etbcod no-lock no-error.
        vpag = free.fresal - free.freant.

        display
                free.etbcod
                free.vencod
                func.funnom when avail func
                free.freval
                free.fresal
                free.freant
                vpag
                    with frame frame-a.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(free).
   end.
end.
