/* */
{admcab.i }
{sys_funcoes.i}

def  input parameter par-parametro       as char.
def var vprocod like produ.procod.
def var par-produ as char.
                        /*
find produ where produ.procod = int(par-parametro) no-lock.
par-parametro = string(recid(produ)).  */

def temp-table tt
    field data      as date
    field datafim as date
    field tipo      as char
    field prvenda as dec
    field perc as dec
    field protdc    as int
    field prpromocao as dec
    field liquido as dec
    field funcod    like precohrg.funcod
    field prdata   like precohrg.data
    field prhora   like precohrg.hora
    field etbcod   like estab.etbcod
    index a data asc tipo asc.

def temp-table tt-preco
    field dti       as date
    field dtf       as date
    field tipo      as char
    field valendo as char
    field valor as dec
    field protdc as int
    field prpromocao as dec
    field perc as dec format ">,>>9.99"
    field funcod    like precohrg.funcod
    field prdata   like precohrg.data
    field prhora   like precohrg.hora
    field etbcod   like estab.etbcod
    index wfpreco dtf desc.

def temp-table tt-estab
    field etbcod   like estab.etbcod
    index etbcod etbcod.
    
def buffer xtt for tt.
def var vnome as char format "x(20)".

par-produ = par-parametro.

find produ where recid(produ) = int(par-produ) no-lock.
find clase of produ no-lock no-error.
find fabri of produ no-lock no-error.
if par-parametro = "MENU"
then
    display 
        produ.procod @ vprocod   colon 11
        produ.pronom    no-label
        produ.fabcod    colon 11
        fabri.fabnom no-label when avail fabri
        produ.clacod    colon 11
        clase.clanom no-label when avail clase 
        with frame fsubcab width 81 color message side-label no-box row 3.

run monta-tt(0).

def buffer btt-preco       for tt-preco.

find first precohrg of produ no-lock no-error.
find first precopromoc of produ no-lock no-error.
if not avail precohrg and not avail precopromoc
then do on endkey undo.
    message "Produto Sem Preco".
    pause 3 no-message.
    leave.
end.

run mostra-loja.
form with frame frame-a.

return.


procedure frame-a.
   def var vatual as log format "*/ " column-label " ".
   def var vreforca like vatual.
   
   vatual = tt-preco.dti <= today and
            (tt-preco.dtf = ? or
             tt-preco.dtf >= today).
   
   vreforca = vatual.
                
   display
      space(0)
      vatual format "*/ " column-label " "
      space(0)
      tt-preco.dti   column-label "De"
      tt-preco.dtf   column-label "Ate"
      tt-preco.tipo  column-label ""      format "x(8)"
      tt-preco.valor column-label "Preco" format ">>,>>9.99"
      vreforca column-label ""
      tt-preco.prpromocao when tt-preco.prpromocao <> 0 column-label "Promocao"
      format ">>,>>9.99"
      tt-preco.perc   when tt-preco.perc <> 0  column-label "Perc" 
                                               format ">>9.99"
      tt-preco.funcod when tt-preco.funcod > 0 column-label "Matric"
      with frame frame-a 9 down  row 7 col 15 overlay
      title string(produ.procod) + " " + produ.pronom.
    if vatual
    then do:
        if tt-preco.prpromocao = 0
        then color disp messages 
            tt-preco.dti
            tt-preco.dtf
            tt-preco.valor with frame frame-a.
        else 
            color disp messages 
                tt-preco.dti
                tt-preco.dtf
                tt-preco.prpromocao with frame frame-a.
    end.
end procedure.

procedure mostra-preco.

def input param par-acao as char.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(11)" extent 5
    initial [" "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" "].

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 20. /*screen-lines*/
assign
    esqregua = yes
    esqpos1  = 1
    recatu1  = ?.

