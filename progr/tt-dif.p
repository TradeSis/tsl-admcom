/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
{setbrw.i}
def var p-banco   like chq.banco.
def var p-agencia like chq.agen.
def var p-conta   like chq.conta.
def var p-numero  like chq.numero.      


def var vdif  like plani.platot.
def var v-val like chq.valor.
def var v-sobre-poe as logical init no format "Sim/Nao".
def var varq as char.
def input parameter p-valor like plani.platot.
def input parameter data_arq like plani.pladat.

def var p-dia like plani.platot.
def var p-pre like plani.platot.
def shared temp-table tt-data
    field etbcod like estab.etbcod
    field datmov like deposito.datmov
    field chedre like deposito.chedre
    field chedia like deposito.chedia.
    
def var varquivo as char.

def var vbanco   like chq.banco.
def var vagencia like chq.agencia.
def var vconta   like chq.conta.
def var vnumero  like chq.numero.


def var v-tot like plani.platot.
def shared temp-table tt-dif
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   as dec format ">>>,>>9.99"
    field cmc7 as char format "x(40)"
    field marca   as char format "x(01)"
    field vstatus as char format "x(10)"
    field rec     as recid.
    
def new shared temp-table tt-lispossi
    field rec     as   recid
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field recchq  as recid 
    field data    as date
    field marca   as char format "x(01)"
    field vstatus  as char format "x(10)"
        index ind-1 valor.


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Marca","Confirmacao","Alteracao","Consulta","Listagem"].
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
    
    display p-valor label "Encontrado"
            p-pre   label "Pre"
            p-dia   label "Dia"
            vdif    label "Dif" format "->>,>>9.99"
                with frame f-tot 
                    side-label row 18 width 80 centered overlay.
     
    find chq where chq.banco   = tt-dif.banco   and
                   chq.agencia = tt-dif.agencia and
                   chq.conta   = tt-dif.conta and 
                   chq.numero  = tt-dif.numero  no-lock.
    find first chqtit of chq no-lock no-error.
    display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia  format ">>>>9"
            tt-dif.conta    format "x(10)"
            tt-dif.numero   
            chq.datemi      format "99/99/99"
            tt-dif.etbcod 
            tt-dif.valor
            tt-dif.vstatus 
            chq.depcod  format ">>>>>>9"
                with frame frame-a 10 down row 4 centered
                width 80.

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

        display p-valor
                p-pre  
                p-dia  
                vdif with frame f-tot. 
            
        find chq where chq.banco   = tt-dif.banco   and
                   chq.agencia = tt-dif.agencia and
                   chq.conta   = tt-dif.conta and 
                   chq.numero  = tt-dif.numero  no-lock.
    find first chqtit of chq no-lock no-error.
    display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia 
            tt-dif.conta    format "x(10)"
            tt-dif.numero   
            chq.datemi
            tt-dif.etbcod 
            tt-dif.valor
            tt-dif.vstatus 
            chq.depcod
                with frame frame-a .

        /**
        display tt-dif.marca
                tt-dif.banco 
                tt-dif.agencia 
                tt-dif.conta 
                tt-dif.numero 
                tt-dif.etbcod 
                tt-dif.valor 
                tt-dif.vstatus with frame frame-a.
        **/
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-dif where recid(tt-dif) = recatu1.

        choose field tt-dif.banco
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
                tt-dif.banco.
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
                tt-dif.banco.
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
                    vdif = ((p-pre + p-dia) - p-valor). 
                end.    
                else do:
                    tt-dif.marca = "".
                    p-valor = p-valor - tt-dif.valor.
                    vdif = ((p-pre + p-dia) - p-valor). 
 
                end.    
            end.
 
            
            if esqcom1[esqpos1] = "Confirmacao"
            then do with frame f-inclui overlay row 6 1 column centered.
            
                message "Confirma cheques marcados" update sresp.
                if not sresp
                then undo.
                
                
                
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

                    find chq where
                     chq.banco   = tt-dif.banco and
                     chq.agencia = tt-dif.agencia  and
                     chq.conta   = tt-dif.conta and
                     chq.numero  = tt-dif.numero no-error.
 
                     find first chqtit of chq no-error. 
                     update tt-dif.banco
                           tt-dif.agencia
                           tt-dif.conta format "x(12)"
                           tt-dif.numero
                           chq.depcod
                           with frame f-altera no-validate.
                    if tt-dif.banco <> chq.banco or
                       tt-dif.agencia <> chq.agencia or
                       tt-dif.conta <> chq.conta or
                       tt-dif.numero <> chq.numero
                    then do:
                        assign
                            chq.banco = tt-dif.banco
                            chq.agencia = tt-dif.agencia
                            chq.conta = tt-dif.conta
                            chq.numero = tt-dif.numero
                            chqtit.banco = chq.banco
                            chqtit.agencia = chq.agencia
                            chqtit.conta = chq.conta
                            chqtit.numero = chq.numero
                            .
                        tt-dif.marca = "*".
                        display tt-dif.marca  no-label
                                tt-dif.banco 
                                tt-dif.agencia 
                                tt-dif.conta    format "x(10)"
                                tt-dif.numero   
                                chq.datemi
                                tt-dif.etbcod 
                                tt-dif.valor
                                tt-dif.vstatus 
                                chq.depcod
                                with frame frame-a
                                 .
                    end.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                
                for each tt-dif where tt-dif.etbcod = 0,
                    each chq where chq.banco   = tt-dif.banco   and
                                   chq.agencia = tt-dif.agencia and
                                   chq.numero  = tt-dif.numero  no-lock.
                                   
                        disp tt-dif.conta column-label "Conta!Maquina"
                                          format "x(15)"
                             chq.conta    column-label "Conta!Sistema"
                                          format "x(15)"
                             tt-dif.numero column-label "Numero!Maquina"
                             chq.numero    column-label "Numero!Sistema"
                                    with frame f-con down centered.
                
                    
                end.
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
            then do with frame f-Lista overlay row 6 1 column centered.
                recatu2 = recatu1. 
                
                varquivo = "l:\relat\dif1." + string(time).  
                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "120" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""dif_chp"" 
                        &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                        &Tit-Rel   = """LISTAGEM DE CHEQUES"""
                        &Width     = "120"  
                        &Form      = "frame f-cabcab"}
    
                
                for each tt-dif:
                    
                     find chq where chq.banco   = tt-dif.banco   and
                            chq.agencia = tt-dif.agencia and
                            chq.conta   = tt-dif.conta and 
                            chq.numero  = tt-dif.numero  no-lock.
                     find first chqtit of chq no-lock no-error.
                     display tt-dif.marca  no-label
                        tt-dif.banco 
                        tt-dif.agencia 
                        tt-dif.conta    format "x(10)"
                        tt-dif.numero   
                        chq.datemi
                        tt-dif.etbcod 
                        tt-dif.valor (total)
                        tt-dif.vstatus
                        chq.depcod 
                   with frame f-lista1 down width 120.
                   down with frame f-lista1.
                    
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

        display p-valor label "Encontrado"
                p-pre   label "Pre"
                p-dia   label "Dia"
                vdif label "Dif"
                    with frame f-tot 
                        side-label row 18 width 80 centered overlay.
        
        find chq where chq.banco   = tt-dif.banco   and
                   chq.agencia = tt-dif.agencia and
                   chq.conta   = tt-dif.conta and 
                   chq.numero  = tt-dif.numero  no-lock.
    find first chqtit of chq no-lock no-error.
    display tt-dif.marca  no-label
            tt-dif.banco 
            tt-dif.agencia 
            tt-dif.conta    format "x(10)"
            tt-dif.numero   
            chq.datemi
            tt-dif.etbcod 
            tt-dif.valor
            tt-dif.vstatus 
            chq.depcod
                with frame frame-a.

        /**
        display tt-dif.marca
                tt-dif.banco
                tt-dif.agencia
                tt-dif.conta
                tt-dif.numero
                tt-dif.etbcod
                tt-dif.valor
                tt-dif.vstatus
                    with frame frame-a.
        **/
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-dif).
   end.
