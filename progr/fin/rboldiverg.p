/* helio 20062022 - PACOTE DE MELHORIAS - ITEM 316897 divedrgencias boleto*/
{admcab.i}
def input param ptitle as char.

def var recatu2        as recid.
def buffer bbanboleto for banboleto.
def var prec as recid.
def var par-rec as recid.
def var vdtini  as date label "data inicial" format "99/99/9999" initial today.
def var vdtfin  as date label "data final"   format "99/99/9999" initial today.
def var vmoecod like titulo.moecod init "BOL". 

update vdtini colon 20
       vdtfin
       with frame fcab centered
       row 4 side-labels title ptitle.

   def var varq as char format "x(60)".
   def var vcp  as char init ";".
   varq = "/admcom/relat/" + "boldiverg_" +
                             string(vdtini,"99999999") + string(vdtfin,"99999999") + 
                             "_"   + string(today,"999999")  + string(time) +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".

        
def var vlookup-contnum as int.
def var vlookup-acordo  as int.


message "Gerando arquivo" varq.

output to value(varq).    
put unformatted
    "Cliente;"
    "Banco;"
    "NossoNumero;"
    "Emissao Boleto;"
    "integracao;"
    "Pagamento Boleto;"
    "Acordo;"
    "Contrato;"
    "Parcela;"
    "Dt Pagam parcela;"
    "Valor Parcela"
    skip.
     
for each banboleto where dtpagamento >= vdtini and dtpagamento <= vdtfin no-lock,
    each banbolorigem of banboleto  no-lock

    break by chaveorigem desc by dadosorigem by banboleto.clifor by banboleto.dtpagamento.

    if first-of(dadosorigem) and last-of(dadosorigem) then next.
    vlookup-contnum = lookup("contnum",chaveorigem).    
    if vlookup-contnum = 0 then next.

    put unformatted
        banboleto.clifor vcp
        BanBoleto.bancod vcp
        BanBoleto.NossoNumero vcp
        BanBoleto.DtEmissao vcp
        BanBoleto.tipoIntegracao format "x(10)" vcp
        BanBoleto.DtPagamento vcp.
    
    vlookup-acordo  = lookup("idacordo",chaveorigem).    
    
    if vlookup-acordo > 0
    then do:
        find cybacordo where cybacordo.idacordo = int(entry(vlookup-acordo,dadosorigem)) no-lock.
        put unformatted
        cybacordo.idacordo format ">>>>>>>9" vcp. 
    end.
    else put unformatted "" vcp.
        
    if vlookup-contnum > 0
    then do:
        find contrato where contrato.contnum = int(entry(vlookup-contnum,dadosorigem)) no-lock.
        find titulo where titulo.empcod = 19 and titulo.titnat = no and
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
            and titulo.titpar = int(entry(vlookup-contnum + 1,dadosorigem))
            no-lock.
        put unformatted
            titulo.titnum   vcp
            titulo.titpar   vcp
            titulo.titdtpag vcp
            titulo.titvlcob vcp. 
    end.
    else do:
        put unformatted
            " ;"
            " ;"
            " ;"
            " ;".
    end.
    put skip.
    

end.  
put "FIM DO ARQUIVO"
    skip.
output close.
  



    message varq "gerado com sucesso.".
    pause 2 no-message.

