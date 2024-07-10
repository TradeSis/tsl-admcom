/*              not/nfbusca.p           */
{admcab.i}
def var vbusca as char format "x(10)".
def var primeiro as log. 
def var vresumo as log.
    def buffer xclasesup for clase.
    def buffer xsclase   for clase.
    def buffer xsetor for setor.
    def buffer xclase for clase.


def buffer desclien for clien.

def workfile wfclien
    field clicod        like clien.clicod init 0.
def buffer bwfclien for wfclien.

def var vmovtdc like tipmov.movtdc.
def var vemite  like plani.emite.
def var listaemite as char.
def var vemitet as log init yes.
def var vdesti  like plani.desti.
def var vdtini  as date format "99/99/9999".
def var vdtfin  as date format "99/99/9999".
def var vserie  like plani.serie.
def var vnumero like plani.numero.
def var vetbcod like estab.etbcod.
def var vopcom  like opcom.opccod.
def var vdata as date. 
def var vetbemi like estab.etbcod. 
def var vetbdes like estab.etbcod.
/*def var vcomromaneio as log format "Sim/Nao" init ?.*/
def var vtransf as log.
def buffer bclien for clien.
def buffer emi-estab for estab.
def buffer des-estab for estab.
def new shared  temp-table tt-plani
    field rec   as recid
    field dtinclu   like plani.dtinclu
    field opctip    like opcom.opctip
    field numero    like plani.numero
    index opctip    opctip dtinclu   numero
    
    .

def var clacod-grupo like clase.clacod.
def var setcod-setor like setor.setcod.
def var vfabcod      like fabri.fabcod.
/*
def var vroman as char extent 3 format "x(15)"
            init [" Geral "," Com Romaneio "," Sem Romaneio "].*/
form vmovtdc label "Tipo de Movimento" colon 20 format ">>>"
     help "Informe o Tipo de Movimentacao"
     tipmov.movtnom  no-label   
     vetbcod colon 20
     estab.etbnom no-label
     vdtini  label "Data Inicial"       colon 20
     help "Informe a Data Inicial"
     vdtfin  label "Data Final"
     help "Informe a Data Final"
     with frame f1 1 down side-label width 80 color with/cyan .
form with frame fimpressao.
     
repeat with frame f1.       
    release tipmov.
    release opcom.
    clear frame f1 all.
    
    assign
        vmovtdc = 0 .
        vetbcod = 0  .
        vemite = 0. vdesti = 0.
        
        listaemite = "".
        
        vopcom = "".
        vmovtdc = 0.
        vemite  = 0.
        vdesti  = 0.
        clacod-grupo = 0.
        vfabcod = 0.
        vserie  = "".
        vetbcod = 0.
        vetbemi = 0.
        vetbdes = 0.
/*        vcomromaneio = ?.*/
        vtransf = no.
    update vmovtdc  with frame f1.
    if vmovtdc > 0
    then do:
        find tipmov where tipmov.movtdc = vmovtdc
                        no-lock no-error.
        if not avail tipmov
        then do:
            bell.
            message color red/with
                "Codigo Invalido para Movimentacao"
                view-as alert-box title " Atencao!! ".
            next.
        end.        
        display tipmov.movtnom  with frame f1.
    end.
    update vetbcod .
    if vetbcod > 0
    then do.
       find estab where estab.etbcod = vetbcod no-lock no-error.
       if not avail estab
       then do.
          message "Estabelecimento invalido" view-as alert-box.
          undo.
       end.
       disp estab.etbnom.
    end.


    vdtini = ?.
    vdtfin = ?.
    update vdtini vdtfin with frame f1.
    if vdtini = ? or vdtfin = ? or vdtini > vdtfin
    then do:
        bell.
        message color red/with
            "Periodo Invalido" view-as alert-box title " Atencao!! ".
        next.
    end.        

for each tt-plani.
   delete tt-plani.
end.

def var vokcla as log.
def var vokfab as log.
def var vokset as log.
vokfab = yes.
vokcla = yes.
vokset = yes.

do vdata = vdtini to vdtfin.
    
    disp vdata with frame ff 1 down. pause 0.
    for each tipmov where (if vmovtdc <> 0
                           then tipmov.movtdc = vmovtdc 
                           else true) no-lock.
    for each estab where (if vetbcod > 0
                          then estab.etbcod = vetbcod else true)
                          no-lock:
    disp estab.etbcod with frame ff. pause 0.
    for each plani where plani.dtinclu = vdata   and
                         plani.etbcod  = estab.etbcod and
                         plani.movtdc  = tipmov.movtdc
                  no-lock.
        find opcom where opcom.opccod = string(plani.hiccod) no-lock no-error.
        if not avail opcom then next.
        create tt-plani. 
        assign
        tt-plani.rec     = recid(plani)
        tt-plani.opctip  = opcom.opctip 
        tt-plani.numero  = plani.numero 
        tt-plani.dtinclu = plani.dtinclu.
    end.
    end.
    end.
