/*
*
*    tt-filial.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-filial
                          fil
*
*/
function troca-label returns character
    (input par-handle as handle,
     input par-label as char).
         
         
    if par-label = "NO-LABEL"
    then par-handle:label   = ?.
    else par-handle:label   = par-label.
                     
end function.


def var vestab-cod as integer.
def var vmes1      as integer.

def var vdtini        as date.
def var vdtfim        as date.

assign vdtfim = date(month(today),01,year(today)) - 1.
   
if (month(vdtfim)) >= 3
then assign vdtini = date(month(vdtfim) - 2,01,year(vdtfim)).
else assign vdtini = date(month(vdtfim) + 10,01,year(vdtfim) - 1).

assign vmes1 = month(vdtini).


def temp-table tt-filial
    field filcod         as integer
    field filnom         as character
    field mes1           as character
    field qtd-mes1       as integer 
    field qtd-mes2       as integer 
    field qtd-mes3       as integer 
    field media          as integer
    field qtd-mes-atual  as integer
    field total          as integer
    index idx01 is primary unique filcod.


def buffer btt-filial for tt-filial.



form tt-filial.filcod     label "Fil"         format ">>9"
     tt-filial.filnom     label "Nome"        format "x(18)"
     tt-filial.qtd-mes1   label "xxxxxxxxx"   format ">>>>>>>>9"  
     tt-filial.qtd-mes2   label "xxxxxxxxx"   format ">>>>>>>>9"
     tt-filial.qtd-mes3   label "xxxxxxxxx"   format ">>>>>>>>9"      
     tt-filial.media      label "Media"       format ">>>>9"
     tt-filial.qtd-mes-atual label "Mes Atual" format ">>>>>>>>9"
     with frame frame-a.

    /*

form tt-filial.filcod     label "Fil"         format ">>9"
     tt-filial.filnom     label "Nome"        format "x(18)"
     tt-filial.qtd-mes1   label "xxxxxxxxx"   format ">>>>>>>>9"  
     tt-filial.qtd-mes2   label "xxxxxxxxx"   format ">>>>>>>>9"
     tt-filial.qtd-mes3   label "xxxxxxxxx"   format ">>>>>>>>9"      
     tt-filial.media      label "Media"       format ">>>>9"
     tt-filial.qtd-mes-atual label "Mes Atual" format ">>>>>>>>9"
     with frame frame-b down.

     */
case (vmes1):

    when 1 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Janeiro").
        troca-label(tt-filial.qtd-mes2:handle , "Fevereiro").
        troca-label(tt-filial.qtd-mes3:handle , "Março").
    end.

    when 2 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Fevereiro").
        troca-label(tt-filial.qtd-mes2:handle , "Março").
        troca-label(tt-filial.qtd-mes3:handle , "Abril").
    end.
    
    when 3 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Março").
        troca-label(tt-filial.qtd-mes2:handle , "Abril").
        troca-label(tt-filial.qtd-mes3:handle , "Maio").
    end.

    when 4 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Abril").
        troca-label(tt-filial.qtd-mes2:handle , "Maio").
        troca-label(tt-filial.qtd-mes3:handle , "Junho").
    end.
    
    when 5 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Maio").
        troca-label(tt-filial.qtd-mes2:handle , "Junho").
        troca-label(tt-filial.qtd-mes3:handle , "Julho").
    end.
    

    when 6 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Junho").
        troca-label(tt-filial.qtd-mes2:handle , "Julho").
        troca-label(tt-filial.qtd-mes3:handle , "Agosto").
    end.
    

    when 7 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Julho").
        troca-label(tt-filial.qtd-mes2:handle , "Agosto").
        troca-label(tt-filial.qtd-mes3:handle , "Setembro").
    end.
    

    when 8 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Agosto").
        troca-label(tt-filial.qtd-mes2:handle , "Setembro").
        troca-label(tt-filial.qtd-mes3:handle , "Outubro").
    end.
    

    when 9 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Setembro").
        troca-label(tt-filial.qtd-mes2:handle , "Outubro").
        troca-label(tt-filial.qtd-mes3:handle , "Novembro").
    end.
    

    when 10 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Outubro").
        troca-label(tt-filial.qtd-mes2:handle , "Novembro").
        troca-label(tt-filial.qtd-mes3:handle , "Dezembro").
    end.
    

    when 11 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Novembro").
        troca-label(tt-filial.qtd-mes2:handle , "Dezembro").
        troca-label(tt-filial.qtd-mes3:handle , "Janeiro").
    end.
    

    when 12 then do:
        troca-label(tt-filial.qtd-mes1:handle , "Dezembro").
        troca-label(tt-filial.qtd-mes2:handle , "Janeiro").
        troca-label(tt-filial.qtd-mes3:handle , "Fevereiro").
    end.


