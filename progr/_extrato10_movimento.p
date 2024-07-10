
def var vsenha as char format "x(20)".
def shared var sal-ant   like estoq.estatual.
def shared var sal-atu   like estoq.estatual.
def shared var vdata1 like plani.pladat label "Data".
def shared var vdata2 like plani.pladat label "Data".
def shared var vetbcod like estab.etbcod.
def shared var vprocod like produ.procod.

def shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec 
    .

def temp-table tt-movim no-undo
    field seq as int
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec 
    index i1 seq.
  
def shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-mes as dec
    field ano-cto as int
    field mes-cto as int
    field cus-ent as dec
    field cus-med as dec
    index i1 ano-cto mes-cto etbcod procod
    .

form tt-movim.data    column-label "Data Saida" format "99/99/9999" 
     help "d=PgDn  u=PgUp  f=Ultimo  p=primeiro  n=NFiscal  o=+opções"
     tt-movim.tipmov  column-label "Operacao"   format "x(12)"
     tt-movim.numero  column-label "Documento"  format "x(9)"
     tt-movim.serie   column-label "SE"         format "x(02)"
     tt-movim.emite   column-label "Emite"      format ">>>>>>>>>"
     tt-movim.desti   column-label "Desti"      format ">>>>>>>>>>"
     tt-movim.movqtm  column-label "Quant"      format "->>>9" 
     tt-movim.movpc   column-label "Valor"      format ">>>9.99" 
     tt-movim.sal-atu column-label "Saldo"      format "->>>>9" 
     with frame frame-a  12 down overlay
                                 ROW 5 CENTERED color white/gray width 80.

form tt-saldo.sal-ant label "Saldo Anterior" format "->>>>9"
     tt-saldo.qtd-ent   label "Ent" format ">>>>>9"
     tt-saldo.qtd-sai   label "Sai" format ">>>>>9"
     tt-saldo.sal-atu label "Saldo no periodo" format "->>>>9"
     with frame f-sal centered row 21 side-label no-box
                                        color white/red overlay.

find estoq where estoq.etbcod = vetbcod and
                 estoq.procod = vprocod
                 no-lock.
sal-atu = estoq.estatual.                 
form sal-atu label "Estoque atual" format "->>>>9"
    with frame f-atual 1 down no-box column 60
    side-label overlay row 4.
    
{admcab.i}
{anset.i}                                                                 

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
/*                                                                                
disp "                  INCLUSAO SERIAIS - ESN/IMEI       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/
def buffer btbcntgen for tbcntgen.                            
def var i as int.

find estab where estab.etbcod = vetbcod no-lock.
find produ where produ.procod = vprocod no-lock.
disp vetbcod label " Filial" 
     estab.etbnom no-label 
     vdata1 label "Periodo" colon 55
     vdata2 no-label
     vprocod
     produ.pronom no-label
     with frame f-pro width 80 color  message
                            row 3 side-label no-box.

pause 0. 


def var vmovtdc like movim.movtdc.

for each tt-movim: delete tt-movim. end.
def var vseq as int.
vseq = 0.
for each tt-movest by data:
    create tt-movim.
    buffer-copy tt-movest to tt-movim.
    vseq = vseq + 1.
    tt-movim.seq = vseq.
end.
    
def var vrec as recid.
def var vdata as date format "99/99/9999".

bl-princ:
repeat:
    /*disp esqcom1 with frame f-com1.
    */
    hide frame f-sal no-pause.
    clear frame f-sal all.
    hide frame f-atual no-pause.
    clear frame f-atual all.
    find first tt-saldo where
               tt-saldo.ano-cto = 0  and
               tt-saldo.mes-cto = 0  and
               tt-saldo.etbcod = vetbcod and
               tt-saldo.procod = vprocod 
               no-lock no-error.
    if avail tt-saldo
    then
    disp tt-saldo.sal-ant 
         tt-saldo.qtd-ent   
         tt-saldo.qtd-sai   
         tt-saldo.sal-atu 
         with frame f-sal.
    pause 0.
          
    disp sal-atu with frame f-atual.

    pause 0.
    
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-movim where recid(tt-movim) = recatu1 no-lock.
    if not available tt-movim
    then do.
        message color red/with
        "Sem registro de movimento no periodo."
        view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-movim).
    /*
    color display message esqcom1[esqpos1] with frame f-com1.
    */
    repeat:
        run leitura (input "seg").
        if not available tt-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-movim where recid(tt-movim) = recatu1 no-lock.

        status default "".

        run color-message.
        choose field tt-movim.data 
                /*help "Refresh de 15 segundos"
                pause 15 */
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return d u f p n o).
        run color-normal.
        pause 0. 
        
        if keyfunction(lastkey) = "page-down"
               or lastkey = 100
        then do:
            do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-movim
                    then leave.
                    recatu1 = recid(tt-movim).
            end.
            leave.
        end.
        
        if keyfunction(lastkey) = "page-up"
                or lastkey = 117
        then do:
            do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-movim
                    then leave.
                    recatu1 = recid(tt-movim).
            end.
            leave.
        end.
        
        if keyfunction(lastkey) = "cursor-down"
        then do:
                run leitura (input "down").
                if not avail tt-movim
                then next.
                color display white/red tt-movim.data with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
        end.
        
        if keyfunction(lastkey) = "cursor-up"
        then do:
                run leitura (input "up").
                if not avail tt-movim
                then next.
                color display white/red tt-movim.data with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
        end.
        
        if lastkey = 102  
        then do:
                find last tt-movim use-index i1.
                recatu1 = recid(tt-movim).
                next bl-princ.
        end.
        
        if lastkey = 112  
        then do:
                find first tt-movim use-index i1.
                recatu1 = recid(tt-movim).
                next bl-princ.
        end.
        
        if lastkey = 110
        then do:
            
                find plani where plani.movtdc = tt-movim.movtdc and
                         plani.etbcod = tt-movim.etbcod and
                         plani.emite  = tt-movim.emite and
                         plani.serie  = tt-movim.serie and
                         plani.numero = int(tt-movim.numero)
                         no-lock no-error.
                if avail plani then                 
                run not_consnota.p (recid(plani)).

                recatu1 = recid(tt-movim).
                next bl-princ.
        end.

        if keyfunction(lastkey) = "return"
              or lastkey = 111
        then do:
            run mais-opcoes.
            next bl-princ.
        end.
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.



        run frame-a.
        /*display esqcom1[esqpos1] with frame f-com1.
        */
        recatu1 = recid(tt-movim).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
        disp tt-movim.data
             tt-movim.tipmov
                    tt-movim.numero
                    tt-movim.serie
                    tt-movim.emite
                    tt-movim.desti
                    tt-movim.movqtm
                    tt-movim.movpc
                    tt-movim.sal-atu
             with frame frame-a.
