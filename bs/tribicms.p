/*
*
*    tribicms.p    -    Esqueleto de Programacao    com esqvazio
*
#1 04/19 - Projeto ICMS Efetivo
*/
{cabec.i}

def input parameter par-procod like produ.procod.
def input parameter par-ncm    as int.
def input parameter par-opccod as int.
def input parameter par-ufemi  like plani.ufemi.
def input parameter par-ufdes  like plani.ufdes.

def var vprocod like produ.procod.
def var vpronom like produ.pronom.

/***
def buffer ecer-itr  for cer-itr.
def buffer icer-itr  for cer-itr.
def buffer scer-itr  for cer-itr.
***/

vpronom = "Padrao".
if par-procod > 0
then do.
    find produ where produ.procod = par-procod no-lock no-error.
    /***admcom if vail produ and
       produ.itecod > 0
    then vprocod = produ.itecod.
    else if avail produ 
         then vprocod = produ.procod.
         else***/ vprocod = par-procod.
    if avail produ
    then vpronom = " Produto: " + produ.pronom.
end.
if par-ncm > 0
then vpronom = "NCM: " + string(par-ncm).

disp
    par-procod format ">>>>>>>>>>9"
    par-ncm    label "NCM"
    par-opccod label "CFOP" format ">>>9"
    par-ufemi
    par-ufdes
    with frame f-cab side-label row 3.
        
form
    tribicms.pais-sigla     colon 18 validate (true, "")
    tribicms.ufecod         colon 44 format "!!"
                            validate (can-find(unfed where unfed.ufecod =
                                                    input tribicms.ufecod), 
                               "UF Invalida")
    tribicms.pais-dest      colon 18 validate (true, "")
    tribicms.unfed-dest     colon 44 format "!!"
                            validate (can-find(unfed where unfed.ufecod =
                                                    input tribicms.unfed-dest),
                               "UF Invalida")
    tribicms.agfis-cod      colon 18 format ">>>>>>>9" label "NCM"
                            validate (true, "")
    tribicms.cfop           colon 18 format ">>>9" validate(true, "")
                            label "CFOP"
    opcom.opcnom            format "x(30)" no-label
    skip(1)
    tribicms.dativig        colon 18 format "99/99/99"
                            validate (tribicms.dativig <> ?, "")
    tribicms.datfvig        colon 44 format "99/99/99"
    skip(1)
    tribicms.pcticms        colon 18
    tribicms.pcticmspdv     colon 44
    tribicms.al_Icms_Efet   colon 18
    skip(1)
    tribicms.pctredutor     colon 18 label "%Reducao Base"
    tribicms.PctMgSubst     colon 44 label "%MVA" validate (true, "")
/***
    tribicms.codtribent colon 18
    ecer-itr.pertrib    colon 44 LABEL "Perc"
    ecer-itr.mensag1    format "x(23)" no-label
    skip(1)
    tribicms.codtribinf colon 18
    icer-itr.pertrib    label "Perc" colon 44
    icer-itr.mensag1    format "x(23)" no-label
    skip(1)
    tribicms.codtribsai colon 18
    scer-itr.pertrib    label "Perc" colon 44
    scer-itr.mensag1    format "x(23)" no-label
***/
    tribicms.cst        colon 18 format "99"
    with frame f-tribicms title " Produto - " + string(par-procod).

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Pesquisa "," Consulta "," Listagem "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tribicms ",
             " Alteracao da tribicms ",
             " ",
             " Consulta  da tribicms ",
             " Listagem  Geral de tribicms "].

def buffer btribicms       for tribicms.

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.


find func where func.funcod = sfuncod and
                func.etbcod = setbcod
          no-lock no-error.
