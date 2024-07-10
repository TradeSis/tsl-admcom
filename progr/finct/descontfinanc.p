/*26022021 helio */
{admcab.i}
def var vlinha as char.
def var vaux as char.
def  temp-table ttcontrato no-undo
    field contnum   like titulo.contnum
    field titpar    like titulo.titpar  init ? 
    field titdtpag  as date
    field titvlpag  as dec
    field descfina  as dec.
    

def var vin as int.

    def var ccarteira as char.
    def var dcarteira as char.
    def buffer dcobra for cobra.    
    def var cmodnom   as char.
   def var vi as int. 
    
   def var varqout as char format "x(65)".
   def var varqin  as char format "x(65)".
        
   def var vcp  as char init ";".
    pause 0.
    
    
    varqin  = "/admcom/financeira/".
    varqout = "/admcom/tmp/ctb/" + "descontos_financeira_" + 
                    string(today,"999999")  + string(time) + "_.csv".
    
    update  skip(2) varqin  label "Entrada" colon 10
            skip(2) varqout label "Saida"   colon 10 skip(2)
                   with
        centered 
        overlay
        side-labels
        color messages
        row 5
        with title "ARQUIVO REM de Ressarcimentos da Financeira".
        
if search(varqin) = ?
then do:
    message "arquivo" varqin "nao encontrado".
    pause.
    undo.
end.    

hide message no-pause.
message "importando arquivo" varqin.

for each ttcontrato.
    delete ttcontrato.
end.
pause 0 before-hide.
def var vregistros as int.
input from value(varqin).
repeat transaction on error undo , next.
    import unformatted vlinha.
    if vregistros = 0
    then do:
        if vlinha begins "00RESSARCI"
        then do:
            vregistros = vregistros + 1.
            next.
        end.    
        else do.        
            message "Layout Incompativel" view-as alert-box.
            return.
        end.
    end.
    vregistros = vregistros + 1.    
    create ttcontrato.
    ttcontrato.contnum = int(substring(vlinha,7,10)).
    ttcontrato.titpar = int(substring(vlinha,17,3)).
    vaux = substring(vlinha,156,8).
    ttcontrato.titdtpag = date(int(substring(vaux,3,2)),int(substring(vaux,1,2)),int(substring(vaux,5,4))).
    vaux = substring(vlinha,140,14).
    ttcontrato.titvlpag = dec(vaux) / 100.
    vaux = substring(vlinha,223,14).
    ttcontrato.descfina = dec(vaux) / 100.


end.
input close.

pause before-hide.

hide message no-pause.
message vin "Contratos".
message "extraindo contratos para arquivo" varqout.
run outcontratos.
hide message no-pause.
message "arquivo" varqout "gerado.".
pause.





procedure outcontratos.
    output to value(varqout). 
    put unformatted 
        "Codigo;Nome;CPF;Contrato;Parcela;Data Pagamento;Carteira;Modalidade;Valor Recebido;Desconto Financeira"
        skip.
                                                
                                                
    for each ttcontrato.
        
        find contrato where contrato.contnum = int(ttcontrato.contnum) no-lock no-error.
        if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.
        
        find first titulo where
            titulo.empcod = 19 and titulo.titnat = no and titulo.etbcod = contrato.etbcod and
            titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum) and
            titulo.titpar = ttcontrato.titpar
            no-lock no-error.
        find cobra where cobra.cobcod = titulo.cobcod no-lock no-error.
        find modal where modal.modcod = contrato.modcod no-lock no-error.
        ccarteira = (if titulo.cobcod <> ? 
                 then string(titulo.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "-").

        cmodnom = if contrato.modcod <> ? 
                then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                else "-".
        
        put unformatted
            contrato.clicod     vcp
            if avail clien then clien.clinom else "-"       vcp
            if avail clien then clien.ciccgc else "-"       vcp
            contrato.contnum    vcp
            ttcontrato.titpar   vcp
            string(ttcontrato.titdtpag,"99/99/9999") vcp
            ccarteira      vcp 
            cmodnom             vcp
            trim(string(ttcontrato.titvlpag,">>>>>>>9.99")) vcp
            trim(string(ttcontrato.descfina,">>>>>9.99")) vcp
            
          skip.
            
    end.
    output close.
end procedure.    





