/*
*
*    banfin.titulo.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Marca "," Relatorio "," Recibo "," Filtros "," "].
def var esqcom2         as char format "x(16)" extent 5
            initial [" Marca Todos "," "," "," "," "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Marca/Desmarca ",
             " Relatorio ",
             " Recibo ",
             " Filtros ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" Marca/Desmarca Todos ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def shared var vsetcod like setaut.setcod.
def shared var vempcod         like banfin.titulo.empcod.


def shared var vetbcod         like banfin.titulo.etbcod.
def shared var vmodcod         like banfin.titulo.modcod initial "PEA".
def shared var vtitnat         like banfin.titulo.titnat.

if sfuncod = 224 or sfuncod = 89
then vsetcod = 0.

def var ffuncionario like func.usercod.
def var fsetor       like setaut.setcod.
def var fdata        like banfin.titulo.titdtven init ?.
def var ffornecedor  like banfin.titulo.clifor init 0.
def var fcampanha    as char.
def var fsituacao    as char init "LIB".

def var vfuncionario like func.usercod.
def var vcampanha    as char.

def var vmeta     as char format "x(35)".

def var vrealizada as char format "x(35)".

def var varquivo as char.

def buffer btitulo       for banfin.titulo.
def var vtitulo         like banfin.titulo.titnum.

def temp-table tt-totsetor
    field setor as int
    field totalqtd as int
    field totalval as dec.

def temp-table tt-marca 
    field rec as recid.
def var vmarca as log.    

def var v-agendado as char.
def var vmatricula like func.usercod.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.

form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    
for each tt-marca.
    delete tt-marca.
end.    
def buffer sel-titulo for banfin.titulo.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find banfin.titulo where recid(banfin.titulo) = recatu1 no-lock.
    if not available banfin.titulo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(banfin.titulo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available banfin.titulo
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
            find banfin.titulo where recid(banfin.titulo) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(banfin.titulo.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(banfin.titulo.titnum)
                                        else "".
            run color-message.
            find tt-marca where tt-marca.rec = recid(banfin.titulo)
            no-error.
            esqcom1[1] = if avail tt-marca
                         then " Desmarca "
                         else " Marca ".
            esqcom2[1] = if avail tt-marca
                         then " Desmarca Todos "
                         else " Marca Todos ".
                       
            display esqcom1 with frame f-com1.            
            display esqcom2 with frame f-com2.
            
            choose field banfin.titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
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
                    if not avail banfin.titulo
                    then leave.
                    recatu1 = recid(banfin.titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail banfin.titulo
                    then leave.
                    recatu1 = recid(banfin.titulo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail banfin.titulo
                then next.
                color display white/red banfin.titulo.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail banfin.titulo
                then next.
                color display white/red banfin.titulo.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
           banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        banfin.titulo.titvlpag 
                                            column-label "Valor Pago"
        banfin.titulo.titvljur column-label "Juros" format "->,>>9.9"
        banfin.titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        banfin.titulo.titsit column-label "S" format "X"
        v-agendado            
                 with frame f-titulo color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                /***
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-titulo on error undo.
                    create banfin.titulo.
                    update banfin.titulo with frame f-titulo.
                    recatu1 = recid(banfin.titulo).
                    leave.
                end.
                ***/
                
                if esqcom1[esqpos1] = " Marca " or
                   esqcom1[esqpos1] = " Desmarca " 
                then do with frame f-titulo on error undo.
                
                    find first tt-marca
                        where tt-marca.rec = recid(banfin.titulo)
                            no-error.
                    if avail tt-marca
                    then delete tt-marca.
                    else do:
                        create tt-marca.
                        tt-marca.rec = recid(banfin.titulo).
                    end.
                end.

                if esqcom1[esqpos1] = " Relatorio "
                then do with frame f-titulo1 on error undo.
                    update "Deseja Imprimir o Relatorio ?"
                           sresp format "Sim/Nao"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.                
                    if sresp = no
                    then leave.
                    else do:
                        find first tt-marca no-error.
                        if not avail tt-marca
                        then do:
                            message "Nao existem titulos selecionados"
                                view-as alert-box.
                            leave.                                
                        end.
                        run p-imp-rel.
                    end.
                end.
                                
                if esqcom1[esqpos1] = " Recibo "
                then do with frame f-titulo on error undo.
                    update "Deseja Imprimir o(s) Recibo(s) ?"
                           sresp format "Sim/Nao"
                           with frame f-lista1 row 15 centered color black/cyan
                                 no-label.                
                    if sresp = no
                    then leave.
                    else do:
                        find first tt-marca no-error.
                        if not avail tt-marca
                        then do:
                            message "Nao existem titulos selecionados"
                                view-as alert-box.
                            leave.                                
                        end.
                        run p-imp-rec.
                    end.
                end.
                
                if esqcom1[esqpos1] = " Filtros "
                then do with frame f-filtratitulo on error undo.
                    update vsetcod label "Setor"
                           ffuncionario label "Funcionario"
                           fdata label "Data"
                           ffornecedor label "Fornecedor"
                           fcampanha label "Campanha"
                           fsituacao label "Situacao"
                           with frame f-filtratitulo 1 down centered row 8                            side-label
                            color message title "Filtro" overlay.               
            if ffuncionario <> ""
            then vfuncionario = "FUNCIONARIO=" + ffuncionario.
            else vfuncionario = "".
            
            if fcampanha <> ""  
            then vcampanha = "CAMPANHA=" + vcampanha.
            else vcampanha = "".
            
                   run leitura (input "pri"). 
                   if not avail banfin.titulo
                   then recatu1 = ?.
                   else recatu1 = recid(banfin.titulo).
                   
                   hide frame f-filtratitulo.

                   
            for each tt-marca.
            delete tt-marca.
            end.
            for each sel-titulo
            where sel-titulo.empcod = wempre.empcod
              and sel-titulo.titnat = vtitnat
              and sel-titulo.modcod = vmodcod
              and sel-titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then sel-titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then sel-titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else sel-titulo.clifor = ffornecedor)
              and (if vcampanha <> ""
                   then lookup(vcampanha,sel-titulo.titobs[2]) > 0
                   else true)
              and (if vfuncionario <> ""
                   then lookup(vfuncionario,sel-titulo.titobs[1]) > 0
                   else true)                   
              and (if vsetcod = 0
                   then true
                   else sel-titulo.titbanpag = vsetcod) no-lock.
                   
                    find first tt-marca
                        where tt-marca.rec = recid(sel-titulo)
                            no-error.
                    if not avail tt-marca
                    then do:
                        create tt-marca.
                        tt-marca.rec = recid(sel-titulo).
                        hide message no-pause.
                        message recid(sel-titulo).
                    end.                   
              end.     
                   run p-imp-rel.
                   
                   leave.
                end.
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-titulo.
                find banfin.modal of banfin.titulo no-lock no-error.
                disp banfin.titulo.modcod
                     modal.modnom when available modal no-label
                     banfin.titulo.titnum
                     banfin.titulo.titpar
