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
         initial ["Inclusao","Alteracao","Listagem","Consulta","Conferencia"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].
def temp-table tt-saldo 
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field pra    like plani.platot
    field pre    like plani.platot
    field ent    like plani.platot.



def buffer bsalexporta  for  salexporta.
def var vetbcod         like salexporta.etbcod.


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
    
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "Geral" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.

    update vdti label "Periodo" 
           vdtf no-label with frame f1.
    
/*
  connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.
  run buscasalc.p(input vetbcod, input vdti, input vdtf).

  if connected ("d")
  then disconnect d.
*/
      
run p-titulos-na-matriz(input vetbcod, input vdti, input vdtf).


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first salexporta where ( if vetbcod = 0
                                      then true
                                      else salexporta.etbcod = vetbcod ) and
                                      salexporta.cxacod = 1 and
                                      salexporta.modcod = "CAR" and
                                      salexporta.saldt  >= vdti and
                                      salexporta.saldt  <= vdtf no-error.
    else
        find salexporta where recid(salexporta) = recatu1.
    vinicio = yes.
    if not available salexporta
    then do:
        message "Nenhum registro encontrado para este periodo".
        undo, retry.
    end.
    clear frame frame-a all no-pause.
    
    find first tt-saldo where tt-saldo.etbcod = salexporta.etbcod and
                              tt-saldo.data   = salexporta.saldt no-error.
    
    vok = "".
    if (salexporta.saldo <> tt-saldo.pra) or
       (salexporta.salimp <> tt-saldo.pre)
    then vok = "*".   


    difpra = salexporta.saldo  - tt-saldo.pra.
    difpre = salexporta.salimp - tt-saldo.pre.
    
    
    display vok no-label 
            salexporta.etbcod column-label "Fl" format ">9"
            salexporta.saldt  column-label "Data" format "99/99/9999"
            salexporta.saldo  column-label "Cartoes!Loja"
                                    format ">>>,>>9.99"
            tt-saldo.pra      column-label "Cartoes!Matriz"
                                    format ">>>,>>9.99" when avail tt-saldo
            difpra            column-label "Dif."
                                    format "->>>9.99"