bl-princ:
repeat:
    if par-acao <> "CONSULTA"
    then disp esqcom1 with frame f-com1.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-preco where recid(tt-preco) = recatu1 no-lock.
    if not available tt-preco
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-preco).
    if par-acao <> "CONSULTA"
    then
        if esqregua
        then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-preco
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if par-acao = "CONSULTA"
    then return.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-preco where recid(tt-preco) = recatu1 no-lock.

            vnome = "".
            if tt-preco.funcod > 0
            then do.
                find func of tt-preco no-lock.
                vnome = func.funnom.
            end.
            disp
               tt-preco.funcod when tt-preco.funcod > 0
               vnome no-label  when tt-preco.funcod > 0
               tt-preco.prdata when tt-preco.prdata <> ?
               string(tt-preco.prhora,"hh:mm") no-label when tt-preco.prhora > 0
               with frame fsub row 21 overlay side-labels no-box.
/**
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-preco.<tab>nom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-preco.<tab>nom)
                                        else "".
**/
            color disp messages 
                tt-preco.dtf
                tt-preco.tipo
                tt-preco.valor
                tt-preco.prpromocao
                tt-preco.perc
                tt-preco.funcod.
            choose field tt-preco.dti help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            color disp normal
                tt-preco.dtf
                tt-preco.tipo
                tt-preco.valor
                tt-preco.prpromocao
                tt-preco.perc
                tt-preco.funcod.
            status default "".
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
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
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-preco
                    then leave.
                    recatu1 = recid(tt-preco).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-preco
                    then leave.
                    recatu1 = recid(tt-preco).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-preco
                then next.
                color display white/red tt-preco.dti with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-preco
                then next.
                color display white/red tt-preco.dti with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-preco on error undo.
                    create tt-preco.
                    update tt-preco.
                    recatu1 = recid(tt-preco).
                    leave.
                end.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-preco).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame fsub    no-pause.
hide frame frame-a no-pause.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first tt-preco where true
                                                no-lock no-error.
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next tt-preco  where true
                                                no-lock no-error.
if par-tipo = "up" 
then                  
        find prev tt-preco where true  
                                        no-lock no-error.
end procedure.

procedure monta-tt.

   def input parameter par-etbcod like estab.etbcod.

   def var vok as log.
   def buffer btt for tt.
   def buffer btt-estab for tt-estab.
   for each tt.
      delete tt.
   end.
   for each tt-preco.
      delete tt-preco.
   end.
    
   if par-etbcod = 0
   then find estab where estab.etbcod = setbcod no-lock.
   else find estab where estab.etbcod = par-etbcod no-lock.

   for each precohrg of produ /*where precohrg.etbcod = estab.etbcod*/ no-lock.
      par-etbcod  =  precohrg.etbcod.
      find btt-estab where btt-estab.etbcod = par-etbcod no-error.
      if not avail btt-estab
      then do.
         create btt-estab.
         btt-estab.etbcod = par-etbcod.
      end.

      find first tt where tt.data = precohrg.dativig no-error.
      if not avail tt
      then create tt.
      assign
          tt.data    = precohrg.dativig
          tt.tipo    = "PRECO"
          tt.prvenda = precohrg.prvenda
          tt.funcod  = precohrg.funcod
          tt.prdata  = precohrg.data
          tt.prhora  = precohrg.hora.
   end.

   for each precopromoc of produ where precopromoc.perc <> 0 or precopromoc.prpromocao <> 0
                   no-lock.

      find btt-estab where btt-estab.etbcod = precopromoc.etbcod no-error.
      if not avail btt-estab
      then do.
          create btt-estab.
          btt-estab.etbcod = precopromoc.etbcod.
      end.
      if precopromoc.etbcod <> par-etbcod
      then next.
      
      create tt.
      assign
         tt.data       = precopromoc.dtivig
         tt.datafim    = precopromoc.dtfvig
         tt.tipo       = "PROMOC"
         tt.funcod     = precopromoc.funcod
         tt.protdc     = precopromoc.protdc
         tt.prpromocao = precopromoc.prpromocao
         tt.perc       = precopromoc.perc.
   end.

   for each tt /*where tt.tipo = "PROMOC"*/
               break by tt.data.
      if tt.tipo = "PROMOC"
      then do.
         find first btt where btt.data > tt.data and btt.tipo = "PROMOC"
                      no-error.
         if avail btt and (btt.data - tt.datafim) < 0
         then do. /* errado */
            find last xtt where xtt.data <= tt.data and xtt.tipo = "PRECO"
                          no-error.
            
            create tt-preco.
            assign
               tt-preco.dti    = btt.data
               tt-preco.dtf    = tt.datafim
               tt-preco.protdc = tt.protdc
               tt-preco.funcod = tt.funcod
               tt-preco.prdata = tt.prdata
               tt-preco.prhora = tt.prhora
               tt-preco.prpromocao = tt.prpromocao
               tt-preco.perc   = tt.perc.
            assign
               tt-preco.valor  = precotabela(produ.procod, setbcod, 
                                             btt.data).
