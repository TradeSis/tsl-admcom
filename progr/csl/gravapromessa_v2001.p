/*
#1 TP 28872041 16.01.19 - Etbcod e modcod na origem
*/
def output param vstatus as char.
def output param vmensagem_erro as char.

def var vetbcod as int.
def var vcontnum as int.
def var vParcelasLista as char.
def var vParcelasValorLista as char.
def var vdtacordo as date.
def var vdtvenc as date.

def shared temp-table GravaAcordoEntrada
    field CNPJ_CPJ as char
    field IDAcordo as char
    field DataAcordo as char
    field QtdContratosOrigem as char
    field VlPrincipal as char
    field VlJuros   as char
    field VlMulta   as char
    field VlHonorarios as char
    field VlEncargos as char
    field VlTotalAcordo as char
    field VlDesconto as char
    field OrigemAcordo as char.

def shared temp-table ContratosOrigem
    field grupo as char
    field NumeroContrato as char.

def shared temp-table ParcelasAcordo
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char.

vstatus = "S".

find first GravaAcordoEntrada.

find cybacordo where cybacordo.idacordo = int(gravaacordoentrada.idacordo)
    no-lock no-error.
if avail cybacordo
then do:
    vstatus = "N".
    vmensagem_erro = "Acordo ja gravado".
    return.
end.    

find first clien where clien.ciccgc = GravaAcordoEntrada.cnpj_cpj no-lock.

vdtacordo = date(int(substr(gravaacordoentrada.dataacordo,1,2)),
                 int(substr(gravaacordoentrada.dataacordo,3,2)),
                 int(substr(gravaacordoentrada.dataacordo,5,4))).

create cybacordo.
ASSIGN
    cybacordo.tipo       = "PRO"
    CybAcordo.IDAcordo   = int(GravaAcordoEntrada.IDAcordo)
    CybAcordo.CliFor     = clien.clicod
    CybAcordo.DtAcordo   = vDtAcordo
    CybAcordo.Situacao   = "A"
    CybAcordo.VlAcordo   = dec(GravaAcordoEntrada.VlTotalAcordo)
    CybAcordo.VlOriginal = dec(GravaAcordoEntrada.VlPrincipal)
    CybAcordo.HrAcordo   = time
    CybAcordo.DtEfetiva  = ?
    CybAcordo.HrEfetiva  = ?.
  assign
    cybacordo.etbcod = 0
    cybacordo.modcod = ""
    cybacordo.tpcontrato = "".    

    find first ContratosOrigem. /* pela estrutura, apenas 1 contrato */
        vetbcod   = int(substr(contratosOrigem.Numerocontrato,1,3)).
        vcontnum  = int(substr(ContratosOrigem.Numerocontrato,4)).

        find contrato where contrato.contnum = vcontnum no-lock.
 
        if cybacordo.etbcod = 0
        then cybacordo.etbcod = vetbcod.
        if cybacordo.modcod = ""
        then cybacordo.modcod = contrato.modcod.
        if cybacordo.tpcontrato = ""
        then cybacordo.tpcontrato = "N".

        create cybacorigem.
        ASSIGN
            CybAcOrigem.IDAcordo   = cybacordo.IDAcordo
            CybAcOrigem.contnum    = contrato.contnum
            cybacorigem.vlOriginal = 0
            CybAcOrigem.etbcod     = contrato.etbcod /* #1 */
            CybAcOrigem.modcod     = contrato.modcod /* #1 */.
 
        vparcelasLista = "".
        vparcelasValorLista = "".

    for each ParcelasAcordo.
 
        for each titulo where 
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = contrato.modcod and 
                titulo.etbcod = contrato.etbcod and 
                titulo.clifor = contrato.clicod and 
                titulo.titnum = string(contrato.contnum) and
                titulo.titpar = int(ParcelasAcordo.numeroparcela)
                no-lock.
     
            if titulo.clifor <= 1 or
               titulo.clifor = ? or
               titulo.titpar = 0 or
               titulo.titnum = "" or
               titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.

            if titulo.titsit <> "LIB" then next.
            
            vparcelasLista = vparcelasLista +
                             if vparcelasLista = ""
                             then string(titulo.titpar)
                             else "," + string(titulo.titpar).
            
            vparcelasValorLista = vparcelasValorLista +
                             if vparcelasValorLista = ""
                             then string(titulo.titvlcob)
                             else "," + string(titulo.titvlcob).
            
            cybacOrigem.vlOriginal = cybAcOrigem.VlOriginal + titulo.titvlcob.
        end.
    end.      
        assign
            CybAcOrigem.ParcelasLista = vParcelasLista
            CybAcOrigem.ParcelasValor = vParcelasValorLista.

    for each ParcelasAcordo.
        vdtvenc   = date(int(substr(parcelasAcordo.Vencimento,1,2)),
                         int(substr(parcelasAcordo.Vencimento,3,2)),
                         int(substr(parcelasAcordo.Vencimento,5,4))).
    
        create CybAcParcela.
        ASSIGN
            CybAcParcela.IDAcordo     = cybacordo.IDAcordo
            CybAcParcela.Parcela      = int(parcelasAcordo.NumeroParcela)
            CybAcParcela.DtVencimento = vDtVenc
            CybAcParcela.VlCobrado    = dec(parcelasAcordo.VlPrincipal).
            CybAcParcela.VlJuros      = dec(parcelasAcordo.VlJuros). /* helio 0310 */
            

        ASSIGN
            CybAcParcela.contnum      = vcontnum.
    end.
    
    vmensagem_erro = "Promessa registrada para " + string(vcontnum).
