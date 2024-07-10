/*  titluc_lib.p                                                            */
/*  Luciano Alves -                                                         */
{admcab.i}
{filtro-estab.def}
{filtro-forne.def}
{filtro-func.def}


def var varquivo as char.
def var vdata as date.
def var vdata1 as date init today.
def var vdata2 as date init today.  


def temp-table tt_titluc
    field rec as recid
    field forcod    like forne.forcod
    field marca     as log format "*/" init no
    index forne     is primary forcod asc
    index rec       is unique rec. 

form
    vforne   colon 31 label "Todos Fornecedores...."
    cforne   no-label
    vEstab   colon 31 label "Todos Estabelecimentos"
    cestab   no-label
    vfunc    colon 31 label "Todos Funcionarios...."
    cfunc    no-label
    vdata1   colon 31 label "Periodo"
    vdata2   label "ate"  skip
    with frame fopcoes row 3 side-label width 80.

do on error undo.
    vforne  = yes.
    {filtro-forne.i}
    do on error undo.
        vestab = yes.
        {filtro-estab.i} 
        do on error undo.
            vfunc = yes. 
            {filtro-func-funcod.i}             
            do on error undo.
                update vdata1 vdata2 with frame fopcoes.
            end.
        end.
    end.
end.

for each wfforne where wfforne.forcod = 0:
    delete wfforne.
end.
for each wffunc where wffunc.funcod = 0:
    delete wffunc.
end.    

for each tt_titluc.
    delete tt_titluc.
end.

for each estab no-lock by etbcod desc.  
    find first wfestab no-error.   
    if avail wfestab  
    then do: 
        if wfestab.etbcod = 0 
        then. 
        else do: 
            find first wfestab where wfestab.etbcod = estab.etbcod no-error. 
            if not avail wfestab 
            then next. 
        end. 
    end.    
    def var vsit as char extent 2 init ["EXC","PEN"].
    def var x as int.
    do vdata = vdata1 to vdata2.
        pause 0.
        display "Processando......" estab.etbcod
                vdata 
                with no-label row 10 1 down.
        pause 0.
        for each modal no-lock.
            do x = 1 to 2.    
                for each titluc where titluc.empcod   = wempre.empcod and
                                      titluc.titnat   = yes           and
                                      titluc.modcod   = modal.modcod  and
                                      titluc.titsit   = vsit[x]       and
                                      titluc.etbcod   = estab.etbcod  and
                                      titluc.titdtven = vdata
                                      no-lock.
                    
                    find first wfforne no-error. 
                    if avail wfforne 
                    then do: 
                        if wfforne.forcod = 0 
                        then. 
                        else do: 
                            find first wfforne where 
                                        wfforne.forcod = titluc.clifor
                                        no-error.
                            if not avail wfforne 
                            then next. 
                        end. 
                    end.
                    find first wffunc no-error. 
                    if avail wffunc 
                    then do: 
                        if wffunc.funcod = 0 
                        then. 
                        else do: 
                            find first wffunc where 
                                        /*
                                        wffunc.etbcod = titluc.etbcod and
                                        */
                                        wffunc.funcod = titluc.vencod
                                        no-error.
                            if not avail wffunc 
                            then next. 
                        end. 
                    end.
                    create tt_titluc.
                    assign tt_titluc.rec    = recid(titluc)
                           tt_titluc.forcod = titluc.clifor .
                end.
            end.
        end.
    end.
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Marca "," Marcar Todas "," Consulta ","  "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Liberar "," ","  "].
    
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer btt_titluc       for tt_titluc.
def var vtt_titluc         like tt_titluc.forcod.


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

