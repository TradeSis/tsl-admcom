def input parameter par-etbcod as int.
def var vtime      as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */


def var vdtini as date.
def var vcpfcnpj like neuclien.cpfcnpj.


def var vl as int.
def var vn as int.
def var vt as int.

vtime = time.
for each estab where estab.etbcod = par-etbcod
    no-lock.

find first neuclien 
        where
        neuclien.etbcod = estab.etbcod and
        neuclien.clicod <> ? and
        neuclien.compdtultenvio <> ?
        no-lock no-error.
if not avail neuclien
then do:
        find first empre no-lock.
        if trim(empre.empfant) = "HML-DREBES"
        then return. /* Nao cadastra novos clientes mais em HML */
end.

vdtini = if avail neuclien
         then neuclien.compdtultenvio - 365
         else 01/01/1900.
if vdtini  = ? then vdtini = today - 1050.

message today string(time,"HH:MM:SS") "Loja" estab.etbcod "     Contratos desde" vdtini.

for each contrato use-index mala

    where   contrato.etbcod = estab.etbcod and
            contrato.dtinicial >= vdtini /** teste novos **/
            
        
        no-lock
        break by contrato.etbcod by contrato.dtinicial desc /* do mais novo para o mais antigo */
        on error undo, next .


    vl = vl + 1.
    
    if vl < 100 or vl mod 1000 = 0 
    then do:
        message today string(time,"HH:MM:SS") "Loja" estab.etbcod "     Lidos" vl "Contratos" vt "VN" vn.
    end.

    if contrato.clicod <= 1 or
       contrato.clicod = ?  or
       contrato.contnum = 0 or
       contrato.contnum = ?
    then next.
    
    find neuclien where neuclien.clicod = contrato.clicod no-lock no-error.
    if avail neuclien
    then next.
    else do:
        find first empre no-lock.
        if trim(empre.empfant) = "HML-DREBES"
        then next. /* Nao cadastra novos clientes mais em HML */
    end.
    


    find clien where clien.clicod = contrato.clicod no-lock no-error.
    if not avail clien
    then next.

    vcpfcnpj = dec(clien.ciccgc) no-error.
    if vcpfcnpj = 0
    then vcpfcnpj = ?.
    
    if vcpfcnpj <> ?
    then do:
        find neuclien where neuclien.cpfcnpj = vcpfcnpj no-lock no-error.
        if avail neuclien
        then next.
    end.
    else next.
    

    vt = vt + 1.
    
    run neuro/comportamento.p (clien.clicod,
                               contrato.contnum,
                               output var-propriedades).

    var-salaberto = dec(achahash("LIMITETOM",var-propriedades)).
            
    /* Se tem pelo menos um contrato em aberto, já cadastro o neuclien **/
    
    if var-salaberto <> 0
    then do on error undo, leave:
        vn = vn + 1.
        if vcpfcnpj <> ? and vcpfcnpj <> 0
        then do:
        create neuclien.        
        ASSIGN
            neuclien.CpfCnpj        = vcpfcnpj.
            neuclien.Clicod         = clien.Clicod.
            neuclien.DtCad          = clien.DtCad.
            neuclien.Nome_Pessoa    = clien.clinom.
            neuclien.DtNasc         = clien.DtNasc.
            neuclien.Nome_Mae       = clien.Mae.
            neuclien.etbcod         = if clien.etbcad = 0 or clien.etbcad = ?
                                      then contrato.etbcod
                                      else clien.etbcad.
            neuclien.tippes         = clien.tippes.
             
            /**
            neuclien.VlrLimite      = clien.VlrLimite
            neuclien.VctoLimite     = clien.VctoLimite
            neuclien.Sit_Credito    = clien.Sit_Credito
            neuclien.CatProf        = clien.CatProf
            neuclien.codigo_mae     = clien.codigo_mae
            neuclien.CompSldLimite  = clien.CompSldLimite
            neuclien.CompDtUltEnvio = clien.CompDtUltEnvio.
            **/
            
        neuclien.CompSitEnvio   = "".
        end.

            
    end.            

end.    /** Contratos **/

end.    /** Estabs **/
 