/*                     banfin.titulo.titdtemi*/
                     banfin.titulo.titdtven
                     banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                     /***
                     banfin.titulo.cobcod ***/ with frame f-titulo.
                end.
                /***
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-titulo on error undo.
                    find banfin.titulo where
                            recid(banfin.titulo) = recatu1 
                        exclusive.
                    update banfin.titulo with frame f-titulo.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" banfin.titulo.titnum
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next banfin.titulo where true no-error.
                    if not available banfin.titulo
                    then do:
                        find banfin.titulo where recid(banfin.titulo) = recatu1.
                        find prev banfin.titulo where true no-error.
                    end.
                    recatu2 = if available banfin.titulo
                              then recid(banfin.titulo)
                              else ?.
                    find banfin.titulo where recid(banfin.titulo) = recatu1
                            exclusive.
                    delete banfin.titulo.
                    recatu1 = recatu2.
                    leave.
                end.
                ***/
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                /***
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lbanfin.titulo.p (input 0).
                    else run lbanfin.titulo.p (input banfin.titulo.titnum).
                    leave.
                    ***/
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                        
                        
/***/
                if esqcom2[esqpos2] = " Marca Todos " or
                   esqcom2[esqpos2] = " Desmarca Todos " 
                then do with frame f-titulo on error undo.
                    if esqcom2[esqpos2] = " Marca Todos "
                    then message "Marcar todos ?" update sresp.
                    else message "Desmarcar todos ?" update sresp.
                    
                    if sresp = yes
                    then do:
                        for each tt-marca.
                            delete tt-marca.
                        end.
                        
                        if esqcom2[esqpos2] = " Marca Todos "
                        then do:
                                                    
                            for each btitulo use-index titnum
                                where btitulo.empcod = wempre.empcod
                                  and btitulo.titnat = vtitnat
                                  and btitulo.modcod = vmodcod 
                                  and btitulo.etbcod = vetbcod
                                  and (if fsituacao <> ""
                                       then btitulo.titsit = fsituacao
                                       else true)
                                  and (if fdata <> ?
                                       then btitulo.titdtven = fdata
                                       else true)
                                  and (if ffornecedor = 0
                                       then true
                                       else btitulo.clifor = ffornecedor)
                                  and (if vcampanha <> ""
                                       then lookup(vcampanha,btitulo.titobs[2]) > 0
                                       else true)
                                  and (if vfuncionario <> ""
                                       then lookup(vfuncionario,btitulo.titobs[1]) > 0
                                       else true)                   
                                  and (if vsetcod = 0
                                       then true
                                   else btitulo.titbanpag = vsetcod) no-lock.
                            find first tt-marca
                                where tt-marca.rec = recid(btitulo)
                                    no-error.
                            if avail tt-marca
                            then delete tt-marca.
                            else do:
                                create tt-marca.
                                tt-marca.rec = recid(btitulo).
                            end.                                   
                        end.
                    end.
                end.                    
                end.