/***
               if tt.prpromocao <> 0
                  then tt.prpromocao 
                  else if tt.perc <> 0
                       then 
                            tt.prvenda
                        else tt.prvenda.
***/   
            find tipprom where tipprom.protdc = tt.protdc
                      no-lock no-error.
            tt-preco.tipo = if avail tipprom
                       then caps(tipprom.protnom)
                       else string(tt-preco.protdc).

            create btt-preco.
            assign
               btt-preco.dti    = btt.data
               btt-preco.dtf    = tt.datafim
               btt-preco.protdc = btt.protdc
               btt-preco.funcod = btt.funcod
               btt-preco.prdata = btt.prdata
               btt-preco.prhora = btt.prhora
               btt-preco.prpromocao = tt.prpromocao
               btt-preco.perc       = tt.perc.
            assign
               btt-preco.valor  = precotabela(produ.procod, setbcod, 
                                             btt.data).
/***               btt-preco.valor = if btt.prpromocao <> 0
                  then btt.prpromocao 
                  else if btt.perc <> 0
                       then 
                            btt.prvenda
                        else btt.prvenda.***/
   
            find tipprom where tipprom.protdc = btt.protdc
                      no-lock no-error.
            btt-preco.tipo = if avail tipprom
                       then caps(tipprom.protnom)
                       else string(btt-preco.protdc).
        end.
        else do. /* correto */
            create tt-preco.
            assign
               tt-preco.dti    = tt.data
               tt-preco.dtf    = tt.datafim
               tt-preco.protdc = tt.protdc
               tt-preco.funcod = tt.funcod
               tt-preco.prdata = tt.prdata
               tt-preco.prhora = tt.prhora
               tt-preco.prpromocao = tt.prpromocao
               tt-preco.perc   = tt.perc.
            assign
               tt-preco.valor  = precotabela(produ.procod, setbcod, 
                                             tt.data).
/***
               tt-preco.valor = if tt.prpromocao <> 0
                  then tt.prpromocao 
                  else if tt.perc <> 0
                       then 
                            tt.prvenda
                        else tt.prvenda.
***/   
            find tipprom where tipprom.protdc = tt.protdc
                      no-lock no-error.
            tt-preco.tipo = if avail tipprom
                       then caps(tipprom.protnom)
                       else string(tt-preco.protdc).
         end.
      end.   
      else do. /* preco */
         vok = no.
         find first btt where btt.data > tt.data no-lock no-error.
         if avail btt and (btt.datafim = ? or btt.datafim > btt.data)
         then vok = yes.
         else 
            if not avail btt
            then do.
               find first btt where btt.data    <= tt.data and 
                                    btt.datafim >= tt.data and
                                    btt.tipo    = "PROMOC" 
                              no-lock no-error.
               vok = not avail btt.
            end.

         if vok 
         then do.
            create tt-preco.
            assign
               tt-preco.dti    = tt.data
               tt-preco.dtf    = if avail btt then btt.data - 1 else ?
               tt-preco.valor  = tt.prvenda
               tt-preco.funcod = tt.funcod
               tt-preco.prdata = tt.prdata
               tt-preco.prhora = tt.prhora
               tt-preco.tipo   = "PRECO".
         end.
      end.
   end.

   find last tt where tt.tipo = "PRECO" no-lock no-error.
   find last btt where btt.tipo = "PROMOC" no-lock no-error.
   if avail tt and avail btt
   then do.
      create tt-preco.
      assign
         tt-preco.dti    = btt.datafim + 1
         tt-preco.valor  = tt.prvenda
         tt-preco.funcod = tt.funcod
         tt-preco.prdata = tt.prdata
         tt-preco.prhora = tt.prhora
         tt-preco.tipo   = "PRECO".
   end.      

