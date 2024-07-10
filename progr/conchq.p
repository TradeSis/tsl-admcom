{admcab.i}

def var v-tipo as char format "x(01)".

def var v-conf as char format "x(20)" extent 3
    initial ["CONFIRMADOS","NAO CONFIRMADOS","GERAL"].
    
def var varquivo        as char.
def var vtexto          as char format "x(30)".
def var v-dig           as int.

def var totchq like chq.valor.

def new shared temp-table tt-man
    field rec as recid
    field banco like chq.banco
    field agencia like chq.agencia
        index ind-1 banco
                    agencia.
    
def new shared temp-table tt-che
    field rec  as recid
    index rec is primary unique rec asc.


def var vok  as log.
def var vtot like plani.platot.
def var vdep like plani.platot.
def var vchqdia like plani.platot.
def var vchqpre like plani.platot.
def var vinfdia like plani.platot.
def var vinfpre like plani.platot.

def temp-table tt-chq
    field marca  as char format "x(01)"
    field etbcod like estab.etbcod
    field chqpre like plani.platot
    field chqdia like plani.platot
    field depdia like plani.platot
    field deppre like plani.platot
    field difpre like plani.platot format "->,>>9.99"
    field difdia like plani.platot format "->,>>9.99"
        index ind-1 etbcod
        index ind-2 marca.
                
                
def temp-table tt-lista
    field recche as recid
    field etbcod like estab.etbcod.
                    
