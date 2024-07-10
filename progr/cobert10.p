{admcab.i}

{setbrw.i}

define            variable vmes  as char format "x(05)" extent 13 initial
    ["  JAN","  FEV","  MAR","  ABR","  MAI","  JUN",
     "  JUL","  AGO","  SET","  OUT","  NOV","  DEZ", "TOTAL"].
form
    with frame f-comp centered overlay row 19 no-box.
    
def var vmes2 as char format "x(05)" extent 13.

def var vaux        as int.
def var vano        as int.
def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.
def var vtotcomp    like himov.himqtm extent 13.

def var vqtdped as int.
def var vfabcod like produ.fabcod.
def var vdias as int format ">>>9" label "Dias de Analise" initial 90.
def var vdata1 as date format "99/99/9999" label "Periodo de Analise".
vdata1 = today - 90.
def var vdata2 as date format "99/99/9999".
vdata2 = today.

def var vcobertura as int format ">>>9" label "Cobertura".

def var vestdep like estoq.estatual.
def var vprocod like produ.procod.
def var vclacod like clase.clacod.
def var vqtd    like movim.movqtm.
def var vqtdest like movim.movqtm.
def var vqtdtot like movim.movqtm.
def var totven  like movim.movqtm.
def var vdata   like plani.pladat.
def var totper  like estoq.estatual.
def var totdis  like estoq.estatual.
def var totdisest like estoq.estatual.

def var varquivo as char format "x(20)".
def var ii as int. 
def var i as int.

def temp-table tt-estab
    field etbcod    like estab.etbcod
    field proper    like distr.proper
    field estatual  like estoq.estatual
    field qtddis    like estoq.estatual
    field qtdven    like estoq.estatual
    field qtddisest like estoq.estatual
    field cobert    as int    
    index ind-1 proper.

def temp-table tt-pro
    field procod  like produ.procod
    field pronom  like produ.pronom
    field fabcod  like fabri.fabcod
    field fabnom  like fabri.fabnom
    field estdep  like vestdep
    field totven  like totven
    field cober     as   int
    field pcvenda like estoq.estvenda
    field pccusto like estoq.estcusto
    field qtdest  as int
    field qtdped  as int
    /*index iprocod procod
    index icober cober */
    index ipronom pronom.

form
    tt-pro.procod                label "Codigo" format ">>>>>9"
    tt-pro.pronom format "x(20)" label "Produto"
    tt-pro.fabnom format "x(10)" label "Fabricante"
    tt-pro.estdep                column-label "E.Dep" format "->>>9"
    tt-pro.totven                column-label "Q.Ven"  format ">>>>9"
    tt-pro.cober                 column-label "Cober" format ">>>>9"
    tt-pro.pcvenda               column-label "P.Ven" format ">,>>9"
    tt-pro.pccusto               column-label "P.Cus" format ">,>>9"
    tt-pro.qtdest                column-label "E.Loj" format "->>>9"
    tt-pro.qtdped                column-label "Q.Ped" format ">>>>9"
    with frame frame-a row 8 8 down overlay no-box width 81.
    
form
    estoq.etbcod                 column-label "Estab"
    tt-pro.procod                column-label "Codigo" format ">>>>>9"
    tt-pro.pronom                column-label "Produto"
    estoq.estatual               column-label "Estoq!Atual" format "->>>>9"   
    with frame f-est.
    

