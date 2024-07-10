
def var vformato    as log  format "Err/" label "FMT".
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

def shared temp-table tt-contratos
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
    

def buffer btt-contratos for tt-contratos.
def var vconectada as log.
def var vexistente as log.
{cabec.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" "," "," "," ",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer atu-estab for estab.

def input parameter par-rec as recid.

recatu1 = ?.

form

        tt-clien.NOVOCPF column-label "CPF"
        tt-clien.marca
        tt-clien.CLICOD  column-label "CODIGO"
        clien.clinom     format "x(30)" 
        tt-clien.REG     column-label "Regs"
        tt-clien.regtit column-label "Parc"
        tt-clien.REGABE  column-label "Abe"
        vformato
    with frame frame-cab0 overlay row 3 width 80 1 down
         title " PRINCIPAL CPF ".



form 
                    tt-contratos.clicod
                    tt-contratos.etbcod
                    tt-contratos.contnum
                    tt-contratos.modcod
                    tt-contratos.titpar
                    tt-contratos.titvlcob
                    tt-contratos.titparabe
                    tt-contratos.titvlabe
                    tt-contratos.conectada
                    tt-contratos.existente

with frame frame-a
                     row 11 5 down
                     no-box centered.


form
                     tt-clicods.clicod column-label "CODIGO"

                clien.ciccgc format "x(14)"
                     clien.clinom format  "x(15)"
                     clien.etbcad format ">>9" column-label "Etb"
                     clien.dtcad format "99/99/9999"
                    tt-clicods.datexp column-label "Alter" 
                 v2formato
                     tt-clicods.sittit
    with frame frame-cab overlay row 8 width 80 1 down no-box
    no-underline.

if par-rec = ? /* Inclusao */
then do on error undo.
    return.
end.


    find tt-clicods where recid(tt-clicods) = par-rec no-lock.
    find tt-clien   where tt-clien.cpf      = tt-clicods.cpf no-lock.
    run fcab0.
    run fcab.
    
    find first tt-contratos no-error.
    if not avail tt-contratos
    then run pega-contratos.


 
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-contratos where recid(tt-contratos) = recatu1 no-lock.
    if not available tt-contratos
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

    recatu1 = recid(tt-contratos).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-contratos
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
            find tt-contratos where recid(tt-contratos) = recatu1 no-lock.
            
            esqcom1[1] = "".
            if tt-clien.clicod <> tt-contratos.clicod
            then do:
                if tt-contratos.conectada = no 
                then do:
                    if tt-clien.regabe > 0 
                    then do:
                        esqcom1[1] = " Conecta".
                    end.
                end.
                else do:
                       /* if tt-contratos.conectada and
                           tt-contratos.existente
                    then*/ esqcom1[1] = " Transfere".
                end.    
            end.    
            disp esqcom1 with frame f-com1.
        color disp messages
        tt-contratos.clicod.
            
            choose field tt-contratos.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
 
        color disp normal
        tt-contratos.clicod.
 
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
                    if not avail tt-contratos
                    then leave.
                    recatu1 = recid(tt-contratos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-contratos
                    then leave.
                    recatu1 = recid(tt-contratos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-contratos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-contratos
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
                
                
                if esqcom1[esqpos1] = " Conecta "
                then do .

                    if connected ("finloja") then disconnect finloja. 
                    for each btt-contratos where
                        btt-contratos.conecta = yes.
                        btt-contratos.conecta = no.
                    end.
                    
                    run con-filial (input  tt-contratos.etbcod,
                                    output vconectada).
                    for each btt-contratos
                        where btt-contratos.etbcod = tt-contratos.etbcod.
                        btt-contratos.conectada = vconectada.
                        
                        if vconectada
                        then do:
                            run cli/existecontrato_1902.p 
                                (tt-clien.cpf,
                                 btt-contratos.contnum,
                                 btt-contratos.etbcod,
                                 btt-contratos.modcod,
                                 btt-contratos.clicod,
                                 tt-clien.clicod,
                                 output vexistente).
                             btt-contratos.existente = vexistente.    
                        end.
                        
                    end.                        
                    
                    leave.
                end. 
                                
                if esqcom1[esqpos1] = " Transfere "
                then do  on endkey undo, retry.
                    hide message no-pause.
                    message "Aguarde....".

                    
                    if not connected ("finloja") 
                    then do:
                        for each btt-contratos where
                            btt-contratos.conecta = yes.
                            btt-contratos.conecta = no.
                            btt-contratos.existente = no.
                        end.
                        message "Conexao Perdida"
                            view-as alert-box.
                        leave.    
                    end.    
                    
                    
                        
                        if tt-contratos.conectada 
                        then do:
                            if tt-contratos.existente
                            then do:
                                run cli/transferecontratoloja_v1902.p 
                                    (tt-clien.cpf,
                                     tt-contratos.contnum,
                                     tt-contratos.etbcod,
                                     tt-contratos.modcod,
                                     tt-contratos.clicod,
                                     /**"TRANSFERE",**/
                                     tt-clien.clicod,
                                     output vexistente ) .
                            end.

                            if connected ("finloja") then disconnect finloja. 
                                    
                            if vexistente or tt-contratos.existente = no
                            then do:
                                run cli/transferecontrato_v1902.p 
                                    (tt-clien.cpf,
                                     tt-contratos.contnum,
                                     tt-contratos.etbcod,
                                     tt-contratos.modcod,
                                     tt-contratos.clicod,
                                     /**"TRANSFERE",**/
                                     tt-clien.clicod,
                                     output vexistente ) .
                                 tt-contratos.existente = ?.
                                 tt-contratos.conectada = ?.
                                for each btt-contratos.
                                    delete btt-contratos.
                                end.
                                recatu1 = ?.
                            end.

                      
                            hide message no-pause.
                            return.
                            /*
                            run pega-contratos.
                            */
                        end.
                                        
                    leave.
                    
                end. 
                

        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-contratos).
    end.
end.

    if connected ("finloja")
    then disconnect finloja.

hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

                
                find clien where clien.clicod = tt-clicods.clicod no-lock.
        
                disp 
                    tt-contratos.clicod
                    tt-contratos.etbcod
                    tt-contratos.contnum
                    tt-contratos.modcod
                    tt-contratos.titpar
                    tt-contratos.titvlcob
                    tt-contratos.titparabe
                    tt-contratos.titvlabe
                    tt-contratos.conectada
                    tt-contratos.existente
                        with frame frame-a.
 
end procedure.

procedure leitura.
def input parameter par-tipo as char.


if par-tipo = "pri" 
then find first  tt-contratos
        no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-contratos
        no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-contratos
    no-lock no-error.

end procedure.

procedure fcab.

                
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
 
    with frame frame-cab.

    
end procedure.
 


procedure fcab0.

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
 
    with frame frame-cab0.

    color disp messages
                tt-clien.novocpf
                with frame frame-cab0.

    
end procedure.
  
procedure pega-contratos.
def var vcontnum as int.
for each titulo where 
        titulo.clifor = tt-clicods.CLICOD
        no-lock.
    if titulo.titnat = yes then next.
    if titulo.modcod begins "C"
    then.
    else next.
    vcontnum = int(titulo.titnum) no-error.
    if error-status:error
    then next.
    
    find first tt-contratos where
            tt-contratos.etbcod  = titulo.etbcod and
            tt-contratos.contnum = int(titulo.titnum) and
            tt-contratos.modcod  = titulo.modcod and
            tt-contratos.clicod  = titulo.clifor
            no-error.
    if not avail tt-contratos
    then do:
        create tt-contratos.
            tt-contratos.etbcod  = titulo.etbcod.
            tt-contratos.contnum = int(titulo.titnum).
            tt-contratos.modcod  = titulo.modcod.
            tt-contratos.clicod  = titulo.clifor.
    end.               
    tt-contratos.titpar    = tt-contratos.titpar   + 1.
    tt-contratos.titvlcob  = tt-contratos.titvlcob + titulo.titvlcob.
    tt-contratos.titparabe = tt-contratos.titparabe + 
                if titulo.titdtpag = ?
                then 1
                else 0.
    tt-contratos.titvlabe = tt-contratos.titvlabe + 
                if titulo.titdtpag = ?
                then titulo.titvlcob
                else 0.
            
                
end.

for each tt-contratos where
    tt-contratos.titvlabe <= 0.
    delete tt-contratos.
end.        



end.



procedure con-filial:
    def input parameter  vfilial as int.
    def output parameter vstatus as log.
    def var vip as char.
    
    vip = "filial" + string(vfilial,"999").
    
    hide message no-pause.
    message "Conectando...>>>>>   " vip.
  
    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja no-error.
    if not connected ("finloja")   
    then do:
        vstatus = no.
    end.
    else do:        
        vstatus = yes.
    end.  
    hide message no-pause.   
    
end procedure.


