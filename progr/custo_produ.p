/* por Lucas Leote */

{admcab.i}

def var vlprod as decimal.
def var vlfrete as decimal.
def var credpis as decimal init 1.65.
def var vlcredpis as decimal.
def var credcofins as decimal init 7.6.
def var vlcredcofins as decimal.
def var credicms as decimal init 12.
def var vlcredicms as decimal.
def var ipi as decimal.
def var vlipi as decimal.
def var mva as decimal.
def var vlmva as decimal.
def var baseicmsst as decimal.
def var calculoicmsst as decimal init 17.
def var vlcalculoicmsst as decimal.
def var vlicmsst as decimal.
def var custototal as decimal.
def var custoliquido as decimal.
def var custost as decimal.
def var redbaseicmsst as decimal init 29.411.
def var vlredbaseicmsst as decimal.

/* Formulario */
form vlprod label "Valor de custo"
     vlfrete label "Valor do frete"
     credpis label "% Cred. PIS"
     credcofins label "% Cred. COFINS"
     credicms label "% Cred. ICMS"
     ipi label "% IPI"
     mva label "% MVA"
     redbaseicmsst label "% Red. Base ICMS/ST"
     calculoicmsst label "% Cal. ICMS/ST"
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update vlprod
       vlfrete
       credpis
       credcofins
       credicms
       ipi
       mva
       redbaseicmsst
       calculoicmsst
with frame f01.

/* Calcula Cred. PIS, Cred. COFINS, Cred. ICMS, IPI e MVA  */
vlcredpis = (vlprod + vlfrete) * credpis.
vlcredcofins = (vlprod + vlfrete) * credcofins.
vlcredicms = (vlprod + vlfrete) * credicms.
vlipi = (vlprod + vlfrete) * ipi.
vlmva = (vlipi / 100 + vlprod + vlfrete) * mva.

/* Calcula as porcentagens  */
vlcredpis = vlcredpis / 100.
vlcredcofins = vlcredcofins / 100.
vlcredicms = vlcredicms / 100.
vlipi = vlipi / 100.
vlmva = vlmva / 100.
redbaseicmsst = redbaseicmsst / 100.

/* Calcula Reducao Base ICMS/ST */
if redbaseicmsst > 0 then do:
        vlredbaseicmsst = baseicmsst - (baseicmsst * redbaseicmsst).
        /*baseicmsst = vlredbaseicmsst.*/
end.

/* Calcula custo total */
custototal = vlprod + vlfrete + vlipi + vlicmsst.

if mva > 0 then do:
        baseicmsst = vlmva + vlprod + vlfrete + vlipi.
        vlcalculoicmsst = (baseicmsst * calculoicmsst) / 100.
        vlicmsst = vlcalculoicmsst - vlcredicms.
	custost = (vlprod + vlfrete + vlipi + vlicmsst) - (vlcredpis + vlcredcofins).
end.

if mva = 0 then do:
	custoliquido = custototal - vlcredpis - vlcredcofins - vlcredicms.
end.

/* Calcula custo total */
custototal = vlprod + vlfrete + vlipi + vlicmsst.                

/* Imprimi valores na tela */
display vlprod label "Valor de custo"
        vlfrete label "Valor do frete"
        credpis label "% Cred. PIS" 
        vlcredpis label "Valor PIS"
        credcofins label "% Cred. COFINS"
        vlcredcofins label "Valor COFINS"
        credicms label "% Cred. ICMS"
        vlcredicms label "Valor ICMS"
        ipi label "% IPI"
        vlipi label "Valor IPI"
        mva label "% MVA"
        vlmva label "Valor MVA"
        redbaseicmsst label "% Red. Base ICMS/ST"
        vlredbaseicmsst label "Val Red. Base ICMS/ST"
        baseicmsst label "Base ICMS ST"
        calculoicmsst label "% Cal. ICMS/ST"
        vlcalculoicmsst label "Vl Cal. ICMS/ST"
        vlicmsst label "Valor ICMS/ST"
        custototal label "Custo total"
	custoliquido label "Custo liquido"
	custost label "Custo com ST"
with frame f-retorno with 2 col width 80 title "Retorno".

pause.
