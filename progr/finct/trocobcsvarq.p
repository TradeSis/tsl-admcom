/* helio 12042023 - ID 155992 Orquestra 465412 - Troca de carteira */
/* 09022023 helio ID 155965 */
/* 30112021 helio retorno carteira */
/* 26112021 helio venda carteira */
{admcab.i}
def input param par-completo as log.
def input   param vcobcodori  like cobra.cobcod.
def input   param vcobcoddes  like cobra.cobcod.
def output  param varqin      as char format "x(65)".
def buffer btitulo for titulo.

def shared temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field contnum   like contrato.contnum    format ">>>>>>>>9"
    field dtemi     like contrato.dtinicial
    field vlabe     as dec
    field vlatr     as dec
    field vlpag     as dec
    field cobcod    like titulo.cobcod
    field vlf_principal as dec
    field vlf_acrescimo as dec
    field vlpre         as dec
    field qtdpag        as int
    field diasatraso    as int format "999"
    index contnum is unique primary contnum asc.

def var vin as int.

   def var vi as int. def var ctpcontrato as char.
    
    def var vcobout like cobra.cobcod label "Carteira".
   def var vcp  as char init ";".
    pause 0.
    

    run get_file.p ("/admcom/tmp/trocacart/","csv",output varqin).
    
    disp skip(2) varqin  label "Entrada" colon 10
            skip(2) 
                   with frame fx
        centered 
        overlay
        side-labels
        color messages
        row 4
        with title "ARQUIVO CSV COM LISTA DE  CONTRATOS".
        
if search(varqin) = ?
then do:
    message "arquivo /admcom/tmp/trocacart/" + varqin "nao encontrado".
    pause.
    return.
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
    import delimiter ";" ttcontrato.contnum no-error.
    if ttcontrato.contnum = 0 or ttcontrato.contnum = ? or error-status:error
    then do:
        delete ttcontrato.
        next.
    end.    
end.
input close.

pause before-hide.
for each ttcontrato where ttcontrato.contnum = 0 or ttcontrato.contnum = ? . 
    delete ttcontrato.
end.
for each ttcontrato break by ttcontrato.contnum.
    if first-of(ttcontrato.contnum) 
    then do:
        run avaliaContrato.    
        next.
    end.    
    delete ttcontrato.
end.    
hide frame fx no-pause.
pause 0 before-hide.     

    
procedure avaliaContrato.

do on error undo:

    find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
    if not avail contrato
    then do:
        delete ttcontrato.
        return.
    end.    
    ttcontrato.dtemi    = contrato.dtinicial.
    ttcontrato.marca    = ?.

    for each btitulo where btitulo.empcod = 19 and btitulo.titnat = no and     
            btitulo.etbcod = contrato.etbcod and btitulo.modcod = contrato.modcod and
            btitulo.clifor = contrato.clicod and btitulo.titnum = string(contrato.contnum)
            no-lock.
        if btitulo.titpar = 0 then next.
        if btitulo.cobcod = vcobcoddes
        then ttcontrato.marca = no.
        if vcobcoddes <> 16
        then do:
            if btitulo.cobcod = 16 and vcobcodori = ?
            then ttcontrato.marca = no.
        end.
        
        if vcobcodori = 1 
        then do:
            if btitulo.cobcod = 1 or btitulo.cobcod = 2
            then.
            else ttcontrato.marca = no.
        end. 
        else if vcobcodori <> ?
             then if btitulo.cobcod <> vcobcodori then ttcontrato.marca = no. 
             
        if btitulo.titsit = "PAG"
        then do:
            ttcontrato.vlpag = ttcontrato.vlpag + btitulo.titvlcob.
            ttcontrato.qtdpag = ttcontrato.qtdpag + 1.
        end.
        if btitulo.titsit = "LIB"
        then do:
            ttcontrato.vlf_principal = ttcontrato.vlf_principal + btitulo.vlf_principal.
            ttcontrato.vlf_acrescimo = ttcontrato.vlf_acrescimo + btitulo.vlf_acrescimo.
            ttcontrato.vlabe = ttcontrato.vlabe + btitulo.titvlcob.
            /*
            ttcontrato.vlpre = ttcontrato.vlpre + (btitulo.titvlcob -
                                                    (btitulo.titvlcob * ttfiltros.percdesagio / 100)).
            */                                                    
            if btitulo.titdtven < today
            then do:
                ttcontrato.vlatr = ttcontrato.vlatr + btitulo.titvlcob.
                ttcontrato.diasatraso = max(ttcontrato.diasatraso,today - btitulo.titdtven) .
            end.    
        end.      
    end.
            
    if ((par-completo = no and ttcontrato.vlabe > 0) or 
         par-completo = yes) and
       ttcontrato.marca = ? 
    then ttcontrato.marca = yes.   

    
    if ttcontrato.marca = no or
       ttcontrato.marca = ?
    then ttcontrato.marca = no.

end.

end procedure.

    
    




