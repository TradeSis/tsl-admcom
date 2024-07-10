/*** Admcom ***/
def var vprogr-emis as char.
/*** ***/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqcom1         as char format "x(14)" extent 5
    initial [" 1.Manutencao ", " "," 3.Filtro "," 4.Pesquisa "," "].
/*
    initial [" 1.Manutencao ", " 2.Inclui "," 3.Filtro "," 4.Listagem "," "].
*/
def var esqcom2         as char format "x(14)" extent 5
    initial ["","","",""," 0.Opcoes "].
/*
    initial ["  "," 7.Relatorio "," 8.Etiquetas ",""," 0.Opcoes "].
*/

form
    esqcom1
    with frame f-com1
               row 5 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes.
                     
{cabec.i}                     
        
def var par-periodo     as   log .
def var par-numero      like plani.numero.
def var par-busca       as   char.

def input parameter par-parametro as char.        /*Claudia - solic 22994*/

def var par-movtdcs    as char.    /* tipmov[01]s possiveis */
def var par-funcoes     as char.    /* Consulta/manutencao */

def var vtotal        as dec.
def var vi as int.
def var par-char as char init "".
def var par-movtdc like tipmov.movtdc.
def var vmovtdc    like tipmov.movtnom extent 15.
def buffer bclien  for clien.
def buffer bforne  for forne.
def buffer bestab  for estab.

def var vpor            as char.
def var vlabel          as   char.
def var vemitdest       as   char format "x(22)" extent 4.
def var vesc            as   char format "x(3)" extent 4.

def var par-dtini   as date format "99/99/9999".
def var par-dtfim   as date format "99/99/9999".
def var vclifor     as int.


function Le returns char
    (input par-onde as char).

if vpor = "DESTI"
then do:
    if par-onde = "first"
    then
        if par-periodo
        then find first plani where
                              plani.desti = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.dtinclu >= par-dtini and
                              plani.dtinclu <= par-dtfim
                                        no-lock no-error.
                                        
        else 
            if par-busca = "NUMERO"
            then find first plani where
                              plani.desti = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.numero = par-numero
                                        no-lock no-error.
        else
            find first plani where
                          plani.desti = vclifor and
                          plani.movtdc = par-movtdc
                                    no-lock no-error.

    if par-onde = "last"
    then
        if par-periodo
        then find last plani where
                             plani.desti = vclifor and
                             plani.movtdc = par-movtdc and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                                        no-lock no-error.
        else
            if par-busca = "NUMERO"
            then
                find last plani where
                              plani.desti = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.numero = par-numero
                                        no-lock no-error.
        else
            find last plani where
                          plani.desti = vclifor and
                          plani.movtdc = par-movtdc
                                        no-lock no-error.

    if par-onde = "next"
    then
        if par-periodo
        then find next plani where
                             plani.desti = vclifor and
                             plani.movtdc = par-movtdc  and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                             no-lock no-error.
        else
            if par-busca = "NUMERO"
            then
                find next plani where
                              plani.desti = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.numero = par-numero
                              no-lock no-error.
        else
            find next plani where   
                          plani.desti = vclifor and
                          plani.movtdc = par-movtdc
                          no-lock no-error.

    if par-onde = "prev"
    then
        if par-periodo
        then find prev plani where
                             plani.desti = vclifor and
                             plani.movtdc = par-movtdc and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                        no-lock no-error.
        else
            if par-busca = "NUMERO"
            then
                find prev plani where
                              plani.desti = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.numero = par-numero
                              no-lock no-error.
            else
                find prev plani where
                               plani.desti = vclifor and
                               plani.movtdc = par-movtdc
                               no-lock no-error.
end.

