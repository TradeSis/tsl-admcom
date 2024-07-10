def {1} shared temp-table tt-result
    field dtresult       as date
    field rec-bruta      as dec format ">>>>>,>>>,>>9.99"
    field ded-venda      as dec format ">>>>>,>>>,>>9.99"
    field imposto        as dec format ">>>>>,>>>,>>9.99"
    field devolucao      as dec format ">>>>>,>>>,>>9.99"
    field rec-liquida    as dec format ">>>>>,>>>,>>9.99"
    field cus-produ      as dec format ">>>>>,>>>,>>9.99"
    field luc-bruto      as dec format ">>>>>,>>>,>>9.99"
    field des-oper       as dec format ">>>>>,>>>,>>9.99"
    field rec-oper       as dec format ">>>>>,>>>,>>9.99"
    field luc-oper       as dec format ">>>>>,>>>,>>9.99"
    field irpj           as dec format ">>>>>,>>>,>>9.99"
    field res-liquida    as dec format ">>>>>,>>>,>>9.99"
    field encargos       as dec format ">>>>>,>>>,>>9.99"
    field cus-devol      as dec format ">>>>>,>>>,>>9.99"
    index idt is primary unique
        dtresult.
