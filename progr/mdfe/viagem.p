/*     mdfe/viagem.p
*
*/
{cabec.i}

def var vtotal as int.
def var vcusto as dec.

def var vhora as char format "x(5)" label "Hr".
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
    initial [" Viagem ", " Nova ", "  ", "", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","Relatorio ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
    def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.
def var vbusca as char.

def var par-dtini as date.
def var par-dtfim as date.
def var par-encdtini as date.
def var par-encdtfim as date.

def var vtime        as int.
def var vct          as int.

pause 0 before-hide.
form with frame f-proc.


def buffer bmdfviagem    for mdfviagem.
def buffer bfrete        for frete.

def temp-table ttviagem
    field marca   as log format "*/ "
    field rec     as recid
    field placa like mdfviagem.placa
    field frecod like mdfviagem.frecod
    index x placa desc
    index y frecod placa desc.

def buffer bttviagem for ttviagem.    
def buffer xmdfviagem for mdfviagem. 
def buffer xttviagem for ttviagem.
    
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
    
def var vchoose as char format "x(30)"  extent 4
            init [" TODOS",
                  " ETC - Empresa Transporte  ",
                  " TAC - Transportador Autonomo ",
                  " PRO - Veiculo Proprio "].
                  
def var tchoose as char format "x(15)"  extent 4
            init ["GERAL",
                  "ETC", 
                  "TAC",
                  "PRO"].
def var vindex as int.
def var vfretpcod like tpfrete.fretpcod.


def var par-etbcod like estab.etbcod.
def var par-placa like mdfviagem.placa.
def var par-frecod like frete.frecod.

def var par-emissao as log format "Sim/Nao".
def var par-fechamento as log format "Sim/Nao".
def var par-abertos as log format "Sim/Nao" init yes.
def var par-naoemitidos as log format "Sim/Nao".


    form
       /** ttviagem.marca  format " / " column-label "" **/
        mdfviagem.etbcod   column-label "Etb" format ">>9"
        frete.frenom      column-label "Transportador"
        mdfviagem.placa
        veiculo.tara
        mdfviagem.dtviagem
        vhora
        mdfviagem.dtemiss
        mdfviagem.dtencer
        with frame frame-a .

form with frame flinha down no-box.
form 
            vfretpcod        colon 30
         tpfrete.descricao

         par-etbcod         colon 30
         par-placa        colon 30
         par-frecod       colon 30
         par-placa         colon 30
         par-abertos        colon 30
         par-emissao        colon 30
         par-dtini          colon 50
         par-dtfim
         par-fechamento     colon 30
         par-encdtini       colon 50
         par-encdtfim
         par-naoemitidos    colon 30
         with frame fcab
            title "Filtros Controle Viagens".

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first ttviagem no-lock no-error.
if not avail ttviagem
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    leave.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttviagem where recid(ttviagem) = recatu1 no-lock.
    if not available ttviagem
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttviagem).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttviagem
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
            find ttviagem where recid(ttviagem) = recatu1 no-lock.
            find mdfviagem where recid(mdfviagem) = ttviagem.rec no-lock.

            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(mdfviagem.placa)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(mdfviagem.placa)
                                        else "".

            choose field mdfviagem.placa help ""
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
                run mdfe/manviagem.p (input-output recatu2).  
                find mdfviagem where recid(mdfviagem) = recatu2 no-lock no-error.
                if avail mdfviagem
                then do:
                    recatu1 = ?.
                    run montatt.
                    leave.
                end.
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
                find first bmdfviagem where bmdfviagem.placa = vbusca
                                    no-lock no-error.
                if avail bmdfviagem
                then do.
                    create ttviagem.
                    ttviagem.rec     = recid(bmdfviagem).
                    ttviagem.placa = bmdfviagem.placa.
                    recatu1 = recid(ttviagem).
                end.
                else do:
                    recatu1 = recatu2.
                    message "OS nao encontrada".
                    pause 1 no-message.
                end.    
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
                    if not avail ttviagem
                    then leave.
                    recatu1 = recid(ttviagem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttviagem
                    then leave.
                    recatu1 = recid(ttviagem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttviagem
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttviagem
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

                if esqcom1[esqpos1] = " Viagem "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = recid(mdfviagem).
                    run mdfe/manviagem.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.
                if esqcom1[esqpos1] = " Nova "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = ?.
                    run mdfe/manviagem.p (input-output recatu2).
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
        recatu1 = recid(ttviagem).
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
    find mdfviagem where recid(mdfviagem) = ttviagem.rec no-lock.
    vhora = string(mdfviagem.hrviagem,"HH:MM").

    find veiculo of mdfviagem no-lock.
    find frete of mdfviagem no-lock.
    
    disp
       /** ttviagem.marca  **/
        mdfviagem.etbcod   
        frete.frenom       
        mdfviagem.placa
        veiculo.tara
        mdfviagem.dtviagem
        vhora
        mdfviagem.dtemiss
        mdfviagem.dtencer
        with frame frame-a 12 down centered color white/red row 4
                  title vchoose[vindex] width 80.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    find first ttviagem use-index y no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    find next ttviagem use-index y no-error.
if par-tipo = "up" 
then                  
    find prev ttviagem use-index y no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    for each xttviagem no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.
end procedure.


procedure montatt.

    for each ttviagem.
        delete ttviagem.
    end.

    if par-placa <> ""
    then do:
        for each mdfviagem where mdfviagem.placa = par-placa no-lock.
            run criatt.
        end.
        leave.
    end.

    hide message no-pause.
    for each estab where
        (if par-etbcod = 0 then true else estab.etbcod = par-etbcod) no-lock.
        
        if par-abertos
        then do:
            for each mdfviagem where mdfviagem.etbcod = estab.etbcod
                              and mdfviagem.dtencer = ?
                    no-lock.

                if par-naoemitidos
                then
                    if mdfviagem.dtemissao = ? 
                    then.
                    else next.

                if par-frecod > 0 and mdfviagem.frecod <> par-frecod
                then next.

                if par-placa <> "" and mdfviagem.placa <> par-placa
                then next.

                if par-emissao
                then
                    if mdfviagem.dtemissao >= par-dtini and
                       mdfviagem.dtemissao <= par-dtfim
                    then.
                    else next.

                if par-fechamento
                then 
                    if mdfviagem.dtencer >= par-encdtini and
                       mdfviagem.dtencer <= par-encdtfim
                    then.
                    else next.

                run criatt.
            end.
        end.
        else do: /* fechados */
            
            for each mdfviagem where mdfviagem.etbcod = estab.etbcod and
                    mdfviagem.dtencer <> ?
                     no-lock. 

                if par-naoemitidos
                then
                    if mdfviagem.dtemissao = ? 
                    then.
                    else next.
                 
                if par-frecod > 0 and mdfviagem.frecod <> par-frecod
                then next.

                if par-placa > "" and mdfviagem.placa <> par-placa
                then next.

                if par-emissao
                then
                    if mdfviagem.dtviagem >= par-dtini and
                       mdfviagem.dtviagem <= par-dtfim
                    then.
                    else next.

                if par-fechamento
                then
                    if mdfviagem.dtencer >= par-encdtini and
                       mdfviagem.dtencer <= par-encdtfim
                    then.
                    else next.

                run criatt.
            end.        
        end.
    end.        
    run ptotal.
                             
end procedure.


procedure criatt.

    find frete of mdfviagem no-lock.
 
    if vfretpcod <> "GERAL" and frete.fretpcod <> vfretpcod 
    then next.
    

    create ttviagem.
    ttviagem.rec   = recid(mdfviagem).
    ttviagem.placa = mdfviagem.placa.
    ttviagem.frecod = frete.frecod.
    
end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.


procedure relatorio2.

    def buffer bplani for plani.
    def var vvenda as dec.

    vcusto = 0.
    vvenda = 0.

    vtotpc = vtotpc + vcusto.

    disp
        mdfviagem.etbcod   column-label "Etb"
        mdfviagem.placa
        /*D* avail etiqestdad format "* / " column-label "A" *D*/
        mdfviagem.placa
        /*D* etiqest.prodesc    *D*/
        frete.frecod 
        mdfviagem.dtviagem
/*D*
        bplani.etbcod when avail bplani column-label "No."
        bplani.numero when avail bplani column-label "N.Fisc."
        bplani.pladat when avail bplani column-label "Remessa"
                      format "99/99/99"
*D*/
     
        clien.clinom format "x(20)" when avail clien
        vcusto column-label "Custo" format ">>>,>>9.99"
        vvenda column-label "Venda" format ">>>>9.99"
        with frame flinha.
    down with frame flinha.            

end procedure.

procedure relatorio.    

    def var mordem as char extent 4
                 init [" Geral ", " Fabricante ", " veiculoto ", " Filial "].
    def var vordem as int.
    def var vreg   as int.
    def var varquivo as char.

    disp mordem format "x(15)"
         with frame f-ordem no-label centered title " Ordenacao ".
    choose field mordem with frame f-ordem.
    vordem = frame-index.
    
    find estab where estab.etbcod = par-etbcod no-lock no-error.

    varquivo = "/admcom/relat/cdetiqueta" + string(time).
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "0"
        &Nom-Rel   = ""cdetiqueta""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """ORDENS DE SERVICO - "" +
                  string(par-etbcod) + "" "" +
                  (if avail estab then string(estab.etbnom) else "" GERAL"")"
       &Width     = "147"
       &Form      = "frame f-cabcab"}
 
    disp skip(1)
         par-etbcod         colon 30
         par-placa        colon 30
         par-frecod       colon 30
         par-placa         colon 30
         par-emissao        colon 30
         par-dtini          colon 50
         par-dtfim
         par-fechamento     colon 30
         par-encdtini       colon 50
         par-encdtfim
         par-naoemitidos     colon 30
         with frame fcab2 side-labels 
              title "Filtros Controle Viagens MDFe".

if vordem = 1
then for each bttviagem no-lock,
    first mdfviagem where recid(mdfviagem) = bttviagem.rec no-lock,
    first frete of mdfviagem no-lock
        break by mdfviagem.etbcod
              by frete.frecod
              by mdfviagem.placa 
              by mdfviagem.dtviagem.
    if vfretpcod = "GERAL" 
    then.
    else
       if frete.fretpcod <> vfretpcod 
       then next.

    find veiculo of mdfviagem no-lock no-error.

    run relatorio2.
end.

/**
if vordem = 2
then for each bttviagem no-lock,
    first mdfviagem where recid(mdfviagem) = bttviagem.rec no-lock,
    veiculo of mdfviagem no-lock
        break 
              by mdfviagem.etbcod
              by mdfviagem.placa.
    if vfretpcod = "GERAL" 
    then.
    else
       if frete.fretpcod <> vfretpcod 
       then next.

    if first-of (veiculo.fabcod)
    then do.
        find fabri of veiculo no-lock.
        disp skip(1)
             veiculo.fabcod
             fabri.fabnom no-label
             skip(1)
             with frame f-fabri side-label no-box.
    end.
    find frete of mdfviagem no-lock.
    run relatorio2.
    vreg = vreg + 1.

    if last-of (veiculo.fabcod)
    then do.
        down with frame flinha.
        disp "Registros=" + string(vreg) @ clien.clinom with frame flinha.
        down 2 with frame flinha.
        vreg = 0.
    end.
end.
**/

if vordem = 3
then for each bttviagem no-lock,
    first mdfviagem where recid(mdfviagem) = bttviagem.rec no-lock,
    veiculo of mdfviagem no-lock
        break by veiculo.placa
              by mdfviagem.etbcod
              by mdfviagem.placa.
    if vfretpcod = "GERAL" 
    then.
    else
       if frete.fretpcod <> vfretpcod 
       then next.
    find frete of mdfviagem no-lock.
    run relatorio2.
    vreg = vreg + 1.

    if last-of (veiculo.placa)
    then do.
        down with frame flinha.
        disp "Registros=" + string(vreg) @ clien.clinom with frame flinha.
        down 2 with frame flinha.
        vreg = 0.
    end.
end.

if vordem = 4
then for each bttviagem no-lock,
    first mdfviagem where recid(mdfviagem) = bttviagem.rec no-lock,
    first frete of mdfviagem no-lock
        break by mdfviagem.etbcod
              by frete.frecod
              by mdfviagem.placa 
              by mdfviagem.dtviagem.
    if vfretpcod = "GERAL" 
    then.
    else
       if frete.fretpcod <> vfretpcod 
       then next.

    find veiculo of mdfviagem no-lock no-error.
    run relatorio2.
    vreg = vreg + 1.

    if last-of (mdfviagem.etbcod)
    then do.
        down with frame flinha.
        disp "Registros=" + string(vreg) @ clien.clinom with frame flinha.
        down 2 with frame flinha.
        vreg = 0.
    end.
end.

down 1 with frame flinha.
disp vtotpc  @ vcusto
     with frame flinha.
down with frame flinha.

output close.

if xestab.etbnom begins "DREBES-FIL"
then os-command silent /fiscal/lp
                     value("/usr/admcom/relat/cdetiqueta" + string(time)).
else run visurel.p (input varquivo, input "").



    
end procedure.

procedure pfiltros.

   disp 
        vfretpcod        colon 30
         tpfrete.fretpcod no-label when avail tpfrete
         par-etbcod         colon 30
         par-placa        colon 30
         par-frecod       colon 30
         par-placa         colon 30
         par-abertos        colon 30
         par-emissao        colon 30
         par-dtini          colon 50
         par-dtfim
         par-fechamento     colon 30
         par-encdtini       colon 50
         par-encdtfim
         par-naoemitidos    colon 30
         with frame fcab
            title "Filtros Controle Viagens"
            width 80 centered.

    display vchoose
        with frame fff centered row 3 no-label overlay width 80.
    choose field vchoose with frame fff.                         
    vfretpcod =  tchoose[frame-index].
    vindex = frame-index.


repeat.

    find tpfrete where tpfrete.fretpcod = vfretpcod no-lock no-error.
    disp
             vfretpcod        colon 30
         tpfrete.descricao no-label when avail tpfrete

         par-etbcod         colon 30
         par-placa        colon 30
         par-frecod       colon 30
         par-placa         colon 30
         par-abertos        colon 30
         par-emissao        colon 30
         par-dtini          colon 50
         par-dtfim
         par-fechamento     colon 30
         par-encdtini       colon 50
         par-encdtfim
         par-naoemitidos    colon 30
         with frame fcab
            title "Filtros Controle Viagens".

    find xestab where xestab.etbcod = setbcod no-lock.
    if xestab.etbnom begins "DREBES-FIL"
    then do:
        par-etbcod = setbcod.
        disp par-etbcod label "Estabelecimento"
        with frame fcab row 3 width 80 side-labels.
    end.
    else do:
        hide message no-pause.
        message color normal 
        "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
        message 
        "Pressione    F8 ou I Para cadastrar nova Viagem".
        update par-etbcod go-on(F8 PF8 i I)
            with frame fcab.
    end.    
    find estab where estab.etbcod = par-etbcod no-lock no-error.
    if par-etbcod <> 0 and not avail estab
    then do:
        message "Estabelecimento Errado".
        undo.
    end.    

    if keyfunction(lastkey) = "GO" and not xestab.etbnom begins "DREBES-FIL"
    then do:
        recatu1 = ?.
        run montatt.
        return.
    end.

    par-placa = "".
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
    message 
    "Pressione    F8 ou I Para cadastrar nova Viagem".
 
    update par-placa when keyfunction(lastkey) <> "I" and
                      keyfunction(lastkey) <> "CLEAR"
        go-on(F8 PF8)
    with frame fcab.
    if keyfunction(lastkey) = "CLEAR" or 
       keyfunction(lastkey) = "I"
    then     do: 
        recatu2 = ?. 
        run mdfe/manviagem.p (input-output recatu2).  
        find mdfviagem where recid(mdfviagem) = recatu2 no-lock no-error.
        if avail mdfviagem
        then do:
            par-etbcod  = mdfviagem.etbcod.
            par-placa = mdfviagem.placa.
            return.
        end.
        else do:
            undo.
        end.
    end.

if par-etbcod <> 0
then find mdfviagem where mdfviagem.placa  = par-placa
                   and mdfviagem.etbcod = par-etbcod
                 no-lock no-error.
else find mdfviagem where mdfviagem.placa = par-placa no-lock no-error.
if par-placa <> ""
then do:
    if not avail mdfviagem
    then do:
        message "Ordem de Servico de Assitencia Inexistente".
        undo.
    end.
    else do.
        if avail mdfviagem
        then do:
            recatu1 = ?.
            run montatt.
            return.
        end.        
    end.
end.

if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

update par-frecod 
    with frame fcab.
find frete where 
    frete.frecod = par-frecod no-lock no-error.
if par-frecod <> 0 and not avail frete then do:
    message "Transportadora Inexistente".
    undo.
end.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".


if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".

if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.


par-placa = "".
update par-placa label "Placa Veiculo"
    with frame fcab.
find veiculo where veiculo.placa = par-placa no-lock no-error.
if par-placa <> "" and not avail veiculo
then do:
    message "veiculoto Inexistente".
    undo.
end.

update par-abertos label "Somente Abertos?" 
        with frame fcab.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

update par-emissao label "Filtra Inclusao"
    with frame fcab.

if keyfunction(lastkey) = "GO" and par-emissao = no
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

if par-emissao
then do:
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".
 
    update par-dtini label "Inclusao de" colon 50
           par-dtfim label "Ate"
           with frame fcab.
    if par-dtini = ? or 
       par-dtfim = ? or
       par-dtfim < par-dtini
    then do:
        message "Datas Invalidas".
        undo.
    end.
end.
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

par-fechamento = no.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

update par-fechamento 
    when par-abertos = no label "Filtra Fechamento"
    with frame fcab.
if keyfunction(lastkey) = "GO" and par-fechamento = no
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

if par-fechamento
    then  do:
        hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ultimo campo".

        update par-encdtini label "Fechamento de"
               par-encdtfim label "Ate"
            with frame fcab.
        if par-encdtini = ? or 
           par-encdtfim = ? or
           par-encdtfim < par-encdtini
        then do:
            message "Datas Invalidas".
            undo.
        end.
    end.                 
if keyfunction(lastkey) = "GO"
then do:
        recatu1 = ?.
        run montatt.
        return.
end.

    leave.

end.
recatu1 = ?.

run montatt.


end procedure.

