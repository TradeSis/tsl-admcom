{/admcom/progr/admcab-batch.i new}

{/admcom/progr/def-var-bsi-qvexp.i new}

assign vdtini = today 
       vdtfim = today
       vdirsaida = "/admcom/carga_admcom/clientes/"
       v-gera-vendas   = false
       v-gera-produtos = false
       v-gera-clientes = true
       v-gera-int-compra = true
       v-gera-filiais = true.
                           
run /admcom/progr/exp-novo-crm.p.

