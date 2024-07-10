/* helio 17032022 ajuste pdf */
/* helio 06012022 Chamado 99814 - Programa reimpressão contratos */ 

{admcab.i}

def input param p-rec as recid.
def input param p-imp as char.
def var pprivenc as date.

def buffer btitulo for titulo.

def var vcontrato as char format "x(30)".
def var vvenda as dec format ">>>>>>>.99".
def var vprest as dec format ">>>>>>>.99".
def var vdpaga as int format ">>9".
def var vendereco as char format "x(25)".
def var vdtult as char.
def var vdtpri as char.
def var vparc as char.
def var largura as int init 56.
def temp-table tt-texto
    field linha as char format "x(96)".

input from value("/admcom/progr/crd/contrato-novacao.txt") no-echo.
repeat transaction.
    create tt-texto.
    import unformatted tt-texto.
end.
input close.
    
find contrato where recid(contrato) = p-rec no-lock.

assign vcontrato = string(contrato.contnum,">>>>>>>>>9").

find last titulo where titulo.empcod = 19 
                   and titulo.titnat = no 
                   and titulo.modcod = contrato.modcod
                   and titulo.etbcod = contrato.etbcod
                   and titulo.clifor = contrato.clicod
                   and titulo.titnum = string(contrato.contnum)
                   no-lock no-error.
if avail titulo then 
    assign vprest = titulo.titvlcob
           vdtult = string(titulo.titdtven,"99/99/99")
           .

find first btitulo where btitulo.empcod = 19
                    and btitulo.titnat = no
                    and btitulo.modcod = contrato.modcod
                    and btitulo.etbcod = contrato.etbcod
                    and btitulo.clifor = contrato.clicod
                    and btitulo.titnum = string(contrato.contnum)
                    and btitulo.titpar <> 0 no-lock no-error.
if avail btitulo then
    assign vdtpri = string(btitulo.titdtven,"99/99/99")
           pprivenc = btitulo.titdtven
           vdpaga = btitulo.titdtven - btitulo.titdtemi.

def temp-table tc-contrato like fin.contrato.

for each tit_novacao where
         tit_novacao.ger_contnum = contrato.contnum
          no-lock:
    vvenda = vvenda + tit_novacao.ori_titvlcob.
    find first tc-contrato where
               tc-contrato.contnum = int(tit_novacao.ori_titnum)
               no-error.
    if not avail tc-contrato
    then do:
        create tc-contrato.
        assign
            tc-contrato.contnum = int(tit_novacao.ori_titnum)
            tc-contrato.etbcod  = tit_novacao.ori_etbcod
            .
    end.

    tc-contrato.vltotal = tc-contrato.vltotal + tit_novacao.ori_titvlcob.
end.

find clien where clien.clicod = contrato.clicod no-lock no-error.
if avail clien then
assign vendereco = trim(clien.endereco[1]).

find finan where finan.fincod = contrato.crecod no-lock no-error.
if avail finan then
    assign vparc = string(finan.finnpc).

def var vqtdp as int.
vqtdp = 0.

for each titulo where titulo.empcod = 19 
                   and titulo.titnat = no 
                   and titulo.modcod = contrato.modcod
                   and titulo.etbcod = contrato.etbcod
                   and titulo.clifor = contrato.clicod
                   and titulo.titnum = string(contrato.contnum)
                   and titulo.titpar > 0
                   no-lock. 
    vqtdp = vqtdp + 1.
end.    

if vqtdp = 0 then return.
vparc = string(vqtdp).                 
                    
def var varquivo as char.
def var valor-divida as dec.
def var pct-fin as dec.

def var vret-CET as char.
def var vret-CETAnual as char.
def var vret-ValorFinanciado as char.
def var vret-Taxa as char.
def var vret-ValorIOF as char. 

{/admcom/progr/api/sicredsimular.i new} /* 10/2021 moving sicred - chamada api json */

assign
    vret-CET = string(contrato.cet) 
    vret-CETAnual = string((exp(1 + contrato.cet / 100,12) - 1) * 100) 
    vret-Taxa = string(contrato.txjuro) 
    vret-ValorIOF = string(contrato.vliof) 
    vret-ValorFinanciado = string(contrato.vlf_principal).
                        
if dec(vret-ValorFinanciado) > 0 and
   dec(vret-ValorIOF) > 0 and
   dec(vret-CET) > 0
then.
else do:
      
                    /* 10/2021 moving sicred - chamada api json */
                    create ttdados.
                        ttdados.loja = string(contrato.etbcod,"9999").