if vpor = "EMITE" /* Admcom nao tem indice */
then do.
    if par-onde = "first"
    then
        if par-periodo
        then find first plani where
                              plani.emite = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.dtinclu >= par-dtini and
                              plani.dtinclu <= par-dtfim
                              no-lock no-error.
        else
        if par-busca = "NUMERO"
        then
            find first plani where
                              plani.emite = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.numero = par-numero
                              no-lock no-error.
        else
            find first plani where
                              plani.emite = vclifor and
                              plani.movtdc = par-movtdc
                              no-lock no-error.

    if par-onde = "last"
    then
        if par-periodo
        then find last plani where
                             plani.emite = vclifor and
                             plani.movtdc = par-movtdc and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                             no-lock no-error.
        else
        if par-busca = "NUMERO"
        then
            find last plani where
                               plani.emite = vclifor and
                               plani.movtdc = par-movtdc and
                               plani.numero = par-numero
                               no-lock no-error.
        else
            find last plani where
                               plani.emite = vclifor and
                               plani.movtdc = par-movtdc
                               no-lock no-error.

    if par-onde = "next"
    then
        if par-periodo
        then find next plani where
                             plani.emite = vclifor and
                             plani.movtdc = par-movtdc and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                             no-lock no-error.
        else
        if par-busca = "NUMERO"
        then find next plani where
                                plani.emite = vclifor and
                                plani.movtdc = par-movtdc and
                                plani.numero = par-numero
                                no-lock no-error.
        else
            find next plani where
                                plani.emite = vclifor and
                                plani.movtdc = par-movtdc
                                no-lock no-error.


    if par-onde = "prev"
    then
        if par-periodo
        then find prev plani where
                             plani.emite = vclifor and
                             plani.movtdc = par-movtdc and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                             no-lock no-error.
        else
            if par-busca = "numero"
            then
                find prev plani where
                              plani.emite = vclifor and
                              plani.movtdc = par-movtdc and
                              plani.numero = par-numero
                no-lock no-error.

        else
            find prev plani where 
                          plani.emite = vclifor and
                          plani.movtdc = par-movtdc
                no-lock no-error.
end.

/******
 ESTABELECIMENTO
*******/ 
if vpor = "ESTAB"
then do:    
    if par-onde = "Total"
    then
        if par-periodo
        then for each plani where 
                             plani.movtdc = par-movtdc and
                             plani.etbcod = vclifor and
                             /*plani.notsit = "F" and*/
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                       no-lock break by plani.dtinclu.   /*Clau*/
            vtotal = vtotal + plani.platot.
        end.
        else for each plani where 
                             plani.movtdc = par-movtdc and
                             plani.etbcod = vclifor /*and
                             plani.notsit = "F"*/
                       no-lock break by plani.dtinclu.   /*Clau*/
            vtotal = vtotal + plani.platot.
        end.

    if par-onde = "first"
    then
        if par-periodo
        then find first plani where 
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor and
                              plani.dtinclu >= par-dtini and
                              plani.dtinclu <= par-dtfim
                              no-lock no-error.
        else 
            if par-busca = "NUMERO"
            then
                find first plani where 
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor and
                              plani.numero = par-numero
                              no-lock no-error.
            else
                find first plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor
                              no-lock no-error.
    if par-onde = "last"
    then 
        if par-periodo
        then find last plani where 
                             plani.movtdc = par-movtdc and
                             plani.etbcod = vclifor and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                                        no-lock no-error.
        else 
            if par-busca = "NUMERO"
            then
                find last plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor and
                              plani.numero = par-numero
                                        no-lock no-error.
            else
                find last plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor
                                        no-lock no-error.
    if par-onde = "next"
    then 
        if par-periodo
        then find next plani where
                             plani.movtdc = par-movtdc and
                             plani.etbcod = vclifor and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                             no-lock no-error.
        else 
            if par-busca = "NUMERO"
            then
                find next plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor and
                              plani.numero = par-numero
                              no-lock no-error.
            else
                find next plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor
                              no-lock no-error.
    if par-onde = "prev"
    then 
        if par-periodo
        then find prev plani where
                             plani.movtdc = par-movtdc and
                             plani.etbcod = vclifor and
                             plani.dtinclu >= par-dtini and
                             plani.dtinclu <= par-dtfim
                             no-lock no-error.
        else 
            if par-busca = "NUMERO"
            then
                find prev plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor and
                              plani.numero = par-numero
                              no-lock no-error.
            else
                find prev plani where
                              plani.movtdc = par-movtdc and
                              plani.etbcod = vclifor
                              no-lock no-error.
end.         
 
end function.


form with frame frame-a.

Procedure mostra-dados.

    def var vnome as char.

    if tipmov.movttra
    then do.
        find estab where estab.etbcod = plani.desti no-lock no-error.
        if avail estab
        then assign
               vnome      = estab.etbnom.
    end.

    display
        plani.serie   column-label "Ser"
        plani.numero  format ">>>>>>>>>>"
        plani.dtinclu format "99/99/99"
        string(plani.horincl, "hh:mm:ss") format "x(5)"
        vnome         column-label "Cliente" format "x(16)"
        opcom.opcnom  format "x(10)" no-label when avail opcom
/*        crepl.crenom when avail crepl format "x(09)" no-label*/
        plani.platot
