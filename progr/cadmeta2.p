/*
*    tt-tbmeta.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-tbmeta
                          cla
*
*/

FUNCTION mesfim returns date(input par-data as date).

     return ((DATE(MONTH(par-data),28,YEAR(par-data)) + 4) -                                 DAY(DATE(MONTH(par-data),28,YEAR(par-data)) + 4)).
             
end function.
             


def var vdti         as date.
def var vdtf         as date.

def var vcha-label-aux as char.

def var vdti-ant     as date.
def var vdtf-ant     as date.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Acoes "," Acumulado ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-tbmeta ",
             " Alteracao da tt-tbmeta ",
             " Exclusao  da tt-tbmeta ",
             " Consulta  da tt-tbmeta ",
             " Listagem  Geral de tt-tbmeta "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def temp-table tt-ac
    field catcod           as integer
    field cont-perc-ano    as integer
    field perc-med-ano     as decimal
    field venda-atu-ano    as decimal
    field venda-met-ano    as decimal
    field percent-dif-ano  as decimal
    
    field cont-perc-1s     as integer
    field perc-med-1s      as decimal
    field venda-atu-1s     as decimal
    field venda-met-1s     as decimal
    field percent-dif-1s   as decimal

    field cont-perc-2s     as integer
    field perc-med-2s      as decimal
    field venda-atu-2s     as decimal
    field venda-met-2s     as decimal
    field percent-dif-2s   as decimal
    index idx01 catcod.
                   
                    


