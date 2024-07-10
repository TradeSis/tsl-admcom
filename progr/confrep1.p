/*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var varq as char.
def var varquivo as char.

def temp-table tt-ip
    field ip as char
    field etbcod like estab.etbcod.


def var difpre like plani.platot.
def var difpra like plani.platot.
def var vok as char format "x(01)".
def var vdti            like plani.pladat initial today.
def var vdtf            like plani.pladat initial today.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
         initial ["Conferencia","","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].
def new shared temp-table tt-saldo 
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field pra    like plani.platot
    field pre    like plani.platot
    field ent    like plani.platot.

def  new shared temp-table tt-salexporta
    field etbcod like estab.etbcod
    field saldat as date
    field praloj as dec
    field pramat as dec
    field pradif as dec
    field preloj as dec
    field premat as dec
    field predif as dec
    field entloj as dec
    field entmat as dec
    field entdif as dec
    index i1 etbcod
    .

def buffer bsalexporta       for salexporta.
def var vetbcod         like salexporta.etbcod.
def var vetbcod1        like salexporta.etbcod.
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
vdti     = today - 1.
vdtf     = today - 1.
    
for each tt-saldo:
        delete tt-saldo.
end.
    
def temp-table tt-estab
    field etbcod like estab.etbcod.
    
update vetbcod label "Filial" 
       vetbcod1 label "Ate" with frame f1 side-label width 80.
/*
if vetbcod = 0
then display "Geral" @ estab.etbnom no-label with frame f1.
else do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
end.
*/

update vdti label "Periodo" 
       vdtf no-label with frame f1.
for each tt-estab.
    delete tt-estab.
end.
def var vi as int.
do vi = vetbcod to vetbcod1:
    create tt-estab.
    tt-estab.etbcod = vi.
end. 
def var varquivo1 as char.
if opsys = "UNIX"
then varquivo1 = "../progr/listaloja".
else varquivo1 = "..\progr\listaloja".
input from value(varquivo1).
repeat:
    import varq. 
    find first tt-ip where 
               tt-ip.etbcod = int(substring(varq,16,2)) 
               no-error.
    if not avail tt-ip
    then do:
        create tt-ip.
        assign tt-ip.etbcod = int(substring(varq,16,2))
               tt-ip.ip     = substring(varq,1,14).
    end.
end.
input close.
 
connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.
def buffer bestab for estab.
for each tt-salexporta:
    delete tt-salexporta .
end.
for each tt-estab,    
    first bestab where bestab.etbcod = tt-estab.etbcod
                    no-lock:
    
    if connected ("finloja")
    then disconnect finloja.
    
    find first  tt-ip where 
                tt-ip.etbcod = bestab.etbcod  no-error.
                
    disp "Conectando......  Filial: "  bestab.etbcod format ">>9"
                "    Transmissao: "
                with frame fdisp down no-label no-box.
    pause 0.            
    connect fin -H value(tt-ip.ip) -S sdrebfin -N tcp -ld finloja 
                                            no-error.
    
    if not connected ("finloja")
    then do:
        disp "NAO CONECTADO" with frame fdisp.
        pause 0.
        next.
    end.                              
    run confrep2.p(input bestab.etbcod,
                   input vdti,
                   input vdtf).
        
       /**
                run tt-pre.p(input salexporta.etbcod,
                             input salexporta.saldt).
          ***/     
                
    if connected ("finloja")
    then  disconnect finloja.

    disp "OK" with frame fdisp.
    pause 0.
