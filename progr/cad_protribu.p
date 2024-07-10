/***
17/04/2013 Produ.proseq  0=Ativo 98=Bloqueado 99=Inativo
#1 04/19 - Projeto ICMS Efetivo
***/
{admcab.i}

def input parameter par-opc as char.
def input parameter par-rec as recid.

def var v-ativo as log format "Sim/Nao".
def var v-mva   as dec.
def var esqcom  as char format "x(19)" extent 3
        initial [" Altera", " Tributaçao Produto", " Tributaçao NCM"].
def var esqpos  as int.

def temp-table tt-produ like produ.

if par-opc = "Pai"
then do.
    find produpai where recid(produpai) = par-rec no-lock.
    find first produ of produpai no-lock no-error.
    if not avail produ
    then do.
        message "Produtos FILHOS nao encontrados" view-as alert-box.
        return.
    end.
end.
else find produ where recid(produ) = par-rec no-lock.

create tt-produ.
{produ.i tt-produ produ}

find clase of produ no-lock no-error.
find fabri of produ no-lock no-error.
disp
    produ.itecod colon 12
    produ.procod colon 12 format ">>>>>>>>9"
    produ.pronom no-label
    produ.clacod colon 12
    clase.clanom no-label when avail clase
    produ.fabcod colon 12
    fabri.fabfant no-label when avail fabri
    with frame f-produ side-label row 4.

/***
    Consulta
***/
    /**** MVA ****/
    find produaux where produaux.procod     = tt-produ.procod
                    and produaux.nome_campo = "MVA"
                  no-lock no-error.
    if avail produaux 
    then v-mva = dec(produaux.valor_campo).
    else v-mva = 0.
    /*** fim MVA ***/

    if tt-produ.proseq = 0
    then v-ativo = yes.
    else v-ativo = no.

find clafis where clafis.codfis = tt-produ.codfis no-lock no-error.

disp
    tt-produ.proipiper colon 15 label "Aliq.ICMS"
    tt-produ.al_Icms_Efet colon 35 label "ICMS Efet."
    tt-produ.codfis label "Classif.Fiscal" format ">>>>>>>9" colon 15
    clafis.char1    colon 35 label "CEST" format "x(7)"
    clafis.pisent colon 15 when avail clafis format ">9.99"
    clafis.cofinsent       when avail clafis format ">9.99"
    clafis.pissai colon 15 when avail clafis format ">9.99"
    clafis.cofinssai       when avail clafis format ">9.99"
    clafis.log1   colon 15 label "Monofásico?" when avail clafis
    v-mva label "MVA"  colon 15 when produ.catcod = 31
    v-ativo label "Ativo" colon 15
    tt-produ.codori colon 15 label "Origem" validate(tt-produ.codori <= 8, "")
    tt-produ.al_Fcp colon 15
    with frame f-tribu side-label title " Tributacao ".

for each tribicms where tribicms.procod = tt-produ.procod or
                        (if tt-produ.codfis > 0
                         then tribicms.agfis-cod = tt-produ.codfis else false)
                  no-lock.
    disp
        tribicms.ufecod     column-label "UF!Emi"
        tribicms.UnFed-dest column-label "UF!Des"
        tribicms.agfis-cod  format "99999999" column-label "NCM"
        tribicms.pcticms    format ">9%" column-label "ICMS"
        tribicms.pcticmspdv format ">9%" column-label "PDV"
        tribicms.al_Icms_Efet format ">9%" column-label "Efe"
        with frame f-tribicms col 48 row 10 7 down title " ICMS ".
end.

find func where func.funcod = sfuncod and
                func.etbcod = setbcod
          no-lock no-error.
if not avail func or func.funfunc <> "CONTABILIDADE"
then assign
        esqcom[1] = "".

repeat.
    view frame f-produ.
    view frame f-tribu.
    view frame f-tribicms.
    disp esqcom with frame f-menu row screen-lines no-label no-box.
    choose field esqcom with frame f-menu.
    esqpos = frame-index.

    if esqcom[esqpos] =  " Altera"
    then run altera.
    else if esqcom[esqpos] = " Tributaçao Produto"
    then do.
        run tribicms.p (produ.procod, 0, 0, "", "").
        next.
    end.
    else if esqcom[esqpos] = " Tributaçao NCM"
    then do.
        run tribicms.p (0, produ.codfis, 0, "", "").
        next.
    end.