repeat:
                  
    assign vqtd    = 0
           vprocod = 0
           vclacod = 0
           totven  = 0.
           
    for each tt-pro:
        delete tt-pro.  
    end.

    hide frame f-linha1 no-pause.
    hide frame f-comp no-pause.    
    update vfabcod at 2 label "Fabricante" with frame f1 side-label width 80.
    if vfabcod <> 0
    then do:
        find fabri where fabri.fabcod = vfabcod no-lock.
        display fabri.fabnom format "x(20)" no-label with frame f1.
    end.
    else disp "Todos" @ fabri.fabnom format "x(20)" with frame f1.

    update vclacod label "Classe" with frame f1.
    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(20)" no-label with frame f1.
    end.
    else disp "Todas" @ clase.clanom with frame f1.
        
    update vcobertura at 3  
           /*vdias to 50*/ space(3)
           vdata1                  " a "
           vdata2 no-label
           with frame f1.
    
    vdias = 0.
    vdias = (vdata2 - vdata1) + 1.
    

    disp "(" + string(vdias) + " Dias)" no-label format "x(12)" with frame f1.
    
    if vfabcod <> 0
    then do:
    
        for each produ where produ.fabcod = vfabcod /*and
                             produ.procod <= 3052 */ no-lock:
            if vclacod <> 0
            then if produ.clacod <> clase.clacod
                 then next.
                 
            
            vestdep = 0.
            for each estoq where (estoq.etbcod >= 900 or  
                                 {conv_igual.i estoq.etbcod}) and            
                                 estoq.procod = produ.procod no-lock:
                vestdep = vestdep + estoq.estatual.
            end.                           

            totven = 0.                       
            do vdata = vdata1 to vdata2:
                for each movim where movim.procod = produ.procod     and
                                         movim.movtdc = 05           and
                                         movim.movdat = vdata no-lock:
                    totven = totven + movim.movqtm.                         
                end.
            end.                                               
            

            if int((vestdep * vdias) / totven) > vcobertura
            then next. 
            
            vqtdest = 0.
            for each estoq where estoq.etbcod < 90  and
                                 estoq.etbcod <> 22 and
                                {conv_difer.i estoq.etbcod} and
                                 estoq.procod = produ.procod no-lock:
                
                vqtdest = vqtdest + estoq.estatual.  
            
            end.        
            vqtdped = 0.        
            do vdata = today - 365 to today:
                for each liped where liped.pedtdc = 1
                                 and liped.procod = produ.procod
                                 and liped.predt  = vdata no-lock:
                    find pedid of liped no-lock  no-error.             

                    if pedid.sitped = "F" then next.
                    
                    vqtdped = vqtdped + (liped.lipqtd - liped.lipent).
                    
                end.
            end.                 

            if vqtdped <= 0 and
               totven <= 0 
            then next.   

            disp produ.procod no-label produ.pronom no-label
                    with centered side-labels 1 down. pause 0.

            find tt-pro where tt-pro.procod = produ.procod no-error.
            if not avail tt-pro
            then do:
                find first estoq of produ no-lock.
                
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                
                create tt-pro.
                assign tt-pro.procod = produ.procod
                       tt-pro.pronom = produ.pronom
                       tt-pro.fabcod = produ.fabcod
                       tt-pro.fabnom = if avail fabri
                                       then fabri.fabnom
                                       else "Nao Cadastrado"
                       tt-pro.estdep = vestdep
                       tt-pro.totven = totven
                       tt-pro.cober    = 
                           int((vestdep * vdias) / totven)
                       tt-pro.pcvenda = estoq.estvenda
                       tt-pro.pccusto = estoq.estcusto
                       tt-pro.qtdest  = vqtdest
                       tt-pro.qtdped  = vqtdped.
            
            end.
        end.         
    end.
    else do:
    
        for each produ no-lock:

            if vclacod <> 0
            then if produ.clacod <> clase.clacod
                 then next.

            vestdep = 0.
            for each estoq where (estoq.etbcod >= 900 or
                                {conv_igual.i estoq.etbcod}) and
                                 estoq.procod = produ.procod no-lock:
                vestdep = vestdep + estoq.estatual.
            end.                           

            totven = 0.                       
            do vdata = vdata1 to vdata2:
                for each movim where movim.procod = produ.procod     and
                                         movim.movtdc = 05           and
                                         movim.movdat = vdata no-lock:
                    totven = totven + movim.movqtm.                         
                end.
            end.                                               
            
            /*if vestdep <= 0 and
               totven <= 0 
            then next.*/   

            if int((vestdep * vdias) / totven) > vcobertura
            then next. 
            
            vqtdest = 0.
            for each estoq where estoq.etbcod < 900  and
                                 estoq.etbcod <> 22 and
                                 {conv_difer.i estoq.etbcod} and
                                 estoq.procod = produ.procod no-lock:
                
                vqtdest = vqtdest + estoq.estatual.  
            
            end.      
              
            vqtdped = 0.        
            do vdata = today - 365 to today:
                for each liped where liped.pedtdc = 1
                                 and liped.procod = produ.procod
                                 and liped.predt  = vdata no-lock:
                    find pedid of liped no-lock  no-error.             

                    if pedid.sitped = "F" then next.
                    
                    vqtdped = vqtdped + (liped.lipqtd - liped.lipent).
                    
                end.
            end.                 

            if vqtdped <= 0 and
               totven <= 0 
            then next.   

            disp produ.procod no-label produ.pronom no-label
                    with centered side-labels 1 down. pause 0.

            find tt-pro where tt-pro.procod = produ.procod no-error.
            if not avail tt-pro
            then do:
                find first estoq of produ no-lock.
                
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                
                create tt-pro.
                assign tt-pro.procod = produ.procod
                       tt-pro.pronom = produ.pronom
                       tt-pro.fabcod = produ.fabcod
                       tt-pro.fabnom = if avail fabri
                                       then fabri.fabnom
                                       else "Nao Cadastrado"
                       tt-pro.estdep = vestdep
                       tt-pro.totven = totven
                       tt-pro.cober    = 
                           int((vestdep * vdias) / totven)
                       tt-pro.pcvenda = estoq.estvenda
                       tt-pro.pccusto = estoq.estcusto
                       tt-pro.qtdest  = vqtdest
                       tt-pro.qtdped  = vqtdped.
            
            end.
        end.         
    end.