if not avail func or func.funfunc <> "CONTABILIDADE"
then assign
        esqcom1[1] = ""
        esqcom1[2] = "".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tribicms where recid(tribicms) = recatu1 no-lock.
    if not available tribicms
    then do.
        esqvazio = yes.
        if esqcom1[1] = ""
        then do.
            message "Sem registros" view-as alert-box.
            leave.
        end.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tribicms).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tribicms
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
            find tribicms where recid(tribicms) = recatu1 no-lock.
            find produ of tribicms no-lock no-error.

            disp produ.pronom format "x(50)" when avail produ
                 with frame fsub row screen-lines overlay no-labels no-box
                 width 80.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tribicms.ufecod)
                                        else "".

            choose field tribicms.ufecod /***pais-sigla***/ help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".

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
                    if not avail tribicms
                    then leave.
                    recatu1 = recid(tribicms).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tribicms
                    then leave.
                    recatu1 = recid(tribicms).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tribicms
                then next.
                color display white/red tribicms.ufecod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tribicms
                then next.
                color display white/red tribicms.ufecod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-tribicms color black/cyan
                      centered side-label row 7.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Pesquisa "
                then do on error undo with frame f-pesq side-label.
                    display
                        "BRA" @ tribicms.pais-sigla
                        ""    @ tribicms.ufecod.
                    prompt-for 
                        /***tribicms.Pais-sigla***/
                        tribicms.ufecod.
                    find first btribicms where 
                           btribicms.pais-sigla = input tribicms.pais-sigla
                       and btribicms.ufecod     = input tribicms.ufecod
                       and btribicms.procod     = par-procod
                       no-lock no-error.
                    if avail btribicms
                    then recatu1 = recid(btribicms).
                    leave.
                end.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tribicms on error undo.
                    run tribinc (?, input vprocod, par-ufemi, par-ufdes).
                    recatu1 = recid(tribicms).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do .
/***
                    find ecer-itr where ecer-itr.codtrib = tribicms.codtribent
                                  no-lock no-error.
                    find icer-itr where icer-itr.codtrib = tribicms.codtribinf
                                  no-lock no-error.
                    find scer-itr where scer-itr.codtrib = tribicms.codtribsai
                                  no-lock no-error.
***/
                    /***Admcom find opfis of tribicms no-lock no-error.***/

                    disp
                        tribicms.pais-sigla
                        tribicms.ufecod
                        tribicms.pais-dest
                        tribicms.unfed-dest
                        tribicms.agfis-cod
                        tribicms.cfop
                        /***Admcom opfis.opfnom***/
                        tribicms.dativig
                        tribicms.datfvig
                        tribicms.pcticms
                        tribicms.pcticmspdv
                        tribicms.al_Icms_Efet
                        tribicms.pctredutor
                        tribicms.PctMgSubst
/***
                        tribicms.codtribent
                        ecer-itr.pertrib
                        ecer-itr.mensag1
                        tribicms.codtribinf
                        icer-itr.pertrib
                        icer-itr.mensag1
                        tribicms.codtribsai
                        scer-itr.pertrib 
                        scer-itr.mensag1
***/
                        tribicms.cst
                        with frame f-tribicms.

                    if esqcom1[esqpos1] = " Consulta "
                    then pause.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tribicms on error undo.
                    run tribinc (recid(tribicms),
                                 input vprocod, par-ufemi, par-ufdes).
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do.
                    run listagem.
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tribicms).
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

/***
    def var emensag as char.
    def var imensag as char.
    def var smensag as char.

    find ecer-itr where ecer-itr.codtrib = tribicms.codtribent no-lock.
    emensag = string(tribicms.codtribent, ">9") + " " +
              substr(ecer-itr.mensag1, 1, 5).

    find icer-itr where icer-itr.codtrib = tribicms.codtribinf no-lock.
    imensag = string(tribicms.codtribinf, ">9") + " " +
              substr(icer-itr.mensag1, 1, 5).

    find scer-itr where scer-itr.codtrib = tribicms.codtribsai no-lock.
    smensag = string(tribicms.codtribsai, ">9") + " " +
              substr(scer-itr.mensag1, 1, 5).
***/
    display
/***        tribicms.pais-sigla   column-label "P.!Emi"***/
        tribicms.ufecod       column-label "UF!Em"
/***        tribicms.pais-dest    column-label "P.!Des"***/
        tribicms.unfed-dest   column-label "UF!De"
        tribicms.procod       format ">>>>>>>>9"
        tribicms.cfop         column-label "CFOP"  format ">>>9"
        tribicms.agfis-cod    column-label "NCM"   format ">>>>>>>9"
        tribicms.dativig      format "99/99/99" column-label "Inicio!Vigencia"
        tribicms.datfvig      format "99/99/99" column-label "Final!Vigencia"
        tribicms.pcticms      column-label "%ICMS" format ">9.99"
        tribicms.pcticmspdv   column-label "%PDV"  format ">9.99"
        tribicms.PctRedutor   column-label "%Rd.Bs"
        tribicms.PctMgSubst   column-label "%MVA"