end procedure.

procedure color-message.
    color display message
        tt-movim.data
        tt-movim.tipmov
                    tt-movim.numero
                    tt-movim.serie
                    tt-movim.emite
                    tt-movim.desti
                    tt-movim.movqtm
                    tt-movim.movpc
                    tt-movim.sal-atu
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        tt-movim.data
        tt-movim.tipmov
                    tt-movim.numero
                    tt-movim.serie
                    tt-movim.emite
                    tt-movim.desti
                    tt-movim.movqtm
                    tt-movim.movpc
                    tt-movim.sal-atu
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-movim where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-movim where true no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-movim where true no-lock no-error.
        
end procedure.

procedure mais-opcoes:

    def var vdata as date format "99/99/9999".
    def var vindex as int.
    def var vop as char format "x(25)"
        extent 5.
    vop[1] = "Posicionar em uma data" .
    if setbcod = 999
    then vop[5] = "RP-somente com senha".
    else vop[5] = "".
    disp vop with frame f-op 1 down overlay no-label
        centere row 6 1 column .
    choose field vop with frame f-op.    
    vindex = frame-index.
    hide frame f-op no-pause.
    clear frame f-op all.
        
    if frame-index = 1
    then do:
        vdata = vdata1.
        update vdata label "Posicionar na data" with frame f-data 1 down
                side-label row 6 color message centered
                overlay.
        find first tt-movim where
                  tt-movim.data = vdata no-error. 
        
        if not avail tt-movim
        then find last tt-movim where
                       tt-movim.data < vdata no-error.
                        
        if avail tt-movim
        then recatu1 = recid(tt-movim).
        hide frame f-data no-pause.
        clear frame f-data all.
    end. 
    if frame-index = 5
    then do:
        message setbcod sfuncod. pause.
        vsenha = "".
        update vsenha blank label "Senha" with frame f-senha side-label
            overlay row 18 column 30  color message.
        if vsenha <> "rpbrasil"
        then.
        else do:

            sparam = "PRODUTO=SIM" + "|PROCOD=" + STRING(vprocod) +
                "|ETBCOD=" + string(vetbcod) + "|".
         
            run removest20142.p.

            sparam = "".
            find estoq where estoq.etbcod = vetbcod and
                             estoq.procod = vprocod 
                             no-lock no-error.
            if avail estoq
            then sal-atu = estoq.estatual.                 
 
        end. 
    end.
 end procedure.
