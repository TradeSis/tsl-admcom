{admcab.i }

def temp-table wfilial
    field wfil like estab.etbcod.

def var vpre as dec.
def var vper as dec format ">>9.99 %" label "Perc.".
DEF BUFFER BESTOQ FOR ESTOQ.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estproper format ">,>>9.99" label "Promocao".
def var vprocod like produ.procod.
repeat:

    for each wfilial:
        delete wfilial.
    end.
    
    UPDATE vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    disp produ.pronom no-label with frame f1.

    FIND BESTOQ WHERE BESTOQ.PROCOD = PRODU.PROCOD AND
                      BESTOQ.ETBCOD = 1 NO-LOCK.
    disp bestoq.estvenda
         bestoq.estproper label "Promocao" format ">>,>>9.99" with frame f1.
    vdata = BESTOQ.ESTPRODAT.
    vpreco = BESTOQ.ESTPROPER.
    vper = 0.
    update vdata
           vper with frame f2.
    vpreco = bestoq.estvenda - ( bestoq.estvenda * (vper / 100)).
    update vpreco with frame f2 centered side-label.
        
    repeat:
        create wfilial.
        update wfilial.wfil label "Filial"
                with frame f-1 side-label centered down.
    end.

    message "Confirma Promocao" update sresp.
    if sresp
    then do:
        for each wfilial no-lock:
            for each estoq where estoq.etbcod = wfilial.wfil and
                                 estoq.procod = produ.procod.
                estoq.datexp = today.
                estoq.estproper = vpreco.
                estoq.estprodat = vdata.
                estoq.dtaltpromoc = today.

                find hisprpro where 
                    hisprpro.procod = estoq.procod and
                    hisprpro.etbcod = estoq.etbcod and
                    hisprpro.Data_inicio = today 
                    no-error.
                if not avail hisprpro
                then create hisprpro.
                ASSIGN 
                    hisprpro.preco_tipo = "P"
                    hisprpro.etbcod     = estoq.etbcod
                    hisprpro.procod     = estoq.procod
                    hisprpro.data_inicio = today
                    hisprpro.data_fim    = estoq.estprodat
                    hisprpro.preco_valor = estoq.estproper
                    hisprpro.OFFER_ID    = ?
                    hisprpro.preco_plano  = estoq.tabcod
                    hisprpro.preco_parcela = estoq.estmin
                    hisprpro.PRICE_KEY  = program-name(1)
                    hisprpro.data_inclu = today
                    hisprpro.hora_inclu = time .

            end.
        end.
    end.
end.