form
        tt_titluc.marca no-label
        tt_titluc.forcod 
        forne.fornom format "x(10)"
        titluc.etbcod
        titluc.vencod
        titluc.titnum
        titluc.titvlcob
        titluc.titdtven
        titluc.titsit
        
        with frame frame-a .


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt_titluc where recid(tt_titluc) = recatu1 no-lock.
    if not available tt_titluc
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do on error undo.
        message "Sem registros filtrados".
        pause 3 no-message.
        leave.
    end.

    recatu1 = recid(tt_titluc).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt_titluc
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
            find tt_titluc where recid(tt_titluc) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt_titluc.forcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt_titluc.forcod)
                                        else "".
            esqcom1[1] = if tt_titluc.marca
                         then " Desmarca "
                         else " Marca ".
            display esqcom1     
                    with frame f-com1.
            run color-message.
            choose field tt_titluc.forcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
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
                    if not avail tt_titluc
                    then leave.
                    recatu1 = recid(tt_titluc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt_titluc
                    then leave.
                    recatu1 = recid(tt_titluc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt_titluc
                then next.
                color display white/red tt_titluc.forcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt_titluc
                then next.
                color display white/red tt_titluc.forcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt_titluc
                 with frame f-tt_titluc color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do with frame f-consulta overlay row 6 centered side-label.

                find titluc where recid(titluc) = tt_titluc.rec no-lock.

                disp titluc.etbcod   label "Filial    "  at 1 
                     titluc.titnum   label "Despesa   "  at 1
                     titluc.clifor   label "Fornecedor"  at 1.
                        
                find foraut where foraut.forcod = titluc.clifor no-lock.
                display foraut.fornom no-label.        
                
     
                display        
                     titluc.modcod   label "Modalidade"  at 1
                     titluc.titdtemi label "Emissao   "  at 1
                     titluc.titdtven label "Vencimento"  at 1
                     titluc.titdtpag label "Pagamento "  at 1
                     titluc.cxacod   label "Caixa     "  at 1
                     titluc.datexp   label "Exportado "  at 1
                        format "99/99/9999"
                        with frame f-consulta no-validate.
                        
                display titluc.titobs[1] no-label 
                        titluc.titobs[2] no-label 
                            with frame f-obs centered
                                title "Observacoes".
                
            end.

                if esqcom1[esqpos1] = " Marca " or
                   esqcom1[esqpos1] = " desMarca " 
                then do with frame f-tt_titluc on error undo.
                    tt_titluc.marca = not tt_titluc.marca.
                end.
                if esqcom1[esqpos1] = " Marcar Todas "
                then do.
                    for each tt_titluc.
                        tt_titluc.marca = yes.
                    end.
                    recatu1 = ?.
                    next bl-princ.
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Liberar "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run libera.
                    recatu1 = ?.
                    next bl-princ.
                    /*view frame f-com1.
                    view frame f-com2.
                    */
                end.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt_titluc).
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
find titluc where recid(titluc) = tt_titluc.rec no-lock .
find forne where forne.forcod = titluc.clifor no-lock.
display 
        tt_titluc.marca no-label
        tt_titluc.forcod 
        forne.fornom format "x(10)" label "Fornecedor"
        titluc.etbcod               label "Filial"
        titluc.vencod               label "Vendedor"
        titluc.titnum               label "Premiacao"
        titluc.titvlcob             label "Valor"
        titluc.titdtven             label "Data"
        titluc.titsit              label "Sit"
        
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt_titluc.forcod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt_titluc.forcod
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt_titluc where true
                                                no-lock no-error.
    else  
        find last tt_titluc  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt_titluc  where true
                                                no-lock no-error.
    else  
        find prev tt_titluc   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt_titluc where true  
                                        no-lock no-error.
    else   
        find next tt_titluc where true 
                                        no-lock no-error.
        
end procedure.
         


procedure libera.
run message.p (input-output sresp,  
               input "Confirma a Liberacao dos Premios Marcados ??" , 
               input " !! ATENCAO !! ").
if sresp 
then do.
    for each tt_titluc where tt_titluc.marca = yes. 
        find titluc where recid(titluc) = tt_titluc.rec .
        create log_titluc.
        ASSIGN log_titluc.empcod    = titluc.empcod 
               log_titluc.modcod    = titluc.modcod 
               log_titluc.CliFor    = titluc.CliFor 
               log_titluc.titnum    = titluc.titnum 
               log_titluc.titpar    = titluc.titpar 
               log_titluc.titnat    = titluc.titnat 
               log_titluc.etbcod    = titluc.etbcod 
               log_titluc.titdtemi  = titluc.titdtemi 
               log_titluc.titdtven  = titluc.titdtven 
               log_titluc.titvlcob  = titluc.titvlcob 
               log_titluc.titdtdes  = titluc.titdtdes 
               log_titluc.titvldes  = titluc.titvldes 
               log_titluc.titvljur  = titluc.titvljur 
               log_titluc.cobcod    = titluc.cobcod 
               log_titluc.bancod    = titluc.bancod 
               log_titluc.agecod    = titluc.agecod 
               log_titluc.titdtpag  = titluc.titdtpag 
               log_titluc.titdesc   = titluc.titdesc 
               log_titluc.titjuro   = titluc.titjuro 
               log_titluc.titvlpag  = titluc.titvlpag.  
        ASSIGN log_titluc.titbanpag = titluc.titbanpag 
               log_titluc.titagepag = titluc.titagepag 
               log_titluc.titchepag = titluc.titchepag 
               log_titluc.titobs[1] = titluc.titobs[1] 
               log_titluc.titobs[2] = titluc.titobs[2] 
               log_titluc.titsit    = titluc.titsit 
               log_titluc.titnumger = titluc.titnumger 
               log_titluc.titparger = titluc.titparger 
               log_titluc.cxacod    = titluc.cxacod 
               log_titluc.evecod    = titluc.evecod 
               log_titluc.cxmdata   = titluc.cxmdata 
               log_titluc.cxmhora   = titluc.cxmhora 
               log_titluc.vencod    = titluc.vencod 
               log_titluc.etbCobra  = titluc.etbCobra 
               log_titluc.datexp    = titluc.datexp 
               log_titluc.moecod    = titluc.moecod 
               log_titluc.log_data  = today
               log_titluc.log_hora  = time
               log_titluc.func_etbcod = setbcod 
               log_titluc.func_funcod = sfuncod
               log_titluc.motivo      = "SITUACAO"
               .
        titluc.titsit = "LIB".
        delete tt_titluc.
    end.
end.
end procedure.
