/** programa nao utilizado */

/**
/* helio 20122021 - Melhorias contas a receber fase II */
{admcab.i new}
def var psicred as recid.

def new shared temp-table ttcontrato no-undo
    field marca     as log
    field contnum   like titulo.titnum
    field titpar    like titulo.titpar  init ? 
    field cobcod    like titulo.cobcod
    index contnum   is unique primary
        contnum asc titpar asc.

def var vin as int.

    def var ccarteira as char.
    def var dcarteira as char.
    def buffer dcobra for cobra.    
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var varqout as char format "x(65)".
   def var vdtout  as date format "99/99/9999" label "Data" init today. 
   def var varqin  as char format "x(65)".
    def var vcobout like cobra.cobcod label "Carteira".
        
   def var vcp  as char init ";".
    pause 0.
    def var vdtlimite as date.
    vdtlimite = date(month(today),01,year(today)) - 1.
    vdtlimite = date(month(vdtlimite),01,year(vdtlimite)).
    
    update  skip(2) vdtout validate(input vdtout >= vdtlimite and input vdtout <= today,"Data menor que data Limite") colon 10 .
    
    
    update  skip(2) vcobout colon 10.
    find cobra where cobra.cobcod = vcobout no-lock no-error.
    disp cobra.cobnom no-labels.
    
    varqin  = "/admcom/tmp/ctb/" + "realocacao" + string(vdtout,"999999") + ".csv".
    varqout = "/admcom/tmp/ctb/" + "contratos_realocados_" + string(vcobout) + "_" +
                    string(vdtout,"999999") + "_"   + string(today,"999999")  + string(time) + "_.csv".

    run get_file.p ("/admcom/tmp/","csv",output varqin).
    
    update  skip(2) varqin  label "Entrada" colon 10
            skip(2) varqout label "Saida"   colon 10 skip(2)
                   with
        centered 
        overlay
        side-labels
        color messages
        row 5
        with title "ARQUIVO CSV COM LISTA DE  CONTRATOS ou CONTRATOS;PARCELA".
        
if search(varqin) = ?
then do:
    message "arquivo" varqin "nao encontrado".
    pause.
    undo.
end.    
def var pcontratocompleto as log.

pcontratocompleto = yes.

hide message no-pause.
message "importando arquivo" varqin.

for each ttcontrato.
    delete ttcontrato.
end.
pause 0 before-hide.
input from value(varqin).
repeat transaction on error undo , next.
    create ttcontrato.
    import delimiter ";" ttcontrato.contnum ttcontrato.titpar.
    if ttcontrato.contnum = "" or ttcontrato.contnum = ?
    then do:
        delete ttcontrato.
        next.
    end.    
end.
input close.

pause before-hide.
for each ttcontrato where ttcontrato.contnum = "" or ttcontrato.contnum = ? . 
    delete ttcontrato.
end.
for each ttcontrato where titpar = 0.
    ttcontrato.titpar = ?.
end.
for each ttcontrato where ttcontrato.titpar = ? break by ttcontrato.contnum.
    if first-of(ttcontrato.contnum) then next.
    disp ttcontrato.
    delete ttcontrato.
end.    
pause 0 before-hide.     
    
/* helio 15122021 - Melhorias contas a receber fase II */
run finct/trocacartctr.p (input varqout).
    
    



procedure outcontratos.
    output to value(varqout). 
    put unformatted 
        "Codigo" vcp 
        "Nome"   vcp 
        "CPF"    vcp 
        "Emissão" vcp 
        "Contrato" vcp  
        "Carteira original" vcp 
        "Data Realocacao" vcp
        "Carteira" vcp 
        "Modalidade"  vcp 
        "Filial"  vcp 
        "Tipo de cobrança" vcp 
        "entrada" vcp  
        "Acréscimo" vcp 
        "Valor" vcp 
        "Serviços financeiros(seguro)" vcp 
        skip.
                                                
                                                
    for each ttcontrato.
        
        find contrato where contrato.contnum = int(ttcontrato.contnum) no-lock no-error.
        if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.
        
        find first titulo where
            titulo.empcod = 19 and titulo.titnat = no and titulo.etbcod = contrato.etbcod and
            titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum) and
            titulo.titdtpag = ?
            no-lock no-error.
        if not avail titulo
        then do:
            find last titulo where
                titulo.empcod = 19 and titulo.titnat = no and titulo.etbcod = contrato.etbcod and
                titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
                titulo.titnum = string(contrato.contnum) 
                no-lock.
        end.    
        find cobra where cobra.cobcod = ttcontrato.cobcod no-lock no-error.
        find dcobra where dcobra.cobcod = vcobout no-lock.
        
        find modal where modal.modcod = contrato.modcod no-lock no-error.
        ccarteira = (if ttcontrato.cobcod <> ? 
                 then string(ttcontrato.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "-").
        dcarteira = (if vcobout <> ? 
                 then string(vcobout) + if avail dcobra 
                                           then ("-" + dcobra.cobnom)
                                           else ""
                 else "-").
                 

        ctpcontrato = if titulo.tpcontrato <> ? 
                then if titulo.tpcontrato = "F"
                     then "FEIRAO"
                     else if titulo.tpcontrato = "N"
                          then "NOVACAO"
                          else if titulo.tpcontrato = "L"
                               then "LP "
                               else "normal "
                else     "-".

        cmodnom = if contrato.modcod <> ? 
                then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                else "-".
        
        put unformatted
            
            contrato.clicod     vcp
            if avail clien then clien.clinom else "-"       vcp
            if avail clien then clien.ciccgc else "-"       vcp
            contrato.dtinicial  vcp
            contrato.contnum    vcp
            ccarteira      vcp 
            vdtout             vcp
            dcarteira           vcp
            cmodnom             vcp
            contrato.etbcod     vcp
            ctpcontrato         vcp
            trim(string(contrato.vlentra,">>>>>9.99")) vcp
            trim(string(contrato.vlf_acrescimo,">>>>>9.99")) vcp
            trim(string(contrato.vltotal,">>>>>9.99")) vcp
            trim(string(contrato.vlseguro,">>>>>9.99")) vcp
          skip.
            
    end.
    output close.
end procedure.    


***/


