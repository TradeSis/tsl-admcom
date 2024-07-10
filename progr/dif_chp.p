{admcab.i}
def var varquivo as char.
def var v-ban like chq.banco.
def var v-age like chq.agencia.
def var v-con like chq.conta.
def var v-num like chq.numero.

def var vdif  like plani.platot.
def var v-val like chq.valor.
def var varq as char.

def input parameter qtd_cheque as int.
def input parameter p-valor like plani.platot.
def input parameter data_arq like plani.pladat.

def var p-dia like plani.platot.
def var p-pre like plani.platot.
def shared temp-table tt-data
    field etbcod like estab.etbcod
    field datmov like deposito.datmov
    field chedre like deposito.chedre
    field chedia like deposito.chedia.
    

def var vbanco   like chq.banco.
def var vagencia like chq.agencia.
def var vconta   like chq.conta.
def var vnumero  like chq.numero.


def var v-tot like plani.platot.
def shared temp-table tt-dif
    field rec     as   recid
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field marca   as char format "x(01)"
    field vstatus as char format "x(10)"
    index ind-1 valor.
    


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
  initial ["Marca","Confirmacao","Exclusao","Consulta","Listagem","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-dif       for tt-dif.


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

    v-tot = 0.
    for each tt-dif:
        v-tot = v-tot + tt-dif.valor.
    end.
    
    p-pre = 0.
    p-dia = 0.
    for each tt-data:
        
        assign p-pre = p-pre + tt-data.chedre
               p-dia = p-dia + tt-data.chedia.
    
    end.


bl-princ:
repeat:

    
    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then
        find first tt-dif where
            true no-error.
    else
        find tt-dif where recid(tt-dif) = recatu1.
    vinicio = yes.
    if not available tt-dif
    then do:
        message "nenhum registro encontrato".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.

    pause 0.
    
    vdif = ((p-pre + p-dia) - p-valor). 
    
    display qtd_cheque label "Qtd"
            p-valor label "Encontrado"
            p-pre   label "Pre"
            p-dia   label "Dia"
            vdif    label "Dif" format "->>,>>9.99"
                with frame f-tot 
                    side-label row 20 width 80 centered overlay.
     
    find chq where chq.banco   = tt-dif.banco   and
                   chq.agencia = tt-dif.agencia and
                   chq.conta   = tt-dif.conta and 
                   chq.numero  = tt-dif.numero  no-lock.
    find chqtit of chq no-lock no-error.
    display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia 
            tt-dif.conta    format "x(10)"
            tt-dif.numero   
            chq.datemi
            tt-dif.etbcod 
            tt-dif.valor
            tt-dif.vstatus 
                with frame frame-a 12 down row 4 centered
                width 80.
     /*
     display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia 
            tt-dif.conta 
            tt-dif.numero 
            tt-dif.etbcod  
            tt-dif.valor 
            tt-dif.vstatus 
                with frame frame-a 12 down row 4 centered.
    */
    recatu1 = recid(tt-dif).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-dif where
                true.
        if not available tt-dif
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.

    
        vdif = ((p-pre + p-dia) - p-valor). 

        display 
                qtd_cheque
                p-valor
                p-pre  
                p-dia  
                vdif with frame f-tot. 
            
        find chq where chq.banco   = tt-dif.banco   and
                   chq.agencia = tt-dif.agencia and
                   chq.conta   = tt-dif.conta and 
                   chq.numero  = tt-dif.numero  no-lock.
    find chqtit of chq no-lock no-error.
    display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia 
            tt-dif.conta    format "x(10)"
            tt-dif.numero   
            chq.datemi
            tt-dif.etbcod 
            tt-dif.valor
            tt-dif.vstatus 
                with frame frame-a.

        /*
        display tt-dif.marca
                tt-dif.banco 
                tt-dif.agencia 
                tt-dif.conta 
                tt-dif.numero 
                tt-dif.etbcod 
                tt-dif.valor 
                tt-dif.vstatus with frame frame-a.
        */
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-dif where recid(tt-dif) = recatu1.

        choose field tt-dif.valor
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
                esqpos1 = if esqpos1 = 6
                          then 6
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
                find next tt-dif where true no-error.
                if not avail tt-dif
                then leave.
                recatu1 = recid(tt-dif).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-dif where true no-error.
                if not avail tt-dif
                then leave.
                recatu1 = recid(tt-dif).
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
            find next tt-dif where
                true no-error.
            if not avail tt-dif
            then next.
            color display normal
                tt-dif.valor.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-dif where
                true no-error.
            if not avail tt-dif
            then next.
            color display normal
                tt-dif.valor.
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
  
            if esqcom1[esqpos1] = "Marca"
            then do:
                if tt-dif.marca = ""
                then do:
                    tt-dif.marca = "*".
                    p-valor = p-valor + tt-dif.valor.
                    qtd_cheque = qtd_cheque + 1.
                    vdif = ((p-pre + p-dia) - p-valor). 
                end.    
                else do:
                    tt-dif.marca = "".
                    p-valor = p-valor - tt-dif.valor. 
                    qtd_cheque = qtd_cheque - 1.
                    vdif = ((p-pre + p-dia) - p-valor). 
 
                end.    
            end.
 
            
            if esqcom1[esqpos1] = "Confirmacao"
            then do with frame f-inclui overlay row 6 1 column centered.
            
                message "Confirma cheques marcados" update sresp.
                if not sresp
                then undo.
                
                
                if opsys = "unix"
                then
                varq = "/admcom/work/" + 
                       string(year(data_arq),"9999") +
                       string(month(data_arq),"99")  + 
                       string(day(data_arq),"99") + ".dig".
                else  
                varq = "..~\work~\" + 
                       string(year(data_arq),"9999") +
                       string(month(data_arq),"99")  + 
                       string(day(data_arq),"99") + ".dig".


 
                
                output to value(varq) append.
                for each tt-dif where tt-dif.marca = "*":
                    
                    put chr(34)
                        tt-dif.banco   format "999"
                        tt-dif.agencia format "9999"
                        tt-dif.conta   format "9999999999" 
                        tt-dif.numero  format "999999" chr(34) skip.
                
                end.        
                output close.        
                
                
                leave.
                
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-dif with frame f-altera no-validate.
            end.
            
            if esqcom1[esqpos1] = "Consulta"
            then do:
                
                find chq where recid(chq) = tt-dif.rec no-lock no-error.
                if avail chq
                then do:
                    find chqtit of chq no-lock no-error. 
                    if avail chqtit 
                    then find clien where clien.clicod = chqtit.clifor
                                              no-lock no-error.
                    
                    find deposito where 
                         deposito.etbcod = chqtit.etbcod and
                         deposito.datmov = chq.datemi no-lock no-error.
    
                 
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
                            chq.valor 
                            deposito.datcon when avail deposito
                                with frame f-con 1 column centered.
                    pause.
                    leave.
                end.
                else do:
                    message "Cheque nao encontrado".
                    pause.
                    leave.
                    
                end.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do:

                v-ban = 0.
                v-age = 0.
                v-con = "".
                v-num = "".
                update v-ban label "Banco"
                       v-age format ">>>9" label "Agencia"
                       v-con format "x(15)" label "Conta"
                       v-num format "x(6)"
                        label "Numero" with frame f-procura
                                                1 column centered.
                find chq where chq.banco = v-ban   and
                               chq.agencia = v-age and
                               chq.conta = v-con   and
                               chq.numero = v-num no-lock no-error.
                if not avail chq
                then do:
                    message "cheque nao encontrado".
                    pause.
                    undo, retry.
                end.
                               
                find chqtit of chq no-lock no-error.  
                if avail chqtit  
                then find clien where clien.clicod = chqtit.clifor
                                              no-lock no-error.
                find deposito where 
                     deposito.etbcod = chqtit.etbcod and
                     deposito.datmov = chq.datemi no-lock no-error.
    
            
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
                        chq.valor 
                        deposito.datcon when avail deposito
                            label "Data Confirmacao"
                        with frame f-pro 1 column centered.
                pause.
                leave.
            end.
 
            
            
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-dif.agencia update sresp.
                if not sresp
                then leave.
                find next tt-dif where true no-error.
                if not available tt-dif
                then do:
                    find tt-dif where recid(tt-dif) = recatu1.
                    find prev tt-dif where true no-error.
                end.
                recatu2 = if available tt-dif
                          then recid(tt-dif)
                          else ?.
                find tt-dif where recid(tt-dif) = recatu1.
                delete tt-dif.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                recatu2 = recatu1. 
                
                varquivo = "l:\relat\dif." + string(time).  
                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "147" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""dif_chp"" 
                        &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                        &Tit-Rel   = """LISTAGEM DE CHEQUES"""
                        &Width     = "147"  
                        &Form      = "frame f-cabcab"}
    
                
                for each tt-dif:
                    
                     find chq where chq.banco   = tt-dif.banco   and
                            chq.agencia = tt-dif.agencia and
                            chq.conta   = tt-dif.conta and 
                            chq.numero  = tt-dif.numero  no-lock.
                     find chqtit of chq no-lock no-error.
                     display tt-dif.marca  no-label
                        tt-dif.banco 
                        tt-dif.agencia 
                        tt-dif.conta    format "x(10)"
                        tt-dif.numero   
                        chq.datemi
                        tt-dif.etbcod 
                        tt-dif.valor
                        tt-dif.vstatus 
                   with frame f-lista down width 120.
                    
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

        vdif = ((p-pre + p-dia) - p-valor). 

        display 
                qtd_cheque label "Qtd"
                p-valor label "Encontrado"
                p-pre   label "Pre"
                p-dia   label "Dia"
                vdif label "Dif"
                    with frame f-tot 
                        side-label row 20 width 80 centered overlay.
        
        find chq where chq.banco   = tt-dif.banco   and
                   chq.agencia = tt-dif.agencia and
                   chq.conta   = tt-dif.conta and 
                   chq.numero  = tt-dif.numero  no-lock.
        find chqtit of chq no-lock no-error.
        display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia 
            tt-dif.conta    format "x(10)"
            tt-dif.numero   
            chq.datemi
            tt-dif.etbcod 
            tt-dif.valor
            tt-dif.vstatus 
                with frame frame-a.

        /*
        display tt-dif.marca
                tt-dif.banco
                tt-dif.agencia
                tt-dif.conta
                tt-dif.numero
                tt-dif.etbcod
                tt-dif.valor
                tt-dif.vstatus
                    with frame frame-a.
        */
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-dif).
   end.
end.
