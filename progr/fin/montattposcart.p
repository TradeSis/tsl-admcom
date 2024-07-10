def input param vdtini as date.
def input param vdtfin as date.
 
def shared temp-table ttposicao no-undo
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

/*
def var vcampo      as char.
def var vdescricao  as char.
def temp-table ttresumo no-undo
    field mesvenc   as int format "99"
    field anovenc   as int format "9999"
    field CAMPO     as char
    field DESCRICAO  as char
    field emissao   like poscart.emissao
    field pagamento like poscart.pagamento
    field saldo     like poscart.saldo
    index idx is unique primary anovenc asc mesvenc asc CAMPO asc DESCRICAO.
*/
     
def var iquarter as int.
def var cquarter as char.
def var xquarter as char extent 4
    init ["M3 ","M2 ","M1 ","P0 "].

def var vdt as date.
   

    iquarter = 0.    
    do vdt = vdtini to vdtfin.  
        if day(vdt) <> 01 then next.    
        iquarter  = iquarter + 1.
        cquarter = xquarter[iquarter].

        for each poscart use-index dtven
                where poscart.dtvenc = vdt
                no-lock.
            find first ttposicao
                where
                ttposicao.mesvenc = month(poscart.dtvenc) and
                ttposicao.anovenc = year(poscart.dtvenc)  and
                ttposicao.etbcod  = poscart.etbcod        and
                ttposicao.modcod  = poscart.modcod        and
                ttposicao.tpcontrato = poscart.tpcontrato and
                ttposicao.cobcod  = poscart.cobcod
                no-error.
            if not avail ttposicao
            then do:
                create ttposicao.
                ttposicao.mesvenc = month(poscart.dtvenc).
                ttposicao.anovenc = year(poscart.dtvenc).
                ttposicao.etbcod  = poscart.etbcod.
                ttposicao.modcod  = poscart.modcod.
                ttposicao.tpcontrato = poscart.tpcontrato.
                ttposicao.cobcod  = poscart.cobcod.
            end.                
            ttposicao.emissao   = ttposicao.emissao     + poscart.emissao.
            ttposicao.pagamento = ttposicao.pagamento   + poscart.pagamento.
            ttposicao.saldo     = ttposicao.saldo       + poscart.saldo.
        end.
    end.      


/**

vcampo = "FILIAL".
for each ttresumo.
    delete ttresumo.
end.    

for each ttposicao.
    if vcampo = "GERAL"
    then do:
        vdescricao = "GERAL".
    end.
    else do:
        if vcampo = "FILIAL"
        then do:
            find estab where estab.etbcod = ttposicao.etbcod no-lock no-error.
            vdescricao = if avail estab
                        then "Fil "+ string(estab.etbcod,"999")
                        else string(ttposicao.etbcod) + "-DESCONHECIDA".
        end.
        else do:
            next.
        end.
    end.
    find first ttresumo where
        ttresumo.mesvenc = ttposicao.mesvenc and
        ttresumo.anovenc = ttposicao.anovenc and
        ttresumo.campo   = vcampo            and
        ttresumo.descricao = vdescricao
        no-error.
    if not avail ttresumo
    then do:
        create ttresumo.       
        ttresumo.mesvenc = ttposicao.mesvenc.
        ttresumo.anovenc = ttposicao.anovenc.
        ttresumo.campo   = vcampo.
        ttresumo.descricao = vdescricao.
    end.
    ttresumo.emissao    = ttresumo.emissao + ttposicao.emissao.
    ttresumo.pagamento  = ttresumo.pagamento + ttposicao.pagamento.
    ttresumo.saldo      = ttresumo.saldo + (ttposicao.emissao - ttposicao.pagamento).

end.


for each ttresumo.
    disp ttresumo.
end.
**/