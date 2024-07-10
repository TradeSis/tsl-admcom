{admcab.i}

{/admcom/progr/def-var-bsi-qvexp.i new}

assign vdtini = today 
       vdtfim = today
       vdirsaida = "/admcom/carga_admcom/"
       v-gera-vendas   = true
       v-gera-produtos = true
       v-gera-clientes = true
       v-gera-int-compra = true
       v-gera-filiais = true
       v-gera-carga-clientes-full = false.

update vdtini label "Periodo" format "99/99/9999" colon 26
       " a " 
       vdtfim format "99/99/9999" no-label skip
       vdirsaida format "x(40)" label "Diretorio Exportação" colon 26  skip
       v-gera-vendas  label "Gera Vendas?"    colon 26 skip
       v-gera-produtos label "Gera Produtos?" colon 26 skip
       v-gera-clientes label "Gera Clientes?" colon 26
                   help "Arquivo usado apenas pelo CRM"
         with frame f-pro side-label width 80.
                    
if v-gera-clientes
then update v-gera-carga-clientes-full
       label "Gera carga inicial?" colon 60            skip
         with frame f-pro side-label width 80.

else display v-gera-carga-clientes-full
       label "Gera carga inicial?" colon 60            skip
         with frame f-pro side-label width 80.
                     
update v-gera-int-compra label "Gera Intenções de Compra?" colon 26 skip
       v-gera-filiais label "Gera Filiais?" colon 26 skip
        with frame f-pro side-label width 80.
                           
if v-gera-vendas or v-gera-produtos
then do:
    run /admcom/progr/bsi-qvexp.p.
end.

run /admcom/progr/exp-novo-crm.p.