/*        plani.notsit  column-label "Sit" format "x(3)"*/
        with frame frame-a 10 down centered row 6.

end procedure.

if num-entries(par-parametro,"|") = 1
then assign
        par-funcoes  = "Consulta"
        par-movtdcs = entry(1,par-parametro,"|").
else assign
        par-funcoes  = entry(1,par-parametro,"|")
        par-movtdcs = entry(2,par-parametro,"|").

repeat.
    assign
       par-periodo = no
       par-busca   = ""
       par-char    = ""
       par-dtini   = ?
       par-dtfim   = ?
       vemitdest   = ""
       vesc        = "".

    if par-movtdcs <> "?" 
    then do:
        do vi = 1 to num-entries(par-movtdcs).
            find tipmov where tipmov.movtdc = int(entry(vi,par-movtdcs))
                        no-lock.
            vmovtdc[vi] = string(tipmov.movtdc, ">>9") + "." +
                          string(tipmov.movtnom, "x(44)") + " " +
/***
                          (if tipmov.xx-pncod <> 0
                           then "v" + string(tipmov.xx-pncod, ">>9")
                           else "    ") + " " +
***/
                          (if tipmov.movtnota then "EMITE " else "DIGITA") +
                          (if tipmov.movtest = no
                           then "" else " Movimenta Estoque").
        end.

        if num-entries(par-movtdcs) = 1
        then par-movtdc = int(par-movtdcs).
        else

        repeat on endkey undo, leave.
            disp
                vmovtdc format "x(78)"
/*                    help "F7 para pesquisar CODIGOS DE OPERACAO" skip*/
                    with frame fchoose-opcom row 5 no-label overlay
                    title " Tipos de Movimentacao ".
            choose field vmovtdc auto-return
/*                    go-on(F7)*/
                    with frame fchoose-opcom.
            par-movtdc = int(entry(frame-index,par-movtdcs)).
/*
            if keyfunction(lastkey) = "HELP"
            then do:
                sretorno = string(par-movtdc).
                run zopcomt.p.
            end.
            else*/ leave.
        end.
        if keyfunction(lastkey) = "END-ERROR"
        then undo, leave.
    end.

    find tipmov where tipmov.movtdc = par-movtdc no-lock.
    disp tipmov.movtdc  format ">>9" colon 25
         tipmov.movtnom format "x(45)"
         with frame ftipmov row 3 side-labels color messages no-box
            width 80 no-labels overlay.

    if tipmov.movttra
    then
        assign
            vemitdest[1] = "1.Filial Origem"
            vemitdest[2] = "2.Filial Destino"
            vesc[1]      = "ETBEMI"
            vesc[2]      = "ETBDES".

    if tipmov.movttra = no
    then
        assign
            /***vemitdest[1] = "1.Emitente"***/
            vemitdest[2] = "2.Destinatario"
            vemitdest[1] = "1.Por Filial"
            /***vesc[1]      = "EMITE"***/
            vesc[2]      = "DESTI"
            vesc[1]      = "ESTAB".
    
    display vemitdest
            with frame fchoose row 6 col 5 no-label 1 col.
    choose field vemitdest
                with frame fchoose.

    par-char = vesc[frame-index].
    hide frame fchoose no-pause.

    vpor = par-char.
    if par-char = "EMITE"
    then assign vlabel = "Emitente".
    if par-char = "DESTI"
    then assign vlabel = "Destinatario".
    if par-char = "ESTAB"
    then assign vlabel = "Filial".
    if par-char = "ETBEMI"
    then assign vlabel = "Filial Origem"
                vpor = "ESTAB".
    if par-char = "ETBDES"
    then assign vlabel = "Filial Destino"
                vpor = "DESTI".
                
    if par-char = "ESTAB" or par-char = "ETBEMI" or par-char = "ETBDES"
    then do.
        display setbcod @ bestab.etbcod colon 16 label "Estab.         "
                        with frame fini.
        bestab.etbcod:label in frame fini = vlabel.
        prompt-for bestab.etbcod
               with frame fini side-label row 4 color message width 81 no-box.
        find bestab where bestab.etbcod = input frame fini bestab.etbcod
                    no-lock no-error.
        disp bestab.etbnom no-label with frame fini.
        vclifor = bestab.etbcod.
    end.

    if par-char = "EMITE" or
       par-char = "DESTI"
    then do with frame finiag
                overlay side-label row 4 color message width 81 no-box:
        disp "" @ bclien.clicod.
        bclien.clicod:label = vlabel.
        prompt-for bclien.clicod colon 15
                                   with frame finiag.
        sretorno = "".
        vclifor = input frame finiag bclien.clicod.
    end.                                           

    pause 0.

    if par-funcoes = "Consulta"
    then assign
            esqcom1[2] = "".
    else do.
