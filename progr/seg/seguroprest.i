def var vsegtipo     as int.
def var vsegprest    as dec.
def var vsegvalor    as dec.
def var vseguro-nota as log init no.
def var vende-seguro as log.

procedure seguroprestamista.
    def input  parameter p-nprest  as int.
    def input  parameter p-parcela as dec.
    def input  parameter p-vencod  as int.
    def output parameter p-segtipo  as int init 0.
    def output parameter p-segprest as dec init 0.
    def output parameter p-segvalor as dec init 0.

    def var vconfec  as log.
    def var vmoveis  as log.
    def var vprocod  as int.
    def var vprocod-del as int.
    def var vprotot  as dec.
    def var vct      as int.
    def var mprodseg as int extent 3 init [578790, 579359, 559911].

    if vende-seguro and
       p-nprest >= 3 and
       p-parcela >= 10
    then do.
        for each wf-movim:
            if wf-movim.movpc = 1
            then next.

            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ
            then next.

            if produ.catcod = 31
            then vmoveis = yes.
            else if produ.catcod = 41
            then vconfec = yes.
            vprotot = vprotot + (wf-movim.movpc * wf-movim.movqtm).
        end.
        if vmoveis and vconfec
        then.
        else do.
            vprocod-del = 0.
            if vmoveis
            then /***vprocod  = 559910.***/
                if vprotot <= 300
                then assign
                        vprocod = 578790
                        vprocod-del = 579359.
                else assign
                        vprocod = 579359
                        vprocod-del = 578790.
            else vprocod  = 559911.

            if vprocod-del > 0
            then do.
                find produ where produ.procod = vprocod-del no-lock.
                find first wf-movim where wf-movim.wrec = recid(produ)
                               no-error.
                if avail wf-movim
                then delete wf-movim.
            end.

            find produ where produ.procod = vprocod no-lock.
            find first estoq of produ no-lock.
            /*
            p-segtipo = produ.catcod.
            */
            if vmoveis then p-segtipo = 31.
                       else p-segtipo = 41.
            find first wf-movim where wf-movim.wrec = recid(produ) no-error.
            if not avail wf-movim
            then do.
                create wf-movim.
                assign
                    wf-movim.wrec   = recid(produ)
                    wf-movim.movqtm = 1
                    wf-movim.movpc = estoq.estvenda
                    wf-movim.vencod = p-vencod
                    wf-movim.movalicms = 98.
                if vmoveis
                then assign
                         p-segprest = 0
                         p-segvalor = estoq.estvenda.
                else assign
                         p-segprest = estoq.estvenda /* 2.99 */
                         p-segvalor = estoq.estvenda * p-nprest.
                wf-movim.movpc = p-segvalor.
            end.
            else
                if vmoveis
                then assign
                         p-segprest = 0
                         p-segvalor = estoq.estvenda.
                else assign
                         p-segprest = estoq.estvenda /* 2.99 */
                         p-segvalor = estoq.estvenda * p-nprest.

            /**********     
            if vmoveis
            then do.
                assign
                    p-segprest = 0
                    p-segvalor = estoq.estvenda.

                if p-parcela >= 10
                then do.
                    find first wf-movim where wf-movim.wrec = recid(produ)
                               no-error.
                    if not avail wf-movim
                    then do.
                        create wf-movim.
                        assign
                            wf-movim.wrec   = recid(produ)
                            wf-movim.movqtm = 1
                            wf-movim.movpc = estoq.estvenda
                            wf-movim.vencod = p-vencod
                            wf-movim.movalicms = 98
                            .
                    end.
                end.
            end.
            else assign
                    p-segprest = estoq.estvenda /* 2.99 */
                    p-segvalor = estoq.estvenda * p-nprest.                        ***********/
        end.
    end.
    else
        /* Desfazer seguro */
        do vct = 1 to 3.
            find produ where produ.procod = mprodseg[vct] no-lock.
            find first wf-movim where wf-movim.wrec = recid(produ) no-error.
            if avail wf-movim
            then delete wf-movim.
        end.

end procedure.