end.
hide frame f-menu no-pause.
hide frame f-tribicms no-pause.


procedure altera.

do on error undo with frame f-tribu side-label.
    do on error undo.
        update tt-produ.proipiper.
        run valida-aliquota-icms.
        if sresp
        then undo ,retry.
        if tt-produ.proipiper <> 17 and
           tt-produ.proipiper <> 18 and
           tt-produ.proipiper <> 98 and
           tt-produ.proipiper <> 99
        then do:
            message "Aliquota Invalida".
            undo, retry.
        end.
        if (tt-produ.proipiper = 17 and today <= 12/31/2019) or
           (tt-produ.proipiper = 18 and today >= 01/01/2020)
        then do:
            message "Aliquota Invalida".
            undo, retry.
        end.
        update tt-produ.al_Icms_Efet.
    end.

    /**** MVA ****/
    find produaux where produaux.procod     = tt-produ.procod
                    and produaux.nome_campo = "MVA"
                  no-lock no-error.
    if avail produaux 
    then v-mva = dec(produaux.valor_campo).
    else v-mva = 0.
    if produ.catcod = 31
    then
        update v-mva help "Infome a Margem do Valor Agregado".
    /*** fim MVA ***/

    do on error undo.
        update tt-produ.codfis.
        if tt-produ.codfis = 0 or
           tt-produ.codfis = 99999999
        then do.
            sresp = no.
            message "Confirma classificacao fiscal ESPECIAL?" update sresp.
            if not sresp
            then undo.
        end.
        else do.
            find clafis where clafis.codfis = tt-produ.codfis no-lock no-error.
            if not avail clafis
            then do:
                message "Classificacao Fiscal Invalida".
                pause.
                undo.
            end.
        end.
    end.

    if tt-produ.proseq = 0 or
       tt-produ.proseq = 99
    then do:
        if tt-produ.proseq = 99
        then v-ativo = no.
        else v-ativo = yes.

        update v-ativo.
        if v-ativo
        then tt-produ.proseq = 0.
        else tt-produ.proseq = 99.
    end.

    if tt-produ.proseq = 98
    then do.
        v-ativo = no.
        v-ativo:label = "Desbloquear".
        update v-ativo.
        if v-ativo
        then tt-produ.proseq = 99.
    end.

    update tt-produ.codori.

    update tt-produ.al_fcp.

    if par-opc = "PAI"
    then
        for each produ of produpai.
            run grava.
        end.
    else do.
        find current produ exclusive.
        run grava.
    end.
end.

end procedure.


procedure valida-aliquota-icms:

    def var produ-lst   as char init "405853,407721".
    
    sresp = no.
    
    if lookup(string(tt-produ.procod),produ-lst) > 0 then return "".
    
    if tt-produ.pronom matches "*celular*" or
       tt-produ.pronom matches "*chip*" or
       tt-produ.pronom matches "*auto radio*" or
       tt-produ.pronom matches "*auto-radio*" or
       tt-produ.pronom matches "*alto falante*" or
       tt-produ.pronom matches "*alto-falante*" or
       tt-produ.pronom matches "*auto falante*" or
       tt-produ.pronom matches "*auto-falante*" or
       tt-produ.pronom matches "*bateria*" or
       /*tt-produ.pronom matches "*colchao*" or*/
       tt-produ.pronom matches "*pneu*" or
       tt-produ.pronom matches "*vivo*" or
       tt-produ.pronom matches "* tim *" or
       tt-produ.pronom matches "*claro*" 
    then do:
        if tt-produ.proipiper = 99
        then.
        else sresp = yes.
    end.
    if sresp
    then message "Aliquota invalida.".
end.

procedure grava.

    assign
        produ.proipiper = tt-produ.proipiper
        produ.codfis    = tt-produ.codfis
        produ.proseq    = tt-produ.proseq
        produ.al_icms_efet = tt-produ.al_icms_efet
        produ.al_fcp    = tt-produ.al_fcp
        produ.datexp    = today.

    /**** MVA ****/
    if produ.catcod = 31 and v-mva > 0
    then do on error undo:
        find produaux where produaux.procod     = produ.procod
                        and produaux.nome_campo = "MVA"
                      no-error.
        if not avail produaux
        then do:
            create produaux.
            assign
                produaux.procod     = produ.procod
                produaux.nome_campo = "MVA".
        end.
        produaux.valor_campo = string(v-mva).
    end.
    /*** fim MVA ***/

end procedure.
