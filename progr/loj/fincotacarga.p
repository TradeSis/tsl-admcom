/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
def input param ctitle as char.
def buffer bfincotaetb for fincotaetb.
def var vetbcod as int.
def var vfincod as int.
def var vdtini as date.
def var vdtfim as date.
def var vconta as int.
    
def var xtime as int.


def var vcotas as int.
def var vpasta as char format "x(40)".
disp "                  Filial;Plano;data inicio;data final;Cotas;" skip
    with frame fff.
vpasta = "/admcom/tmp/import/". /* helio 03042024 912 */
disp vpasta label "Pasta" colon 20
    with side-labels frame fff.
def var varquivo as char format "x(50)" label "Arquivo CSV (;)" .
hide frame  fff no-pause.

run   /admcom/progr/get_file.p (vpasta, "csv", output varquivo) .

disp varquivo colon 20
    with row 3
        centered
        with frame fff.
if search(varquivo) = ?
then do:
    message "arquivo nao encontrado"
        view-as alert-box.
    return.
end.            
def var vokestab as log.
def var vokfinan as log.
vokfinan = yes.
vokestab = no.
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vetbcod vfincod vdtini vdtfim vcotas no-error.
    if vfincod = 0 or vfincod = ? then next.
    find finan where finan.fincod = vfincod no-lock no-error.
    if not avail finan
    then do:
        vokfinan = no.
    end.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab
        then do:
            vokestab = yes. 
        end.    
    end.
    else do:
        vokestab = yes.
    end.
end.
input close.

if vokestab = no or vokfinan = no
then do:
    message "erro no arquivo, provavelmente formatacao"
        view-as alert-box.
    undo.
end.
 
sresp = no.
message "carga com" vconta - 2 "registros".
message "Antes da Carga, Eliminar os registros antigos na tabela de cotas?" update sresp.
if sresp
then do:
    for each fincotaetb.
        delete fincotaetb.
    end.    
end.
hide message no-pause.
message "aguarde....".
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vetbcod vfincod vdtini vdtfim vcotas no-error.

    if vfincod = 0 or vfincod = ? then next.
    
    
    find fincotaetb where fincotaetb.etbcod = vetbcod and fincotaetb.fincod = vfincod no-error.
    if not avail fincotaetb
    then do:
        create fincotaetb.
        fincotaetb.etbcod = vetbcod.
        fincotaetb.fincod = vfincod.
        fincotaetb.dtivig = vdtini.
    end.
    fincotaetb.dtfvig = vdtfim.
    fincotaetb.cotaslib = vcotas.    
    fincotaetb.ativo = yes.    
end.
input close.

hide message no-pause.
message "carga realizada".