def var vcatcod like produ.catcod.    
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(13)" extent 3
            initial ["Consulta","Listagem","Gera Arquivo"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bchq       for chq.
def var vetbcod       like estab.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

    vdti = today - 1.
    vdtf = today - 1.

         
repeat:    

    v-tipo = "".
    for each tt-lista:
        delete tt-lista.
    end.
        
    clear frame f-com1 no-pause.
    recatu1 = ?.
    
    display v-conf with frame f-tipo no-label centered row 10.
    choose field v-conf with frame f-tipo.
    
    if frame-index = 1
    then v-tipo = "C".

    if frame-index = 2
    then v-tipo = "N".
    
    if frame-index = 3
    then v-tipo = "G".
    
    hide frame f-tipo no-pause.

    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final"
                with frame fdata side-label width 80 row 3.
   
    
    for each tt-chq:
        delete tt-chq.
    end.
    
    
    vtot = 0.

    assign vchqdia = 0
           vinfdia = 0
           vchqpre = 0
           vinfpre = 0.
    

    for each chq use-index chqdatemi
                 where chq.datemi >= vdti        and
                       chq.datemi <= vdtf no-lock.
                          

        find first chqtit use-index ind-1
                          where chqtit.banco   = chq.banco    and
                                chqtit.agencia = chq.agencia  and
                                chqtit.conta   = chq.conta    and
                                chqtit.numero  = chq.numero no-lock no-error.
        if not avail chqtit
        then next.
        if chq.datemi = chq.data
        then.
        else next.

        if v-tipo = "C"
        then do:
            find deposito where deposito.etbcod = chqtit.etbcod and
                                deposito.datmov = chq.datemi no-lock no-error.
            if avail deposito and
               deposito.datcon <> ?
            then.
            else next.
        end.

        if v-tipo = "N"
        then do:
            find deposito where deposito.etbcod = chqtit.etbcod and
                                deposito.datmov = chq.datemi no-lock no-error.
            if not avail deposito or
               deposito.datcon = ?
            then.
            else next.
        end.
        

        
        
        find first tt-chq where tt-chq.etbcod = chqtit.etbcod no-error.
        if not avail tt-chq
        then do:
            create tt-chq.
            assign tt-chq.etbcod = chqtit.etbcod
                   tt-chq.marca  = "".
        end.  
        assign tt-chq.chqdia = tt-chq.chqdia + chq.valor 
               vchqdia       = vchqdia       + chq.valor.
               
    end.
    
    for each chq use-index chqdata
                 where chq.data >= vdti        and
                       chq.data <= vdtf no-lock.
                          
        find first chqtit use-index ind-1
                          where chqtit.banco   = chq.banco    and
                                chqtit.agencia = chq.agencia  and
                                chqtit.conta   = chq.conta    and
                                chqtit.numero  = chq.numero no-lock no-error.
        if not avail chqtit
        then next.

        if chq.datemi <> chq.data
        then.
        else next. 
 
        if v-tipo = "C"
        then do:
            find deposito where deposito.etbcod = chqtit.etbcod and
                                deposito.datmov = chq.datemi no-lock no-error.
            if avail deposito and
               deposito.datcon <> ?
            then.
            else next.
        end.

        if v-tipo = "N"
        then do:
            find deposito where deposito.etbcod = chqtit.etbcod and
                                deposito.datmov = chq.datemi no-lock no-error.
            if not avail deposito or
               deposito.datcon = ?
            then.
            else next.
        end.
         

        find first tt-chq where tt-chq.etbcod = chqtit.etbcod no-error.
        if not avail tt-chq
        then do:
            create tt-chq.
            assign tt-chq.etbcod = chqtit.etbcod
                   tt-chq.marca  = "". 
        end.  
        assign tt-chq.chqpre = tt-chq.chqpre + chq.valor
               vchqpre       = vchqpre       + chq.valor.
               
    end.

    display "Tot...." 
            vchqpre  to 42
            vchqdia  to 55
             with frame f-tot 
                no-label no-box color message row 21 width 80
                overlay. 
    pause 0.            
            
bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-chq where true no-error.
    else find tt-chq where recid(tt-chq) = recatu1.
    if not available tt-chq
    then do:
        message "Nao existe divergencia para este dia".
        pause.
        undo, retry.
    end.
    
    clear frame frame-a all no-pause.
    
    view frame f-tot .
    pause 0.
    display tt-chq.etbcod  column-label "Fil"
            tt-chq.chqpre  column-label "Cheque Pre"
            tt-chq.chqdia  column-label "Cheque Dia"
                with frame frame-a 13 down centered overlay
                    title trim(" -  Dia: " + 
                               string(vdti,"99/99/9999") + " - " + 
                               string(vdtf,"99/99/9999")).
    pause 0.
    recatu1 = recid(tt-chq).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.

    repeat:
        find next tt-chq where true no-error.
        if not available tt-chq
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        
        display tt-chq.etbcod 
                tt-chq.chqpre 
                tt-chq.chqdia
                    with frame frame-a.
    

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-chq where recid(tt-chq) = recatu1.


        choose field tt-chq.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
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
                esqpos1 = if esqpos1 = 3
                          then 3
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
            find next tt-chq where true no-error.
            if not avail tt-chq
            then next.
            color display normal
                tt-chq.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-chq where true no-error.
            if not avail tt-chq
            then next.
            color display normal
               tt-chq.etbcod.
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
            if esqcom1[esqpos1] = "Listagem" 
            then do: 
                run listagem.
            end.

            if esqcom1[esqpos1] = "Gera Arquivo*"
            then do:
                
                for each tt-che:
                    delete tt-che.
                end.
                
                for each chq where chq.datemi >= vdti        and
                                   chq.datemi <= vdtf.
                          
                    find first chqtit of chq no-lock no-error. 
                    if not avail chqtit 
                    then next.
                
                    vok = no.
                    for each tt-chq where tt-chq.marca = "*".
                        if chqtit.etbcod = tt-chq.etbcod
                        then vok = yes.
                    end.

                    if vok = no
                    then next.
                    
                                       /*
                    if chqtit.banco <> 41
                    then next.         */
                    
                    
                    if chq.datemi <> chq.data
                    then next. 
                    
                    message "Gerando arquivo....".
                    
                    display chq.banco
                            chq.numero
                            chq.valor(total)
                             with 1 down centered. pause 0.
                            
                            
                    find tt-che where tt-che.rec = recid(chq) no-error.
                    if not avail tt-che
                    then do:
                        create tt-che.
                        assign tt-che.rec = recid(chq).
                    end.
                    
                    vtexto = string(chq.numero).
                    run verif11.p ( input vtexto , 
                                    output v-dig).

                    if v-dig <> chq.controle3
                    then chq.controle3 = v-dig.
        
                end.
                
                run arq041.p.
                recatu1 = ?. /* recid(tt-chq). */
                
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay centered down.

                
                hide frame f-tot no-pause.
                for each tt-man.
                    delete tt-man.
                end.

                totchq = 0.
                
                for each chq where chq.datemi >= vdti        and
                                   chq.datemi <= vdtf no-lock.
                          

                     find first chqtit where chqtit.banco   = chq.banco    and
                                            chqtit.agencia = chq.agencia  and
                                            chqtit.conta   = chq.conta    and
                                            chqtit.numero  = chq.numero 
                                                no-lock no-error.
                    if not avail chqtit
                    then next.
                    if chq.datemi = chq.data
                    then.
                    else next.
                    
                    if chqtit.etbcod <> tt-chq.etbcod
                    then next.

 
                   
                    
                    if v-tipo = "C" 
                    then do: 
                        find deposito where deposito.etbcod = chqtit.etbcod and
                                            deposito.datmov = chq.datemi 
                                                    no-lock no-error.
                        if avail deposito and 
                           deposito.datcon <> ?
                        then.
                        else next.
                    end.

                    
                    if v-tipo = "N" 
                    then do:
                        find deposito where 
                             deposito.etbcod = chqtit.etbcod and
                             deposito.datmov = chq.datemi no-lock no-error.
                        if not avail deposito or
                           deposito.datcon = ?
                        then.
                        else next.
                    end.
 
               
                    find first tt-man where tt-man.rec = recid(chq) no-error.
                    if not avail tt-man
                    then do:
                        create tt-man.
                        assign tt-man.rec     = recid(chq)
                               tt-man.agencia = chq.agencia
                               tt-man.banco   = chq.banco
                               totchq         = totchq + chq.valor.
                    end.
                end.
                
                for each chq where chq.data >= vdti        and
                                   chq.data <= vdtf no-lock.
                          
                     
                    find first chqtit where chqtit.banco   = chq.banco    and
                                            chqtit.agencia = chq.agencia  and
                                            chqtit.conta   = chq.conta    and
                                            chqtit.numero  = chq.numero 
                                            no-lock no-error.
                    if not avail chqtit
                    then next.

                    if chq.datemi <> chq.data
                    then.
                    else next. 
 
                    if chqtit.etbcod <> tt-chq.etbcod
                    then next.
                    
                    
                    if v-tipo = "C" 
                    then do: 
                        find deposito where deposito.etbcod = chqtit.etbcod and
                                            deposito.datmov = chq.datemi 
                                                            no-lock no-error.
                        if avail deposito and
                           deposito.datcon <> ?
                        then.
                        else next.
                    end.

                    if v-tipo = "N" 
                    then do:
                        find deposito where 
                             deposito.etbcod = chqtit.etbcod and
                             deposito.datmov = chq.datemi no-lock no-error.
                        if not avail deposito or
                           deposito.datcon = ?
                        then.
                        else next.
                    end.
 
                    find first tt-man where tt-man.rec = recid(chq) no-error.
                    if not avail tt-man
                    then do:
                        create tt-man.
                        assign tt-man.rec     = recid(chq)
                               tt-man.agencia = chq.agencia
                               tt-man.banco   = chq.banco
                               totchq         = totchq + chq.valor.
                    end.
                end.
                

               
                run tt-man.p(input totchq).
                view frame f-tot.
                    
 
            end.
            
            if esqcom1[esqpos1] = "Marca"
            then do:
                if tt-chq.marca = ""
                then tt-chq.marca = "*".
                else tt-chq.marca = "".
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
        

        display tt-chq.etbcod 
                tt-chq.chqpre 
                tt-chq.chqdia
                    with frame frame-a.
 
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-chq).
   end.
