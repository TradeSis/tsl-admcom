def var vformato    as log format "Err/" label "FMT".
def var v2formato   as char format "x(05)" label "FMT".

def shared temp-table tt-clien no-undo
    field cpf like neuclien.cpf
    field NOVOCPF as char format "x(14)"  
    field CLICOD  like neuclien.clicod    init ?
    field DATEXP like clien.datexp format "99/99/9999"
    field reg as int    format ">>9"
    field regabe as int format ">>9"
    field regtit as int format ">>9"
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field marca    as log column-label "*" format "*/ " init yes
    index cpf is unique primary cpf asc clicod asc
    index regabe regabe asc.

def shared temp-table tt-clicods no-undo
    field cpf like neuclien.cpf
    field clicod as int format ">>>>>>>>>>9" 
    field datexp like clien.datexp format "99/99/9999"
    field NOVOCPF as char format "x(14)"  
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field sittit   as char format "x(03)" label "Tit"
    index cpf is unique primary cpf asc clicod asc.


def new shared temp-table tt-contratos
    field contnum like contrato.contnum  format ">>>>>>>>>9"
    field etbcod  like contrato.etbcod
    field modcod  like contrato.modcod
    field CLICOD  like contrato.clicod
    field titpar    as int format ">9" label "Parc"
    field titparabe as int format ">9" column-label "Abe"
    field titvlcob  as dec format ">>>>>>9.99" label "Valor"
    field titvlabe  as dec format ">>>>>>9.99" column-label "Abe"
    field conectada as log format "Sim/   " column-label "Conec"
    field existente as log format "Sim/   " column-label "Exist".
    