end.       
if connected ("d") 
then disconnect d.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first tt-salexporta no-error.
    else
        find tt-salexporta where recid(tt-salexporta) = recatu1.
    vinicio = yes.
    if not available tt-salexporta
    then do:
        message "NENHUMA DIVERGENCIA ENCONTRADA"           .
               undo, retry.
    end.
    clear frame frame-a all no-pause.
    vok = "".
    if pradif <> 0 or predif <> 0
    then vok = "*".
    display vok no-label 
            tt-salexporta.etbcod column-label "Fl" format ">9"
            tt-salexporta.saldat  column-label "Data" format "99/99/9999"
            tt-salexporta.praloj  column-label "Prazo!Loja"
                                    format ">>>,>>9.99"
            tt-salexporta.pramat  column-label "Prazo!Matriz"
                                    format ">>>,>>9.99" 
            tt-salexporta.pradif  column-label "Difer"
                                    format "->>9.99"
            tt-salexporta.preloj  column-label "Prestacao!Loja"
                                    format ">>>,>>9.99"
            tt-salexporta.premat  column-label "Prestacao!Matriz"
                                    format ">>>,>>9.99" 
            tt-salexporta.predif   column-label "Difer"
                                format ">>,>>9.99"    
                with frame frame-a 14 down row 5 centered width 80
                        title "RESUMO GERAL DOS CAIXAS".

    recatu1 = recid(tt-salexporta).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-salexporta no-error.

        if not available tt-salexporta
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
        vok = "".
        if pradif <> 0 or predif <> 0
        then vok = "*".
 
        display vok
                tt-salexporta.etbcod 
                tt-salexporta.saldat
                tt-salexporta.praloj  
                tt-salexporta.pramat 
                tt-salexporta.pradif 
                tt-salexporta.preloj  
                tt-salexporta.premat 
                tt-salexporta.predif 
                with frame frame-a. 
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-salexporta where recid(tt-salexporta) = recatu1.
        display vok
                tt-salexporta.etbcod 
                tt-salexporta.saldat
                tt-salexporta.praloj  
                tt-salexporta.pramat 
                tt-salexporta.pradif 
                tt-salexporta.preloj  
                tt-salexporta.premat 
                tt-salexporta.predif 
                with frame frame-a. 
         choose field tt-salexporta.etbcod
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
                find next tt-salexporta no-error.

                if not avail tt-salexporta
                then leave.
                recatu1 = recid(tt-salexporta).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-salexporta no-error.
                if not avail tt-salexporta
                then leave.
                recatu1 = recid(tt-salexporta).
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
            find next tt-salexporta no-error.

            if not avail tt-salexporta
            then next.
            color display normal
                tt-salexporta.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-salexporta no-error.
            if not avail tt-salexporta
            then next.
            color display normal
                tt-salexporta.etbcod.
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
            /**
            if esqcom1[esqpos1] = "*Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-salexporta.
                update tt-salexporta.salimp
                       tt-salexporta.etbcod.
                recatu1 = recid(tt-salexporta).
                leave.
            end.
            if esqcom1[esqpos1] = "*Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-salexporta with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "*Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-salexporta with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                    
                varquivo = "..\relat\transmissao." + string (vetbcod,"999") 
                                         + string(day(today)).
                             
                {mdad.i
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "130"
                    &Page-Line = "66"
                    &Nom-Rel   = """salexp"""
                    &Nom-Sis   = """SISTEMA DE CREDIARIO"""
                    &Tit-Rel   = """CONFERENCIA DE PAGAMENTOS"""
                    &Width     = "130"
                    &Form      = "frame f-cab"}.
 
                
                
                for each tt-salexporta no-lock:

                    find first tt-saldo 
                        where tt-saldo.etbcod = tt-salexporta.etbcod and
                              tt-saldo.data   = tt-salexporta.saldt no-error.
    
        
                    vok = "".
                    if avail tt-saldo
                    then do:
                    if (tt-salexporta.saldo <> tt-saldo.pra) or
                       (tt-salexporta.salimp <> tt-saldo.pre)
                    then vok = "*".   
    
                    difpra = tt-salexporta.saldo  - tt-saldo.pra.
                    difpre = tt-salexporta.salimp - tt-saldo.pre.
                    end.
                    display vok no-label 
                            tt-salexporta.etbcod column-label "Fl" format ">9"
                            tt-salexporta.saldt  column-label "Data" 
                                    format "99/99/9999"
                            tt-salexporta.saldo  column-label "Prazo!Loja"
                                    format ">>>,>>9.99"
                            tt-saldo.pra      column-label "Prazo!Matriz"
                                    format ">>>,>>9.99" when avail tt-saldo
                            difpra            column-label "Dif."
                                    format ">>>9.99"
                            tt-salexporta.salimp column-label "Prestacao!Loja"
                                    format ">>>,>>9.99"
                            tt-saldo.pre      column-label "Prestacao!Matriz"
                                    format ">>>,>>9.99" when avail tt-saldo
                            difpre            column-label "Diferenca"
                                    format ">>,>>9.99"    
                                with frame f-lista centered width 100 down
                                        title "RESUMO GERAL DOS CAIXAS".

                
                end.
                {mrod.i}
                leave.
            end.
            ***/
            if esqcom1[esqpos1] = "Conferencia"
            then do:
                if opsys = "UNIX"
                then input from ../progr/listaloja.
                else input from ..\progr\listaloja.
                repeat:
                    import varq. 
                    find first tt-ip where 
                               tt-ip.etbcod = int(substring(varq,16,2)) 
                                                                    no-error.
                    if not avail tt-ip
                    then do:
                        create tt-ip.
                        assign tt-ip.etbcod = int(substring(varq,16,2))
                               tt-ip.ip     = substring(varq,1,14).
    
                    end.
                end.
                input close.
 
                if connected ("finloja")
                then disconnect finloja.
    
    
                find first tt-ip where tt-ip.etbcod = tt-salexporta.etbcod 
                                no-error.
                
                message "Conectando...".
                connect fin -H value(tt-ip.ip) -S sdrebfin -N tcp -ld finloja 
                                            no-error.
    

                if not connected ("finloja")
                then do:
        
                    message "Banco nao conectado".
                    undo, retry.    

                end.

                run tt-pre.p(input tt-salexporta.etbcod,
                             input tt-salexporta.saldat).
               
                
                if connected ("finloja")
                then do:
                    disconnect finloja.
                end.
    
                
                
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

        vok = "".
        if pradif <> 0 or predif <> 0
        then vok = "*".
 
        display vok
                tt-salexporta.etbcod 
                tt-salexporta.saldat
                tt-salexporta.praloj  
                tt-salexporta.pramat 
                tt-salexporta.pradif 
                tt-salexporta.preloj  
                tt-salexporta.premat 
                tt-salexporta.predif 
                with frame frame-a.
                
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-salexporta).
   end.
end.