/***/
                        
                        
                        
                        
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
        recatu1 = recid(banfin.titulo).
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

procedure frame-a.
    if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
       banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
    then v-agendado = "*".
    else v-agendado = "".
    if acha("FUNCIONARIO",banfin.titulo.titobs[1]) <> ?
    then vmatricula = acha("FUNCIONARIO",banfin.titulo.titobs[1]).
    else vmatricula = "".
    find first tt-marca where tt-marca.rec = recid(banfin.titulo)
        no-error.
    if avail tt-marca
    then vmarca = yes.
    else vmarca = no.
    
    display vmarca no-label format "*/"
            banfin.titulo.clifor label "Forne"
            vmatricula label "Matric."
           banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        banfin.titulo.titvlpag 
        when banfin.titulo.titvlpag > 0 format "->>,>>9.99"
                                            column-label "Valor Pago"
        /***
        banfin.titulo.titvljur column-label "Juros" format "->,>>9.9"
        banfin.titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        ***/
        banfin.titulo.titsit column-label "S" format "X"
        /*
        v-agendado
        */
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        banfin.titulo.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        banfin.titulo.titnum
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    if esqascend  
    then  
    find first banfin.titulo use-index titnum
            where banfin.titulo.empcod = wempre.empcod
              and banfin.titulo.titnat = vtitnat
              and banfin.titulo.modcod = vmodcod
              and banfin.titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then banfin.titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then banfin.titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else banfin.titulo.clifor = ffornecedor)
              and (if vcampanha <> ""
                   then lookup(vcampanha,banfin.titulo.titobs[2]) > 0
                   else true)
              and (if vfuncionario <> ""
                   then lookup(vfuncionario,banfin.titulo.titobs[1]) > 0
                   else true)
              and (if vsetcod = 0
                   then true
                   else banfin.titulo.titbanpag = vsetcod) no-lock no-error.
    else  
        find last banfin.titulo use-index titnum
            where banfin.titulo.empcod = wempre.empcod
              and banfin.titulo.titnat = vtitnat
              and banfin.titulo.modcod = vmodcod
              and banfin.titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then banfin.titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then banfin.titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else banfin.titulo.clifor = ffornecedor)
              and (if vcampanha <> ""
                   then lookup(vcampanha,banfin.titulo.titobs[2]) > 0
                   else true)
              and (if vfuncionario <> ""
                   then lookup(vfuncionario,banfin.titulo.titobs[1]) > 0
                   else true)                     
              and (if vsetcod = 0
                   then true
                   else banfin.titulo.titbanpag = vsetcod) no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next banfin.titulo use-index titnum
            where banfin.titulo.empcod = wempre.empcod
              and banfin.titulo.titnat = vtitnat
              and banfin.titulo.modcod = vmodcod
              and banfin.titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then banfin.titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then banfin.titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else banfin.titulo.clifor = ffornecedor)
              and (if vsetcod = 0
                   then true
                   else banfin.titulo.titbanpag = vsetcod) no-lock no-error.
    else  
        find prev banfin.titulo use-index titnum
            where banfin.titulo.empcod = wempre.empcod
              and banfin.titulo.titnat = vtitnat
              and banfin.titulo.modcod = vmodcod
              and banfin.titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then banfin.titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then banfin.titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else banfin.titulo.clifor = ffornecedor)
              and (if vcampanha <> ""
                   then lookup(vcampanha,banfin.titulo.titobs[2]) > 0
                   else true)
              and (if vfuncionario <> ""
                   then lookup(vfuncionario,banfin.titulo.titobs[1]) > 0
                   else true)                   
              and (if vsetcod = 0
                   then true
                   else banfin.titulo.titbanpag = vsetcod) no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev banfin.titulo use-index titnum
            where banfin.titulo.empcod = wempre.empcod
              and banfin.titulo.titnat = vtitnat
              and banfin.titulo.modcod = vmodcod
              and banfin.titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then banfin.titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then banfin.titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else banfin.titulo.clifor = ffornecedor)
              and (if vcampanha <> ""
                   then lookup(vcampanha,banfin.titulo.titobs[2]) > 0
                   else true)
              and (if vfuncionario <> ""
                   then lookup(vfuncionario,banfin.titulo.titobs[1]) > 0
                   else true)                   
              and (if vsetcod = 0
                   then true
                   else banfin.titulo.titbanpag = vsetcod) no-lock no-error.
    else   
        find next banfin.titulo use-index titnum
            where banfin.titulo.empcod = wempre.empcod
              and banfin.titulo.titnat = vtitnat
              and banfin.titulo.modcod = vmodcod
              and banfin.titulo.etbcod = vetbcod
              and (if fsituacao <> ""
                   then banfin.titulo.titsit = fsituacao
                   else true)
              and (if fdata <> ?
                   then banfin.titulo.titdtven = fdata
                   else true)
              and (if ffornecedor = 0
                   then true
                   else banfin.titulo.clifor = ffornecedor)
              and (if vcampanha <> ""
                   then lookup(vcampanha,banfin.titulo.titobs[2]) > 0
                   else true)
              and (if vfuncionario <> ""
                   then lookup(vfuncionario,banfin.titulo.titobs[1]) > 0
                   else true)                        
              and (if vsetcod = 0
                   then true
                   else banfin.titulo.titbanpag = vsetcod) no-lock no-error.
        
