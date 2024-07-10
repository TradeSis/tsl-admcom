{admcab.i}
             
setbcod = 900.

def var vhora1 as char. 

def var vhora2 as char.

def buffer bkit for kit.

def stream str-log .

def temp-table tt-pendente like com.liped
        field modcod like com.pedid.modcod
        field vencod like com.pedid.vencod.

def temp-table tt-mov
    field procod like com.produ.procod
    field qtdcont like tdocbpro.qtdcont
    index i-procod is primary unique procod.

def buffer btt-mov for tt-mov.    
def buffer ctt-mov for tt-mov.
def var vdesti like tdocbase.etbdes.
def var vmarca as char format "X".
def buffer btdocbase for tdocbase.
form  vmarca  
             tdocbase.etbdes
             tdocbase.dtdoc
             vhora1 
             tdocbase.dcbnum
             tdocbase.situacao
             tdocbase.DtRetTar
             vhora2 
             tdocbase.ecommerce 
             with frame frame-a.

def new shared temp-table tt-plani like com.plani.
def new shared temp-table tt-movim like com.movim.
def new shared temp-table tt-sel
    field rec    as   recid
    field desti  like tdocbase.etbdes.
    
def buffer btt-sel for tt-sel.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [  

             " NF Transf " ,
             
             "  Consulta ",
             
             " Filtro    ",

              "  ",
             
             " "].

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].


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

find first ebljh where ebljh.situacao = "F"
       no-lock no-error.
if not avail ebljh
then do:
    message "Nenhuma movimentacao encontrada.".
    pause 3 no-message.
    leave.
end.

{setbrw.i}

form ebljh.numero_carregamento   column-label "Carga"  format ">>>>>>>>9"
     ebljh.numero_filial         column-label "Filial" format ">>9"
     ebljh.data                  no-label
     ebljh.hora                  no-label
     ebljh.codigo_transp         column-label "Transp"
     ebljh.placa_veiculo         column-label "Placa"
     with frame f-linha 12 down.
        
