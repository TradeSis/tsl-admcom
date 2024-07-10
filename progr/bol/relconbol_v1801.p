/* helio 28022022 - iepro */

{cabec.i}
def var vconta as int.
def var xok    as log format "  /Nok" label "Sit".
def var vloop as int.

def var vbusca as char.
def var vtotal as int.
def var vcusto as dec.

def var par-busca       as   char.
def buffer xestab for estab.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Detalhe ", " ", " ", " ", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","","","",""].
def var esqhel1         as char format "x(80)" extent 5.
    def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.

def var vtime        as int.
def var vct          as int.

pause 0 before-hide.
form with frame f-proc.

def new  shared temp-table tt-resumo no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
    field titvlrcustas   as dec label "Vlr Custas"
    field vltaxa        as dec label "Vlr Taxa".

def  new shared temp-table tt-bolteds no-undo
    field boltedforma   as char format "x(05)" label "Forma"
    field bancod  like banco.bancod
    field bancart like bancarteira.bancart
    field rec     as recid
    field Chave   as char format "x(20)"
    field vlcobrado     as dec label "Vlr Documento"
    field vlpagamento   as dec label "Vlr Extrato"
    field vltitpag      as dec label "Vlr Baixa"
    field titvlrcustas   as dec label "Vlr Custas"
    field vltaxa        as dec label "Vlr Taxa".


def new shared var pchoose as char label "Forma".

def new shared var par-pagamento as log format "Sim/Nao" 
        label "Filtra Periodo Pagamento" init yes.
def new shared var par-dtpagini as date format "99/99/9999" label "de".
def new shared var par-dtpagfim as date format "99/99/9999" label "ate".


def new shared var par-banco  as log format "Sim/Nao" label "Filtra Banco"
    init no.
def new shared var par-numban as int format ">>>9" label "Banco".
def new shared var par-bancod as int format ">>>9" label "Banco".



    
def new shared var par-carteira  as log format "Sim/Nao" 
        label "Filtra Carteira" init no.
def new shared var par-bancart as int format ">>9" label "Carteira".
 
def var vescsituacao as char format "x(40)"  extent 8
            init [" TODOS",
                  " Vinculados",
                  " Pendentes",
                  " Abertos",
                  " Efetivado",
                  " Liquidados",
                  " Marcado p/ Enviar",
                  " Baixados"].
                  
def var tescsituacao as char format "x(15)"  extent 8
            init ["GER",
                  "V", 
                  "P",
                  "A",
                  "E",
                  "L",
                  "ENVIARBOLETO",
                  "B"].

def buffer xtt-resumo for tt-resumo.
    
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
    
def var vescforma as char format "x(40)"  extent 3
            init [" TODOS",
                  " Boletos",
                  " TEDs"].
                  
def var tescforma as char format "x(15)"  extent 3
            init ["GER",
                  "BOL", 
                  "TED"].

def var vindex as int.
def var ptitle as char.

    form
        tt-resumo.boltedforma column-label "Forma"
        tt-resumo.bancart     column-label "Cart"
        banco.numban          column-label "Banc"
        banco.bandesc         format "x(5)" column-label "Banco"  
        tt-resumo.vlcobrado   column-label "Vlr!Cobrado"
            format ">>>>>>>>>9.99"
        tt-resumo.vlpagamento column-label "Vlr!Pago"                          
            format ">>>>>>>>>9.99"
        tt-resumo.vltitpag    column-label "Vlr!Baixa" 
            format ">>>>>>>>>9.99"
        tt-resumo.vltaxa      column-label "Diferenca"
        xok format "   /NOK" column-label "Sit"
 
        with frame frame-a 
        07 down centered  row 4
                          title ptitle width 80.
                          

form with frame flinha 
                     row 16 3 down
                     no-box.
 .