end procedure.

procedure p-imp-rec.
varquivo = "./lfsetorr." + string(time).

    /*
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """RECIBOS LANCAMENTOS PREMIOS"""
            &Tit-Rel   = """IMPRESSO EM "" + string(today) "
            &Width     = "150"
            &Form      = "frame f-cabcab"}

    */
    output to value(varquivo).
    
    for each tt-marca.
        find banfin.titulo where recid(banfin.titulo) = tt-marca.rec no-lock.
        if acha("FUNFOLHA",banfin.titulo.titobs[1]) <> ?
        then vmatricula = acha("FUNFOLHA",banfin.titulo.titobs[1]).
        else vmatricula = "".
        if acha("META",banfin.titulo.titobs[1]) <> ?
        then vmeta = acha("META",banfin.titulo.titobs[1]).
        else vmeta = "".
        if acha("REALIZADA",banfin.titulo.titobs[2]) <> ?
        then vrealizada = acha("REALIZADA",banfin.titulo.titobs[2]).
        else vrealizada = "".
        
        find forne where forne.forcod = banfin.titulo.clifor no-lock no-error.
        find first func where func.usercod = vmatricula no-lock no-error.
        find setaut where setaut.setcod = banfin.titulo.titbanpag
            no-lock no-error.
            
        put skip(2)
            fill("=",80) format "x(80)"             
            skip(1).
                        
        disp banfin.titulo.titbanpag            label "Setor....."
             setaut.setnom no-label
             skip
             banfin.titulo.clifor               label "Fornecedor" 
             forne.fornom no-label when avail forne
             skip
             vmatricula                         label "Matricula."
             func.funnom no-label when avail func
             skip
             vmeta                              label "Meta......"
             skip
             vrealizada                         label "Realizada."
             skip
             banfin.titulo.titvlcob             label "Valor....."
             skip
             banfin.titulo.titdtven             label "Data......"
             with frame f-recibo side-labels.
             
        put skip(1)
            fill("_",25) format "x(25)" at 30
            "Assinatura" at 37
            skip.
            
    end.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.            