/***
        imensag column-label "Tribut!Propria" format "x(7)"
        emensag column-label "Tribut!Entrada" format "x(7)"
        smensag column-label "Tribut!Saida"   format "x(7)"
***/
        tribicms.cst
        with frame frame-a 10 down centered color white/red row 7
        title " Tributacao " + vpronom + " ".
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tribicms where 
                        (if vprocod > 0
                         then tribicms.procod = vprocod else true)
                    and (if par-ufemi <> ""
                         then tribicms.ufecod = par-ufemi else true)
                    and (if par-ufdes <> ""
                         then tribicms.unfed-dest = par-ufdes else true)
                    and (if par-ncm > 0
                         then tribicms.agfis-cod = par-ncm else true)
                    and (if par-opccod > 0 and par-opccod < 9999
                         then tribicms.cfop = par-opccod else true)
                    and (if par-opccod = 9999
                         then tribicms.cfop > 0 else true)
         no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tribicms  where
                        (if vprocod > 0
                         then tribicms.procod = vprocod else true)
                    and (if par-ufemi <> ""
                         then tribicms.ufecod = par-ufemi else true)
                    and (if par-ufdes <> ""
                         then tribicms.unfed-dest = par-ufdes else true)
                    and (if par-ncm > 0
                         then tribicms.agfis-cod = par-ncm else true)
                    and (if par-opccod > 0 and par-opccod < 9999
                         then tribicms.cfop = par-opccod else true)
                    and (if par-opccod = 9999
                         then tribicms.cfop > 0 else true)
         no-lock no-error.
             
if par-tipo = "up" 
then find prev tribicms where
                        (if vprocod > 0
                         then tribicms.procod = vprocod else true)
                    and (if par-ufemi <> ""
                         then tribicms.ufecod = par-ufemi else true)
                    and (if par-ufdes <> ""
                         then tribicms.unfed-dest = par-ufdes else true)
                    and (if par-ncm > 0
                         then tribicms.agfis-cod = par-ncm else true)
                    and (if par-opccod > 0 and par-opccod < 9999
                         then tribicms.cfop = par-opccod else true)
                    and (if par-opccod = 9999
                         then tribicms.cfop > 0 else true)
         no-lock no-error.
        
end procedure.


procedure listagem.

    def var varqsai as char.
/***
    def var emensag as char.
    def var imensag as char.
    def var smensag as char.
***/

    update sresp label "Emitente/Destinatario" format "Emitente/Destinatario"
       with frame f-lista side-label.

    varqsai = "../impress/tribicms" + string(time).
    {mdadmcab.i 
        &Saida     = "value(varqsai)"
        &Page-Size = "0"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""tribicms""
        &Nom-Sis   = """BS"""
        &Tit-Rel   = " ""TRIBUTACAO ENTRE ESTADOS - "" + vpronom"
        &Width     = "96"
        &Form      = "frame f-cabcab1"}

    if sresp
    then
        for each tribicms no-lock break by tribicms.ufecod.
/***
    find ecer-itr where ecer-itr.codtrib = tribicms.codtribent no-lock.
    emensag = string(tribicms.codtribent, ">9") + " " +
              substr(ecer-itr.mensag1, 1, 5).

    find icer-itr where icer-itr.codtrib = tribicms.codtribinf no-lock.
    imensag = string(tribicms.codtribinf, ">9") + " " +
              substr(icer-itr.mensag1, 1, 5).

    find scer-itr where scer-itr.codtrib = tribicms.codtribsai no-lock.
    smensag = string(tribicms.codtribsai, ">9") + " " +
              substr(scer-itr.mensag1, 1, 5).
***/
            disp
                tribicms.pais-sigla   column-label "Pais!Emi"
                tribicms.ufecod       column-label "UF!Emi"
                tribicms.pais-dest    column-label "Pais!Des"
                tribicms.unfed-dest   column-label "UF!Des"
                tribicms.procod       format ">>>>>>>>9"
                tribicms.cfop         column-label "CFOP" format ">>>9"
                tribicms.agfis-cod    column-label "NCM" format ">>>>>>>9"
                tribicms.dativig      format "99/99/99" column-label "Dt.I.Vig"
                tribicms.datfvig      format "99/99/99" column-label "Dt.F.Vig"
                tribicms.pcticms      column-label "%ICMS" format ">9.99"
                tribicms.pcticmspdv   column-label "%PDV"  format ">9.99"
                tribicms.pctredutor   column-label "%Red.Base"
                tribicms.PctMgSubst   column-label "%MVA"
                tribicms.cst
