def var vprecovenda like estoq.estven init 0.
def var vprecosugerido like ctpromoc.precosugerido init 0.
def var vsequencia like ctpromoc.sequencia init 0.

output to /var/www/drebes/arquivosdesenv/produtos/exp_avista_promo.csv.

    put "procod ; pcusto ; pvenda ; ppromo ; sequencia ; precovenda ; prodtcad" skip.

    for each produ where produ.proseq = 0 no-lock.

        find first estoq where estoq.estven > 0 and
                               estoq.procod = produ.procod no-lock no-error.
        if not avail estoq then next.

        find last ctpromoc where ctpromoc.procod = produ.procod no-lock no-error.
        if avail ctpromoc then do:
            if ctpromoc.dtfim >= today then do: 
                vprecovenda = ctpromoc.precosugerido.
                vprecosugerido = ctpromoc.precosugerido.
                vsequencia = ctpromoc.sequencia.
            end.
        end.
        else vprecovenda = estoq.estven.

        put                                                                
            produ.procod format ">>>>>>>>>9" ";"
            estoq.estcusto ";"
            estoq.estven ";"
            vprecosugerido ";"
            vsequencia ";"
            vprecovenda ";"
            YEAR(produ.prodtcad) format "9999" "-" MONTH(produ.prodtcad) format "99" "-" DAY(produ.prodtcad) format "99" skip.

    end.

output close.