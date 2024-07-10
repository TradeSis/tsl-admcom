
def input parameter p-rec as recid.

define            variable vmescomp as char format "x(09)" extent 12 initial
    ["Janeiro","Fevereiro","Mar‡o","Abril","Maio","Junho",
     "Julho","Agosto", "Setembro","Outubro","Novembro","Dezembro"].


def var vcontrato as char format "x(30)".
def var vvenda as dec format ">>>>>>>.99".
def var vprest as dec format ">>>>>>>.99".
def var vdpaga as int format ">>9".
def var vendereco as char format "x(25)".
def var vdtult as char.
def var vdtpri as char.
def var vparc as char.
def buffer btitulo for fin.titulo.
def var largura as int init /*56*/ 112.
def temp-table tt-texto
    field linha as char format "x(96)".

def var v-etbcod like estab.etbcod.
def var v-pladat like plani.pladat.

input from value("/admcom/progr/crd/contrato.txt") no-echo.
repeat transaction.
    create tt-texto.
    import unformatted tt-texto.
end.
input close.

find contrsite where recid(contrsite) = p-rec no-lock.    
find contrato of contrsite no-lock.

assign vcontrato = string(contrato.contnum,">>>>>>>>>9").

find last titulo where titulo.contnum = contrato.contnum no-lock no-error.
if not avail titulo
then
find last titulo where titulo.empcod = 19 
                   and titulo.titnat = no 
                   and titulo.modcod = contrato.modcod
                   and titulo.etbcod = contrato.etbcod
                   and titulo.clifor = contrato.clicod
                   and titulo.titnum = string(contrato.contnum)
                   no-lock no-error.
if avail titulo
then 
    assign vprest = titulo.titvlcob - titulo.titdesc /* Seguro */
           vdtult = string(titulo.titdtven,"99/99/99")
           vparc  = string(titulo.titpar).
           
find first btitulo where btitulo.contnum = contrato.contnum and
                        btitulo.titpar  = 1 no-lock no-error.
if not avail btitulo
then
find first btitulo where btitulo.empcod = 19
                    and btitulo.titnat = no
                    and btitulo.modcod = contrato.modcod
                    and btitulo.etbcod = contrato.etbcod
                    and btitulo.clifor = contrato.clicod
                    and btitulo.titnum = string(contrato.contnum)
                    and btitulo.titpar = 1 no-lock no-error.
if avail btitulo
then
    assign vdtpri = string(btitulo.titdtven,"99/99/99")
           vdpaga = btitulo.titdtven - today.

assign 
    vvenda   = contrsite.valortotal
    v-etbcod = contrsite.etbcod
    v-pladat = contrsite.dataTransacao.

find clien where clien.clicod = contrato.clicod no-lock no-error.
if avail clien then
assign vendereco = trim(clien.endereco[1]).

find finan where finan.fincod = contrato.crecod no-lock no-error.

def var varquivo as char.
def var valor-divida as dec.
def var pct-fin as dec.
def var vret-CET                 as char.
def var vret-CETAnual            as char.
def var vret-Taxa                as char.
def var vret-ValorIOF            as char.
def var vret-ValorFinanciado     as char.

assign vret-CET =      trim(string(round(decimal(contrSite.taxaCET),2),">,>>9.99")).
assign vret-CETAnual = trim(string(round(decimal(contrSite.taxaCETAno),2),">,>>9.99")).
assign vret-taxa     = trim(string(round(decimal(contrSite.taxaCalc),2),">,>>9.99")).
assign vret-valoriof   = trim(string(round(decimal(contrSite.valorIOF),2),">>,>>9.99")).
assign vret-valorfinanciado   = trim(string(round(decimal(contrSite.valortotalprazo),2),">>>,>>9.99")).


varquivo = "/mnt/Crediario_Digital/contrato_" + string(contrato.contnum) .

valor-divida = contrSite.valorTotalPrazo.
pct-fin = (valor-divida / dec(contrsite.valorTotal)) * 100.

{/admcom/progr/crd/contratositeimp.i}

def var vpdf as char.
 
 run /admcom/progr/pdfout.p (input varquivo,
                  input "/mnt/Crediario_Digital/",
                  input "contrato_" + string(contrato.contnum) + ".pdf",
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).


/**if scarne = "local"
**then unix silent /fiscal/lp value(varquivo).
**else unix silent /fiscal/lp value(varquivo) 1.
**/

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