l1: repeat:
    clear frame f-com1 all.
    hide frame f-com1.
    clear frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    color display message esqcom1[esqpos1] with frame f-com1 .
    
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = ebljh  
        &cfield = ebljh.numero_carregamento
        &noncharacter = /* 
        &ofield = " ebljh.numero_filial
                    ebljh.data
                    ebljh.hora
                    ebljh.codigo_transp
                    ebljh.placa_veiculo "  
        &aftfnd1 = " "
        &where  = " ebljh.situacao = ""F"" and
                    (if vdesti > 0 then ebljh.numero_filial = vdesti
                    else true) "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = "" filtro"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " Message color red/with
                        ""Nenum registro encontrato""
                        view-as alert-box.
                        leave l1.
                        " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = " NF Transf"
    THEN DO on error undo:
        for each tt-sel. delete tt-sel. end.    
        create tt-sel. 
        assign tt-sel.rec = recid(ebljh)
               tt-sel.desti  = ebljh.numero_filial.
                    
        find first tt-sel no-lock no-error.
        if not avail tt-sel
        then do:
            message "Nenhum movimento selecionado.".
            pause 2 no-message.
            recatu1 = ?.
            leave.
        end.
        disp ebljh.numero_carregamento label "Carregamento"   
                    format ">>>>>>>>9"
             ebljh.numero_filial       label "Filial destino"
             ebljh.data                label "Data Carga"
             ebljh.hora                label "Hora Carga"
             ebljh.codigo_transp       label "Tranportador"
             ebljh.placa_veiculo       label "Placa"
             with frame f-eminf 1 down centered color message
                    side-label 1 column overlay
                    width 80 row 6.
                    
        message "Confirma a emissao da NF Tranferencia?"
                            update sresp.
        if not sresp 
        then do:
            recatu1 = ?.
            for each tt-sel.   delete tt-sel.   end.                
            for each tt-mov. delete tt-mov. end.
            leave.
        end.
        else do:            
            run emissao-NFe.
                    
            for each  tt-sel. delete  tt-sel. end.
            for each tt-mov. delete tt-mov. end.    
            recatu1 = ?.
            leave.
        end.
    END.
    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO:
                    
        display 
            ebljh.numero_filial  label "Des"
            ebljh.data           label "Emi"
            ebljh.numero_carregamento format ">>>>>>>>9"
                                label "Carga"
            ebljh.situacao
                            with frame f-tit centered side-label row 4.

        for each eblji of ebljh no-lock:
            find com.produ where 
                     produ.procod = int(eblji.procod) no-lock. 

            disp eblji.procod format ">>>>>>>>>9"
                 produ.pronom format "x(20)" 
                 eblji.Quantidade column-label "Qtd."
                             (total)
                 eblji.situacao
                with frame f-con 10 down row 7 centered 
                                        title " Produtos ".
        end.
        pause.
        view frame f-com1.
        view frame f-com2.
            
    END.
    if esqcom1[esqpos1] = " FILTRO"
    THEN DO:
        vdesti = 0.

        update vdesti label "Destinatario"
                           with frame f-desti side-labels
                           row 8 overlay centered title " Filtro ".
        

    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
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
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.



/*************************************************************
find first tdocbase where tdocbase.tdcbcod = "ROM" and
            tdocbase.situacao = "F"
       no-lock no-error.
if not avail tdocbase
then do:
    message "Nenhuma movimentacao encontrada.".
    pause 3 no-message.
    leave.
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tdocbase where recid(tdocbase) = recatu1 no-lock.
    if not available tdocbase
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else leave.

    recatu1 = recid(tdocbase).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tdocbase
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
        hide frame f-tit no-pause.
        hide frame f-con no-pause.
        view frame frame-a. pause 0.
        view frame f-com1. pause 0.
        view frame f-com2. pause 0.
        if not esqvazio
        then do:
            find tdocbase where recid(tdocbase) = recatu1 no-lock.

            status default "".

            run color-message.
            
            choose field vmarca
                         tdocbase.etbdes 
                         tdocbase.dtdoc 
                         tdocbase.dcbnum 
                         tdocbase.situacao
                help ""
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
                    if not avail tdocbase
                    then leave.
                    recatu1 = recid(tdocbase).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tdocbase
                    then leave.
                    recatu1 = recid(tdocbase).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tdocbase
                then next.
                color display white/red vmarca
                                        tdocbase.etbdes  
                                        tdocbase.dtdoc  
                                         vhora1
                                        tdocbase.dcbnum  
                                        tdocbase.situacao with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tdocbase
                then next.
                color display white/red vmarca
                                        tdocbase.etbdes  
                                        tdocbase.dtdoc  
                                         vhora1
                                        tdocbase.dcbnum  
                                        tdocbase.situacao with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tdocbase
                 with frame f-tdocbase color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Seleciona "
                then do:
                    
                    find tt-sel where tt-sel.rec = recid(tdocbase)
                                  no-error.
                    if not avail tt-sel
                    then do:
                        
                        find first btt-sel no-lock no-error.
                        if avail btt-sel
                        then do:
                            find btdocbase where 
                                    recid(btdocbase) = tt-sel.rec
                                 no-lock no-error.
                            if avail btdocbase
                            then do:
                                if btdocbase.etbdes <> tdocbase.etbdes
                                then do:
                                    view frame frame-a. pause 0.
                                    message "Destinatario deve ser o mesmo.Selecao Invalida.".
                                    pause 2 no-message.
                                    recatu1 = ?.
                                    leave.
                                end.
                            end.
                        end.
                        
                        create tt-sel.
                        assign tt-sel.rec = recid(tdocbase)
                               tt-sel.desti  = tdocbase.etbdes.
                    end.
                    else delete tt-sel.
                    
                    recatu1 = recid(tdocbase).
                    leave.
                end.

                if esqcom1[esqpos1] = " Filtro "
                then do:
                    vdesti = 0.

                    view frame frame-a. pause 0.
                    
                    update vdesti label "Destinatario"
                           with frame f-desti side-labels
                                      row 8 overlay centered title " Filtro ".
                    if vdesti = 0
                    then leave.
                    for each tt-sel:
                        delete tt-sel.
                    end.
                    for each btdocbase where 
                                btdocbase.dtret = ? and 
                                btdocbase.situacao = "F"
                               and btdocbase.ecommerce = no  
                                               no-lock:
                        
                        if btdocbase.etbdes <> vdesti 
                        then next.
                        
                        find tt-sel where tt-sel.rec =  recid(btdocbase)
                                                          no-error.
                        if not avail tt-sel
                        then do:
                            create tt-sel.
                            assign tt-sel.rec =  recid(btdocbase)
                                   tt-sel.desti  = btdocbase.etbdes.
                        end.
                        else delete tt-sel.

                    end.
                    recatu1 = ?.
                    leave.
                end.

                if esqcom1[esqpos1] = "  Consulta "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    
                    display 
                            tdocbase.etbdes  label "Des"
                            tdocbase.dtdoc label "Emi"
                            tdocbase.dcbnum
                            tdocbase.situacao
                            with frame f-tit centered side-label row 4.

                    for each tdocbpro of tdocbase no-lock:
                        find com.produ where 
                             produ.procod = tdocbpro.procod no-lock. 

                        disp tdocbpro.procod format ">>>>>>>>>9"
                             produ.pronom format "x(20)" 
                             tdocbpro.movqtm column-label "Qtd.Sep"
                             (total)
                             tdocbpro.qtdcont column-label "Qtd.Col"
                             (total)
                             tdocbpro.situacao
                             tdocbpro.campo_log1 format "Exced/" no-label
                             tdocbpro.pednum
                             
                             with frame f-con 10 down row 7 centered 
                                        title " Produtos ".
                    
                    end.
                end.                
                            
                if esqcom1[esqpos1] = " emissao-NFeNF Transf "
                then do:
                    
                    for each tt-sel.
                        delete tt-sel.
                    end.    
                    /*****
                    sresp = no.
                    run /admcom/wms/consulta_tdocbase.p (input recatu1,
                                                           output sresp).
                    if sresp
                    then do:
                        message "Documento base em uso no BSWMS"
                                     view-as alert-box.
                        leave.
                    end.
                    ****/        
                    create tt-sel. 
                    assign tt-sel.rec = recid(tdocbase)
                           tt-sel.desti  = tdocbase.etbdes.
                    
                    view frame frame-a. pause 0.
                    find first tt-sel no-lock no-error.
                    if not avail tt-sel
                    then do:
                        message "Nenhum movimento selecionado.".
                        pause 2 no-message.
                        recatu1 = ?.
                        leave.
                    end.
                    
                    message "Confirma a emissao da NF Tranferencia?"
                            update sresp.
                    if not sresp 
                    then do:
                        recatu1 = ?.
                        for each tt-sel.   
                            delete tt-sel.  
                        end.                
                        for each tt-mov.
                            delete tt-mov.
                        end.
                        delete tt-sel.
                        leave.
                    end.
                    
                    run emissao-NFe.
                    
                    for each  tt-sel.
                        delete  tt-sel.
                    end.
                    for each tt-mov.
                        delete tt-mov.
                    end.    
                    recatu1 = ?.
                    leave.
                    
                end.


            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
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
        recatu1 = recid(tdocbase).
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
    vmarca = "".
    find tt-sel where  tt-sel.rec = recid(tdocbase) no-lock no-error.
    if avail tt-sel
    then vmarca = "*".
    vhora1 = string(tdocbase.HrCriTar,"HH:MM:SS").
    vhora2 = string(tdocbase.HrretTar,"HH:MM:SS").
    display vmarca         /*column-label "X"*/ no-label
            tdocbase.etbdes
            tdocbase.dtdoc        column-label "Data!Corte"
            vhora1         no-label
            tdocbase.dcbnum       column-label "Numero"
            tdocbase.situacao     column-label "Sit"
            tdocbase.DtRetTar     column-label "Data!Expedicao"
            vhora2 no-label
            tdocbase.ecommerce format "Ecom/" no-label
            tdocbase.RomExterno format "TGest/" no-label
            with frame frame-a 10 down centered color white/red row 5
                        overlay.
