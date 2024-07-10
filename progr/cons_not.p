/*
*
*    tt-plani.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-plani
                          placod
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var vetbcod         like plani.etbcod.
def var vnumero         like plani.numero.
def var vdti            as date.
def var vdtf            as date.
/*** 
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," DETALHES NF "," PRODUTOS ", " EXCLUIR NF " ,"  "].
***/

def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," DETALHES NF "," PRODUTOS ", " " ," "].

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-plani ",
             " Alteracao da tt-plani ",
             " Exclusao  da tt-plani ",
             " Consulta  da tt-plani ",
             " Listagem  Geral de tt-plani "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

form vetbcod label "Fil"
     vnumero label "Nota" format ">>>>>>>>9"
     vdti    label "Período de"  format "99/99/9999"
     vdtf    label "até"         format "99/99/9999"
         with frame f-carrega-tt row 3 overlay side-labels no-box.

{admcab.i}

def temp-table tt-plani like plani
    field natur-oper       as char
    field recuperada       as log format "S/N" label "Rec"
    field reg-fiscal       as log format "S/N" label "Fis"
    field inutilizada      as log format "S/N" label "I".

def buffer btt-plani       for tt-plani.

form
    tt-plani with frame f-tt-plani side-labels 5 col.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

form
    tt-plani.EtbCod
    tt-plani.PlaCod  format ">>>>>>>>>9"
    tt-plani.Numero
    tt-plani.PlaDat
    tt-plani.movtdc  format ">>>9"
    tt-plani.Serie   column-label "Ser"
    tt-plani.ICMS
    tt-plani.BSubst
    tt-plani.ICMSSubst
    tt-plani.DescProd
    tt-plani.PLaTot
    tt-plani.OpCCod format ">>>>9"
    tt-plani.ProTot
    tt-plani.vencod
    tt-plani.VlServ
    tt-plani.DescServ
    tt-plani.AcFServ
    tt-plani.Frete
    tt-plani.DesAcess
    tt-plani.AcFProd
    tt-plani.ModCod
    tt-plani.AlICMS
    tt-plani.Outras
    tt-plani.BICMS
    tt-plani.Emite
    tt-plani.datexp
    tt-plani.UFDes format "x(50)"
    tt-plani.Desti
    tt-plani.DtInclu
        with frame f-consulta-tt-plani-01 with 2 col overlay.

form
    tt-plani.plades
    tt-plani.crecod
    tt-plani.PedCod
    tt-plani.BIPI
    tt-plani.AlIPI
    tt-plani.IPI
    tt-plani.Seguro
    tt-plani.AlISS
    tt-plani.UFEmi
    tt-plani.BISS
    tt-plani.CusMed
    tt-plani.UserCod
    tt-plani.HorIncl
    tt-plani.NotSit
    tt-plani.NotFat
    tt-plani.HiCCod
    tt-plani.NotObs
    tt-plani.RespFre
    tt-plani.NotTran
    tt-plani.Isenta
    tt-plani.ISS
    tt-plani.NotPis
    tt-plani.NotAss
    tt-plani.NotCoFinS
    tt-plani.TMovDev
    tt-plani.IndEmi
    tt-plani.NotPed
    tt-plani.cxacod
        with frame f-consulta-tt-plani-02 with 2 col overlay.

form movim.procod
     produ.pronom format "x(25)"
     movim.movtdc  format ">>>>9"
     movim.movdat  format "99/99/9999"
     movim.movqtm
     movim.movpc
        with frame f-mostra-itens-01 row 5 overlay.

repeat.
            
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    
empty temp-table tt-plani.

run p-carrega-tt.
if keyfunction(lastkey) = "end-error"
then leave.

