/*  nfacobecom.p */
{admcab.i}

/*
sparam = SESSION:PARAMETER.

if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

if sparam <> "AniTA"
then do:
    message "Esta opçao precisa ser executada no Anita."
                    view-as alert-box.
    return.                
end.
*/

def input parameter par-rec as recid.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var nfe-emite like A01_infnfe.emite.
def var nfe-serie like A01_infnfe.serie.
def var nfe-numero like A01_infnfe.numero.
def var vchavenfe as char.
def var vchar as char extent 5 format "x(78)".


/***
sresp = yes.
run blok-NFe.p (input setbcod,
                input "nfacobecom_nfe.p",
                output sresp).
if not sresp
then return.
***/

find plani where recid(plani) = par-rec no-lock no-error.
if not avail plani
then do:
    message "NF invalida!" view-as alert-box.
    return.
end.

find clien where clien.clicod = plani.desti no-lock no-error.
if not avail clien
then do:
    message "NF com Cliente inválido!" view-as alert-box.
    return.
end.

    find first planiaux where planiaux.movtdc      = plani.movtdc 
                          and planiaux.etbcod      = plani.etbcod 
                          and planiaux.placod      = plani.placod 
                          and planiaux.emite       = plani.emite 
                          and planiaux.numero      = plani.numero 
                          and planiaux.serie       = plani.serie 
                          and planiaux.nome_campo  = "NOTA-ACOBERTADA"
                              no-lock no-error.
    if avail planiaux
    then do: 
        nfe-emite  = int(acha("EMITE",planiaux.valor_campo)).
        nfe-serie  = acha("SERIE",planiaux.valor_campo).
        nfe-numero = int(acha("NUMERO",planiaux.valor_campo)).

        find A01_infnfe where
             A01_infnfe.emite = nfe-emite and
             A01_infnfe.serie = nfe-serie and
             A01_infnfe.numero = nfe-numero
             no-lock no-error.
        
        if avail A01_infnfe and
           A01_infnfe.situacao <> "Cancelada" and
           A01_infnfe.situacao <> "Inutilizada"
        then do:     
            message "Nota Fiscal ja foi Acobertada... NFE: " A01_infnfe.numero
                view-as alert-box.
            return.
        end.
    end.

if today - plani.pladat > 31
then do:
    message "NAO E POSSÍVEL ACOBERTAR UM CUPOM EMITIDO A MAIS DE 30 DIAS!"
                 view-as alert-box title "Erro".
    undo, return.
end.

find estab where estab.etbcod = plani.emite no-lock.
run not_notgvlclf.p ("Estab", recid(estab), output sresp).
if not sresp
then undo.

run not_notgvlclf.p ("Clien", recid(clien), output sresp).
if not sresp
then undo.

if num-entries(plani.notped,"|") >= 2
then .
else do.
    /* Chave de origem */
    if length(plani.ufemi) = 44
    then vchavenfe = plani.ufemi.
    else if length(plani.ufdes) = 44
    then vchavenfe = plani.ufdes.

    if vchavenfe = ""
    then do.
        message "Chave da NFE nao encontrada" view-as alert-box.
        return.
    end.
end.

    sresp = no.
    message "Confirma emitir NFe de acobertamento?" update sresp.
    if not sresp then return.
    
    for each tt-plani:
        delete tt-plani.
    end.
    for each tt-movim:
        delete tt-movim.
    end.
    def var vopccod like plani.opccod.
    vopccod = 5929.
    
    /*
    find clien where clien.clicod = plani.desti no-lock no-error.
    if avail clien and
             clien.ufecod[1] <> "RS"
    then vopccod = 6929.
    */
             
    create tt-plani.
    buffer-copy plani to tt-plani.
    assign
        tt-plani.movtdc  = 48
        tt-plani.hiccod  = vopccod
        tt-plani.opccod  = vopccod
        tt-plani.bicms   = 0
        tt-plani.icms    = 0
        tt-plani.pladat  = today
        tt-plani.dtinclu = today
        tt-plani.horincl = time
        tt-plani.notass  = plani.placod
        tt-plani.ufemi   = vchavenfe.

    if num-entries(plani.notped,"|") >= 2
    then tt-plani.notobs[3] = "Ref. Cupom Fiscal " + entry(2,plani.notped,"|").
    else tt-plani.notobs[3] = "Ref. " + vchavenfe.

    disp tt-plani.notobs[3] with frame f-929.
    pause 0.
    prompt-for vchar[1]
               vchar[2]
               vchar[3]
               vchar[4]
               vchar[5] 
               with frame f-929 width 80 no-label
                            title " Dados adicionais ".
    
    if input frame f-929 vchar[1] <> ""
    then tt-plani.notobs[3] = tt-plani.notobs[3] + " " + 
                                input frame f-929 vchar[1].
    if input frame f-929 vchar[2] <> ""
    then tt-plani.notobs[3] = tt-plani.notobs[3] + " " + 
                                input frame f-929 vchar[2].
    if input frame f-929 vchar[3] <> ""
    then tt-plani.notobs[3] = tt-plani.notobs[3] + " " + 
                                input frame f-929 vchar[3].
    if input frame f-929 vchar[4] <> ""
    then tt-plani.notobs[3] = tt-plani.notobs[3] + " " + 
                                input frame f-929 vchar[4].
    if input frame f-929 vchar[5] <> ""
    then tt-plani.notobs[3] = tt-plani.notobs[3] + " " +
                                input frame f-929 vchar[5].
                                        
    for each movim where movim.etbcod = plani.etbcod 
                     and movim.placod = plani.placod 
                     and movim.movtdc = plani.movtdc 
                     and movim.movdat = plani.pladat no-lock:
        create tt-movim.
        buffer-copy movim to tt-movim.
        assign
            tt-movim.movtdc    = 48
            tt-movim.movbicms  = 0
            tt-movim.movicms   = 0
            tt-movim.movalicms = 0
            tt-movim.movcsticms = "41"
            tt-movim.movdat    = tt-plani.dtinclu
            tt-movim.movhr     = tt-plani.horincl
            tt-movim.movalpis  = 0
            tt-movim.movalcofins = 0
            tt-movim.movpis    = 0
            tt-movim.movcofins = 0
            tt-movim.movcstpiscof = 49
            tt-movim.opfcod = vopccod.
    end.
    
    run manager_nfe.p (input "5929",
                       input par-rec,
                       output sresp).