end procedure.

procedure color-message.
    vmarca = "".
    find tt-sel where  tt-sel.rec = recid(tdocbase) no-lock no-error.
    if avail tt-sel
    then vmarca = "*".

    color display message vmarca
                          tdocbase.etbdes 
                          tdocbase.dtdoc 
                          tdocbase.dcbnum 
                          tdocbase.situacao 
                          with frame frame-a.
end procedure.

procedure color-normal.
    vmarca = "".
    find tt-sel where  tt-sel.rec = recid(tdocbase) no-lock no-error.
    if avail tt-sel
    then vmarca = "*".

    color display normal  vmarca
                          tdocbase.etbdes 
                          tdocbase.dtdoc 
                          tdocbase.dcbnum 
                          tdocbase.situacao 
                          with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first  tdocbase where tdocbase.tdcbcod = "ROM" and
            tdocbase.situacao = "F" 
            
            no-lock no-error.
    else  
        find last  tdocbase where tdocbase.tdcbcod = "ROM" and
            tdocbase.situacao = "F"  
            no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next  tdocbase where tdocbase.tdcbcod = "ROM" and
            tdocbase.situacao = "F"  
            no-lock no-error.
    else  
        find prev  tdocbase where tdocbase.tdcbcod = "ROM" and
            tdocbase.situacao = "F"  
            no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev  tdocbase where tdocbase.tdcbcod = "ROM" and
                    tdocbase.situacao = "F"   
            no-lock no-error.
    else   
        find next  tdocbase where tdocbase.tdcbcod = "ROM" and
            tdocbase.situacao = "F"  
            no-lock no-error.
        
