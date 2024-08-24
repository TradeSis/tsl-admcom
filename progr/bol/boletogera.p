/* helio 24082024 - proj boletagem */
/* terceiro programa do processo */
/* criar boletagbol */
/* chama api para emissao, se retornar preenche 
    boletagbol.NossoNumero
    boletagbol.DtEmissao 
    boletagbol.LinhaDigitavel
    boletagbol.CodigoBarras
*/
def input parameter par-banco as int.
def input parameter par-clicod as int.
def input parameter par-numerodocumento as char.
def input parameter par-dtvencimento    as date.
def input parameter par-vlcobrado     as dec.

def output parameter par-recid-boleto as rec.
def output parameter mensagem_erro as char.

def var vhostname as char.
input through hostname.
import vhostname.
input close. 
def var vhml as log.

vhml = no.

if vhostname = "SV-CA-DB-DEV" or 
   vhostname = "SV-CA-DB-QA"
then do: 
    vhml = yes.
end.

find banco where banco.bancod = par-banco no-lock.
do on error undo:
    create boletagbol.
    par-recid-boleto = recid(boletagbol).
    boletagbol.bolcod         = next-value(boletagbol).
    /*boletagbol.NossoNumero    = {2}.NossoNumero. */ /* Banrisul calcula nosso numero */
    boletagbol.bancod         = par-banco.
    boletagbol.Documento      = par-numerodocumento.
    boletagbol.DtVencimento   = par-dtvencimento .
    boletagbol.VlCobrado      = par-vlcobrado.
    /*boletagbol.DtEmissao      = {2}.DtEmissao.*/ /* quando emitir , ganha data de emissao */
    /*boletagbol.LinhaDigitavel = {2}.LinhaDigitavel.*/
    /*boletagbol.CodigoBarras   = {2}.CodigoBarras.*/
    /*boletagbol.DtPagamento    = {2}.DtPagamento.*/
    boletagbol.CliFor         = par-clicod.
    /*boletagbol.DtBaixa        = {2}.DtBaixa.*/
    /*boletagbol.hrBaixa        = {2}.hrBaixa.*/
    /*boletagbol.hrEmissao      = {2}.hrEmissao.*/

end.

run api/boletoemitir.p (par-recid-boleto, output mensagem_erro).