def var vdesmes as char format "x(10)" extent 12
    init["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
             "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
             
def buffer bclase for clase.

def var vmes as int.

def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

def var setbcod-aux as integer.            

def var vcla-meta as integer.

def var varquivo   as character.

def temp-table tt-tbmeta like tbmeta
     field rowid            as rowid
     field catcod           as integer
     field venda-ant        as dec
     field venda-atu        as dec
     field venda-met        as dec 
     field percent-dif      as dec
     
     /**** Acumulado Anual ****/
     field venda-ant-acum   as dec
     field venda-atu-acum   as dec
     field venda-met-acum   as dec
     field perc-med       as integer
     field percent-dif-acum as integer    
     
     
     /****** 1º Semestre ******/
     field venda-ant-1s    as dec
     field venda-atu-1s    as dec
     field venda-met-1s    as dec
     field perc-med-1s   as integer
     field percent-dif-1s  as integer    
     

     /****** 2º Semestre ******/
     field venda-ant-2s    as dec
     field venda-atu-2s    as dec
     field venda-met-2s    as dec
     field perc-med-2s   as integer
     field percent-dif-2s  as integer    
     
     
     index idx-perc percent-dif asc.
            
form
    tt-tbmeta.etbcod     label "Filial"     skip
    tt-tbmeta.ano                           skip
    tt-tbmeta.mes     format ">>9" 
    vdesmes[vmes]                                 skip
    vcla-meta   format ">>>>>>>>9"          label "Setor"           
    bclase.clanome  colon 40  no-label format "x(25)"          skip
    tt-tbmeta.perc     format ">>,99%"                     skip
      with frame f02 side-label 3 column centered row 8.

{admcab.i}


procedure troca-label:
    
    def input parameter par-handle as handle.
    def input parameter par-label as char.
    
    if par-label = "NO-LABEL"
    then par-handle:label = ?.
    else par-handle:label = par-label.
    
end procedure.

                           
                           
define temp-table tt-cla
        field cla-cod       as integer
        field clasup        as integer
        index idx01 cla-cod.
                            
def buffer btbmeta       for tbmeta.
def buffer ctbmeta       for tbmeta.


def var vtt-tbmeta         like tt-tbmeta.cla-cod.

def var vano as integer.

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
    
form vano label " ***  Informe o Ano" format ">>>9"
        "***"
     with frame f01 
              side-label row 3 no-box.
/*                 
update vano
         with frame f01.
*/

vmes = month(today).
vano = year(today).

disp vmes format "99"   label "Mes"
     vdesmes[vmes] no-label
     vano format "9999" label "Ano"
        with frame f-mes 1 down width 80
           color message no-box side-label.
                    

update vmes format "99"   label "Mes"
        with frame f-mes.
        
disp       vdesmes[vmes] no-label     with frame f-mes.
update  vano format "9999" label "Ano"
        with frame f-mes 1 down width 80 no-box side-label.
               
               

/*
if setbcod <> 999
then assign setbcod-aux = setbcod
            esqcom1[1]  = " Consulta "
            esqcom1[2]  = ""
            esqcom1[3]  = ""
            esqcom1[4]  = ""
            esqcom1[5]  = "".
else update setbcod-aux no-label with frame f-etbcod row 6
                            centered title "Informe a Filial ".

*/

if setbcod = 999
then assign setbcod-aux = 01.
else assign setbcod-aux = setbcod.


assign vdti      = date(vmes,01,vano)
       vdtf      = mesfim(date(vmes,01,vano))
       vdti-ant  = date(vmes,01,vano - 1)
       vdtf-ant  = date(month(vdtf) + 1,01,vano - 1) - 1.

/*
display vdti      format "99/99/9999"
        vdtf      format "99/99/9999"
        vdti-ant  format "99/99/9999"  
        vdtf-ant  format "99/99/9999".
*/

for each claseaux where claseaux.cadmeta = yes no-lock:

if not can-find(first btbmeta
                where btbmeta.etbcod = setbcod-aux
                  and btbmeta.cla-cod = claseaux.clacod      
                  and btbmeta.ano    = vano
                  and btbmeta.mes    = vmes)
then do:                  
        
create btbmeta.
assign btbmeta.etbcod     = setbcod-aux
       btbmeta.cla-cod    = claseaux.clacod
       btbmeta.ano        = vano
       btbmeta.mes        = vmes
       btbmeta.datcad     = today.
         
end.
end.



for each btbmeta where btbmeta.etbcod = setbcod-aux
                   and btbmeta.ano    = vano
                   and btbmeta.mes    = vmes no-lock,
                   
    first clase where clase.clacod = btbmeta.cla-cod
                  and clase.clagrau = 1  no-lock.

    create tt-tbmeta.
    
    buffer-copy btbmeta to tt-tbmeta.

    assign tt-tbmeta.rowid = rowid(btbmeta)
           tt-tbmeta.catcod = integer(clase.claper).

    find first tt-cla where tt-cla.cla-cod = btbmeta.cla-cod no-lock no-error.
    if not avail tt-cla
    then do:
        create tt-cla.
        assign tt-cla.cla-cod = btbmeta.cla-cod
               tt-cla.clasup  = btbmeta.cla-cod.
    end.

    for each cclase where cclase.clasup = btbmeta.cla-cod no-lock.
    
        find first tt-cla where tt-cla.cla-cod = cclase.clacod
                                                 no-lock no-error.
        if not avail tt-cla
        then do:
            create tt-cla.
            assign tt-cla.cla-cod = cclase.clacod
                   tt-cla.clasup  = btbmeta.cla-cod.
        end.
        
        for each dclase where dclase.clasup = cclase.clacod no-lock.
        
            find first tt-cla where tt-cla.cla-cod = dclase.clacod
                                                      no-lock no-error.
            if not avail tt-cla
            then do:
                create tt-cla.
                assign tt-cla.cla-cod = dclase.clacod
                       tt-cla.clasup  = btbmeta.cla-cod.
            end.
            
            for each eclase where eclase.clasup = dclase.clacod no-lock.
                
                find first tt-cla where tt-cla.cla-cod = eclase.clacod
                                                    no-lock no-error.
                if not avail tt-cla
                then do:
                    create tt-cla.
                    assign tt-cla.cla-cod = eclase.clacod
                           tt-cla.clasup  = btbmeta.cla-cod.
                end.
            end.                       
        end.
    end.
end.

message "Gerando a estrutura de classes e Calculando as vendas...".

for each tt-cla no-lock.

    find first tt-tbmeta where tt-tbmeta.cla-cod = tt-cla.clasup
                                    exclusive-lock no-error.

    for each produ where produ.catcod = tt-tbmeta.catcod
                     and produ.clacod = tt-cla.cla-cod no-lock,
    
        each movim where movim.etbcod = setbcod-aux
                     and movim.movtdc = 5
                     and movim.procod = produ.procod
                     and movim.movdat >= vdti-ant
                     and movim.movdat <= vdtf-ant no-lock:
                     
        assign tt-tbmeta.venda-ant = tt-tbmeta.venda-ant
                                        + (movim.movpc * movim.movqtm).
                                        
    
    end.

    for each produ where produ.catcod = tt-tbmeta.catcod
                     and produ.clacod = tt-cla.cla-cod no-lock,
    
        each movim where movim.etbcod = setbcod-aux
                     and movim.movtdc = 5
                     and movim.procod = produ.procod
                     and movim.movdat >= vdti
                     and movim.movdat <= vdtf no-lock:
                     
        assign tt-tbmeta.venda-atu = tt-tbmeta.venda-atu
                                        + (movim.movpc * movim.movqtm).
    
    end.

end.

for each tt-tbmeta exclusive-lock.

    assign tt-tbmeta.venda-met   =  tt-tbmeta.venda-ant
                                 +(tt-tbmeta.venda-ant * tt-tbmeta.perc / 100).
    
    assign tt-tbmeta.percent-dif = (100 - ((tt-tbmeta.venda-atu * 100)
                                            / tt-tbmeta.venda-met))
                                            * - 1.

end.

pause 0 no-message.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else do:
        find tt-tbmeta where recid(tt-tbmeta) = recatu1 no-lock.
        
        find first clase where clase.clacod = tt-tbmeta.cla-cod
                           and clase.clagrau = 1  no-lock no-error.

    end.    
    if not available tt-tbmeta
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-tbmeta).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-tbmeta
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
            find tt-tbmeta where recid(tt-tbmeta) = recatu1 no-lock.
            
            find first clase where clase.clacod = tt-tbmeta.cla-cod
                               and clase.clagrau = 1 
                                            no-lock no-error.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-tbmeta.perc)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-tbmeta.perc)
                                        else "".
            run color-message.
            choose field tt-tbmeta.cla-cod help ""
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
                    if not avail tt-tbmeta
                    then leave.
                    recatu1 = recid(tt-tbmeta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-tbmeta
                    then leave.
                    recatu1 = recid(tt-tbmeta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-tbmeta
                then next.
                color display white/red tt-tbmeta.cla-cod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-tbmeta
                then next.
                color display white/red tt-tbmeta.cla-cod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-tbmeta.etbcod   label "Estab" skip
                 tt-tbmeta.ano       skip
                 tt-tbmeta.mes       skip
                 tt-tbmeta.cla-cod  format ">>>>>>>>9"  
                 bclase.clanome  colon 40  no-label format "x(25)"  skip
                 tt-tbmeta.perc    format ">>.99%"    skip
                 with frame f-tt-tbmeta color black/cyan
                      centered side-label row 5 3 column.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-02 on error undo.
                    create tt-tbmeta.
                    assign tt-tbmeta.etbcod = setbcod-aux
                           tt-tbmeta.mes    = vmes 
                           tt-tbmeta.ano = vano
                           tt-tbmeta.datcad = today. 
                    

                    display tt-tbmeta.etbcod skip
                            tt-tbmeta.ano skip
                            tt-tbmeta.mes
                            vdesmes[vmes] no-label skip
                            with frame f02.
                    do on error undo, retry:
    
                        assign vcla-meta = tt-tbmeta.cla-cod.

                        update vcla-meta
                             with frame f02.
                        
                        assign tt-tbmeta.cla-cod = vcla-meta.
                        
                        find first bclase where bclase.clacod = tt-tbmeta.cla-cod
                                        and bclase.clatipo = yes
                                        and bclase.clagrau = 1
                                                  no-lock no-error.
                                                  
                        if not avail bclase
                            or not can-find(first claseaux
                                      where claseaux.clacod = tt-tbmeta.cla-cod
                                        and claseaux.cadmeta = yes)
                        then do:
                                                  
                            message "Setor inválido(" tt-tbmeta.cla-cod "),"                                          "pressione F7 e selecione"
                                    " um setor entre os disponíveis. "
                                                view-as alert-box.
                                    
                            undo, retry.
                            
                        end.                          
                    end.                              
                    display bclase.clanome when avail bclase
                                 with frame f02.                   

                    update tt-tbmeta.perc                 skip
                             with frame f02.
                    
                    create tbmeta.
                    buffer-copy tt-tbmeta to tbmeta.
                    
                    recatu1 = recid(tt-tbmeta).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f02.

                    assign vcla-meta = tt-tbmeta.cla-cod.

                    display tt-tbmeta.etbcod
                            tt-tbmeta.ano
                            tt-tbmeta.mes
                            vcla-meta
                            tt-tbmeta.perc.
                            
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f02 on error undo.
                    find tt-tbmeta where
                            recid(tt-tbmeta) = recatu1 
                        exclusive.
                        
                    

                    display tt-tbmeta.etbcod skip
                            tt-tbmeta.ano skip
                            tt-tbmeta.mes  skip.
                            
                    do on error undo, retry:
    
                        assign vcla-meta = tt-tbmeta.cla-cod.

                        update vcla-meta.              
                        
                        assign tt-tbmeta.cla-cod = vcla-meta.
       
                        find first bclase where bclase.clacod = tt-tbmeta.cla-cod
                                        and bclase.clatipo = yes
                                        and bclase.clagrau = 1
                                                  no-lock no-error.
                                                  
                        if not avail bclase
                        then do:
                                                  
                            message "Setor inválido(" tt-tbmeta.cla-cod "),"      ~                                    "pressione F7 e selecione"
                                    " um setor entre os disponíveis. "
                                                view-as alert-box.
                                    
                            undo, retry.
                            
                        end.                          
                    end.                              
                    display bclase.clanome when avail bclase.

                    update tt-tbmeta.perc skip.
                    
                    find first tbmeta where rowid(tbmeta) = tt-tbmeta.rowid
                                        exclusive-lock.
                                        
                    buffer-copy tt-tbmeta to tbmeta.                    
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-tbmeta.perc
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-tbmeta where true no-error.
                    if not available tt-tbmeta
                    then do:
                        find tt-tbmeta where recid(tt-tbmeta) = recatu1.
                        find prev tt-tbmeta where true no-error.
                    end.
                    recatu2 = if available tt-tbmeta
                              then recid(tt-tbmeta)
                              else ?.
                    find tt-tbmeta where recid(tt-tbmeta) = recatu1
                            exclusive.
                    
                    find tbmeta where rowid(tbmeta) = tt-tbmeta.rowid                             exclusive-lock.
                    
                    delete tbmeta.
                    delete tt-tbmeta.
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
                    then run ltt-tbmeta.p (input 0).
                    else run ltt-tbmeta.p (input tt-tbmeta.cla-cod).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = " Acoes "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    
                    run marca_acoes.p(input tt-tbmeta.rowid).
                    
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                if esqcom2[esqpos2] = " Acumulado "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    
                    run p-acumulado.

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
        recatu1 = recid(tt-tbmeta).
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
display tt-tbmeta.cla-cod format ">>>>>>>>9"
        clase.clanom format "x(23)"
        tt-tbmeta.perc format ">>9.99%"   column-label "%Meta"
        tt-tbmeta.venda-atu  format ">,>>>,>>9.99"
        tt-tbmeta.venda-met format ">,>>>,>>9.99" column-label "Meta"
        tt-tbmeta.percent-dif column-label "%Cresc." format "+>,>>9.99%"
        with frame frame-a 11 down centered color white/red row 5.

assign vcha-label-aux = substring(vdesmes[tt-tbmeta.mes],1,3)
                            + "/" + string(tt-tbmeta.ano).

run troca-label(input tt-tbmeta.venda-atu:handle,
                input vcha-label-aux).
           
end procedure.
procedure color-message.
color display message
        tt-tbmeta.cla-cod
        clase.clanom
        tt-tbmeta.perc
        tt-tbmeta.venda-atu
        tt-tbmeta.venda-met
        tt-tbmeta.percent-dif
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-tbmeta.cla-cod
        clase.clanom
        tt-tbmeta.perc
        tt-tbmeta.venda-atu
        tt-tbmeta.venda-met
        tt-tbmeta.percent-dif
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-tbmeta where tt-tbmeta.etbcod = setbcod-aux
                            and tt-tbmeta.ano = vano
                                    use-index idx-perc no-lock no-error.
    else  
        find last tt-tbmeta  where tt-tbmeta.etbcod = setbcod-aux
                            and tt-tbmeta.ano = vano
                                    use-index idx-perc no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-tbmeta  where tt-tbmeta.etbcod = setbcod-aux
                            and tt-tbmeta.ano = vano
                                    use-index idx-perc no-lock no-error.
    else  
        find prev tt-tbmeta   where tt-tbmeta.etbcod = setbcod-aux
                             and tt-tbmeta.ano = vano
                                    use-index idx-perc no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-tbmeta where tt-tbmeta.etbcod = setbcod-aux
                           and tt-tbmeta.ano = vano
                                        use-index idx-perc no-lock no-error.
    else   
        find next tt-tbmeta where tt-tbmeta.etbcod = setbcod-aux
                           and tt-tbmeta.ano = vano
                                        use-index idx-perc no-lock no-error.
       
find first clase where clase.clacod = tt-tbmeta.cla-cod 
                   and clase.clagrau = 1 no-lock no-error.        
        
end procedure.
         
         
         
procedure p-acumulado:

    def var vint-conta-perc      as integer.
    def var vint-conta-perc-1s   as integer.
    def var vint-conta-perc-2s   as integer.


/************* Agrupa todos os valores por depto ***************/


    def var vcont-perc-31-ano     as integer. 
    def var vperc-med-31-ano      as decimal.       
    def var vvenda-atu-31-ano     as decimal.
    def var vvenda-met-31-ano     as decimal. 
    def var vpercent-dif-31-ano   as decimal.
    
    def var vcont-perc-41-ano     as integer.
    def var vperc-med-41-ano      as decimal.
    def var vvenda-atu-41-ano     as decimal.
    def var vvenda-met-41-ano     as decimal.
    def var vpercent-dif-41-ano   as decimal.
    


    def var vcont-perc-31-1s     as integer.
    def var vperc-med-31-1s      as decimal.       
    def var vvenda-atu-31-1s     as decimal.
    def var vvenda-met-31-1s     as decimal. 
    def var vpercent-dif-31-1s   as decimal.
    
    def var vcont-perc-41-1s     as integer.
    def var vperc-med-41-1s      as decimal.
    def var vvenda-atu-41-1s     as decimal.
    def var vvenda-met-41-1s     as decimal.
    def var vpercent-dif-41-1s   as decimal.
    


    def var vcont-perc-31-2s     as integer.
    def var vperc-med-31-2s      as decimal.       
    def var vvenda-atu-31-2s     as decimal.
    def var vvenda-met-31-2s     as decimal. 
    def var vpercent-dif-31-2s   as decimal.
    
    def var vcont-perc-41-2s     as integer.
    def var vperc-med-41-2s      as decimal.
    def var vvenda-atu-41-2s     as decimal.
    def var vvenda-met-41-2s     as decimal.
    def var vpercent-dif-41-2s   as decimal.
    

    message "Gerando a estrutura de classes e Calculando as vendas...".

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cadmeta2." + string(time).
    else varquivo = "l:\relat\cadmeta2." + string(time).
            
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""CADMETA2""
                &Nom-Sis   = """CADASTRO DE METAS"""
                &Tit-Rel   = """ACUMULADO ANUAL DE METAS """
                &Width     = "200"
                &Form      = "frame f-cabcab"}

for each tt-cla no-lock.

    find first tt-tbmeta where tt-tbmeta.cla-cod = tt-cla.clasup
                                    exclusive-lock no-error.

    for each produ where produ.catcod = tt-tbmeta.catcod
                     and produ.clacod = tt-cla.cla-cod no-lock,
    
        each movim where movim.etbcod = setbcod-aux
                     and movim.movtdc = 5
                     and movim.procod = produ.procod
                     and movim.movdat >= date(01,01,year(vdti-ant))
                     and movim.movdat <= date(12,31,year(vdtf-ant)) no-lock:
                     
        assign tt-tbmeta.venda-ant-acum = tt-tbmeta.venda-ant-acum
                                            + (movim.movpc * movim.movqtm).

        if month(movim.movdat) <= 6
        then
        assign tt-tbmeta.venda-ant-1s = tt-tbmeta.venda-ant-1s
                                            + (movim.movpc * movim.movqtm).
        else                                
        assign tt-tbmeta.venda-ant-2s = tt-tbmeta.venda-ant-2s
                                            + (movim.movpc * movim.movqtm).

    
    end.

    for each produ where produ.catcod = tt-tbmeta.catcod
                     and produ.clacod = tt-cla.cla-cod no-lock,
    
        each movim where movim.etbcod = setbcod-aux
                     and movim.movtdc = 5
                     and movim.procod = produ.procod
                     and movim.movdat >= date(01,01,year(vdti))
                     and movim.movdat <= vdtf no-lock:
                     
        assign tt-tbmeta.venda-atu-acum = tt-tbmeta.venda-atu-acum
                                          + (movim.movpc * movim.movqtm).

        if month(movim.movdat) <= 6
        then
        assign tt-tbmeta.venda-atu-1s = tt-tbmeta.venda-atu-1s
                                          + (movim.movpc * movim.movqtm).
        else
        assign tt-tbmeta.venda-atu-2s = tt-tbmeta.venda-atu-2s
                                          + (movim.movpc * movim.movqtm).

    
    
    end.

end.

assign vint-conta-perc = 0
       vint-conta-perc-1s = 0
       vint-conta-perc-2s = 0.

for each tt-tbmeta exclusive-lock,

    each ctbmeta where ctbmeta.etbcod  = tt-tbmeta.etbcod
                   and ctbmeta.ano     = tt-tbmeta.ano
                   and ctbmeta.cla-cod = tt-tbmeta.cla-cod
                             no-lock break by tt-tbmeta.cla-cod.

    if first-of(tt-tbmeta.cla-cod)
    then assign vint-conta-perc = 0
                vint-conta-perc-1s = 0
                vint-conta-perc-2s = 0.

    if ctbmeta.mes <= 6
    then assign vint-conta-perc-1s = vint-conta-perc-1s + 1
                tt-tbmeta.perc-med-1s = tt-tbmeta.perc-med-1s
                                                + ctbmeta.perc.
                                                
    else assign vint-conta-perc-2s = vint-conta-perc-2s + 1
                tt-tbmeta.perc-med-2s = tt-tbmeta.perc-med-2s
                                                + ctbmeta.perc.

    assign tt-tbmeta.perc-med = tt-tbmeta.perc-med + ctbmeta.perc
           vint-conta-perc    = vint-conta-perc + 1.

    if last-of(tt-tbmeta.cla-cod) 
    then
    assign
      tt-tbmeta.perc-med = round((tt-tbmeta.perc-med / vint-conta-perc),2)
   tt-tbmeta.perc-med-1s = round((tt-tbmeta.perc-med-1s / vint-conta-perc-1s),2)
   tt-tbmeta.perc-med-2s = round((tt-tbmeta.perc-med-2s / vint-conta-perc-2s),2)
                      .
end.

for each tt-tbmeta exclusive-lock.


    assign tt-tbmeta.venda-met-acum = tt-tbmeta.venda-ant-acum
                  +(tt-tbmeta.venda-ant-acum * tt-tbmeta.perc-med / 100).
    
    assign tt-tbmeta.percent-dif-acum = (100 - ((tt-tbmeta.venda-atu-acum * 100)
                                            / tt-tbmeta.venda-met-acum))
                                            * - 1.



    assign tt-tbmeta.venda-met-1s = tt-tbmeta.venda-ant-1s
                  +(tt-tbmeta.venda-ant-1s * tt-tbmeta.perc-med-1s / 100).
    
    assign tt-tbmeta.percent-dif-1s = (100 - ((tt-tbmeta.venda-atu-1s * 100)
                                            / tt-tbmeta.venda-met-1s))
                                            * - 1.


    
    assign tt-tbmeta.venda-met-2s = tt-tbmeta.venda-ant-2s
                  +(tt-tbmeta.venda-ant-2s * tt-tbmeta.perc-med-2s / 100).
    
    assign tt-tbmeta.percent-dif-2s = (100 - ((tt-tbmeta.venda-atu-2s * 100)
                                            / tt-tbmeta.venda-met-2s))
                                            * - 1.

end.

run p-carrega-tt-ac.

for each tt-tbmeta no-lock,

    first clase where clase.clacod = tt-tbmeta.cla-cod
                  and clase.clagrau = 1 no-lock break by tt-tbmeta.catcod.
    
    display tt-tbmeta.cla-cod  format ">>>>>>>>9"
            clase.clanom format "x(20)"
            tt-tbmeta.catcod format ">9" column-label "Dep"
            tt-tbmeta.perc-med format ">>>>.99%"   column-label "%Medio Meta"
            tt-tbmeta.venda-atu-acum   format ">>,>>>,>>9.99"
            tt-tbmeta.venda-met-acum format ">>,>>>,>>9.99"
                                    column-label "Meta Acum"
            tt-tbmeta.percent-dif-acum
                                column-label "%Cresc." format "+>,>>9.99%"
            "|"  column-label "|"                   
                                
            tt-tbmeta.perc-med-1s format ">>>>.99%" 
                                        column-label "%Medio Meta 1º Sem"
            tt-tbmeta.venda-atu-1s   format ">>,>>>,>>9.99"
                                column-label "1º Sem" 
            tt-tbmeta.venda-met-1s format ">>,>>>,>>9.99"
                                    column-label "Meta Acum 1º Sem"
            tt-tbmeta.percent-dif-1s
                             column-label "%Cresc. 1º Sem" format "+>,>>9.99%"
                                
            "|" column-label "|"                   
                                
            tt-tbmeta.perc-med-2s format ">>>>.99%"
                column-label "%Medio Meta" when tt-tbmeta.perc-med-2s > 0
            tt-tbmeta.venda-atu-2s   format ">>,>>>,>>9.99"
                column-label "2º Sem" when tt-tbmeta.venda-atu-2s > 0                      tt-tbmeta.venda-met-2s format ">>,>>>,>>9.99"
                column-label "Meta Acum" when tt-tbmeta.venda-met-2s > 0                     tt-tbmeta.percent-dif-2s
                 when tt-tbmeta.percent-dif-2s > 0 
                     column-label "%Cresc." format "+>,>>9.99%"
                                
                    with frame f-relat down
                    centered color white/red row 5 width 205.

    run troca-label(input tt-tbmeta.venda-atu-acum:handle,
                    input "  Acum " + string(tt-tbmeta.ano)).
                    
                    
                    
                    

end.
/*
display
    fill("=",95) format "x(95)" no-label
    "Totais"
    fill("=",95) format "x(95)" no-label
with frame f-relat-separador down
                      centered color white/red row 5 width 205.
*/
                      
display skip(1)
         with frame f-relat-separador down
                       centered color white/red row 5 width 205.



for each tt-ac no-lock:

    display tt-ac.catcod format ">>>>>>>>9" column-label "Depto"
            tt-ac.perc-med-ano  format ">,>>9.99%" column-label "%Medio Meta"    
            tt-ac.venda-atu-ano format ">,>>>,>>>,>>9.99"   
            tt-ac.venda-met-ano format ">,>>>,>>>,>>9.99"
                                    column-label "Meta Acum"   
            tt-ac.percent-dif-ano   format "+>>,>>9.99%"
                                    column-label "%Cresc."

            "|" column-label "|"
            
            tt-ac.perc-med-1s  format ">,>>9.99%" column-label "%Meta 1ºS"
            tt-ac.venda-atu-1s format ">,>>>,>>>,>>9.99" column-label "Venda 1ºS"
            tt-ac.venda-met-1s format ">,>>>,>>>,>>9.99" column-label "Meta 1ºS"
            tt-ac.percent-dif-1s   format "+>>,>>9.99%"
                                    column-label "%Cresc."
                                      
            "|" column-label "|"
            
            tt-ac.perc-med-2s  format ">,>>9.99%" column-label "%Meta 2ºS"
                    when tt-ac.perc-med-2s > 0
           tt-ac.venda-atu-2s format ">,>>>,>>>,>>9.99" column-label "Venda 2ºS"
                    when tt-ac.venda-atu-2s > 0
            tt-ac.venda-met-2s format ">,>>>,>>>,>>9.99" column-label "Meta 2ºS"
                    when tt-ac.venda-met-2s > 0
            tt-ac.percent-dif-2s   format "+>>,>>9.99%"
                    when tt-ac.percent-dif-2s > 0
                                    column-label "%Cresc." skip

             with frame f-relat-acum down
                      centered color white/red row 5 width 205.

    run troca-label(input tt-ac.venda-atu-ano:handle,
                    input "     Acum " + string(vano)).
                        
end.    
    
   /* 
    run troca-label(input tt-tbmeta.venda-atu-acum:handle,
                    input "  Acum " + string(tt-tbmeta.ano)).
                    
    */



output close.
             
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else {mrod.i}.
         
end procedure.         



procedure p-carrega-tt-ac.


for each tt-tbmeta no-lock,

    first clase where clase.clacod = tt-tbmeta.cla-cod
                  and clase.clagrau = 1 no-lock.
    
    find first tt-ac where tt-ac.catcod = tt-tbmeta.catcod
                        exclusive-lock no-error.
    if not avail tt-ac
    then create tt-ac.
        
    assign
    tt-ac.catcod          = tt-tbmeta.catcod
    tt-ac.cont-perc-ano   = tt-ac.cont-perc-ano + 1
    tt-ac.perc-med-ano    = tt-ac.perc-med-ano + tt-tbmeta.perc-med
    tt-ac.venda-atu-ano   = tt-ac.venda-atu-ano + tt-tbmeta.venda-atu-acum
    tt-ac.venda-met-ano   = tt-ac.venda-met-ano + tt-tbmeta.venda-met-acum
    
    tt-ac.cont-perc-1s    = tt-ac.cont-perc-1s + 1
    tt-ac.perc-med-1s     = tt-ac.perc-med-1s + tt-tbmeta.perc-med-1s
    tt-ac.venda-atu-1s    = tt-ac.venda-atu-1s + tt-tbmeta.venda-atu-1s
    tt-ac.venda-met-1s    = tt-ac.venda-met-1s + tt-tbmeta.venda-met-1s
                             
    tt-ac.cont-perc-2s    = tt-ac.cont-perc-2s + 1
    tt-ac.perc-med-2s     = tt-ac.perc-med-2s + tt-tbmeta.perc-med-2s
    tt-ac.venda-atu-2s    = tt-ac.venda-atu-2s + tt-tbmeta.venda-atu-2s
    tt-ac.venda-met-2s    = tt-ac.venda-met-2s + tt-tbmeta.venda-met-2s.

end.

for each tt-ac exclusive-lock:

    assign tt-ac.percent-dif-ano = (100 - ((tt-ac.venda-atu-ano * 100)
                                 / tt-ac.venda-met-ano))
                                            * - 1
            
           tt-ac.percent-dif-1s  = (100 - ((tt-ac.venda-atu-1s * 100)
                                 / tt-ac.venda-met-1s))
                                            * - 1
                           
           tt-ac.percent-dif-2s  = (100 - ((tt-ac.venda-atu-2s * 100)
                                        / tt-ac.venda-met-2s))
                                            * - 1.

    assign tt-ac.perc-med-ano = tt-ac.perc-med-ano / tt-ac.cont-perc-ano
           tt-ac.perc-med-1s = tt-ac.perc-med-1s / tt-ac.cont-perc-1s 
           tt-ac.perc-med-2s = tt-ac.perc-med-2s / tt-ac.cont-perc-2s.

end.


end procedure.


                                                                                  