end procedure.




/**********************************************************/
form with frame frame-a-etb.

procedure frame-a-etb.
    if tt-estab.etbcod > 0
    then find estab of tt-estab no-lock.

    display tt-estab.etbcod column-label "Etb" format ">>9"
            (if tt-estab.etbcod = 0
            then "Geral"
            else estab.etbnom) @ estab.etbnom format "x(08)"  label "Estab"
        with frame frame-a-etb 9 down row 7.
end procedure.

procedure mostra-loja.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqregua        as log.
def var esqvazio        as log.
/**
def var esqcom1         as char format "x(12)" extent 5
    initial [" "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" "].
form
    esqcom1
    with frame f-com1
                row screen-lines no-box no-labels side-labels column 1 centered.
**/
assign
    esqregua = yes
    esqpos1  = 1.

bl-princ:
repeat:
/***
    disp esqcom1 with frame f-com1.
***/
    if recatu1 = ?
    then
        run leitura-etb (input "pri").
    else
        find tt-estab where recid(tt-estab) = recatu1 no-lock.
    if not available tt-estab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a-etb all no-pause.
    if not esqvazio
    then run frame-a-etb.

    recatu1 = recid(tt-estab).
    if not esqvazio
    then repeat:
        run leitura-etb (input "seg").
        if not available tt-estab
        then leave.
        if frame-line(frame-a-etb) = frame-down(frame-a-etb)
        then leave.
        down
            with frame frame-a-etb.
        run frame-a-etb.
    end.
    if not esqvazio
    then up frame-line(frame-a-etb) - 1 with frame frame-a-etb.

    repeat with frame frame-a-etb:

        if not esqvazio
        then do:
            find tt-estab where recid(tt-estab) = recatu1 no-lock.

            status default "Selecione um estabelecimento".
            color disp messages estab.etbnom. 
            
            run monta-tt(tt-estab.etbcod).
            run mostra-preco ("CONSULTA").

            choose field tt-estab.etbcod help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return).
            color disp normal estab.etbnom.
            status default "".
        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a-etb):
                    run leitura-etb (input "down").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a-etb):
                    run leitura-etb (input "up").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura-etb (input "down").
                if not avail tt-estab
                then next.
                color display white/red estab.etbnom with frame frame-a-etb.
                if frame-line(frame-a-etb) = frame-down(frame-a-etb)
                then scroll with frame frame-a-etb.
                else down with frame frame-a-etb.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura-etb (input "up").
                if not avail tt-estab
                then next.
                color display white/red estab.etbnom with frame frame-a-etb.
                if frame-line(frame-a-etb) = 1
                then scroll down with frame frame-a-etb.
                else up with frame frame-a-etb.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" 
        then do:
            color disp messages estab.etbnom.
            run monta-tt(tt-estab.etbcod).
            run mostra-preco ("").
            leave.
        end.
        if not esqvazio
        then run frame-a-etb.
        recatu1 = recid(tt-estab).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a-etb no-pause.
hide frame frame-a no-pause.

end procedure.

procedure leitura-etb . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first tt-estab where true
                                                no-lock no-error.
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next tt-estab  where true
                                                no-lock no-error.             
if par-tipo = "up" 
then                  
        find prev tt-estab where true  
                                        no-lock no-error.        
end procedure.
 