/***
        vprogr-emis = "nfe-" + string(tipmov.movtdc, "999") + ".p".
        if search(vprogr-emis) <> ?
        then
***/
            if tipmov.movtnota = yes
            then esqcom1[2] = " 2.Emite ".
            else esqcom1[2] = " 2.Inclui ".
    end.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then le("last").
    else find plani where recid(plani) = recatu1 no-lock.
    if not available plani
    then do.
        esqvazio = yes.
        if esqcom1[2] = " 2.Inclui " or esqcom1[2] = " 2.Emite "
        then esqpos1 = 2.
        else do:
            message "Nenhuma Nota nesta Selecao".
            pause.
            leave.
        end.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run mostra-dados.
   /* else leave.*/

    recatu1 = recid(plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        le("prev").
        if not available plani
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run mostra-dados.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find plani where recid(plani) = recatu1 no-lock.
            find first docrefer where
                   docrefer.numori      = plani.numero and
                   docrefer.serieori    = plani.serie  and
                   docrefer.codedori    = plani.emite  and
                   docrefer.dtemiori    = plani.pladat
                   no-lock no-error.
            esqcom2[1] = if avail docrefer
                         then "6.NF Associada" else "".
            display esqcom2 with frame f-com2.

            status default "".
            run color-message.
            choose field plani.numero help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0
                      tab PF4 F4 ESC return) .

            run color-normal.
            status default "".
        end.

            if keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or
               keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or
               keyfunction(lastkey) = "5"
            then do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqregua = yes.
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = int(keyfunction(lastkey)).
                color display message esqcom1[esqpos1] with frame f-com1.
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
                    le("prev").
                    if not avail plani
                    then leave.
                    recatu1 = recid(plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    le("next").
                    if not avail plani
                    then leave.
                    recatu1 = recid(plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                le("prev").
                if not avail plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                le("next").
                if not avail plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio or
           keyfunction(lastkey) = "1" or 
           keyfunction(lastkey) = "2" or 
           keyfunction(lastkey) = "3" or 
           keyfunction(lastkey) = "4" or 
           keyfunction(lastkey) = "5" or 
           keyfunction(lastkey) = "6" or 
           keyfunction(lastkey) = "7" or 
           keyfunction(lastkey) = "8" or 
           keyfunction(lastkey) = "9"  
        then do on error undo, retry on endkey undo, leave:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " 1.Manutencao "  
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame ftotal  no-pause.
                    def var vnotsit like plani.notsit.
                    vnotsit = plani.notsit.
                    recatu1 = recid(plani).
                    run not_consnota.p (input recid(plani)). 
                    find plani where recid(plani) = recatu1 no-lock no-error.
                    if not avail plani or vnotsit <> plani.notsit
                    then 
                        recatu1 = ?.
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.

                if esqcom1[esqpos1] = " 2.Emite "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    if tipmov.movtnota = no
                    then /***run not/nfentin.p (input par-movtdc,
                                            input-output recatu1)***/.
                    else do:
                        /***run value(vprogr-emis) (tipmov.movtdc).***/
                        run emite-nfe.
                    end.                
                    view frame fini.
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                end.

                if esqcom1[esqpos1] = " 3.Filtro "
                then do:
                    run filtro.
/*                    view frame ftotal.*/
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " 4.Pesquisa "
                then do:
                    run pesquisa.
                    leave.
                end.

                if esqcom1[esqpos1] = " 4.Listagem "
                then do:
                   run listagem.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] =  " 7.Relatorio "
                then do:
                    run impressao. 
                    leave.
                end.
                if esqcom2[esqpos2] =  " 0.Opcoes "
                then do:
                    pause 0.
                    run not_opcplani.p (recid(plani)).
                    leave.
                end.
                if esqcom2[esqpos2] = "6.NF Associada"
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run not_assnot.p (recid(plani)).
                    view frame frame-a.
                    view frame f-com1.
                    view frame f-com2.
                end.
            end.
        end.

        if not esqvazio
        then run mostra-dados.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(plani).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.
hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame f-plani1 no-pause.
hide frame f-plani2 no-pause.

end.
hide frame fini no-pause.

procedure color-message.
    color display message
        plani.numero
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        plani.numero
        with frame frame-a.
end procedure.

procedure numero-nota.   

do with frame fproc side-label centered row 10 overlay color message. 
    prompt-for plani.numero colon 10 format ">>>>>>>>>>".
    par-numero = input frame fproc plani.numero.
    par-periodo = no.
    par-busca = "NUMERO".
    recatu1 = ?.
/*    run total.*/
    leave.
end. 

end procedure.


procedure periodo.
/*    run total.*/
    pause 0.
    update "Periodo" 
           par-dtini  
           par-dtfim 
           with frame fperiodo overlay row 20 color message no-label no-box.
    hide frame fperiodo no-pause.
    par-periodo = yes.  
end procedure.


procedure filtro. 

    view frame f-com1. 
    def var vtipobusca as char format "x(55)" extent 4 /* 11 */
            init [ "1.Geral  " ,
                   "2.Por Numero de Nota Fiscal" ,
                   "3.Por Periodo " ,
                   "" ].
    def var ctipobusca as char format "x(20)" extent 4 /* 11 */
            init [ "GERAL" , 
                   "NUMERO" ,   
                   "PERIODO",
                   ""].
        
    def var vescolha as char.
    def var rectit as recid.
    def var recag as recid.
    pause 0.
    display " T i p o s   d e   B u s c a s " at 16
            skip(7) /* 14 */
            with frame fmessage color message row 4 width 64 no-box overlay.
    pause 0.
    display vtipobusca at 4
            with frame ftipobusca  column 3 row 5  no-label overlay  1 column.
         
    choose field vtipobusca auto-return with frame ftipobusca.
    vescolha = ctipobusca[frame-index].
    hide frame ftipobusca no-pause.
    hide frame fmessage no-pause.
        recag = ?.
        rectit = ?.
        if vescolha = "periodo"
        then do: 
            run periodo.
            par-busca = "". 
            recatu1 = ?. 
/*            run total.*/
            leave.
        end.
        if vescolha = "numero"
        then do:   
            run numero-nota.
        end.

        if vescolha = "geral"
        then do: 
            par-periodo = no. 
            par-busca = "". 
            recatu1 = ?. 
/*            run total.*/
            leave.
        end.

end procedure.


procedure pesquisa.

    view frame f-com1. 
    def var vtipobusca as char format "x(55)" extent 11.
    def var ctipobusca as char format "x(20)" extent 11.
    def var vescolha as char.
    def var rectit   as recid.
    def var vnumero  as int.
    def var vecf     as int.
    def buffer bplani for plani.

    if tipmov.movtvenda and tipmov.movtdev = no
    then assign
            vtipobusca[1] = " Cupom Fiscal"
            ctipobusca[1] = "CF".

    pause 0.
    display " T i p o s   d e   P e s q u i s a s " at 16
            skip(14)
            with frame fmessage color message row 4 width 64 no-box overlay.
    pause 0.
    display vtipobusca at 4
            with frame ftipobusca  column 3 row 5  no-label overlay  1 column.
         
    choose field vtipobusca auto-return with frame ftipobusca.
    vescolha = ctipobusca[frame-index].
    hide frame ftipobusca no-pause.
    hide frame fmessage no-pause.

    if vescolha = "CF"
    then do.
        update
            vnumero label "Cupom Fiscal" format ">>>>>9"
            vecf    label "ECF" format ">>9"
            with frame f-cf side-label.
        find first bplani where bplani.movtdc = par-movtdc
                          and bplani.etbcod = bestab.etbcod
                          and bplani.notped matches 
                                          "*" + string(vnumero) + "|" + 
                                          string(vecf) + "*"
                           no-lock no-error.
        if avail bplani
        then recatu1 = recid(bplani).
        hide frame f-cf no-pause.
    end.

end procedure.


procedure emite-nfe.

    if sremoto
    then
        /*** LOJAS ***/
        case par-movtdc.
            when  6 then run loj/nftra_NFe.p.
            when 11 then run loj/nfoutent.p (par-movtdc).
            when 26 then run loj/nfoutsai.p.
            when 46 then run nfe_5102.p.
            when 53 then run loj/nfoutent.p (par-movtdc).
            when 57 then run loj/nfoutent.p (par-movtdc).
            otherwise message "Emissao de NFE indisponivel" view-as alert-box.
        end case.
    else
        /*** MATRIZ ***/
        case par-movtdc.
            when  6 then run nftra.p.
            when  9 then run nfe-009.p.
            otherwise message "Emissao de NFE indisponivel" view-as alert-box.
        end case.

end procedure.

