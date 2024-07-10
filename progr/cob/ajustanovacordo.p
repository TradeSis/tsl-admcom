def input parameter p-clicod as int.
def output param    p-situacao as log.

def var vaberto as dec.
def var vvencido as log. 

def var vger_contnum like tit_novacao.ger_contnum.
p-situacao = no.
for each novacordo where
           novacordo.clicod = p-clicod and
           novacordo.situacao = "PENDENTE"
           no-lock.

    vger_contnum = ?.
    vaberto = 0.       
    vvencido = no.
    for each tit_novacao where tit_novacao.id_acordo = string(novacordo.id_acordo) no-lock.
        find titulo where 
            titulo.empcod = tit_novacao.ori_empcod and
            titulo.titnat = tit_novacao.ori_titnat and
            titulo.modcod = tit_novacao.ori_modcod and
            titulo.etbcod = tit_novacao.ori_etbcod and
            titulo.clifor = tit_novacao.ori_clifor and
            titulo.titnum = tit_novacao.ori_titnum and
            titulo.titpar = tit_novacao.ori_titpar and
            titulo.titdtemi = tit_novacao.ori_titdtemi
            no-lock no-error.
        if vger_contnum = ? 
        then vger_contnum = tit_novacao.ger_contnum.
        if avail titulo
        then
            if titulo.titsit = "LIB"
            then vaberto = vaberto + titulo.titvlcob.
    end.        
    /* ID 65601 helio.neto 30/06/2021 */
    
    for each tit_acordo of novacordo no-lock.
        if tit_acordo.titdtven < today
        then vvencido = yes.    
    end.    
    
    if vaberto = 0 or vvencido
    then do:
        find contrato where contrato.contnum = vger_contnum no-lock no-error.
        run pp.
    end.
    else p-situacao = yes.
    
end.        
                    
            
procedure pp.

do on error undo.
 
    find current novacordo exclusive no-wait no-error.
    if avail novacordo
        then
        novacordo.situacao = if (avail contrato or vaberto = 0) and vvencido = no
                             then "EFETIVADO"
                             else "CANCELADO".

    release novacordo.
end.
    
end procedure.