find first tt-pro no-lock no-error.
if not avail tt-pro
then do:
    message "Nao foram encontrados produtos nesta situacao".
    undo.
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Estoque "," Pedidos ", " Notas "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["  ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer btt-pro       for tt-pro.
def var vtt-pro         like tt-pro.procod.


form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-pro where recid(tt-pro) = recatu1 no-lock.
    if not available tt-pro
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-pro).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-pro
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
            find tt-pro where recid(tt-pro) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-pro.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-pro.procod)
                                        else "".
            run compras.
            run color-message.

            choose field tt-pro.procod help ""
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
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pro
                then next.
                color display white/red tt-pro.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pro
                then next.
                color display white/red tt-pro.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-pro
                 with frame f-tt-pro color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Estoque " or esqvazio
                then do with frame f-tt-pro on error undo.

                   run procest9.p(input string(tt-pro.procod), input vdias).
                   
                end.
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pro.
                    disp tt-pro.
                end.

                if esqcom1[esqpos1] = " Pedidos "
                then do with frame f-tt-pro on error undo.
    
                    if tt-pro.qtdped <> 0
                    then do:
                        hide frame f-comp no-pause.
                        run coberped.p (input tt-pro.procod).
                    end.
                    
                end.
                
                if esqcom1[esqpos1] = " Notas "
                then do with frame f-tt-pro on error undo.

                     hide frame f-comp no-pause.
                     run cobernf.p (input tt-pro.procod).

                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-pro.procod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-pro where true no-error.
                    if not available tt-pro
                    then do:
                        find tt-pro where recid(tt-pro) = recatu1.
                        find prev tt-pro where true no-error.
                    end.
                    recatu2 = if available tt-pro
                              then recid(tt-pro)
                              else ?.
                    find tt-pro where recid(tt-pro) = recatu1
                            exclusive.
                    delete tt-pro.
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
                    then run ltt-pro.p (input 0).
                    else run ltt-pro.p (input tt-pro.procod).
                    leave.
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
        recatu1 = recid(tt-pro).
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
display 
    tt-pro.procod
    tt-pro.pronom
    tt-pro.fabnom
    tt-pro.estdep
    tt-pro.totven
    tt-pro.cober 
    tt-pro.pcvenda
    tt-pro.pccusto
    tt-pro.qtdest
    tt-pro.qtdped
        with frame frame-a .
