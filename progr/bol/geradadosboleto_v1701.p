def input parameter par-banco as int.
def input parameter par-recid-bancarteira as recid.
def input parameter par-tipoIntegracao as char.
def input parameter par-clicod as int.
def input parameter par-numerodocumento as char.
def input parameter par-dtvencimento    as date.
def input parameter par-vlcobrado     as dec.

def output parameter par-recid-boleto as rec.
def output parameter vstatus  as char.
def output parameter vmensagem_erro as char.

def var vdvAgeConta as char.
def var vnossonumero as int.
def var vdvNossoNumero as int.
def var vdvcodigoBarras as int.
def var vcampo1 as char.
def var vdv1     as char.
def var vcampo2 as char.
def var vdv2 as char.
def var vcampo3 as char.
def var vdv3 as char.
def var vcampo4 as char.
def var vdv4 as char.
def var vcampo5 as char.
def var vcodigoBarras as char.
def var vnummoeda as char init "9".


function fator_vencimento returns int
    (input pdtvencimento as date).
    
    return
        pdtvencimento - date(10/07/1997).

end function.


function modulo10 returns integer
    (input par-numeron as char).

   def var vdivisao as int.
   def var vdigito as int.
    
   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso  as int.
   def var vtam   as int.
    def var vparc2 as int.
       def var vct2 as int.
   vpeso = 2.
   vtam  = length(par-numeron).

   do vct = vtam to 1 by -1.
        vparc = (int(substr(par-numeron, vct, 1)) * vpeso).
        def var vparcori as int.
        vparcori = vparc.
        vparc2 = 0.
        if vparc >= 10
        then do:
            do vct2 = 1 to length(string(vparc)).
                vparc2 = vparc2 + int(substr(string(vparc), vct2, 1)).
            end.
            vparc = vparc2.
        end.
        else vparc2 = vparc.
        vsoma = vsoma + vparc.
        /**
        hide message no-pause.
        message substr(par-numeron,vct,1) vpeso vparcori vparc vsoma.
        pause.
        **/ 
        if vpeso = 2 
        then vpeso = 1.
        else vpeso = 2.
        
    end.
    vdivisao = truncate(vsoma / 10,0).
    vresto = vsoma - (vdivisao * 10).
    
    vdigito = 10 - vresto.
    
    if vresto = 0 
    then vdigito = 0.
    
    return vdigito.
end function.



function modulo11 returns integer
    (input par-numeron as char).

   def var vdivisao as int.
   def var vdigito as int.
    
   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso  as int.
   def var vtam   as int.
   
   vpeso = 2.
   vtam  = length(par-numeron).
   do vct = vtam to 1 by -1.
        vparc = (int(substr(par-numeron, vct, 1)) * vpeso).
        vsoma = vsoma + vparc.
        vpeso = vpeso + 1.
        if vpeso > 9
        then vpeso = 2.
    end.
    vdivisao = truncate(vsoma / 11,0).
    vresto = vsoma - (vdivisao * 11).

    /** 03.05 helio */
    
    if vresto < 2 
    then vdigito = 1. /* 1010 helio nao pode ser 0 */ 
    else vdigito = 11 - vresto.
    /**
    if vdigito = 1 or vdigito >= 10
    then vdigito = 0.
    **/
    
    return vdigito.
end function.



vstatus = "S".
vmensagem_erro = "".

if par-recid-bancarteira = ?
then do:
    find first banco where banco.numban = par-banco no-lock no-error.
    if not avail banco
    then do:
        find first bancarteira where
            bancarteira.principal = "PGERAL" no-lock no-error.
        if not avail bancarteira
        then do:
            vstatus = "N".
            vmensagem_erro  = "Sem parametrizacao da carteira".
        end.
    end.
    else do:
        find first bancarteira where bancarteira.bancod = banco.bancod and
                bancarteira.principal <> ?
                no-lock no-error.
        if not avail bancarteira
        then do:
            vstatus = "N".
            vmensagem_erro  = 
                    (if avail banco
                    then  ("Banco " + string(par-banco,"999") + " ")
                    else "")
                     + "Sem parametrizacao "
                            + "da carteira".
        end.                  
        else do:
            vmensagem_erro = string(bancarteira.bancod).
        end.
    end.
end.
else do:
    find bancarteira where recid(bancarteira) = par-recid-bancarteira
        no-lock.
end.

if avail bancarteira and vstatus = "S"
then do.
    par-recid-bancarteira = recid(bancarteira).
    do on error undo:
        find bancarteira where recid(bancarteira) = par-recid-bancarteira
            exclusive no-error.
        if not avail bancarteira
        then do:
            vstatus = "N".
            vmensagem_ERRO = "Nao conseguiu obter PROXIMO NOSSO NUMERO".
        end.    
        else do:
            vnossonumero = bancarteira.nossonumeroatual + 1.
            bancarteira.nossonumeroatual = vnossonumero.        
        end.
    end.        
    find bancarteira where recid(bancarteira) = par-recid-bancarteira
        no-lock.
end.    