end case.



def var vqtd-mes1     as integer.
def var vqtd-mes2     as integer.
def var vqtd-mes3     as integer.
def var vmedia-asstec as integer.
def var vqtde-asstec-atual  as integer.
def var vconta-asstec as integer.


update vestab-cod label "Informe a Filial"
        with frame f01 side-label.

if vestab-cod = 0
then do:

    for each estab where estab.etbcod < 900 no-lock:
    
        assign vqtd-mes1          = 0
               vqtd-mes2          = 0
               vqtd-mes3          = 0
               vmedia-asstec      = 0
               vqtde-asstec-atual = 0
               vconta-asstec      = 0.

        run p-calcula-os-filial (input estab.etbcod,
                                 output vqtd-mes1,
                                 output vqtd-mes2,
                                 output vqtd-mes3,
                                 output vconta-asstec,
                                 output vmedia-asstec,
                                 output vqtde-asstec-atual).
        
        create tt-filial.
        assign tt-filial.filcod        = estab.etbcod
               tt-filial.filnom        = estab.etbnom
               tt-filial.qtd-mes1      = vqtd-mes1
               tt-filial.qtd-mes2      = vqtd-mes2
               tt-filial.qtd-mes3      = vqtd-mes3
               tt-filial.media         = vmedia-asstec
               tt-filial.qtd-mes-atual = vqtde-asstec-atual.
        
    end.
    
end.
else do:

     assign vqtd-mes1          = 0
            vqtd-mes2          = 0
            vqtd-mes3          = 0
            vmedia-asstec      = 0
            vqtde-asstec-atual = 0
            vconta-asstec      = 0.

     find first estab where estab.etbcod = vestab-cod no-lock no-error.

     if avail estab
     then
     run p-calcula-os-filial (input estab.etbcod,
                              output vqtd-mes1,
                              output vqtd-mes2,
                              output vqtd-mes3,
                              output vconta-asstec,
                              output vmedia-asstec,
                              output vqtde-asstec-atual).
                              
       
     create tt-filial.
     assign tt-filial.filcod        = estab.etbcod
            tt-filial.filnom        = estab.etbnom
            tt-filial.qtd-mes1      = vqtd-mes1
            tt-filial.qtd-mes2      = vqtd-mes2
            tt-filial.qtd-mes3      = vqtd-mes3
            tt-filial.media         = vmedia-asstec
            tt-filial.qtd-mes-atual = vqtde-asstec-atual.

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
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-filial ",
             " Alteracao da tt-filial ",
             " Exclusao  da tt-filial ",
             " Consulta  da tt-filial ",
             " Listagem  Geral de tt-filial "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def var vtt-filial         like tt-filial.filcod.


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

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-filial where recid(tt-filial) = recatu1 no-lock.
    if not available tt-filial
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-filial).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-filial
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
            find tt-filial where recid(tt-filial) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-filial.filnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-filial.filnom)
                                        else "".
            run color-message.
            
            choose field tt-filial.filcod help ""
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
                    if not avail tt-filial
                    then leave.
                    recatu1 = recid(tt-filial).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-filial
                    then leave.
                    recatu1 = recid(tt-filial).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-filial
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-filial
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-filial
                 with frame f-tt-filial color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-filial on error undo.
                    create tt-filial.
                    update tt-filial.
                    recatu1 = recid(tt-filial).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-filial.
                    disp tt-filial.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-filial on error undo.
                    find tt-filial where
                            recid(tt-filial) = recatu1 
                        exclusive.
                    update tt-filial.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-filial.filnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-filial where true no-error.
                    if not available tt-filial
                    then do:
                        find tt-filial where recid(tt-filial) = recatu1.
                        find prev tt-filial where true no-error.
                    end.
                    recatu2 = if available tt-filial
                              then recid(tt-filial)
                              else ?.
                    find tt-filial where recid(tt-filial) = recatu1
                            exclusive.
                    delete tt-filial.
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
                    then run p-listagem (input 0).
                    else run p-listagem (input tt-filial.filcod).
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
        recatu1 = recid(tt-filial).
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

