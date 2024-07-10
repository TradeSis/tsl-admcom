
def var vdtini as date.
def var vdtfin as date.
def var vano as int.
def var vmes as int.
def var vdata as date.
    
    vmes = month(today).
    vano = year(today).
    assign
        vdtini   = date(vmes,01,vano)
        vano     = year(vdtini) + if month(vdtini) = 12 then 1 else 0
        vmes     = if month(vdtini) = 12 then 1 else month(vdtini) + 1
        vdata    = date(vmes,01,vano) - 1
        vdtfin   = vdata.

        vmes = vmes - 4.
        if vmes <= 0
        then do:
            vmes = 12 + vmes.
            vano = vano - 1.
        end.    
        vdtini = date(vmes,01,vano).
 
def new shared temp-table ttposicao no-undo
    field mesvenc   as int format "99"
    field anovenc   as int format "9999"
    field etbcod    like estab.etbcod
    field modcod    like titulo.modcod
    field tpcontrato like titulo.tpcontrato
    field cobcod    like titulo.cobcod
    field emissao   like poscart.emissao
    field pagamento like poscart.pagamento
    field saldo     like poscart.saldo
    index idx is unique primary anovenc asc mesvenc asc etbcod asc modcod asc tpcontrato asc cobcod asc.

def var vtoday as date.
def var vtime as int.
if search("./gerametacobrancaeis.time") <> ?
then do:
    input from ./gerametacobrancaeis.time.
    import vtoday vtime.
    input close.

    if vtoday = today
    then do:
        if time - vtime > 3600
        then.
        else return.
    end.
end.
    
output to ./gerametacobrancaeis.time.
export today time.
output close.

message "Gerando  meta realizado cobranca periodo " vdtini vdtfin "   - " vtoday string(vtime,"HH:MM:SS").

run /admcom/progr/fin/montattposcart.p (vdtini, vdtfin).

run /admcom/barramento/async/gerametarealizadocobranca.p.