bl-princ:
repeat:

    display vetbcod
            vnumero
            vdti 
            vdtf
               with frame f-carrega-tt.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-plani where recid(tt-plani) = recatu1 no-lock.
    if not available tt-plani
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-plani
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
            find tt-plani where recid(tt-plani) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-plani.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-plani.numero)
                                        else "".
            run color-message.
            choose field tt-plani.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plani
                then next.
                color display white/red tt-plani.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plani
                then next.
                color display white/red tt-plani.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-plani
                 with frame f-tt-plani color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqvazio
                then do:
                
                    display "(Nenhuma Nota encontrada!)"
                                with frame f-nenhum-registro centered row 9.
                    leave bl-princ.
                    /*
                    undo, next bl-princ.
                    */
                end.

                if esqcom1[esqpos1] = " Consulta "
                then do.
                    hide frame frame-a no-pause.
                    find first plani where plani.etbcod = tt-plani.etbcod
                                 and plani.placod = tt-plani.placod
                                 and plani.movtdc = tt-plani.movtdc
                               no-lock no-error.
                    if avail plani
                    then run not_consnota.p (recid(plani)).
                    view frame frame-a.
                    next.
                end.

                if esqcom1[esqpos1] = " Inclusao "
                then do with frame f-tt-plani on error undo.
                    create tt-plani.
                    update tt-plani.
                    recatu1 = recid(tt-plani).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-plani.
                    disp tt-plani.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-plani on error undo.
                    find tt-plani where
                            recid(tt-plani) = recatu1 
                        exclusive.
                    update tt-plani.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-plani.numero
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-plani where true no-error.
                    if not available tt-plani
                    then do:
                        find tt-plani where recid(tt-plani) = recatu1.
                        find prev tt-plani where true no-error.
                    end.
                    recatu2 = if available tt-plani
                              then recid(tt-plani)
                              else ?.
                    find tt-plani where recid(tt-plani) = recatu1
                            exclusive.
                    do on error undo:        
                    delete tt-plani.
                    end.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run ltt-plani.p (input 0).
                    else run ltt-plani.p (input tt-plani.etbcod).
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Detalhes NF "
                then do:
                
                    display tt-plani.EtbCod
                            tt-plani.PlaCod
                            tt-plani.Numero
                            tt-plani.PlaDat
                            tt-plani.movtdc
                            tt-plani.Serie
                            tt-plani.ICMS
                            tt-plani.BSubst
                            tt-plani.ICMSSubst
                            tt-plani.DescProd
                            tt-plani.PLaTot
                            tt-plani.OpCCod
                            tt-plani.ProTot
                            tt-plani.vencod
                            tt-plani.VlServ
                            tt-plani.DescServ
                            tt-plani.AcFServ
                            tt-plani.Frete
                            tt-plani.DesAcess
                            tt-plani.AcFProd
                            tt-plani.ModCod
                            tt-plani.AlICMS
                            tt-plani.Outras
                            tt-plani.BICMS
                            tt-plani.Emite
                            tt-plani.datexp
                            tt-plani.UFDes
                            tt-plani.Desti
                            tt-plani.DtInclu
                                 with frame f-consulta-tt-plani-01.
                

                    display
                            tt-plani.plades
                            tt-plani.crecod
                            tt-plani.PedCod
                            tt-plani.BIPI
                            tt-plani.AlIPI
                            tt-plani.IPI
                            tt-plani.Seguro
                            tt-plani.AlISS
                            tt-plani.UFEmi
                            tt-plani.BISS
                            tt-plani.CusMed
                            tt-plani.UserCod
                            tt-plani.HorIncl
                            tt-plani.NotSit
                            tt-plani.NotFat
                            tt-plani.HiCCod
                            tt-plani.NotObs
                            tt-plani.RespFre
                            tt-plani.NotTran
                            tt-plani.Isenta
                            tt-plani.ISS
                            tt-plani.NotPis
                            tt-plani.NotAss
                            tt-plani.NotCoFinS
                            tt-plani.TMovDev
                            tt-plani.IndEmi
                            tt-plani.NotPed
                            tt-plani.cxacod
                        with frame f-consulta-tt-plani-02 with 2 col overlay.
                end.
                
                if esqcom1[esqpos1] = " PRODUTOS "
                then do:
                
                    clear frame f-mostra-itens-01.
                
                    hide frame f-mostra-itens-01.

                    for each movim where movim.etbcod = tt-plani.etbcod
                                     and movim.placod = tt-plani.placod
                                     and movim.movdat = tt-plani.pladat
                                  /* and movim.movtdc = tt-plani.movtdc */
                                                no-lock,
                                                
                        first produ where produ.procod = movim.procod
                                        no-lock: 
                                        
                        display movim.procod 
                                produ.pronom format "x(25)"
                                movim.movtdc format ">>>9"
                                movim.movdat format "99/99/9999"
                                movim.movqtm 
                                movim.movpc.
                                                 
                    end.
                    
                end.
                if esqcom1[esqpos1] = " EXCLUIR NF "
                then do:
                
                    sresp = no.
                    
                    message "Deseja realmente excluir a NF " tt-plani.numero
                            " do ADMCOM? " update sresp.
                            
                    if sresp
                    then do:
                            
                        for each plani where plani.etbcod = tt-plani.etbcod
                                         and plani.placod = tt-plani.placod
                                         and plani.serie = tt-plani.serie
                                         and plani.pladat = tt-plani.pladat
                                         and plani.movtdc = tt-plani.movtdc
                                                exclusive-lock.

                    
                           for each movim where movim.etbcod = tt-plani.etbcod
                                            and movim.placod = tt-plani.placod
                                            and movim.movdat = tt-plani.pladat
                                            and movim.movtdc = tt-plani.movtdc
                                                    exclusive-lock.
                               
                               if string(movim.placod) begins "550"
                               then do:
                                  assign movim.placod =                                   int(replace(string(movim.placod),"550","557"))
                                         movim.movtdc = 9997.
                               end.
                               else if string(movim.placod) begins "559"       
                               then do:
                                  assign movim.placod =
                                  int(replace(string(movim.placod),"559","557"))
                                         movim.movtdc = 9997.
                                                               
                               end.                                
                               
                           end.

                           if string(plani.placod) begins "550"
                           then do:
                               assign plani.placod =                                                              int(replace(string(plani.placod),"550","557"))
                                      plani.movtdc = 9997.
                           end.
                           else if string(plani.placod) begins "559"       
                           then do:
                               assign plani.placod =
                                  int(replace(string(plani.placod),"559","557"))
                                      plani.movtdc = 9997.
                           end.                                

                           find first planiaux
                                where planiaux.etbcod = plani.etbcod
                                  and planiaux.emite  = plani.emite
                                  and planiaux.serie = plani.serie
                                  and planiaux.numero = plani.numero
                                  and planiaux.nome_campo = "TIPMOV-ANTIGO"
                                        no-lock no-error.
                           if not avail planiaux
                           then do:

                                create planiaux.
                                assign planiaux.etbcod = plani.etbcod
                                       planiaux.emite  = plani.emite
                                       planiaux.serie = plani.serie
                                       planiaux.numero = plani.numero
                                       planiaux.nome_campo = "TIPMOV-ANTIGO"
                                       planiaux.valor_campo
                                                = string(plani.movtdc).
                   
                           end.
                           find first planiaux
                                where planiaux.etbcod = plani.etbcod
                                  and planiaux.emite  = plani.emite
                                  and planiaux.serie = plani.serie
                                  and planiaux.numero = plani.numero
                                  and planiaux.nome_campo = "EXCLUIR-NF"
                                        no-lock no-error.
                           if not avail planiaux
                           then do:

                                create planiaux.
                                assign planiaux.etbcod = plani.etbcod
                                       planiaux.emite  = plani.emite
                                       planiaux.serie = plani.serie
                                       planiaux.numero = plani.numero
                                       planiaux.nome_campo = "EXCLUIR-NF"
                                       planiaux.valor_campo
                                                = string(sfuncod).
                   
                           end.

                            delete plani.
                        end.
                        
                        delete tt-plani.

                    end.        
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
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
        recatu1 = recid(tt-plani).
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