/***
        imensag column-label "Tribut!Propria"
        emensag column-label "Tribut!Entrada"
        smensag column-label "Tribut!Saida"
***/
                with frame f-linha down no-box width 136.

            if last-of(tribicms.ufecod)
            then down 1 with frame f-linha.
        end.
    else
        for each tribicms no-lock break by tribicms.unfed-dest.

/***
    find ecer-itr where ecer-itr.codtrib = tribicms.codtribent no-lock.
    emensag = string(tribicms.codtribent, ">9") + " " +
              substr(ecer-itr.mensag1, 1, 5).

    find icer-itr where icer-itr.codtrib = tribicms.codtribinf no-lock.
    imensag = string(tribicms.codtribinf, ">9") + " " +
              substr(icer-itr.mensag1, 1, 5).

    find scer-itr where scer-itr.codtrib = tribicms.codtribsai no-lock.
    smensag = string(tribicms.codtribsai, ">9") + " " +
              substr(scer-itr.mensag1, 1, 5).
***/
            disp
                tribicms.pais-dest    column-label "Pais!Des"
                tribicms.unfed-dest   column-label "UF!Des"
                tribicms.pais-sigla   column-label "Pais!Emi"
                tribicms.ufecod       column-label "UF!Emi"
                tribicms.cfop         column-label "CFOP" format ">>>9"
                tribicms.dativig      format "99/99/99" column-label "Dt.I.Vig"
                tribicms.datfvig      format "99/99/99" column-label "Dt.F.Vig"
                tribicms.pcticms      column-label "%ICMS" format ">9.99"
                tribicms.pcticmspdv   column-label "%PDV"  format ">9.99"
                tribicms.pctredutor   column-label "%Red.Base"
                tribicms.PctMgSubst   column-label "%MVA"
                tribicms.cst
/***
        imensag column-label "Tribut!Propria"
        emensag column-label "Tribut!Entrada"
        smensag column-label "Tribut!Saida"
***/
            with frame f-linha2 down
                 title " Tributacao Produto " + vpronom + " ".

            if last-of(tribicms.unfed-dest)
            then down 1 with frame f-linha2.
        end.

    output close.
    run visurel.p (varqsai, "").

end procedure.


procedure tribinc.

def input parameter par-rec    as   recid.
def input parameter par-procod like produ.procod.
def input parameter par-ufemi  as char.
def input parameter par-ufdes  as char.