/***
            salexporta.salimp column-label "Pagamento!Loja"
                                    format ">,>>9.99"
            tt-saldo.pre      column-label "Pagamento!Matriz"
                                format ">,>>9.99" when avail tt-saldo
            difpre            column-label "Diferenca"
                                format "->>,>>9.99"    
***/                                
                with frame frame-a 12 down centered /*width 80*/
                        title "RESUMO GERAL DOS CAIXAS - CARTOES DE CREDITO".

    recatu1 = recid(salexporta).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next salexporta where ( if vetbcod = 0
                                     then true
                                     else salexporta.etbcod = vetbcod ) and
                                          salexporta.cxacod = 1 and
                                          salexporta.modcod = "CAR" and
                                          salexporta.saldt  >= vdti and
                                          salexporta.saldt  <= vdtf no-error.

        if not available salexporta
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find first tt-saldo where tt-saldo.etbcod = salexporta.etbcod and
                                  tt-saldo.data   = salexporta.saldt no-error.
    
        
        vok = "".
        if (salexporta.saldo <> tt-saldo.pra) or
           (salexporta.salimp <> tt-saldo.pre)
        then vok = "*".   
    
        difpra = salexporta.saldo  - tt-saldo.pra.
        difpre = salexporta.salimp - tt-saldo.pre.
    
        
        display vok
                salexporta.etbcod 
                salexporta.saldt  
                salexporta.saldo  
                tt-saldo.pra when avail tt-saldo
                difpra
                /*salexporta.salimp 
                tt-saldo.pre 
                difpre when avail tt-saldo*/
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find salexporta where recid(salexporta) = recatu1.

        choose field salexporta.etbcod
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
                find next salexporta where ( if vetbcod = 0
                                      then true
                                      else salexporta.etbcod = vetbcod ) and
                                      salexporta.cxacod = 1 and
                                      salexporta.modcod = "CAR" and
                                      salexporta.saldt  >= vdti and
                                      salexporta.saldt  <= vdtf no-error.

                if not avail salexporta
                then leave.
                recatu1 = recid(salexporta).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev salexporta where ( if vetbcod = 0
                                      then true
                                      else salexporta.etbcod = vetbcod ) and
                                      salexporta.cxacod = 1 and
                                      salexporta.modcod = "CAR" and
                                      salexporta.saldt  >= vdti and
                                      salexporta.saldt  <= vdtf no-error.
                if not avail salexporta
                then leave.
                recatu1 = recid(salexporta).
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
            find next salexporta where ( if vetbcod = 0
                                      then true
                                      else salexporta.etbcod = vetbcod ) and
                                      salexporta.cxacod = 1 and
                                      salexporta.modcod = "CAR" and
                                      salexporta.saldt  >= vdti and
                                      salexporta.saldt  <= vdtf no-error.

            if not avail salexporta
            then next.
            color display normal
                salexporta.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev salexporta where ( if vetbcod = 0
                                      then true
                                      else salexporta.etbcod = vetbcod ) and
                                      salexporta.cxacod = 1 and
                                      salexporta.modcod = "CAR" and
                                      salexporta.saldt  >= vdti and
                                      salexporta.saldt  <= vdtf no-error.
            if not avail salexporta
            then next.
            color display normal
                salexporta.etbcod.
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

            if esqcom1[esqpos1] = "*Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create salexporta.
                update salexporta.salimp
                       salexporta.etbcod.
                recatu1 = recid(salexporta).
                leave.
            end.
            if esqcom1[esqpos1] = "*Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update salexporta with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "*Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp salexporta with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                    
                varquivo = "..\relat\transm-c." + string (vetbcod,">>9") 
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
 
                
                
                for each salexporta where
                                ( if vetbcod = 0
                                  then true
                                  else salexporta.etbcod = vetbcod ) and
                                       salexporta.cxacod = 1 and
                                       salexporta.modcod = "CAR" and
                                       salexporta.saldt  >= vdti and
                                       salexporta.saldt  <= vdtf no-lock.

                    find first tt-saldo 
                        where tt-saldo.etbcod = salexporta.etbcod and
                              tt-saldo.data   = salexporta.saldt no-error.
    
        
                    vok = "".
                    
                    if (salexporta.saldo <> tt-saldo.pra) or
                       (salexporta.salimp <> tt-saldo.pre)
                    then vok = "*".   
    
                    difpra = salexporta.saldo  - tt-saldo.pra.
                    difpre = salexporta.salimp - tt-saldo.pre.
                    
                    display vok no-label 
                            salexporta.etbcod column-label "Fl" format ">9"
                            salexporta.saldt  column-label "Data" 
                                    format "99/99/9999"
                            salexporta.saldo  column-label "Cartoes!Loja"
                                    format ">>>,>>9.99"
                            tt-saldo.pra      column-label "Cartoes!Matriz"
                                    format ">>>,>>9.99" when avail tt-saldo
                            difpra            column-label "Dif."
                                    format ">>>9.99"
                            /***
                            salexporta.salimp column-label "Prestacao!Loja"
                                    format ">>>,>>9.99"
                            tt-saldo.pre      column-label "Prestacao!Matriz"
                                    format ">>>,>>9.99" when avail tt-saldo
                            difpre            column-label "Diferenca"
                                    format ">>,>>9.99"    
                            ***/        
                                with frame f-lista centered width 100 down
                                    title "RESUMO GERAL DOS CAIXAS".

                
                end.
                {mrod.i}
                leave.
            end.
            
            if esqcom1[esqpos1] = "*Conferencia"
            then do:
             
                input from ..\progr\listaloja.
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
    
    
                find first tt-ip where tt-ip.etbcod = salexporta.etbcod 
                                no-error.
                
                message "Conectando...".
                connect fin -H value(tt-ip.ip) -S sdrebfin -N tcp -ld finloja 
                                            no-error.
    

                if not connected ("finloja")
                then do:
        
                    message "Banco nao conectado".
                    undo, retry.    

                end.

                run tt-pre.p(input salexporta.etbcod,
                             input salexporta.saldt).
               
                
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

        find first tt-saldo where tt-saldo.etbcod = salexporta.etbcod and
                                  tt-saldo.data   = salexporta.saldt no-error.
    
        
        vok = "".
        if (salexporta.saldo <> tt-saldo.pra) /*or
           (salexporta.salimp <> tt-saldo.pre)  */
        then vok = "*".   
    
        difpra = salexporta.saldo  - tt-saldo.pra.
        difpre = salexporta.salimp - tt-saldo.pre.

        display vok
                salexporta.etbcod 
                salexporta.saldt  
                salexporta.saldo  
                tt-saldo.pra     when avail tt-saldo
                difpra
                /*salexporta.salimp 
                tt-saldo.pre
                difpre when avail tt-saldo*/
                with frame frame-a.
                
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(salexporta).
   end.
end.


procedure p-titulos-na-matriz:

    def input parameter vetbcod as int.
    def input parameter vdti    as date format "99/99/9999".
    def input parameter vdtf    as date format "99/99/9999".
    def var   vsaldo            as dec.
    def var   vsalimp           as dec.
    def var   vdata             as date format "99/99/9999".

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock.
        
        do vdata = vdti to vdtf:

           for each titulo where titulo.empcod = 19
                             and titulo.titnat = no  
                             and titulo.modcod = "CAR" 
                             and titulo.titdtpag = vdata 
                             and titulo.etbcobra = estab.etbcod 
                             no-lock use-index etbcod:

               vsaldo = vsaldo + titulo.titvlcob.
               
            end.
            for each titulo where titulo.empcod = 19
                              and titulo.titnat = no 
                              and titulo.modcod = "CRE"
                              and titulo.titdtpag = vdata
                              and titulo.etbcobra = estab.etbcod
                              no-lock use-index etbcod:
            
                    find moeda where
                         moeda.moecod = titulo.moecod no-lock no-error. 
                    if avail moeda  
                    then do:   
                        if moeda.moetit = yes  
                        then vsalimp = vsalimp + titulo.titvlcob. 
                    end.
                    
                end.

            find first tt-saldo where tt-saldo.etbcod = estab.etbcod and
                                      tt-saldo.data   = vdata no-error.
            if not avail tt-saldo
            then do:
            
                create tt-saldo.
                assign tt-saldo.etbcod = estab.etbcod
                       tt-saldo.data   = vdata
                       tt-saldo.pra    = vsaldo
                       tt-saldo.pre    = vsalimp
                       tt-saldo.ent    = 0.
            
            end.
            

        end.

    end.

end procedure.