end.
procedure frame-a.
display tt-plani.etbcod
        tt-plani.placod format ">>>>>>>>9"
        tt-plani.numero
        tt-plani.opccod format ">>>9"
        tt-plani.movtdc format ">>>9"
        tt-plani.natur-oper format "x(15)"
        tt-plani.pladat
        tt-plani.serie
        tt-plani.recuperada
        tt-plani.reg-fiscal
        tt-plani.inutilizada
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-plani.etbcod
        tt-plani.placod  format ">>>>>>>>9"
/*        tt-plani.numero
        tt-plani.opccod format ">>>9"
        tt-plani.movtdc format ">>>9"
        tt-plani.natur-oper format "x(20)"
        tt-plani.pladat
        tt-plani.serie */
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-plani.etbcod
        tt-plani.placod  format ">>>>>>>>9"
        tt-plani.numero
        tt-plani.opccod format ">>>9"
        tt-plani.movtdc format ">>>9"
        tt-plani.natur-oper format "x(15)"
        tt-plani.pladat
        tt-plani.serie
        tt-plani.recuperada
        tt-plani.reg-fiscal
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-plani where true
                                                no-lock no-error.
    else  
        find last tt-plani  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-plani  where true
                                                no-lock no-error.
    else  
        find prev tt-plani   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-plani where true  
                                        no-lock no-error.
    else   
        find next tt-plani where true 
                                        no-lock no-error.
        