end procedure.
*******************************/

procedure emissao-NFe:
    def var vmovseq like com.movim.movseq.
    def var recpla as recid.
    def buffer xestab for ger.estab.
    def buffer bplani for com.plani.
    def var vplacod like com.plani.placod.
    def var vnumero like com.plani.numero.
    def var recmov as recid.    
    
    for each tt-mov.        delete tt-mov.      end.
    for each tt-pendente.   delete tt-pendente. end.
    
    find first tt-sel no-lock no-error.
 
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.

    def var vserie like com.plani.serie.
    
    vplacod = ?.
    vnumero = ?.
    vserie = "1".
    vmovseq = 0.
    
    create tt-plani. 
    assign tt-plani.etbcod   = setbcod
           tt-plani.placod   = vplacod 
           tt-plani.emite    = setbcod
           tt-plani.serie    = vserie
           tt-plani.numero   = vnumero 
           tt-plani.movtdc   = 6 
           tt-plani.desti    = tt-sel.desti
           tt-plani.pladat   = today 
           tt-plani.notfat   = tt-sel.desti
           tt-plani.dtinclu  = today 
           tt-plani.horincl  = time 
           tt-plani.notsit   = no 
           tt-plani.hiccod   = 5152 
           tt-plani.opccod   = 5152 
           tt-plani.datexp   = today.
    
    /* criar movim */

    for each tt-sel:
        for each ebljh where recid(ebljh) = tt-sel.rec no-lock:
            for each eblji of ebljh no-lock:
                find first tt-mov where 
                            tt-mov.procod = eblji.procod no-error.
                if not avail tt-mov
                then do:
                    create tt-mov.
                    assign tt-mov.procod = eblji.procod.
                end.
                tt-mov.qtdcont = tt-mov.qtdcont + eblji.quantidade.
            end.
        end.
            
        /***
        for each tdocbase where recid(tdocbase) = tt-sel.rec no-lock. 
            for each tdocbpro of tdocbase no-lock. 
                
                if tdocbpro.qtdcont < tdocbpro.movqtm 
                then do on error undo.
                    def var vExcesso as log.
                    vExcesso = no.
                    if tdocbpro.campo_log1
                    then do.
                        find first liped where liped.etbcod = tdocbase.etbdes
                                           and liped.pedtdc = 3 
                                           and liped.pednum = tdocbpro.pednum                                           and liped.procod = tdocbpro.procod
                                           no-error.
                        if avail liped
                        then do.
                            run criarepexporta.p ("LIPED_PENDENTE",
                                                  "INCLUSAO",  
                                                  recid(liped)).
                            liped.pendente    = yes.
                            liped.PendMotivo  = "Excesso de Carga".
                            liped.lip_status  = "".
                            vExcesso = yes.
                        end.
                    end.
                    def buffer cpedid for pedid.
                    find first liped where liped.etbcod = tdocbase.etbdes
                                       and liped.pedtdc = 3 
                                       and liped.pednum = tdocbpro.pednum  
                                       and liped.procod = tdocbpro.procod
                                       no-lock no-error.                    
                    if avail liped and tdocbpro.pednum <> ? and
                        vExcesso = no
                    then do.
                        find cpedid of liped no-lock.
                        create tt-pendente.
                        assign
                            tt-pendente.etbcod   = liped.etbcod 
                            tt-pendente.vencod   = cpedid.vencod
                            tt-pendente.pedtdc   = liped.pedtdc
                            tt-pendente.pednum   = liped.pednum
                            tt-pendente.procod   = liped.procod
                            tt-pendente.lipcor   = string(liped.lipcor,"x(30)")
                            tt-pendente.predt    = cpedid.peddat  /*today*/
                            tt-pendente.prehr    = liped.prehr
                            tt-pendente.lipqtd   = tdocbpro.movqtm  -
                                                   tdocbpro.qtdcont                                      tt-pendente.lippreco = liped.lippreco
                            tt-pendente.modcod   = cpedid.modcod. 
                    end.
                end.
            
                find tt-mov where tt-mov.procod = tdocbpro.procod no-error.
                if not avail tt-mov
                then do:
                    create tt-mov.
                    assign tt-mov.procod = tdocbpro.procod.
                end.
                tt-mov.qtdcont = tt-mov.qtdcont + tdocbpro.qtdcont.
            end.    
        end.
        *******/
    end.
    
    vmovseq = 0.
    for each tt-mov,
        first produ where produ.procod = tt-mov.procod
                no-lock by produ.pronom:
        
        find com.estoq where estoq.etbcod = setbcod
                     and estoq.procod = tt-mov.procod no-lock no-error.
        if not avail estoq
        then 
            find first estoq where 
                       estoq.procod = tt-mov.procod no-lock no-error.
        
        if tt-mov.qtdcont = 0 
        then do.
            delete tt-mov.
            next.
        end. 
        find first tt-plani exclusive-lock.
                            
        vmovseq = vmovseq + 1.
        create tt-movim. 
        assign tt-movim.movtdc = tt-plani.movtdc 
               tt-movim.PlaCod = tt-plani.placod 
               tt-movim.etbcod = tt-plani.etbcod 
               tt-movim.movseq = vmovseq 
               tt-movim.procod = tt-mov.procod 
               tt-movim.movqtm = tt-mov.qtdcont 
               tt-movim.movpc  = if avail estoq
                        then estoq.estcusto else 1
               tt-movim.movdat = tt-plani.pladat 
               tt-movim.MovHr  = int(time) 
               tt-movim.emite  = tt-plani.emite 
               tt-movim.desti  = tt-plani.desti 
               tt-movim.datexp = tt-plani.datexp.    
                                   
        if avail estoq and estoq.estcusto = 0 
        then tt-movim.movpc = 1.
                            
        tt-plani.platot = tt-plani.platot + 
                    (tt-movim.movpc * tt-movim.movqtm). 
        tt-plani.protot = tt-plani.protot + 
                    (tt-movim.movpc * tt-movim.movqtm).
                        
        delete tt-mov.
    end.

    find first tt-plani exclusive-lock.

    find first tt-movim where tt-movim.procod > 0 no-error.
    
    if avail tt-movim
    then do:
        
        release tt-movim.

        find first tt-movim
             where tt-movim.etbcod = tt-plani.etbcod and
                   tt-movim.placod = tt-plani.placod and
                   tt-movim.movtdc = tt-plani.movtdc and
                   tt-movim.movdat = tt-plani.pladat
                            no-lock no-error.
                            
        if not avail tt-movim
        then do:
    
            output stream str-log
                to value("/admcom/wms/logsnfe/nota_sem_item.csv") append.

            put stream str-log
                "ETBCOD;PLACOD;MOVTDC;PLADAT;" skip.

            for each tt-movim no-lock.
            
                put stream str-log
                    tt-movim.etbcod
                    ";"
                    tt-movim.placod
                    ";"
                    tt-movim.movtdc
                    ";"
                    tt-movim.movdat
                    ";" skip.
            
            

            end.
    
            output stream str-log close.

        end.
    
    end.

    release tt-movim.
        
    find first tt-movim
         where tt-movim.etbcod = tt-plani.etbcod and
               tt-movim.placod = tt-plani.placod and
               tt-movim.movtdc = tt-plani.movtdc and
               tt-movim.movdat = tt-plani.pladat
                       no-lock no-error.

    if not avail tt-movim
    then do:
        bell.
        message color red/with
        "Movimentacao sem itens, NFe nao sera gerada."
        view-as alert-box.
    end.
    else do:    
        def var p-ok as log init no.
        def var p-valor as char.
        p-valor = "".
        run le_tabini.p (setbcod, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
        if p-valor = "NFE"
        then do:
            
            run manager_nfe.p (input "wms_alcis_5152",
                               input ?,
                               output p-ok).
        end.
    end.

    /*
    run cria-novo-pedido.
    */
    for each tt-sel. delete tt-sel. end.
    for each tt-pendente. delete tt-pendente. end.

end procedure.



/************************
procedure cria-novo-pedido:
    def var vpednum like com.pedid.pednum.
    def buffer btt-pendente for tt-pendente.
    def buffer bpedid for com.pedid.
    def buffer bliped for com.liped.
    def buffer nprodu for com.produ.
    def var v-pendente as log init no.
    do.
        v-pendente = no.
        for each tt-pendente where
                   no-lock .
            find first nprodu where
                       nprodu.procod = tt-pendente.procod 
                       no-lock no-error.
                
            if not avail nprodu 
            then do. /* message "1". pause 3.*/ next. end.
            if nprodu.pronom matches "*RECARGA*" 
            then do. /* message "2". pause 3.*/ next. end.
            if nprodu.pronom matches "*FRETEIRO*" 
            then do. /* message "3". pause 3.*/ next. end.
            if nprodu.pronom begins "*" 
            then do. /* message "4". pause 3.*/ next. end.
            if nprodu.proipival = 1 
            then do. /* message "5". pause 3.*/ next. end.
            if nprodu.clacod = 182 
            then do. /* message "6". pause 3.*/ next. end.
            if nprodu.clacod = 3068 
            then do. /* message "7". pause 3.*/ next. end.
            if nprodu.clacod = 96
            then do. /* message "8". pause 3.*/ next. end.
    
            v-pendente = yes.
            leave.
        end.           
        if v-pendente = no  
        then do. /* message "9". pause 3.*/ next. end.
        
        if v-pendente = yes
        then do:            
            /* nao cria mais um pedido pendente por corte 
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = tt-pendente.etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
            
            create com.pedid.
            assign com.pedid.etbcod = tt-pendente.etbcod 
                   com.pedid.pedtdc = 3
                   com.pedid.modcod = "PEDP"
                   com.pedid.peddat = tt-ped.peddat
                   com.pedid.pednum = vpednum
                   com.pedid.sitped = "E"
                   com.pedid.pedsit = yes.
            */
        end.
        else next.
        
        for each btt-pendente 
                 no-lock:
            find first nprodu where
                       nprodu.procod = btt-pendente.procod 
                       no-lock no-error.
                
            if not avail nprodu 
            then do. /* message "10". pause 3.*/ next. end.
            if nprodu.pronom matches "*RECARGA*" 
            then do. /* message "11". pause 3.*/ next. end.
            if nprodu.pronom matches "*FRETEIRO*" 
            then do. /* message "12". pause 3.*/ next. end.
            if nprodu.pronom begins "*" 
            then do. /* message "13". pause 3.*/ next. end.
            if nprodu.proipival = 1  
            then do. /* message "14". pause 3.*/ next. end.
            if btt-pendente.lipqtd = 0
            then do. /* message "15". pause 3.*/ next. end.
            
            /* um pedid para cada pendente */
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = btt-pendente.etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
            if btt-pendente.etbcod <> 200
            then do.
                def buffer PEDO-pedid for pedid.
                find PEDO-pedid where PEDO-pedid.etbcod = btt-pendente.etbcod
                                  and PEDO-pedid.pedtdc = btt-pendente.pedtdc
                                  and PEDO-pedid.pednum = btt-pendente.pednum
                                      no-lock no-error.
                create com.pedid.
                assign com.pedid.etbcod = btt-pendente.etbcod 
                       com.pedid.vencod = btt-pendente.vencod
                       com.pedid.pedtdc = 3
                       com.pedid.modcod = btt-pendente.modcod
                       com.pedid.peddat = btt-pendente.predt
                       com.pedid.pednum = vpednum
                       com.pedid.sitped = "E"
                       com.pedid.pedsit = yes
                       com.pedid.pendente = yes.
                if avail PEDO-pedid
                then do. 
                    com.pedid.vencod = PEDO-pedid.vencod.
                    com.pedid.clfcod = PEDO-pedid.clfcod.
                    com.pedid.condat = PEDO-pedid.condat.
                end.
                create pedpend.
                ASSIGN pedpend.etbcod-ori = btt-pendente.etbcod
                       pedpend.pedtdc-ori = btt-pendente.pedtdc
                       pedpend.pednum-ori = btt-pendente.pednum
                       pedpend.etbcod-des = com.pedid.etbcod 
                       pedpend.pednum-des = com.pedid.pednum 
                       pedpend.pedtdc-des = com.pedid.pedtdc. 
            end.
            def buffer xxliped for liped.
            find first xxliped where xxliped.etbcod = btt-pendente.etbcod and
                                     xxliped.pedtdc = btt-pendente.pedtdc and
                                     xxliped.pednum = btt-pendente.pednum and
                                     xxliped.procod = btt-pendente.procod
                                     no-error.

            if avail xxliped
            then do.
                def buffer xxpedid for pedid.
                find xxpedid of xxliped no-lock no-error.
                if avail xxpedid
                then do.
                    find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                          tbgenerica.TGCodigo = xxpedid.modcod 
                                          no-lock no-error. 
                    if tbgenerica.tglog
                    then do.
                        run criarepexporta.p ("LIPED_PENDENTE",
                                              "INCLUSAO",  
                                              recid(xxliped)).
                        xxliped.pendente    = yes.
                        xxliped.PendMotivo  = "Produto nao separado no CD.".
                        if btt-pendente.etbcod <> 200
                        then xxliped.lip_status  =   trim(
                                        "Gerou Pendente " +
                                            "[" +
                                                string(com.pedid.pednum)
                                                + "]" ).
                    end.
                end.
            end.
            /*******************************/
            if btt-pendente.etbcod <> 200
            then do.
                find first  com.liped where 
                        com.liped.etbcod = com.pedid.etbcod and
                        com.liped.pedtdc = com.pedid.pedtdc and
                        com.liped.pednum = com.pedid.pednum and
                        com.liped.procod = btt-pendente.procod no-error.
                if not avail com.liped
                then do:
                    create com.liped.
                    assign 
                        com.liped.pedtdc    = com.pedid.pedtdc
                        com.liped.pednum    = com.pedid.pednum
                        com.liped.procod    = btt-pendente.procod
                        com.liped.lippreco  = btt-pendente.lippreco
                        com.liped.lipsit    = "Z"
                        com.liped.predtf    = com.pedid.peddat
                        com.liped.predt     = com.pedid.peddat
                        com.liped.etbcod    = com.pedid.etbcod
                        com.liped.lipcor    = 
                        string(btt-pendente.lipcor,"x(30)")
                        com.liped.protip    = string(time)
                        com.liped.prehr     = btt-pendente.prehr
                        com.liped.pendente  = yes .
                end.
                com.liped.lipqtd = com.liped.lipqtd + btt-pendente.lipqtd.
            end.
        end.
    end.        
end procedure.
********************************/