end.

/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio


            substituir    <tabela>
                          <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Relatorio ", " "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " "].

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
    recatu1 = ?.

def var vpor       as log format "Destinatario/Emitente".


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-plani where recid(tt-plani) = recatu1 no-lock.
    if not available tt-plani
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
       message "Notas fiscais nao localizadas" view-as alert-box.
       leave.
    end.

    recatu1 = recid(tt-plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-plani
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
            find tt-plani where recid(tt-plani) = recatu1 no-lock.

/***
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(<tabela>.<tab>nom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(<tabela>.<tab>nom)
                                        else "".
***/
            choose field plani.numero help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0 
                      page-down   page-up
                      tab PF4 F4 ESC return).

            status default "".
            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" 

            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                find first tt-plani where tt-plani.numero =
                                int(vbusca) no-lock no-error.
                if avail tt-plani
                then recatu1 = recid(tt-plani). 
                else recatu1 = recatu2. 
                leave.
            end.


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
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plani
                then next.
                color display white/red plani.numero with frame frame-a.
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

                if esqcom1[esqpos1] = " Relatorio "
                then do.
                    /*vresumo = no.
                    run imprime.
                    hide frame fimpressao no-pause.
                    */
                    run relatorio.
                    leave.
                end.
                if esqcom1[esqpos1] = " Resumo "
                then do.
                    vresumo = yes.
                    run imprime.
                    hide frame fimpressao no-pause.
                    leave.
                end.
                if esqcom1[esqpos1] = " Imprime "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    run not/lnfbusca.p 
                    (recid(plani), vetbcod, vmovtdc, vemite, 
                    vdesti, vopcom, vdtini, vdtfin ).  
                    view frame frame-a.
                    view frame f-com1.
                    undo.
                end.

                if esqcom1[esqpos1] = " Consulta "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    run not_consnota.p (recid(plani)). 
                    view frame frame-a.
                    view frame f-com1.
                    leave.
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
        recatu1 = recid(tt-plani).
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

   def var vnome as char.
   def var vopcom as char.

   find plani where recid(plani) = tt-plani.rec no-lock.
   find crepl of plani no-lock no-error.
   find tipmov of plani no-lock.   
   
    /*nfpagc*/   

            
        display
                opctip column-label "Tipo"
                plani.etbcod
                plani.serie column-label "Ser"
                plani.numero format ">>>>>>>>9"
                plani.dtinclu format "99/99/99" 
                plani.pladat  format "99/99/99"
                plani.hiccod format "9999" column-label "CFOP"
                /*tipmov.movtnom  format "x(7)" column-label "Movimento"*/
                plani.movtdc format ">>9"
                plani.desti format ">>>>>>>>>9"
                plani.platot 
                with frame frame-a 10 down row 6 no-box
                width 80
                .
        
end procedure.
 
procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-plani where true
                                                no-lock no-error.
    else  
        find last tt-plani  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-plani  where true
                                                no-lock no-error.
    else  
        find prev tt-plani   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-plani where true  
                                        no-lock no-error.
    else   
        find next tt-plani where true 
                                        no-lock no-error.
        
end procedure.
 

procedure relatorio:

    def var varquivo as char.
    varquivo = "/admcom/relat/nfbusca." + string(time).
    
    output to value(varquivo).
    
    for each tt-plani.
        def var vnome as char.
   def var vopcom as char.

   find plani where recid(plani) = tt-plani.rec no-lock.
   find crepl of plani no-lock no-error.
   find tipmov of plani no-lock.   
   
    /*nfpagc*/   

            
        display
                opctip column-label "Tipo"
                plani.etbcod
                plani.emite  
                plani.serie column-label "Ser"
                plani.numero format ">>>>>>>>9"
                plani.dtinclu format "99/99/99" 
                plani.pladat  format "99/99/99"
                plani.hiccod format "9999" column-label "CFOP"
                /*tipmov.movtnom  format "x(7)" column-label "Movimento"*/
                plani.movtdc format ">>9"
                tipmov.movtnom no-label
                plani.desti format ">>>>>>>>>9"
                plani.platot 
                with frame frame-r down 
                width 150
                .
    end.    
    
    output close.
    
    run visurel.p(varquivo,"").
end procedure.