end.


/* Antonio - seleciona possivel */
procedure pi-chqdifer:

def input parameter p-banco   like chq.banco.
def input parameter p-agencia like chq.agen.
def input parameter p-conta   like chq.conta.
def input parameter p-numero  like chq.numero.      
def input parameter p-valor   like chq.valor.

def buffer bchq for chq.
def var v-auxdata as date.

for each tt-lispossi:
    delete tt-lispossi.
end.    

do v-auxdata = (today - 7) to today :
   for each bchq use-index chqdatemi 
                 where bchq.datemi = v-auxdata no-lock:
                
                /* Procura por Data, Banco e Valor */
                if bchq.valor <> p-valor then next.
                if bchq.banco <> p-banco then next.

                find first chqtit of bchq no-lock no-error.
                
                create tt-lispossi.
                assign
                    tt-lispossi.rec     = recid(bchq)
                    tt-lispossi.banco   = bchq.banco
                    tt-lispossi.agencia = bchq.agencia
                    tt-lispossi.conta   = bchq.conta
                    tt-lispossi.numero  = bchq.numero
                    tt-lispossi.data    = bchq.data
                    tt-lispossi.etbcod  = if avail chqtit
                            then chqtit.etbcod else 0
                    tt-lispossi.valor   = bchq.valor
                    tt-lispossi.recchq  = recid(bchq).
    end.