end.
end.



procedure listagem.

    def var mtiporel as char extent 2 format "x(10)" init ["Geral", "Emissao"].
    def var vtiporel as int.

    disp mtiporel with frame f-tiporel no-label centered
            title " Tipo do relatorio ".
    choose field mtiporel with frame f-tiporel.
    vtiporel = frame-index.    


/*
def var vemitidos like sresp.
def var vvencidos like sresp.

                vemitidos = yes.
                vvencidos = yes.
                update
                    vemitidos label "Emtidos no periodo?"
                    vvencidos label "Vencidos no periodo?"
                    with frame f-lista side-label.

                hide frame f-lista no-pause.
*/

                for each tt-lista:
                    delete tt-lista.
                end.

                for each chq where chq.datemi >= vdti        and
                                   chq.datemi <= vdtf no-lock.
                          

                    find first chqtit where chqtit.banco   = chq.banco    and
                                            chqtit.agencia = chq.agencia  and
                                            chqtit.conta   = chq.conta    and
                                            chqtit.numero  = chq.numero 
                                                no-lock no-error.
                    if not avail chqtit
                    then next.

                    if vtiporel = 1
                    then do.
                    
                    if chq.datemi = chq.data
                    then.
                    else next.

                    end.

                    if v-tipo = "C" 
                    then do: 
                        find deposito where deposito.etbcod = chqtit.etbcod and
                                            deposito.datmov = chq.datemi 
                                                    no-lock no-error.
                        if avail deposito and 
                           deposito.datcon <> ?
                        then.
                        else next.
                    end.

                    
                    if v-tipo = "N" 
                    then do:
                        find deposito where 
                             deposito.etbcod = chqtit.etbcod and
                             deposito.datmov = chq.datemi no-lock no-error.
                        if not avail deposito or
                           deposito.datcon = ?
                        then.
                        else next.
                    end.
        
                    find first tt-lista where 
                               tt-lista.recche = recid(chq) no-error.
                    if not avail tt-lista
                    then do:
                        create tt-lista.
                        assign tt-lista.etbcod = chqtit.etbcod
                               tt-lista.recche = recid(chq). 
                    end.
                end.
    
                if vtiporel = 1
                then 
                for each chq where chq.data >= vdti        and
                                   chq.data <= vdtf no-lock.
                          
                    find first chqtit where chqtit.banco   = chq.banco    and
                                            chqtit.agencia = chq.agencia  and
                                            chqtit.conta   = chq.conta    and
                                            chqtit.numero  = chq.numero 
                                            no-lock no-error.
                    if not avail chqtit
                    then next.

                    if chq.datemi <> chq.data
                    then.
                    else next. 

                    if v-tipo = "C" 
                    then do: 
                        find deposito where deposito.etbcod = chqtit.etbcod and
                                            deposito.datmov = chq.datemi 
                                                            no-lock no-error.
                        if avail deposito and
                           deposito.datcon <> ?
                        then.
                        else next.
                    end.

                    if v-tipo = "N" 
                    then do:
                        find deposito where 
                             deposito.etbcod = chqtit.etbcod and
                             deposito.datmov = chq.datemi no-lock no-error.
                        if not avail deposito or
                           deposito.datcon = ?
                        then.
                        else next.
                    end.
 
                    find first tt-lista where 
                         tt-lista.recche = recid(chq) no-error.
                    if not avail tt-lista
                    then do:
                        create tt-lista.
                        assign tt-lista.etbcod = chqtit.etbcod
                               tt-lista.recche = recid(chq). 
                    end.
                end.
     
                if opsys = "UNIX"
                then varquivo = "/admcom/relat/conchq." + string(mtime).
                else varquivo = "l:~\relat~\conchq." + string(mtime).  

                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "147" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""conbiu"" 
                        &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                        &Tit-Rel   = """LISTAGEM DE CHEQUES DE: "" +
                                     string(vdti,""99/99/9999"") + 
                                     "" ATE "" +
                                     string(vdtf,""99/99/9999"")"
                        &Width     = "147"  
                        &Form      = "frame f-cabcab"}

                for each tt-lista break by tt-lista.etbcod:
                    find chq where recid(chq) = tt-lista.recche no-lock.
                    find first chqtit of chq no-lock no-error.
                    if avail chqtit
                    then find clien where clien.clicod = chqtit.clifor
                                          no-lock no-error.
                    
            
                    display chqtit.etbcod when avail chqtit
                                column-label "FL" format ">99"
                            clien.clicod when avail clien
                            clien.clinom when avail clien format "x(30)" 
                            chq.datemi column-label "Data!Emissao"
                            chq.data   column-label "Data!Venc."
                            chq.banco   
                            chq.agencia format ">>>>9"  
                            chq.conta   format "x(15)"   
                            chq.numero  format "x(15)" 
                            chq.valor(total by tt-lista.etbcod)
                                    with frame f3 down width 140.
                end.                                   
                output close.
                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo,"").
                end.
                else do:    
                    {mrod.i}
                end.



end procedure.