/*                        ttdados.dataInicio = string(year(contrato.dtinicial),"9999")  + "-" +
                                             string(month(contrato.dtinicial),"99") + "-" +
                                             string(day(contrato.dtinicial),"99")   + " 00:00:00". */
                        ttdados.dataPrimeiroVencimento = 
                                             string(year(pprivenc),"9999")  + "-" +
                                             string(month(pprivenc),"99") + "-" +
                                             string(day(pprivenc),"99")   + " 00:00:00" .
                        ttdados.plano           = string(contrato.crecod,"9999").
                        ttdados.prazo           = int(vparc).
                        ttdados.valorSolicitado = contrato.vlf_principal.
                        vret-ValorFinanciado    = string(ttdados.valorSolicitado).
                        ttdados.valorParcela    = ?.
                        ttdados.valorSeguro     = 0.
                        ttdados.taxa            = ?.
                        ttdados.prazoMin        = ?.
                        ttdados.prazoMax        = ?.
    

                    run /admcom/progr/api/sicredsimular.p. /* 10/2021 moving sicred - chamada api json */

                find first ttreturn no-error.
                if avail ttreturn
                then do:
                    assign vret-CET            = string(ttreturn.cetMes).
                    assign vret-CETAnual       = string(ttreturn.cetAno).
                    assign vret-ValorIOF       = string(ttreturn.valorIOF).
                    assign vret-Taxa           = string(ttreturn.taxaMes).
                    /* 10/2021 moving sicred - chamada api json */
                    
                end.
end.

assign vret-CET = trim(string(round(decimal(vret-CET),2),">,>>9.99")).
assign vret-CETAnual = trim(string(round(decimal(vret-CETAnual),2),">,>>9.99")).

varquivo = "/admcom/tmp/financeira/contrato_" + string(contrato.contnum).

valor-divida = vprest * int(vparc).
pct-fin = (valor-divida / dec(vret-ValorFinanciado)) * 100.

{crd/contratoimp-novacao.i}


if p-imp = "epson-contratos"
then do:
    def temp-table ttsaida  no-undo serialize-name "impressoras"
        field nome      as char format "x(30)" serialize-name "text"
        field endereco  as char format "x(40)" serialize-name "value".

    input THROUGH value("lpstat -t 2>/dev/null |grep device").
    repeat.
        create ttsaida.
        import        ^        ^        ttsaida.nome        ttsaida.endereco.
        ttsaida.nome = replace(ttsaida.nome,":","").
    end.
    input close.

    find first ttsaida where ttsaida.nome = p-imp no-error.
    if not avail ttsaida
    then do:
        message "impressora " p-imp "na cadastrada neste servidor".
        p-imp = "pdf".
    end.    
    
end.
if p-imp = "epson-contratos"
then do:


    os-command silent "lpr -P " value(p-imp) value(varquivo).
    
    /*helio 1702022 gerar sempre
    sresp = no.    
    *message "contrato impresso em " p-imp "!  GERAR PDF?" update sresp.
    *if sresp 
    *then */
    
    p-imp = "PDF".
    
end.
if p-imp = "PDF"
then do:
    def var vpdf as char.

    run /admcom/progr/pdfout.p (input varquivo,
                      input "/admcom/tmp/financeira/",
                      input "contrato_" + string(contrato.contnum) + ".pdf",
                      input "Portrait",
                      input 8.2,
                      input 1,
                      output vpdf).
    os-command silent value("rm -f " + varquivo).

    message "arquivo PDF " "/admcom/tmp/financeira/" + vpdf "Gerado!"
        view-as alert-box.
end.



procedure imprime-texto.

def var vPos     as int.
def var vPalavra as char.
def var vPosUlt  as int.
def var vLetra   as char.
def var mTexto   as char extent 70.
def var vLin     as int.
def var vTextoIni   as char.

for each tt-texto no-lock.
    assign
        vtextoini = tt-texto.linha + " "
        vLin      = 1
        vPalavra  = ""
        mTexto    = ""
        vPos      = 1.
    repeat.
        if vPos > Length(vTextoIni)
        then leave.
        vLetra = substr(vTextoIni, vPos, 1).
        vPalavra = vPalavra + vLetra.
        if vLetra = " "
        then do.
            mTexto[vLin] = mTexto[vLin] + vPalavra.
            vPalavra = "".
            vPosUlt = vPos.
        end.
        if length(mTexto[vLin]) + length(vpalavra) > /*=*/ largura
        then do.
            vLin = vLin + 1.
            vPalavra = "".
            vPos = vPosUlt + 1.
        end.
        else
            vPos = vPos + 1.
    end.

    /* Fazer o alinhento "justificado" */
    do vPos = 1 to vLin - 1.
        mTexto[vPos] = trim(mTexto[vPos]).
        /* faz leitura do fim p/o incio da linha*/
        vPosUlt = length(mTexto[vPos]).
        repeat.
            if length(mTexto[vPos]) >= largura
            then leave.
            if substr(mTexto[vPos], vPosUlt, 1) = " " /* acrescenta um espaco */
            then mTexto[vPos] = substr(mTexto[vPos], 1, vPosUlt) +
                                substr(mTexto[vPos], vPosUlt).
            vPosUlt = vPosUlt - 1.
            if vPosUlt = 0
            then vPosUlt = length(mTexto[vPos]).
        end.
    end.
    do vPos = 1 to vLin.
        put unformatted mTexto[vPos] skip.
    end.
end.

end procedure.

