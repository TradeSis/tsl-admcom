def input param pcontnum        as int.
def input param pidBiometria    as char.
def input param pversaocomponente as char.
def input param pnomecomponente as char.
def input param ppdvmov         as recid.



    find pdvmov     where recid(pdvmov) = ppdvmov no-lock.
    find cmon of pdvmov no-lock.
    find contrato   where contrato.contnum = pcontnum no-lock.
    
    create contrassin.
    contrassin.contnum     = contrato.contnum.
    contrassin.clicod      = contrato.clicod.
    
    contrassin.idBiometria = pidBiometria.
    
    contrassin.dtinclu     = pdvmov.datamov.
    contrassin.hrincl     = pdvmov.horamov.
    contrassin.dtproc      = ?.
    contrassin.hrproc      = ?.
    contrassin.etbcod      = pdvmov.etbcod.
    contrassin.cxacod      = cmon.cxacod.
    contrassin.ctmcod      = pdvmov.ctmcod.
    contrassin.nsu         = pdvmov.sequencia.
    contrassin.hash1 = sha1-digest(string(contrassin.contnum),"CHARACTER") no-error.
    contrassin.hash2 = sha1-digest(string(contrassin.contnum) + contrassin.idbiometria,"CHARACTER") no-error.
    /* dpge ip - 03072024 */
    contrassin.versaocomponente = pversaocomponente.
    contrassin.nomecomponente = pnomecomponente.