display tt-filial.filcod        
        tt-filial.filnom
        tt-filial.qtd-mes1
        tt-filial.qtd-mes2
        tt-filial.qtd-mes3
        tt-filial.media        
        tt-filial.qtd-mes-atual
        with frame frame-a 11 down centered color white/red row 5.

end procedure.

procedure color-message.
color display message
        tt-filial.filcod     
        tt-filial.filnom      
        tt-filial.qtd-mes1     
        tt-filial.qtd-mes2    
        tt-filial.qtd-mes3     
        tt-filial.media        
        tt-filial.qtd-mes-atual
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-filial.filcod     
        tt-filial.filnom      
        tt-filial.qtd-mes1     
        tt-filial.qtd-mes2    
        tt-filial.qtd-mes3     
        tt-filial.media        
        tt-filial.qtd-mes-atual
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-filial where true
                                                no-lock no-error.
    else  
        find last tt-filial  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-filial  where true
                                                no-lock no-error.
    else  
        find prev tt-filial   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-filial where true  
                                        no-lock no-error.
    else   
        find next tt-filial where true 
                                        no-lock no-error.
        
end procedure.

         
         
procedure p-calcula-os-filial:
   
   def input parameter ipint-etbcod as integer.
   
   def output parameter op-qtd-mes1          as integer.
   def output parameter op-qtd-mes2          as integer.   
   def output parameter op-qtd-mes3          as integer.   
   def output parameter op-conta-asstec      as integer.
   def output parameter op-media-asstec      as integer.   
   def output parameter op-qtde-asstec-atual as integer.
   
      
   /* Conta as ASSTEC dos ultimos 3 meses e faz uma media mensal */
   for each asstec where asstec.etbcod    = ipint-etbcod
                     and asstec.dtentdep >= vdtini
                     and asstec.dtentdep <= vdtfim no-lock:
      
       if month(asstec.dtentdep) = month(vdtini)
       then assign op-qtd-mes1 = op-qtd-mes1 + 1.
       else if month(asstec.dtentdep) <> month(vdtini)
                and month(asstec.dtentdep) <> month(vdtfim)
            then op-qtd-mes2 = op-qtd-mes2 + 1.     
            else if month(asstec.dtentdep) = month(vdtfim)
                 then op-qtd-mes3 = op-qtd-mes3 + 1.

       assign op-conta-asstec = op-conta-asstec + 1.

   end.
   assign op-media-asstec = (op-qtd-mes1 + op-qtd-mes2 + op-qtd-mes3) / 3.

   /* Conta as OS abertas no mes atual e ve se ultrapassou a media mensal */
   for each asstec where asstec.etbcod    = ipint-etbcod
                     and asstec.dtentdep > vdtfim
                     and asstec.dtentdep <= today no-lock:

       assign op-qtde-asstec-atual = op-qtde-asstec-atual + 1.
       
   end.
         
end procedure.




procedure p-listagem:

    def input parameter ipint-estab as integer.

    def var varquivo as char.
    
    clear frame frame-a.
    hide frame frame-a.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/l-med-os-fil." + string(time).
    else varquivo = "l:~\relat~\l-med-os-fil." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""con_asst.p""
                &Nom-Sis   = """SISTEMA ASST TÉCNICA"""
                &Tit-Rel   = """RELATÓRIO DE OS ABERTAS POR FILIAL"""
                &Width     = "130"
                &Form      = "frame f-cabcab"}
                           /*
    disp with frame f-dados.
                             */
    for each tt-filial no-lock:

        if ipint-estab > 0
        then do:
        
            if ipint-estab <> tt-filial.filcod
            then next.

        end.

        display tt-filial.filcod        
                tt-filial.filnom
                tt-filial.qtd-mes1
                tt-filial.qtd-mes2
                tt-filial.qtd-mes3
                tt-filial.media        
                tt-filial.qtd-mes-atual     
                with frame frame-a centered overlay.

       down with frame frame-a.
                                       
    
    end.

    display skip
    with frame frame-a centered overlay.
    
    
    output close.
    
    clear frame frame-a.
    hide frame frame-a.

    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.


end procedure.