{cabec.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Contratos "," Higieniza"," "," ",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer atu-estab for estab.

def input-output parameter par-rec as recid.

recatu1 = ?.


form with frame frame-a
                     row 8 5 down
                     no-box.


form

        tt-clien.NOVOCPF column-label "CPF"
        tt-clien.marca
        tt-clien.CLICOD  column-label "CODIGO"
        clien.clinom     format "x(30)" 
        tt-clien.REG     column-label "Regs"
        tt-clien.regtit column-label "Parc"
        tt-clien.REGABE  column-label "Abe"
        vformato
    with frame frame-cab overlay row 3 width 80 1 down
         title " CONTA PRINCIPAL do CPF ".

if par-rec = ? /* Inclusao */
then do on error undo.
    return.
end.


    find tt-clien where recid(tt-clien) = par-rec no-lock.
    run fcab.
    

 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-clicods where recid(tt-clicods) = recatu1 no-lock.
    if not available tt-clicods
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
          recatu1 = ?.
        leave.
    end.

    recatu1 = recid(tt-clicods).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-clicods
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
            find tt-clicods where recid(tt-clicods) = recatu1 no-lock.
                
                find clien where clien.clicod = tt-clicods.clicod no-lock.
                v2formato = if tt-clicods.zerar
                            then "ZERAR"
                            else if tt-clicods.caracter
                                 then "CARACTER"
                                 else if tt-clicods.tamanho
                                      then "TAMANHO"
                                      else "".
            
            if tt-clicods.sittit = ""
            then do:
                esqcom1[1] = if tt-clien.marca
                             then if tt-clicods.clicod <> tt-clien.clicod or
                                     tt-clien.reg = 1
                                  then " Higieniza "
                                  else if v2formato <> ""
                                       then " Formato "
                                       else " Higieniza"
                             else if tt-clien.marca = ?
                                  then ""
                                  else if tt-clicods.clicod <> tt-clien.clicod
                                       then " Higieniza"
                                       else "-".
                esqcom1[2] = "".
            end.
            else do:
                esqcom1[1] = " Contratos ".
                if tt-clien.marca = ?
                then esqcom1[2] = "".
                else esqcom1[2] = if tt-clien.regabe <= 1
                             then if tt-clien.clicod <> tt-clicods.clicod
                                  then " Higieniza"
                                  else " higieniza"
                             else if tt-clien.clicod <> tt-clicods.clicod
                                  then " Principal "
                                  else " ".
            end.
            
            
            disp esqcom1 with frame f-com1.
        color disp messages
        tt-clicods.clicod.
            
            choose field tt-clicods.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        tt-clicods.clicod.
 
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-clicods
                    then leave.
                    recatu1 = recid(tt-clicods).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-clicods
                    then leave.
                    recatu1 = recid(tt-clicods).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-clicods
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-clicods
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Contratos "
                then do .
                    hide frame f-com1 no-pause.
                    for each tt-contratos.
                            delete tt-contratos.
                    end.        
                    run cli/manhigcontrato_v1801.p (input recatu1).
                    
                    view frame f-com1.
                end. 
                if esqcom1[esqpos1] = " Higieniza " and
                   tt-clien.marca = yes  
                then do on error undo:
                    hide frame f-com1  no-pause.  

                    run cli/higaltera_v1801.p (recid(tt-clien),
                                               recid(tt-clicods)).
                        tt-clien.marca = ?.
                        disp tt-clien.marca 
                            with frame frame-cab.
                    recatu1 = ?. 
                    leave.
                end. 
                if esqcom1[esqpos1] = " Higieniza " and
                   tt-clien.marca = no  
                then do on error undo:
                    hide frame f-com1  no-pause.  
                    
                    run cli/higaltera_v1801.p (recid(tt-clien),
                                               recid(tt-clicods)).
                    
                    leave.
                end. 
                
                if esqcom1[esqpos1] = " Principal "
                then do on error undo:
                    message "Confirma Trocar para a Conta Principal > "
                        tt-clicods.clicod
                        update sresp.
                    if sresp
                    then do:
                        find neuclien where 
                            neuclien.clicod = tt-clicods.clicod
                            no-lock no-error.
                        if avail neuclien
                        then do:
                            if neuclien.cpf <> ?
                            then sresp = no.       
                        end.                
                        tt-clien.clicod = tt-clicods.clicod. 
                        find neuclien where neuclien.cpf = tt-clien.cpf
                            no-lock no-error.
                        if avail neuclien
                        then     
                            run cli/neuclienloghigie.p  
                                (tt-clien.cpf,  
                                 "NEUCLIEN",  
                                 recid(neuclien),  
                                 "CLICOD",  
                                 string(tt-clien.clicod)). 
                    end.
                    disp 
                        tt-clien.clicod
                            with frame frame-cab.
                    recatu1 = ?. 
                    leave.
                end.

        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-clicods).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

                
                find clien where clien.clicod = tt-clicods.clicod no-lock.
                v2formato = if tt-clicods.zerar
                            then "ZERAR"
                            else if tt-clicods.caracter
                                 then "CARACTER"
                                 else if tt-clicods.tamanho
                                      then "TAMANHO"
                                      else "".
        
                disp clien.ciccgc format "x(14)"
                     tt-clicods.clicod column-label "CODIGO"
                     clien.clinom format  "x(15)"
                     clien.etbcad format ">>9" column-label "Etb"
                     clien.dtcad format "99/99/9999"
                    tt-clicods.datexp column-label "Alter" 
                 v2formato
                     tt-clicods.sittit
                        with frame frame-a.
 
end procedure.

procedure leitura.
def input parameter par-tipo as char.


if par-tipo = "pri" 
then find first  tt-clicods where tt-clicods.cpf =  tt-clien.cpf
         and
                    (if tt-clien.zerar
                    then (tt-clicods.clicod = tt-clien.clicod)
                    else true )

        no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-clicods where tt-clicods.cpf =  tt-clien.cpf
         and
                    (if tt-clien.zerar
                    then (tt-clicods.clicod = tt-clien.clicod)
                    else true )

        no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-clicods where tt-clicods.cpf =  tt-clien.cpf
         and
                    (if tt-clien.zerar
                    then (tt-clicods.clicod = tt-clien.clicod)
                    else true )

    no-lock no-error.

end procedure.

procedure fcab.

    find tt-clien where recid(tt-clien) = par-rec no-lock.

    vformato = tt-clien.zerar or
               tt-clien.caracter or
               tt-clien.tamanho. 
    find clien where clien.clicod = tt-clien.clicod no-lock no-error.

    disp 
        tt-clien.NOVOCPF 
        tt-clien.marca
        tt-clien.CLICOD 
        clien.clinom when avail clien 
        tt-clien.REG    
        tt-clien.regtit
        tt-clien.REGABE 
        vformato
 
    with frame frame-cab.

    color disp messages
                tt-clien.novocpf
                with frame frame-cab.

    
end procedure.
 