if vstatus = "S"
then do on error undo:
    def var vagencia as char format "x(4)".
    def var vconta   as char format "x(5)".
    def var vdvconta as char format "x(1)".

    find clien where clien.clicod = par-clicod no-lock.
    find banco of bancarteira no-lock.

    vagencia = string(bancarteira.agencia,"9999"). 
    vconta   = substring(string(bancarteira.contacor,"999999"),1,5).
    vdvconta = substring(string(bancarteira.contacor,"999999"),6,1).
    if banco.numban = 341 /* Itau */
    then do:
        vdvAgeConta = string(modulo10(vagencia + vconta),"9").
        vDvNossoNumero = modulo10(vagencia +
                              vconta   +
                              string(bancarteira.bancart,"999") +
                              string(vNossoNumero,"99999999")
                             ) .  
    end.
       
    create banBoleto.
    par-recid-boleto = recid(banBoleto).
    ASSIGN
        banBoleto.bancod         = bancarteira.bancod
        banBoleto.Agencia         = bancarteira.Agencia
        banBoleto.ContaCor        = bancarteira.ContaCor
        banBoleto.BanCart        = bancarteira.BanCart
        banBoleto.NossoNumero    = vNossoNumero
        banBoleto.DVNossoNumero  = vDVNossoNumero
        banBoleto.Documento      = par-NumeroDocumento
        banBoleto.Situacao       = "A"
        banBoleto.tipoIntegracao = par-tipoIntegracao
        banBoleto.CliFor         = clien.clicod
        banBoleto.CPFCNPJ        = clien.ciccgc
        banBoleto.DtVencimento   = par-DtVencimento
        banBoleto.VlCobrado      = par-VlCobrado
        banBoleto.DtEmissao      = today
        banBoleto.DtPagamento    = ?
        banBoleto.VlPagamento    = 0
        banBoleto.VlJuros        = 0
        banBoleto.TpBaixa        = ?.
    
    banBoleto.fatorVencimento = fator_vencimento(par-dtvencimento).


    vcodigoBarras = string(banco.numban,"999")  
                      + string(vnummoeda,"9")      
                      + string(banboleto.fatorVencimento,"9999") 
                      + string(banBoleto.vlCobrado * 100,"9999999999") 
                      + string(banBoleto.banCart,"999")
                      + string(banBoleto.nossoNumero,"99999999") 
                      + string(banBoleto.DvNossoNumero,"9")
                      + vagencia
                      + vconta
                      + vdvAgeConta
                      + string(0,"999").

    vdvCodigoBarras = modulo11(vcodigoBarras).
    
    vcodigoBarras = substring(vcodigoBarras,1,4) + 
                    string(vdvCodigoBarras,"9" ) +
                    substring(vcodigoBarras,5,43).
                    
    banBoleto.dvcodigoBarras = vdvCodigoBarras.
    banBoleto.codigoBarras = vcodigoBarras.
    if banco.numban = 341
    then do:
        banBoleto.ImpNossoNumero = string(banBoleto.bancart,"999")
                                 + "/" 
                                 + string(banBoleto.nossoNumero,"99999999") 
                                 + "-"
                                 + string(banBoleto.dvNossoNumero,"9").
    end.
         
    vcampo1       = string(banco.numban,"999")  
                  + string(vnummoeda,"9")      
                  + string(banboleto.bancart,"999")
                  + 
                    string(
                    substr(string(banBoleto.nossoNumero,"99999999"),1,2)
                    ,"99").
    vdv1      = string(modulo10(vcampo1)).
    vcampo1   = vcampo1 + vdv1.
    vcampo1 = substr(vcampo1,1,5) + '.' +
              substr(vcampo1,6,5).

    vcampo2   =  string(
                    substr(string(banBoleto.nossoNumero,"99999999"),3,6)
                    ,"999999")  
              + string(banBoleto.dvNossoNumero,"9")
              + string(
                    substr(vagencia,1,3)
                    ,"999"). 
    vdv2      = string(modulo10(vcampo2)).
    vcampo2   = vcampo2 + vdv2.
         
    vcampo2 = substr(vcampo2,1,5) + '.' + 
              substr(vcampo2,6,6).

    
    vcampo3   = string(
                    substr(vagencia,4,1)
                    ,"9") 
              + vconta 
              + vdvageconta
              + "000".
 
    vdv3      = string(modulo10(vcampo3)).
    vcampo3   = vcampo3 + vdv3.
 
    vcampo3 = substr(vcampo3,1,5) + '.' +
              substr(vcampo3,6,6).
    
    vdv4      = substr(vcodigoBarras,5,1).
    vcampo4   = vdv4. 

    vcampo5   = substr(vcodigoBarras,6,4) + 
                substr(vcodigoBarras,10,10).
 
    banBoleto.LinhaDigitavel = vcampo1 + " " +
                               vcampo2 + " " +
                               vcampo3 + " " +
                               vcampo4 + " " +
                               vcampo5.

    vmensagem_erro = "Boleto com Nosso Numero " + 
                        string(vnossonumero,"99999999") +
                        " Gerado".
end.
