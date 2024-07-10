/***
    08/2017 - Nova novacao
              CALCULAR TAXA DE JUROS AO MES
***/

    define input parameter par-vlmontante as decimal.
    define input parameter par-vltotcontr as decimal.
    define input parameter par-qtdparc    as int.
    define output parameter par-txjuros   as decimal.

    def var vvlparcela        as dec.
    def var juros_inicial     as dec.
    def var juros_final       as dec.
    def var suposto_juros     as dec.
    def var suposto_parcela   as dec.
    def var suposta_diferenca as dec.
    def var vct               as int.
    def var vachou            as logic. 

    vvlparcela    = par-vltotcontr / par-qtdparc.
    juros_inicial = 0.   /*** -1 ***/
    juros_final   = 999. /*** 99999 ***/

    do vct = 1 TO 1000:
        suposto_juros = (juros_final + juros_inicial) / 2.
                       
        suposto_parcela = (par-vlmontante * suposto_juros) / 
                          (1 - exp(1 / (1 + suposto_juros), par-qtdparc)).
                                                              
        suposta_diferenca = ABSOLUTE (vvlparcela - suposto_parcela).

/*
        disp vct
            suposto_juros * 100 @ suposto_juros
            suposto_parcela
            suposta_diferenca format ">>>>>>>9.999999999999999999"
            with frame f-calculo down.
        down with frame f-calculo.
*/
        if suposta_diferenca > 0.000001 /* 0.0000001 */
        then
            if suposto_parcela > vvlparcela
            then juros_final   = suposto_juros.
            else juros_inicial = suposto_juros.
        else do.
            vachou = yes.
            leave.
        end.
    end.
    if vachou
    then do:
        if suposto_juros <> -100 or
           suposta_diferenca < 0.01 /*** ***/
        then suposto_juros = round(suposto_juros * 100, 6).
        par-txjuros = suposto_juros.
    end.