end procedure.

         
procedure p-carrega-tt.
   
   def var vdata   as date.
   
   assign vdti = today - 60
          vdtf = today.
   
/*   bl_carrega_tt:*/
   do on error undo with frame f-carrega-tt.

       update vetbcod
              vnumero
              vdti
              vdtf.
       
       message "Buscando Notas... Aguarde...".
       pause 0 no-message.
       
       do vdata = vdti to vdtf:
           /* NF */
           for each tipmov no-lock,
               each plani where plani.etbcod = vetbcod
                            and plani.numero = vnumero
                            and plani.pladat = vdata 
                            and plani.movtdc = tipmov.movtdc no-lock.
                            
               find first planiaux where planiaux.etbcod = plani.etbcod
                                     and planiaux.emite  = plani.emite
                                     and planiaux.serie = plani.serie
                                     and planiaux.numero = plani.numero
                                     and planiaux.nome_campo = "RECUPERADA"
                                               no-lock no-error.

               create tt-plani.
               buffer-copy plani to tt-plani.
               
               assign tt-plani.natur-oper = tipmov.movtnom. 
               
               if avail planiaux
               then assign tt-plani.recuperada = yes.

               find fiscal where fiscal.emite  = tt-plani.emite and
                                 fiscal.desti  = tt-plani.desti and
                                 fiscal.movtdc = tt-plani.movtdc and
                                 fiscal.numero = tt-plani.numero and
                                 fiscal.serie  = tt-plani.serie 
                           no-lock no-error.
               if avail fiscal
               then assign tt-plani.reg-fiscal = yes.
           end.
       end.

       if not can-find (first tt-plani)
       then do:
           /* Inutilizada */
           do vdata = vdti to vdtf:
            for each tipmov no-lock,
               each placon where placon.etbcod = vetbcod
                            and placon.numero = vnumero
                            and placon.pladat = vdata 
                            and placon.movtdc = tipmov.movtdc no-lock.
               create tt-plani.
               buffer-copy placon to tt-plani.
               assign
                    tt-plani.natur-oper  = tipmov.movtnom
                    tt-plani.inutilizada = yes. 
            end.
           end.
           if not can-find (first tt-plani)
           then do.
               message "Nenhuma Nota Encontrada!" view-as alert-box.
               undo.
           end.
       end.
       else do:

            if vetbcod = 995
            then do:
                vetbcod = 991.
                /*next bl_carrega_tt.*/
            end.    

            if vetbcod = 991
            then do:
                vetbcod = 995.
                next. /*leave bl_carrega_tt.*/
            end.    
       
            next. /*leave bl_carrega_tt.*/
       end.       
   end.           
         
end procedure.

