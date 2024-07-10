/*
*
*    produpai.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input  parameter par-catcod like produpai.catcod.

def var vbusca as char format "xxxxxxx". 
def var primeiro as log.
def buffer xprodupai for produpai.
def buffer bcategoria for categoria.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Grade "," Inclusao "," Consulta "," Alteracao "," Packs "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Opcoes "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial [" Opcoes ", " "].

def var vprocod as int.
def var vclacod like produ.clacod.
def var par-rec as recid.
def buffer bprodupai       for produpai.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vpreco      as dec.
find categoria where categoria.catcod = par-catcod no-lock.

bl-princ:
repeat:
    display "Tipo: "   
            categoria.catcod  
            categoria.catnom  
        with frame fcategoria 1 down overlay  
                        no-label column 1 row 3 color message no-box.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find produpai where recid(produpai) = recatu1 no-lock.
    if not available produpai
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(produpai).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available produpai
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
            find produpai where recid(produpai) = recatu1 no-lock.

            disp produpai.pronom
                 produpai.prorefter
                 with frame fsub
                 row 20 overlay
                 no-labels
                 no-box width 80.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(produpai.pronom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(produpai.pronom)
                                        else "".

            choose field produpai.itecod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      page-down   page-up F7 PF7
                      tab PF4 F4 ESC return) .

            status default "".
            if keyfunction(lastkey) >= "0" and
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message no-label
                                frame f-procura side-label overlay:
                if keyfunction(lastkey) <> "HELP"
                then 
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
                find xprodupai where 
                     xprodupai.itecod = int(vbusca) no-lock no-error. 
                if avail xprodupai
                then do:
                    if xprodupai.catcod <> par-catcod
                    then do. 
                        find bcategoria of xprodupai no-lock.
                        message "Produto e´ " bcategoria.catnom 
                                        view-as alert-box.
                    end.
                    else do.
                        vclacod = 0.
                        recatu1 = recid(xprodupai).
                    end.
                end.
                else recatu1 = recatu1.
                leave.
            end.
            if keyfunction(lastkey) = "HELP"
            then do:
                sretorno = "".
                run applhelp.p.
                find produpai where produpai.itecod = int(sretorno)
                                    no-lock no-error.
                if avail produpai 
                then do:
                    recatu1 = recid(produpai) .
                end.
                next bl-princ.
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
                    if not avail produpai
                    then leave.
                    recatu1 = recid(produpai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail produpai
                    then leave.
                    recatu1 = recid(produpai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail produpai
                then next.
                color display white/red produpai.itecod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail produpai
                then next.
                color display white/red produpai.itecod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form produpai
                 with frame f-produpai color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Grade " and not esqvazio 
                then do:
                    find first produ of produpai no-lock no-error.
                    if not avail produ 
                    then do.
                        message "Produto Pai sem Filhos" view-as alert-box.
                        leave.
                    end.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cad_produpaisku.p (input recid(produpai)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do on error undo with frame f-produ.
                    par-rec = ?.
                    hide frame f-com1 no-pause.    
                    hide frame f-com2 no-pause.  
                    run cad_produman.p ("IncPAI",
                                    par-catcod,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    find first produpai where 
                        produpai.itecod = vprocod no-lock no-error.
                    if avail produpai
                    then recatu1 = recid(produpai).
                    leave.
/***
                    if avail produ                                             
                    then do:
                        par-itecod = produ.itecod.
                        recatu1 = ?.
                        return.
                    end.
                    /***h
                    recatu1 = par-rec. 
                    if par-rec <> ?
                    then do: 
                       find produ where recid(produ) = par-rec no-lock.
                       par-itecod = produ.itecod.
                       return.
                    end.
                    ***/
                    
                    vclacod = 0.
                    view frame f-com1.
                    view frame f-com2.
                    leave.
***/
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do:                
                    vprocod = produpai.itecod.
                    
                    run cad_produman.p ("ALTPai",
                                    par-catcod,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do. 
                    vprocod = produpai.itecod.

                    run cad_produman.p ("CONPai",
                                    par-catcod,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    leave.
                end.
                if esqcom1[esqpos1] = " Packs "
                then do.
                    find grade of produpai no-lock no-error. 
                    if not avail grade
                    then do.
                        message "Produto Pai sem Grade Associada"
                                view-as alert-box.
                        leave.
                    end.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run cad_pack.p (recid(produpai), "").
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
               if esqcom2[esqpos2] = " Opcoes "
               then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame fsub  no-pause.
                    run opcoes.
                    view frame fsub.
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(produpai).
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
hide frame fsub    no-pause.

procedure frame-a.

/***
def var vpreco2 as dec.
def var vpromoc as char.

vpreco = 0.
find first produ where produ.itecod = produpai.itecod no-lock no-error.
if avail produ
then 
     vpreco  = 111 /*precotabela (produ.procod, setbcod, today)*/ .
***/

def buffer sclase for clase.

find first sclase where sclase.clacod = produpai.clacod NO-LOCK NO-ERROR. 
IF AVAIL sclase
THEN  find first clase where clase.clacod = sclase.clacod NO-LOCK NO-ERROR. 
find fabri of produpai no-lock no-error.

display produpai.itecod column-label "Codigo"
        produpai.pronom column-label "Descricao" format "x(23)"  
        clase.clanom    format "x(8)" column-label "Classe" when avail clase 
        produpai.prorefter  format "x(17)" 
        fabri.fabnom    format "x(8)" column-label "Fabric" when avail fabri
/***
        vpreco          format ">>>>9.99" column-label "Preco"
        space(0)
        vpromoc format "x(1)" no-label
***/
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then
    if vclacod = 0
    then
        find last produpai use-index produpai
                           where produpai.catcod = par-catcod
                             and produpai.itecod <> 0
                           no-lock no-error.
    else if vclacod <> 0
    then   
        find last  produpai use-index produpai        
                     where produpai.catcod = par-catcod
                       and produpai.itecod <> 0
                       and produpai.clacod  = vclacod
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if vclacod = 0
    then
        find prev produpai use-index produpai
                     where produpai.catcod = par-catcod
                       and produpai.itecod <> 0
                                                no-lock no-error.
    else
        if vclacod <> 0
        then   
            find prev  produpai use-index produpai
                             where produpai.catcod = par-catcod
                               and produpai.itecod <> 0
                               and produpai.clacod  = vclacod
                                                no-lock no-error.

if par-tipo = "up" 
then                  
    if vclacod = 0
    then
        find next produpai use-index produpai
                            where produpai.catcod = par-catcod
                              and produpai.itecod <> 0
                                                no-lock no-error.
    else
        if vclacod <> 0
        then   
            find next  produpai  use-index produpai
                            where produpai.catcod = par-catcod
                                            and produpai.itecod <> 0
                                            and produpai.clacod  = vclacod
                                                no-lock no-error.

end procedure.


procedure opcoes.

    def var mopcoes as char format "x(20)" extent 2 init ["Tributacao",""].
    def var vopcao  as int.

    disp mopcoes with frame f-opcoes with 1 col no-label col 59
        title " Opcoes ".
    choose field mopcoes with frame f-opcoes.
    vopcao = frame-index.
    if vopcao = 1
    then run cad_protribu.p ("Pai", recid(produpai)).

end procedure.