pause 0 before-hide.
def buffer btribicms for tribicms.
repeat on endkey undo , leave with frame f-tribicms:

    if par-rec = ? /* Inclusao */
    then do.
        clear frame f-tribicms all.
        display
            "BRA"     @ tribicms.pais-sigla
            "BRA"     @ tribicms.pais-dest
            par-ufemi @ tribicms.ufecod
            par-ufdes @ tribicms.unfed-dest
            par-ncm   @ tribicms.agfis-cod.

        prompt-for 
            /***Admcom tribicms.pais-sigla ***/
            tribicms.ufecod
            /***Admcom tribicms.pais-dest ***/
            tribicms.unfed-dest.

        prompt-for
            tribicms.agfis-cod when par-opccod = 0.
        if input tribicms.agfis-cod > 0
        then do.
            find first clafis where clafis.codfis =
                                      input tribicms.agfis-cod
                                no-lock no-error.
            if not avail clafis
            then do.
                message "NCM nao cadastrado" view-as alert-box.
                undo.
            end.
        end.

        prompt-for tribicms.cfop.
        if input tribicms.cfop > 0
        then do.
            find opcom where opcom.opccod = string(input tribicms.cfop)
                       no-lock no-error.
            if not avail opcom
            then do.
                message "CFOP invalido" view-as alert-box.
                undo.
            end.
            disp opcom.opcnom.
        end.
        else if par-opccod > 0
        then do.
            message "CFOP deve ser informado" view-as alert-box.
            undo.
        end.

        prompt-for tribicms.dativig.

        find first btribicms where 
                           btribicms.pais-sigla = input tribicms.pais-sigla
                       and btribicms.ufecod     = input tribicms.ufecod
                       and btribicms.pais-dest  = input tribicms.pais-dest
                       and btribicms.unfed-dest = input tribicms.unfed-dest
                       and btribicms.procod     = par-procod
                       and btribicms.cfop       = input tribicms.cfop
                       and btribicms.agfis-cod  = input tribicms.agfis-cod
                       and btribicms.agfis-dest = 0 
                       and btribicms.dativig   <= input tribicms.dativig
                       and (btribicms.datfvig  = ? or
                            btribicms.dativig >= input tribicms.dativig)
                         no-lock no-error.
        if available btribicms
        then do:
            message "tributacao ja cadastrada, nao pode ser alterada"
                    view-as alert-box.
            undo.
        end.

        find first btribicms
                         where btribicms.pais-sigla = input tribicms.pais-dest
                           and btribicms.ufecod     = input tribicms.ufecod
                           and btribicms.pais-dest  = input tribicms.pais-dest
                           and btribicms.unfed-dest = input tribicms.unfed-dest
                           and btribicms.procod     = 0 /***par-procod***/
                           and btribicms.cfop       = 0
                           and btribicms.agfis-cod  = input tribicms.agfis-cod
                           and btribicms.agfis-dest = 0
                           and (btribicms.datfvig   = ? or
                                btribicms.datfvig  >= input tribicms.dativig )
                         use-index tribicms
                         no-lock no-error.
        if not available btribicms  and
           ( input tribicms.cfop   <> 0  /***or
             input tribicms.agfis-cod <> 0  or
             input tribicms.agfis-dest <> 0***/ )
        then do:
/***            message input tribicms.opfcod
                input tribicms.agfis-cod 
                input tribicms.agfis-dest***/.
            pause. 
            message "ainda nao foi incluida tributacao padrao da mercadoria"
                    view-as alert-box.
            undo.
        end.

        create tribicms.
        assign
            tribicms.pais-sigla
            tribicms.ufecod
            tribicms.pais-dest
            tribicms.unfed-dest
            tribicms.procod     = par-procod
            tribicms.cfop
            tribicms.agfis-cod
            tribicms.agfis-dest = 0
            tribicms.dativig
            tribicms.TbtpTrib-cod = "T".
    end.
    else
        find tribicms where recid(tribicms) = par-rec exclusive.

    update
        tribicms.datfvig.

    update
        tribicms.pcticms
        tribicms.pcticmspdv
        tribicms.al_Icms_Efet when tribicms.pcticmspdv = 99
        tribicms.pctredutor
        tribicms.PctMgSubst
        tribicms.cst.
/***
    update tribicms.codtribent.
    find ecer-itr where ecer-itr.codtrib = tribicms.codtribent no-lock.
    disp ecer-itr.pertrib
         ecer-itr.mensag1.

    if tribicms.codtribent = 16
    then do on error undo.
        update tribicms.codtribinf.
        find icer-itr where icer-itr.codtrib = tribicms.codtribinf no-lock.
        if icer-itr.pertrib = 0
        then do.
            message "Cod.Tributacao invalido" view-as alert-box.
            undo.
        end.
        disp icer-itr.pertrib
             icer-itr.mensag1.
    end.

        update tribicms.codtribsai.
        find scer-itr where scer-itr.codtrib = tribicms.codtribsai no-lock.
        disp scer-itr.pertrib
             scer-itr.mensag1.
    if tribicms.ufecod = "RS" and
       tribicms.unfed-dest = "RS" and
       tribicms.procod > 0 and
       tribicms.cfop   = 0 and
       tribicms.agfis-cod  = 0
    then do.
        find current produ exclusive.
        produ.ctpreco-cod = tribicms.codtribsai. /* ECF */
    end.
***/

    if par-rec <> ?
    then leave.
    clear frame f-tribicms all.
end.
hide frame f-tribicms.

end procedure.