end procedure.
procedure color-message.
color display message
      tt-pro.procod
      tt-pro.pronom
      tt-pro.fabnom
      tt-pro.estdep
      tt-pro.totven
      tt-pro.cober
      tt-pro.pcvenda
      tt-pro.pccusto
      tt-pro.qtdest
      tt-pro.qtdped
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-pro.procod
        tt-pro.pronom
        tt-pro.fabnom
        tt-pro.estdep
        tt-pro.totven
        tt-pro.cober
        tt-pro.pcvenda
        tt-pro.pccusto
        tt-pro.qtdest
        tt-pro.qtdped
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-pro where true
                                                no-lock no-error.
    else  
        find last tt-pro  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-pro  where true
                                                no-lock no-error.
    else  
        find prev tt-pro   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-pro where true  
                                        no-lock no-error.
    else   
        find next tt-pro where true 
                                        no-lock no-error.
        
end procedure.
         
procedure compras.

    vaux = 0. vano = 0.
    vaux    = month(today).
    vano    = year(today).
    do i = 1 to 12:
        vaux = vaux - 1.
        if vaux = 0
        then do:
            vmes2[i] = "DEZ".
            vaux = 12.
            vano = vano - 1.
        end.
        vmes2[i] = vmes[vaux].
        vnummes[i] = vaux.
        vnumano[i] = vano.
    end.
    vmes2[13] = "TOTAL".       
    disp
    vmes2[1] no-label space(1)
    vmes2[2] no-label space(1)
    vmes2[3] no-label space(1)
    vmes2[4] no-label space(1)
    vmes2[5] no-label space(1)
    vmes2[6] no-label space(1)
    vmes2[7] no-label space(1)
    vmes2[8] no-label space(1)
    vmes2[9] no-label space(1)
    vmes2[10] no-label space(1)
    vmes2[11] no-label space(1)
    vmes2[12] no-label space(1) 
    vmes2[13] no-label space(1)
    with frame f-comp
    /*title     " C O M P R A  M E S E S  A N T E R I O R E S "*/.

    for each produ where produ.procod = tt-pro.procod no-lock:
    vtotcomp[13] = 0.
    do i = 1 to 12: 
        vtotcomp[i] = 0.
    
        for each estab where estab.etbcod >= 94 no-lock:

            if estab.etbcon >= 900 and estab.etbcod < 994 then next. 
            
            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]   and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.
            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            vtotcomp[13] = vtotcomp[13] + himov.himqtm.
        end.
    
    end.

    disp
        vtotcomp[1] format ">>>>9" no-label
        vtotcomp[2] format ">>>>9" no-label
        vtotcomp[3] format ">>>>9" no-label
        vtotcomp[4] format ">>>>9" no-label
        vtotcomp[5] format ">>>>9" no-label
        vtotcomp[6] format ">>>>9" no-label
        vtotcomp[7] format ">>>>9" no-label
        vtotcomp[8] format ">>>>9"  no-label
        vtotcomp[9] format ">>>>9"  no-label
        vtotcomp[10] format ">>>>9" no-label
        vtotcomp[11] format ">>>>9" no-label
        vtotcomp[12] format ">>>>9" no-label 
        vtotcomp[13] format ">>>>9" no-label with frame f-comp.
   
   
   
   end.
   /*do on endkey undo.
       if keyfunction(lastkey) = "end-error"
       then do:
            hide frame f-comp no-pause.
            next.
       end.
       pause.
       hide frame f-comp no-pause.
       next .
   end.
     */
end procedure.