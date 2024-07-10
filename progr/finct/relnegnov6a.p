def input parameter pfinal   as int.
def input parameter pcontnum as int.
def input-output parameter pordem as int.
def shared temp-table ttanteriores
    field final    like contrato.contnum format ">>>>>>>>>>9"
    field contnum  like contrato.contnum format ">>>>>>>>>>9"
    field ordem    as int
    field anterior like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field saldoabe  like titulo.titvlcob.


def buffer bttanteriores for ttanteriores.
def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field saldoabe  like titulo.titvlcob  
    index idx is unique primary tipo desc contnum asc.
for each ttnovacao.
    delete ttnovacao.
end.
    
    for each ttanteriores where ttanteriores.final = pfinal and  ttanteriores.contnum = pcontnum.

        find contrato where contrato.contnum = ttanteriores.anterior no-lock.
            find first pdvmoeda where pdvmoeda.modcod = contrato.modcod                and
    
                                    pdvmoeda.titnum = string(contrato.contnum)
                                    no-lock no-error.
    
        if avail pdvmoeda
        then do:
                find first pdvmov of pdvmoe no-lock no-error.
                
                    if not avail pdvmov then next.
                    find pdvtmov of pdvmov no-lock.
                    if pdvtmov.novacao = no
                    then next.
                        
            run fin/montattnov.p (recid(pdvmov),no).
            find first ttnovacao no-error.
                                    
            for each ttnovacao where ttnovacao.contnum <> contrato.contnum .             
                create bttanteriores.
                bttanteriores.final   = pfinal.                
                bttanteriores.contnum = contrato.contnum.
                bttanteriores.ordem   = pordem.
                bttanteriores.anterior = ttnovacao.contnum.
                bttanteriores.valor = ttnovacao.valor.
                bttanteriores.saldoabe = ttnovacao.saldoabe.
                
                /*
                disp ttnovacao with title string(pcontnum) + "-" + string(contrato.contnum).
                */
            end            .

        end.
        
        find first ttnovacao no-error.
        if avail ttnovacao
        then do:
            pordem = pordem + 1.
            run finct/relnegnov6a.p (pfinal , contrato.contnum, 
                                    input-output pordem).
        end.     
    end.        
        