end.
find first tt-lispossi no-error.
if not avail tt-lispossi
then do:
    message "Nenhum cheque encontrado com Valor e Banco iguais ao q/foi lido CMC7 !!" view-as alert-box.
    leave.
end.
return.

form tt-lispossi.banco     column-label "BANCO"
     tt-lispossi.agencia   column-label "AGENCIA"
     tt-lispossi.conta     column-label "CONTA"    format "x(12)" 
     tt-lispossi.numero    column-label "NUMERO"
     tt-lispossi.data      column-label "DATA"
     tt-lispossi.valor     column-label "VALOR"    format ">>>,>>9.99"
     with frame f-lista  width 78 down CENTERED title "CHEQUES POSSIVEIS DE ALTERACAO".
         
ll: repeat:
        assign a-seeid = -1 a-recid = -1 a-seerec = ?.
        {sklcls.i
            &help = "                     ENTER=Seleciona "
            &file = tt-lispossi
            &cfield = tt-lispossi.valor
            &noncharacter = /*
            &ofield = " tt-lispossi.banco
                        tt-lispossi.agencia format "">>>>9""
                        tt-lispossi.conta
                        tt-lispossi.numero
                        tt-lispossi.data
                  "
            &where = true
            &naoexiste1 = " leave ll. "
            &aftselect1 = "
                    if keyfunction(lastkey) = ""RETURN""
                    then do:
                        i-seeid = a-recid.
                        i-recid = recid(tt-lispossi).
                        p-conta = tt-lispossi.conta.

                        find bchq where recid(bchq) = tt-lispossi.recchq
                                    no-error.
                        find first chqtit of chq  no-error.
                        message ""Lido p/cmc7 -> Banco:"" p-banco 
                                     "" Agen.:"" p-agencia 
                                     "" Conta:"" p-conta ""No.:"" p-numero                              skip "" Regravar ?? -> "" update v-sobre-poe.     
                        if v-sobre-poe = yes
                        then do :
                            assign bchq.agencia = p-agencia
                                   bchq.conta   = p-conta
                                   bchq.numero  = p-numero.           
                            if avail chqtit
                            then assign
                                   chqtit.conta   = bchq.conta
                                   chqtit.agencia = bchq.agencia
                                   chqtit.numero  = bchq.numero
                                    .
                            next keys-loop.
                        end.
                        /*next ll.*/
                        a-recid = i-recid.
                        a-seeid = i-seeid.
                        next keys-loop.

                    end. "

            &otherkeys1 = " "  
            &form  = " frame f-lista down "
        }
        if keyfunction(lastkey) = "end-error"
        then do:
            leave ll.
        end.
    end.
    hide frame f-lista.
end procedure.



