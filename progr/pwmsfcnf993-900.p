/*  pwmsfcnf.p  */
{admcab.i}
setbcod = 993.
def var vsaldo as dec.
def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec.
    def var vdesval as dec.
    def var prazo as dec.
 
def buffer btitulo for titulo.
def var simpnota as log init no.
def buffer cprodu for produ.
def var vlibera as log init no.
def var ped-especial as log init no.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Fechar "," Consulta "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
/*def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " Exclusao  da plani ",
             " Consulta  da plani ",
             " Listagem  Geral de plani "].
             
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].*/


def buffer bplani       for plani.
def var vplani         like plani.numero.


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


find first plani where plani.movtdc = 4 
                    and plani.etbcod = setbcod 
                    and plani.notsit = yes no-lock no-error.  
                    
if not avail plani
then do:
    message "Nenhuma Nota Fiscal Aberta.". 
    pause 2 no-message. 
    setbcod = 900.
    return.
end.    
 

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find plani where recid(plani) = recatu1 no-lock.
    if not available plani
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(plani).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available plani
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
            find plani where recid(plani) = recatu1 no-lock.

            /*status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(plani.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(plani.numero)
                                        else "".*/
            run color-message.
            choose field plani.pladat  
                         plani.numero 
                         plani.serie 
                         plani.emite 
                         forne.fornom 
                         plani.platot 
                         plani.notsit
            
            help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
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
~                if esqregua
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
                    if not avail plani
                    then leave.
                    recatu1 = recid(plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail plani
                    then leave.
                    recatu1 = recid(plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail plani
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail plani
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

            if esqvazio
            then do:
                message "Nenhuma Nota Fiscal Aberta.".
                pause 2 no-message.
                return.
 
            end.
            
            form plani
                 with frame f-plani color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Fechar "
                then do with frame f-plani on error undo.

                    sresp = no.
                    run bloqent.p(input recid(plani),
                                  output sresp).
                    if sresp = no
                    then do:
                        message color red/with
                            "FECHAMENTO BLOQUEADO POR FALTA DE SERIAIS." skip
                            "COMUNIQUE DEPARTAMENTO DE COMPRAS"
                            view-as alert-box.
                        leave.
                    end.              
                    view frame frame-a. pause 0.
                    recatu1 = recid(plani).
                    /****
                    find divplaniwms where 
                         divplaniwms.plani-PlaCod     = plani.PlaCod  and
                         divplaniwms.plani-EtbCod     = plani.EtbCod  
                          no-lock no-error.
                    if avail divplaniwms 
                    then do.
                        find wmsplani where  
                             wmsplani.EtbCod = divplaniwms.wmsplani-EtbCod  and
                             wmsplani.PlaCod = divplaniwms.wmsplani-PlaCod
                             no-lock no-error.   
                        if avail wmsplani and
                           wmsplani.plasit = "X"
                        then do on error undo. 
                            run divplaniwms.p (recid(divplaniwms)).
                        /*  leave.*/
                        end.
                    end.
                    ***/
                    sresp = no.
                    message "Confirma o fechamento da Nota Fiscal?"
                            update sresp.
                    if not sresp
                    then leave.
                    
                    ped-especial = no.
                    run ver-ped-esp.
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock.
                        find cprodu where cprodu.procod = movim.procod no-lock.
                        if ped-especial = no and cprodu.proipival <> 1
                        then do:
                            run gera-p-dis.
                        end.
                        do transaction:
                            run atuest.p(input recid(movim),
                                         input "I",
                                         input 0).
                            find estoq where estoq.etbcod = movim.etbcod and
                                         estoq.procod = movim.procod
                                         no-lock .
                        end.
                    end.

                    find plani where recid(plani) = recatu1 no-error.
                    do on error undo:
                        plani.notsit = no.
                        find current plani no-lock.
                    end.
                    
                    find first titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero)
                              no-lock no-error.
                    if not avail titulo
                    then do:   
                        if plani.opccod <> 1910 and
                           plani.opccod <> 2910 and
                           plani.opccod <> 2949
                        then run atu-fat-finan.
                    end.

                    /****
                    if today >= 04/28/2014
                    then do:
                        run removest-nf.p(plani.movtdc,
                                      plani.etbcod,
                                      plani.emite,
                                      plani.serie,
                                      plani.numero).
                        setbcod = 993.
                    end.
                    *****/
                    recatu1 = ?.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Consulta "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.

                    display plani.emite  label "Emi"
                            plani.desti  label "Des"
                            plani.pladat label "Emi"
                            plani.numero
                            plani.notsit
                            with frame f-tit centered side-label row 4.

                    for each movim where movim.etbcod = plani.etbcod
                                     and movim.placod = plani.placod
                                     and movim.movtdc = plani.movtdc
                                     and movim.movdat = plani.pladat no-lock:

                        find produ where 
                             produ.procod = movim.procod no-lock no-error. 

                        disp movim.procod format ">>>>>>>>>9"
                             produ.pronom format "x(35)" when avail produ
                             movim.movqtm column-label "Qtd"
                             movim.movpc  column-label "Val"
                             with frame f-con 10 down row 7 centered 
                                        title " Produtos ".
                                        
                    end. 

                    pause.
                    
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                    
                    recatu1 = recid(plani).
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
        recatu1 = recid(plani).
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

setbcod = 900.

procedure frame-a.
    
    find forne where forne.forcod = plani.emite no-lock no-error.
    
    /*Nede adicionado format no display do plani.numero 21/03/2012*/
    display plani.pladat 
            plani.numero format "9999999"
            plani.serie
            plani.emite
            forne.fornom when avail forne format "x(15)"
            plani.platot
            plani.notsit
            with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
    find forne where forne.forcod = plani.emite no-lock no-error.

    color display message
plani.pladat 
            plani.numero
            plani.serie
            plani.emite
            forne.fornom when avail forne
            plani.platot
            plani.notsit

            with frame frame-a.
end procedure.
procedure color-normal.
    find forne where forne.forcod = plani.emite no-lock no-error.

    color display normal
plani.pladat 
            plani.numero
            plani.serie
            plani.emite
            forne.fornom when avail forne
            plani.platot
            plani.notsit

            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first plani where plani.movtdc = 4
                           and plani.etbcod = setbcod
                           and plani.notsit = yes no-lock no-error.

    else  
        find last plani  where plani.movtdc = 4
                           and plani.etbcod = setbcod
                           and plani.notsit = yes no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next plani  where plani.movtdc = 4
                           and plani.etbcod = setbcod
                           and plani.notsit = yes no-lock no-error.
    else  
        find prev plani   where plani.movtdc = 4
                           and plani.etbcod = setbcod
                           and plani.notsit = yes no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev plani where plani.movtdc = 4
                           and plani.etbcod = setbcod
                           and plani.notsit = yes no-lock no-error.
    else   
        find next plani where plani.movtdc = 4
                           and plani.etbcod = setbcod
                           and plani.notsit = yes no-lock no-error.
        
end procedure.

procedure ver-ped-esp:
    def buffer bpedid for pedid.
    ped-especial = no.
    for each plaped where plaped.forcod = plani.emite and
                          plaped.numero = plani.numero
                          no-lock,
        first pedid where pedid.etbcod = plaped.pedetb and
                          pedid.pedtdc = plaped.pedtdc and
                          pedid.pednum = plaped.pednum and
                          pedid.pedtdc = 1
                          no-lock:
        find first bpedid where 
                   (bpedid.pedtdc = 4 or
                    bpedid.pedtdc = 6) and
                   bpedid.pedsit = yes and
                   bpedid.comcod = pedid.pednum
                   no-lock no-error.
        if avail bpedid           
        then do:
            ped-especial = yes.
            leave.
        end.
    end.
end procedure.

procedure gera-p-dis:
    vlibera = yes.
    find first hiest where hiest.etbcod = movim.etbcod and
                     hiest.procod = movim.procod    
                     no-lock no-error.
    if not avail hiest
    then do:
        for each estab where estab.etbnom matches "*DREBES-FIL*" no-lock:
            run ver-cnt-repos.
            if vlibera = no then next.           
            find pedid where pedid.etbcod = estab.etbcod and
                             pedid.pedtdc = 7 and
                             pedid.pednum = estab.etbcod
                             no-error.
            if not avail pedid
            then do:
                create pedid.
                assign
                    pedid.pedtdc = 7
                    pedid.etbcod = estab.etbcod
                    pedid.pednum = estab.etbcod
                    pedid.pedsit = yes
                    pedid.sitped = "A"
                    pedid.peddat = today
                    .
            end.
            find liped where liped.pedtdc = pedid.pedtdc and
                             liped.etbcod = pedid.etbcod and
                             liped.pednum = pedid.pednum and
                             liped.procod = movim.procod and
                             liped.lipcor = "" /*and
                             liped.predt  = today*/
                             no-lock no-error.
            if not avail liped
            then do:                 
                             
            create liped.
            assign
                 liped.pedtdc = pedid.pedtdc
                 liped.etbcod = pedid.etbcod 
                 liped.pednum = pedid.pednum
                 liped.procod = movim.procod
                 liped.lipcor = ""
                 liped.predt  = today
                 liped.predtf = today + 8
                 liped.lipqtd = ?
                 liped.lipsit = "A"
                 liped.protip = "N"
                 .  
            end.                      
        end.
    end.    
    else do:
        find estoq where estoq.etbcod = movim.etbcod and
                         estoq.procod = movim.procod
                         no-lock no-error.
        if avail estoq and estoq.estatual = 0
        then do:
        for each estab where estab.etbnom matches "*DREBES-FIL*" no-lock:
            run ver-cnt-repos.
            if vlibera = no then next. 
            find pedid where pedid.etbcod = estab.etbcod and
                             pedid.pedtdc = 7 and
                             pedid.pednum = estab.etbcod
                             no-error.
            if not avail pedid
            then do:
                create pedid.
                assign
                    pedid.pedtdc = 7
                    pedid.etbcod = estab.etbcod
                    pedid.pednum = estab.etbcod
                    pedid.pedsit = yes
                    pedid.sitped = "A"
                    pedid.peddat = today
                    .
            end.
            find liped where liped.pedtdc = pedid.pedtdc and
                             liped.etbcod = pedid.etbcod and
                             liped.pednum = pedid.pednum and
                             liped.procod = movim.procod and
                             liped.lipcor = "" /*and
                             liped.predt  = today*/
                             no-lock no-error.
            if not avail liped
            then do:                 
                             
            create liped.
            assign
                 liped.pedtdc = pedid.pedtdc
                 liped.etbcod = pedid.etbcod 
                 liped.pednum = pedid.pednum
                 liped.procod = movim.procod
                 liped.lipcor = ""
                 liped.predt  = today
                 liped.predtf = today + 8
                 liped.lipqtd = ?
                 liped.lipsit = "A"
                 liped.protip = "R"
                 . 
            end.                      
        end.

        end.                     
    end.
end.         

procedure ver-cnt-repos:
    vlibera = yes.
    find first cntrepos where 
               cntrepos.tipo = 1 and     
               cntrepos.etbcod = estab.etbcod  and
               cntrepos.fabcod = 0 and
               cntrepos.catcod = 0 and
               cntrepos.clacod = 0
               no-lock no-error.
    if avail cntrepos and           
             cntrepos.campo1[1] = "Inativo"
                then vlibera = no.
end procedure.            

def var vdtemi as date.

procedure atu-fat-finan:
    
    def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec format ">>,>>>,>>9.99".
    def var vdesval as dec.
    def var prazo as dec.
    
    if month(today) <> month(plani.dtinclu)
    then vdtemi = today.
    else vdtemi = plani.dtinclu.

    find first titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock no-error.
    if not avail titulo
    then do:                          
    if plani.hiccod <> 599 and
       plani.hiccod <> 699
    then do:
    if simpnota = yes
    then do:
        do vi = 1 to 20:
            if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
            then leave.
            do transaction:
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = "DUP"
                       titulo.clifor = forne.forcod
                       titulo.titsit = "LIB"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = vdtemi
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = vi  .
                       
                titulo.titvlcob =
                        dec(acha("VAL-" + string(vi,"999"),placon.notobs[1])) 
                       .
                titulo.titdtven =
                        date(acha("DTV-" + string(vi,"999"),placon.notobs[1])) 
                        .
                vezes = vi.        
                vtotpag = vtotpag + titulo.titvlcob.
            end.
        end.
        run man-titulo.
    end.
    else do on error undo:
    
    if plani.platot = 0
    then vtotpag = plani.protot.
    else vtotpag = plani.platot.
    disp vezes vtotpag label "Total Faturamento" with frame f-pag.
    update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                with frame f-pag width 80 side-label centered color white/red
                row 7
                title " Informe os dados para faturamento  ".

    find first movim where movim.placod = plani.placod and
                           movim.etbcod = plani.etbcod no-lock no-error.
                           
    if avail movim and (plani.hiccod <> 599 and plani.hiccod <> 699)
    then do on error undo, retry:
        update vtotpag with frame f-pag.
    
        if vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod)
        then do:
            message "Verifique os valores da nota".
            undo, retry.
        end.

        do i = 1 to vezes:
            do transaction:
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = "DUP"
                       titulo.clifor = forne.forcod
                       titulo.titsit = "lib"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = vdtemi
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = i.
                if prazo <> 0
                then assign titulo.titvlcob = vtotpag
                            titulo.titdtven = titdtemi + prazo.
                else assign titulo.titvlcob = vtotpag / vezes
                            titulo.titdtven = titulo.titdtemi + (30 * i).
                vsaldo = vsaldo + titulo.titvlcob.
            end.
        end.
        run man-titulo.
    end.
    end.
    end.
    end.
end procedure.

procedure man-titulo:
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi.
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            update prazo with frame ftitulo.
            do transaction:
                titulo.titdtven = plani.pladat + prazo.
                titulo.titvlcob = vsaldo.
                update titulo.titdtven
                       titulo.titvlcob with frame ftitulo no-validate.
            end.
            vsaldo = vsaldo - titulo.titvlcob.
        
            find titctb where titctb.forcod = titulo.clifor and
                              titctb.titnum = titulo.titnum and
                              titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do transaction:
                create titctb.
                ASSIGN titctb.etbcod   = titulo.etbcod
                       titctb.forcod   = titulo.clifor
                       titctb.titnum   = titulo.titnum
                       titctb.titpar   = titulo.titpar
                       titctb.titsit   = titulo.titsit
                       titctb.titvlpag = titulo.titvlpag
                       titctb.titvlcob = titulo.titvlcob
                       titctb.titdtven = titulo.titdtven
                       titctb.titdtemi = titulo.titdtemi
                       titctb.titdtpag = titulo.titdtpag.
            end.
            down with frame ftitulo.
        end.
        if plani.frete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = plani.emite
                   btitulo.cxacod   = plani.emite
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vdtemi
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = plani.frete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end. 
end procedure.