form  
    par-banco        colon 25
             par-numban   banco.bandesc no-label format "x(20)"
    par-carteira        colon 25
             par-bancart   

    par-pagamento       colon 25
             par-dtpagini   
             par-dtpagfim

         pchoose    format "x(30)"      colon 25
             
         with frame fcab
            row 3 centered side-labels
            title "Filtros Rel Conciliacao ".

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first tt-resumo no-lock no-error.
if not avail tt-resumo
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    next.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-resumo where recid(tt-resumo) = recatu1 no-lock.
    if not available tt-resumo
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tt-resumo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-resumo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-resumo where recid(tt-resumo) = recatu1 no-lock.

            clear frame flinha all no-pause.
            vloop = 0.
            /**
            for each tt-bolteds where tt-bolteds.cpf =  tt-resumo.cpf
                    and
                    (if tt-resumo.zerar
                    then (tt-bolteds.clicod = tt-resumo.clicod)
                    else true )
                break by tt-bolteds.datexp desc
                with frame flinha.
                
                vloop = vloop + 1.
                if vloop > 3
                then leave.
                find clien where clien.clicod = tt-bolteds.clicod no-lock.
        
                disp clien.ciccgc format "x(14)"
                     clien.clicod column-label "CODIGO"
                     clien.clinom format  "x(15)"
                     clien.etbcad format ">>9" column-label "Etb"
                     clien.dtcad format "99/99/9999".
        
                disp tt-bolteds.datexp column-label "Alter" .
                v2formato = if tt-bolteds.zerar
                            then "ZERAR"
                            else if tt-bolteds.caracter
                                 then "CARACTER"
                                 else if tt-bolteds.tamanho
                                      then "TAMANHO"
                                      else "".
                disp v2formato
                     tt-bolteds.sittit.
                down.                     
            end.
            **/
                
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-resumo.boltedforma)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-resumo.boltedforma)
                                        else "".

            choose field tt-resumo.boltedforma help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 F8 PF8 I i
                      tab PF4 F4 ESC return).
            
            if keyfunction(lastkey) = "CLEAR"     or
               keyfunction(lastkey) = "I"
            then do: 
                recatu2 = ?.                
                hide frame frame-a no-pause.
            end.
 
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca label "Busca"
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                leave.                
            end.

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
                    if not avail tt-resumo
                    then leave.
                    recatu1 = recid(tt-resumo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-resumo
                    then leave.
                    recatu1 = recid(tt-resumo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-resumo
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-resumo
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-etiqest color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Detalhe "
                then do:
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    hide frame frame-a no-pause. 
                    recatu2 = recid(tt-resumo).
                    run bol/manconbol_v1801.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
                

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                
                if esqcom2[esqpos2] = "Filtros" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pfiltros.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = "Relatorio" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run relatorio.
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
        recatu1 = recid(tt-resumo).
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

    find banco where banco.bancod = tt-resumo.bancod no-lock no-error.
    xok = tt-resumo.vlcobrado = tt-resumo.vlpagamento - tt-resumo.vltitpag.
    disp 
        tt-resumo.boltedforma
        tt-resumo.bancart
        banco.numban when avail banco
        banco.bandesc when avail banco
        tt-resumo.vlcobrado
        tt-resumo.vlpagamento
        tt-resumo.vltitpag
        tt-resumo.vlpagamento - tt-resumo.vltitpag @ tt-resumo.vltaxa
        xok format "   /NOK" column-label "Sit"
 
        with frame frame-a.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    find first tt-resumo  no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    find next tt-resumo  no-error.
if par-tipo = "up" 
then                  
    find prev tt-resumo no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    
    for each xtt-resumo no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.
end procedure.

procedure montatt.

for each tt-resumo.
    delete tt-resumo.
end.
for each tt-bolteds.
    delete tt-bolteds.
end.         

run bol/conbol_v1801.p. /* helio 27/04/2021 */

hide message no-pause.
end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.

procedure pfiltros.

repeat.
    hide frame flinha no-pause.
    clear frame fcab all no-pause.        
    ptitle = "".


    update par-banco  with frame fcab.
    if keyfunction(lastkey) = "GO" 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
    
    if par-banco
    then do on error undo, next:
        hide message no-pause.
        message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
        if par-numban = ?
        then assign
                par-numban = 0.
        
        update par-numban
            with frame fcab.
        par-bancod = 0.
        for each banco where banco.numban = par-numban no-lock.
            find first bancarteira of banco no-lock no-error.
            if avail bancarteira
            then do:
                par-bancod = banco.bancod.
                leave.
            end.    
        end.
        if par-bancod = 0
        then do:
            message "Banco nao possui Carteira associada".
        end.
        else do:    
            find banco where banco.bancod = par-bancod no-lock.
            disp banco.bandesc 
                with frame fcab.
        end.
             
    end.
    if keyfunction(lastkey) = "GO" 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
    

    update par-carteira with frame fcab.
    if keyfunction(lastkey) = "GO" 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
    
    if par-carteira
    then do:
        hide message no-pause.
        message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
        if par-bancart = ?
        then assign
                par-bancart = 0.
        
        update par-bancart
            with frame fcab.
    end.
    if keyfunction(lastkey) = "GO" 
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.
    


    hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    do:
        update par-pagamento with frame fcab.
        /**
        if keyfunction(lastkey) = "GO" and 
           par-vencimento = no and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
        if par-pagamento
        then do:
            hide message no-pause.
            message color normal 
            "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
            if par-dtpagini = ?
            then assign
                    par-dtpagini = date(01,01,year(today))
                    par-dtpagfim = today.
            
            update par-dtpagini
                   par-dtpagfim
                with frame fcab.
            if par-dtpagini = ? or 
               par-dtpagfim = ? or
               par-dtpagfim < par-dtpagini
            then     do:
                message "Datas Invalidas".
                undo.
            end.
        end.
        /**
        if keyfunction(lastkey) = "GO" and
           pchoose <> "LIQ" and
           pchoose <> "BAI"
 
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.
        **/
        
    end.
    
     hide message no-pause.
    message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
     
    display vescforma
        with frame fff centered row 8 no-label overlay 1 col
        title " Escolha Filtro Forma de Pagamento ".
    choose field vescforma with frame fff.                         
    pchoose =  tescforma[frame-index].
    vindex = frame-index.
    
    hide frame fff no-pause.
    ptitle =  pchoose + "-" + vescforma[vindex] .
    
    disp pchoose + "-" + vescforma[vindex] @ pchoose with frame fcab.

    run montatt.
    /**
    find first tt-resumo no-error.
    if avail tt-resumo
    then **/ leave.

end.
recatu1 = ?.

/**
run montatt.
**/

hide frame flinha no-pause.


end procedure.