end procedure.

procedure p-imp-rel.
varquivo = "./lfsetorrel." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """RELATORIO LANCAMENTOS PREMIOS"""
            &Tit-Rel   = """IMPRESSO EM "" + string(today) "
            &Width     = "150"
            &Form      = "frame f-cabcab1"}

    for each tt-totsetor.
        delete tt-totsetor.
    end.        

    for each tt-marca,
        banfin.titulo where recid(banfin.titulo) = tt-marca.rec no-lock
            break by banfin.titulo.titbanpag.
        if acha("FUNFOLHA",banfin.titulo.titobs[1]) <> ?
        then vmatricula = acha("FUNFOLHA",banfin.titulo.titobs[1]).
        else vmatricula = "".
        if acha("META",banfin.titulo.titobs[1]) <> ?
        then vmeta = acha("META",banfin.titulo.titobs[1]).
        else vmeta = "".
        if acha("REALIZADA",banfin.titulo.titobs[2]) <> ?
        then vrealizada = acha("REALIZADA",banfin.titulo.titobs[2]).
        else vrealizada = "".
        
        find forne where forne.forcod = banfin.titulo.clifor
            no-lock no-error.
        find first func where func.usercod = vmatricula no-lock no-error.               disp banfin.titulo.titbanpag            column-label "Setor"
             banfin.titulo.clifor               column-label "Fornecedor" 
             forne.fornom no-label when avail forne format "x(20)"
             vmatricula                         column-label "Matricula"
             func.funnom no-label when avail func format "x(20)"
             vmeta                              column-label "Meta"
                format "x(20)"
             vrealizada                         column-label "Realizada"
                format "x(20)"
             banfin.titulo.titvlcob             column-label "Valor"
             banfin.titulo.titdtven             column-label "Data"
             with frame f-relatorio down.
             down with frame f-relatorio width 150.
        
        find first tt-totsetor
            where tt-totsetor.setor = banfin.titulo.titbanpag
                no-error.
        if not avail tt-totsetor
        then do:
            create tt-totsetor.
            tt-totsetor.setor = banfin.titulo.titbanpag.
        end.
        tt-totsetor.totalqtd = tt-totsetor.totalqtd + 1.
        tt-totsetor.totalval = tt-totsetor.totalval + banfin.titulo.titvlcob.
        
        find first tt-totsetor
            where tt-totsetor.setor = ?
                no-error.
        if not avail tt-totsetor
        then do:
            create tt-totsetor.
            tt-totsetor.setor = ?.
        end.
        tt-totsetor.totalqtd = tt-totsetor.totalqtd + 1.
        tt-totsetor.totalval = tt-totsetor.totalval + banfin.titulo.titvlcob.        
        
        if last-of(banfin.titulo.titbanpag)
        then do:
            find first tt-totsetor where 
                    tt-totsetor.setor = banfin.titulo.titbanpag
                no-error.
             put skip(1).   
             if avail tt-totsetor
             then
            disp "Total do Setor " tt-totsetor.setor  " - Parcelas: " tt-totsetor.totalqtd "     - Valor: " tt-totsetor.totalval with frame f-totsetor no-box ~ no-labels.
        end.
            
    end.

    
    find first tt-totsetor where tt-totsetor.setor = ? no-error.
    put skip(1).
    if avail tt-totsetor
    then
    disp "Total Geral                 - Parcelas: " tt-totsetor.totalqtd "      - Valor: " tt-totsetor.totalval with frame f-totsetorg no-box no-labels.
    
    /*
    for each tt-totsetor.
        disp tt-totsetor.
    end.        
    */

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.            
end procedure.
