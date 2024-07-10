{/admcom/progr/admcab-batch.i new}

setbcod = 999.
sfuncod = 101.

def var varquivo as char.
def var varqsai as char.
def var vassunto as char.
def var vmail as char.

varquivo = "/admcom/logs/mail.sh-guradirel-" + string(day(today),"99") +
            string(month(today),"99") + string(year(today),"9999") + "." +
            string(time).

output to value(varquivo) append.
put "Inicio processamento plani-4-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "PLANILHA DE FECHAMENTO GERAL".
varqsai = "". 
run /admcom/progr/plani-4-cron.p (output varqsai).
    
put "Final  processamento plani-4-cron.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.
    
if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1001", input varquivo,
                input varqsai, input vassunto).
end.


output to value(varquivo) append.
put "Inicio processamento info1006.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "PEDIDOS DE COMPRA EM ATRASO MOVEIS ".
varqsai = "". 
run /admcom/progr/info1006.p (output varqsai).
    
put "Final  processamento info1006.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.
/**    
if search(varqsai) <> ?
then do:
    run envia_info.p(input "1006", input varqsai).
end.
**/

output to value(varquivo) append.
put "Inicio processamento info1007.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "PEDIDOS DE COMPRA EM ATRASO CONFECCAO".
varqsai = "". 
run /admcom/progr/info1007.p (output varqsai).
    
put "Final  processamento info1007.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.
/**    
if search(varqsai) <> ?
then do:
    run envia_info.p(input "1007", input varqsai).
end.
**/

output to value(varquivo) append.
put "Inicio processamento informativo 1042 (info-vencido-vencer.p) " 
        today " "
        string(time,"hh:mm:ss") skip.

run /admcom/progr/info-vencido-vencer.p(output varqsai).

put "Final  processamento info-vencido-vencer.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

vassunto = "VENCIDOS E A VENCER".
 
if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1042", input varquivo,
                input varqsai, input vassunto).
end.

output to value(varquivo) append.
put "Inicio processamento informativo 1043(info-vencidos-periodo.p) " 
        today " "
        string(time,"hh:mm:ss") skip.

run /admcom/progr/info-vencidos-periodo.p(input varquivo).

put "Final  processamento info-vencidos-periodo.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

/****  EMAIL-VENDA ***/ 
output to value(varquivo) append.
put "Inicio processamento info1008.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "".
varqsai = "". 

run /admcom/progr/info1008.p (output varqsai).
    
put "Final  processamento info1008.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

/*** FIM EMAIL-VENDA ***/

/*** inicio DG despesas ***/

output to value(varquivo) append.
put "Inicio processamento dg017.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "METAS DE DESPESAS".
varqsai = "". 
run /admcom/progr/dg017.p.
    
put "Final  processamento dg017.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.
    
/*** fim DG despesas ***/

/*** Perf Venda ****/

output to value(varquivo) append.
put "Inicio processamento convgen2-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "Venda dia setor".
varqsai = "". 
run /admcom/progr/convgen2-cron.p (output varqsai).
    
put "Final  processamento convgen2-cron.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

   
if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1009", input varquivo,
                input varqsai, input vassunto).
end.



/***
output to value(varquivo) append.
put "Inicio processamento convgen2-ant-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "Venda dia setor".
varqsai = "". 
run /admcom/progr/convgen2-ant-cron.p (output varqsai).
    
put "Final  processamento convgen2-ant-cron.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1010", input varquivo,
                input varqsai, input vassunto).
end.


***/

/*** Fim PF ****/


output to value(varquivo) append.
put "Inicio processamento curva-31-ant-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "ABC FORNECEDORES GERAL".
varqsai = "". 
run /admcom/progr/curva-31-cron.p (output varqsai).
    
put "Final  processamento curva-31-cron.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1011", input varquivo,
                input varqsai, input vassunto).
end.

output to value(varquivo) append.
put "Inicio processamento curva-41-ant-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "ABC FORNECEDORES GERAL".
varqsai = "". 
run /admcom/progr/curva-41-cron.p (output varqsai).
    
put "Final  processamento curva-41-cron.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1012", input varquivo,
                input varqsai, input vassunto).
end.


if weekday(today) = 2
then do:
    
    output to value(varquivo) append.

    put "Inicio processamento resu2002-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "RESUMO C.V.E. GERAL".
    varqsai = "".
    run /admcom/progr/resu2002-cron.p (output varqsai).
    
    put "Final  processamento resu2002-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1000", input varquivo,
                input varqsai, input vassunto).
    end.

    output to value(varquivo) append.

    put "Inicio processamento plani-4-ant-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "PLANILHA DE FECHAMETO GERAL ANO ANTERIOR".
    varqsai = "".
    run /admcom/progr/plani-4-ant-cron.p (output varqsai).
    
    put "Final  processamento plani-4-ant-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1001", input varquivo,
                input varqsai, input vassunto).
    end.
    
    output to value(varquivo) append.

    put "Inicio processamento bascontr-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "BASE DE PRODUTOS LEBES".
    varqsai = "".
    run /admcom/progr/bascontr-cron.p (input "PRODU", output varqsai).
    
    put "Final  processamento bascontr-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1002", input varquivo,
                input varqsai, input vassunto).
    end.

end.

/* Antonio - Analise Planos p/Depto - relcpg-cron.p */
if weekday(today) = 2 or int(day(today)) = 1
then do:
    
    output to value(varquivo) append.

    put "Inicio processamento relcpg-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "PLANO POR DEPTO.- MOVEIS".
    varqsai = "".
    run /admcom/progr/relcpg-cron.p (input 31, output varqsai).
    
    put "Final  processamento relcpg-cron.p moveis" 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1013", input varquivo,
                input varqsai, input vassunto).
    end.

    vassunto = "PLANO POR DEPTO.- CONFECCOES".
    varqsai = "".                          
    run /admcom/progr/relcpg-cron.p (input 41, output varqsai).
    
    put "Final  processamento relcpg-cron.p confeccoes" 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1014", input varquivo,
                input varqsai, input vassunto).
    end.


end.
/**/

/* Antonio - Consulta Compras Mensal - rped1-cron.p */
if weekday(today) = 2 
then do:
    
    output to value(varquivo) append.

    put "Inicio processamento rped1-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "MOVIMENTO POR COMPRA MENSAL".
    varqsai = "".
    run /admcom/progr/rped1-cron.p (output varqsai).
    
    put "Final  processamento rped1-cron.p" 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1015", input varquivo,
                input varqsai, input vassunto).
    end.

end.
/**/

/* Antonio - RELATORIO FORNECEDORES GERAL- relfor03-cron.p */
if weekday(today) = 2 
then do:
    
    output to value(varquivo) append.

    put "Inicio processamento relfor03-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "RELATORIO DE FORNECEDORES MENSAL POR CLASSE".
    varqsai = "".
    run /admcom/progr/relfor03-cron.p (output varqsai).
    
    put "Final  processamento relfor03-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
    
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1016", input varquivo,
                input varqsai, input vassunto).
    end.

end.
/**/

/* Antonio - Performance de Estoque Resumo - perfoest-cron.p */

if int(day(today)) = 15  or int(day(today)) = 1  or weekday(today) >= 0 

then do:
    
    output to value(varquivo) append.

    put "Inicio processamento perfoest-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.

    vassunto = "PERFORMANCE DE ESTOQUE P/CLASSES".
    varqsai = "".
    run /admcom/progr/perfoest-cron.p (output varqsai).
    
    put "Final  processamento perfoest-cron.p" 
        today " "
        string(time,"hh:mm:ss") skip.
    output close.
   
    if search(varqsai)  <> ?
    then do:
        run envia_info_anexo.p(input "1017", input varquivo,
                input varqsai, input vassunto).
    end.

end.
/**/

output to value(varquivo) append.
put "Inicio processamento info1018.p "
     today " "
     string(time,"hh:mm:ss") skip.

run /admcom/progr/info1018.p.
                
put "Final  processamento info1018.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.


output to value(varquivo) append.
put "Inicio processamento info1019.p "
     today " "
     string(time,"hh:mm:ss") skip.

run /admcom/progr/info1019.p.

put "Final  processamento info1019.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.


output to value(varquivo) append.
put "Inicio processamento info1020.p "
     today " "
     string(time,"hh:mm:ss") skip.

run /admcom/progr/info1020.p.

put "Final  processamento info1020.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.


output to value(varquivo) append.
put "Inicio processamento info1021.p "
     today " "
     string(time,"hh:mm:ss") skip.
                                       
run /admcom/progr/info1021.p.
                                        
put "Final  processamento info1021.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.                                                  



output to value(varquivo) append.
put "Inicio processamento info1022.p "
     today " "
     string(time,"hh:mm:ss") skip.
                                       
run /admcom/progr/info1022.p.
                                        
put "Final  processamento info1022.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.                                                  


output to value(varquivo) append.
put "Inicio processamento info1023.p "
    today " "
    string(time,"hh:mm:ss") skip.
          
run /admcom/progr/info1023.p.
          
put "Final  processamento info1023.p "
    today " "
    string(time,"hh:mm:ss") skip.
output close.
                    


output to value(varquivo) append.
put "Inicio processamento info1024.p "
    today " "
    string(time,"hh:mm:ss") skip.
        
run /admcom/progr/info1024.p.
        
put "Final  processamento info1024.p "
    today " "
    string(time,"hh:mm:ss") skip.
output close.


/*
output to value(varquivo) append.
put "Inicio processamento info1025.p "
    today " "
    string(time,"hh:mm:ss") skip.
        
run /admcom/progr/info1025.p.
        
put "Final  processamento info1025.p "
    today " "
    string(time,"hh:mm:ss") skip.
output close.
*/ 

                

output to value(varquivo) append.
put "Inicio processamento lclim-info1026.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "INFO1026 - DATABASE MARKETING-SINTETICO".
varqsai = "". 
run /admcom/progr/lclim-info1026.p (output varqsai).
    
put "Final  processamento lclim-info1026 "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1026", input varquivo,
                input varqsai, input vassunto).
end.





output to value(varquivo) append.
put "Inicio processamento lisadi-info1027 - Moveis" 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "INFO1027 - VENDA ADICIONAL POR VENDEDOR - MOVEIS".
varqsai = "". 
run /admcom/progr/lisadi-info1027.p (input 31,
                                     output varqsai).
    
put "Final  processamento lisadi-info1027 - Moveis"  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1027", input varquivo,
                input varqsai, input vassunto).
end.


output to value(varquivo) append.
put "Inicio processamento lisadi-info1027.p - confeccoes" 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "INFO1027 - VENDA ADICIONAL POR VENDEDOR - CONFECCOES".
varqsai = "". 
run /admcom/progr/lisadi-info1027.p (input 41,
                                     output varqsai).
    
put "Final  processamento lisadi-info1027 - confeccoes"  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1027", input varquivo,
                input varqsai, input vassunto).
end.







output to value(varquivo) append.
put "Inicio processamento marg_r-info1028.p - Moveis" 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "INFO1028 - CUSTO/VENDA/MARGEM - RESUMO - MOVEIS".
varqsai = "". 
run /admcom/progr/marg_r-info1028.p (input 31,
                                     output varqsai).
    
put "Final  processamento marg_r-info1028.p - Moveis"  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1028", input varquivo,
                input varqsai, input vassunto).
end.


output to value(varquivo) append.
put "Inicio processamento marg_r-info1028.p - confeccoes" 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "INFO1028 - CUSTO/VENDA/MARGEM - RESUMO - CONFECCOES".
varqsai = "". 
run /admcom/progr/marg_r-info1028.p (input 41,
                                     output varqsai).
    
put "Final  processamento marg_r-info1028.p - confeccoes"  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1028", input varquivo,
                input varqsai, input vassunto).
end.




output to value(varquivo) append.
put "Inicio processamento convlo-info1029.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "INFO1029 - PERFORMANCE DE VENDAS".
varqsai = "". 
run /admcom/progr/convlo-info1029.p (output varqsai).
    
put "Final  processamento convlo-info1029.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1029", input varquivo,
                input varqsai, input vassunto).
end.




output to value(varquivo) append.
put "Inicio processamento convlo-info1030.p "
     today " "
string(time,"hh:mm:ss") skip.
vassunto = "INFO1030 - META CARTAO PRESENTE".
varqsai = "".
run /admcom/progr/convlo-info1030.p (output varqsai).
               
put "Final  processamento convlo-info1030.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.
                                
if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1030", input varquivo,
                           input varqsai, input vassunto).
end.
                

output to value(varquivo) append.
put "Inicio processamento rlbon-info1031.p "
     today " "
string(time,"hh:mm:ss") skip.
vassunto = "INFO1031 - E-MAIL PARA CLIENTES COM BONUS NAO UTILIZADO".
varqsai = "".
run /admcom/progr/info1031.p (output varqsai).
               
put "Final  processamento rlbon-info1031.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.
                                
if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1031", input varquivo,
                           input varqsai, input vassunto).
end.

                
                
output to value(varquivo) append.
put "Inicio processamento info1035.p "
     today " "
string(time,"hh:mm:ss") skip.
vassunto = "INFO1035 - PRODUTOS SUBTITUIDO PEDIDO AUTOMATICO".
varqsai = "".
run /admcom/progr/info1035.p (output varqsai).
               
put "Final  processamento info1035.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.

                                
                                
if weekday(today) = 1
then do:
                
                
output to value(varquivo) append.
put "Inicio processamento info1036.p "
     today " "
string(time,"hh:mm:ss") skip.
vassunto = "INFO1036 - LIMITES LIB E UTIL CARTAO ".
varqsai = "".
run /admcom/progr/limites-cron.p (output varqsai).
               
put "Final  processamento info1036.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.

if search(varqsai) <> ?
then do:
    run envia_info_anexo.p(input "1036", input varquivo,
                           input varqsai, input vassunto).
end.

end.

                
output to value(varquivo) append.
put "Inicio processamento info1037.p "
     today " "
string(time,"hh:mm:ss") skip.
vassunto = "INFO1037 - NOTAS LANÇADAS SEM BIPAR CHAVE DO DANFE".
varqsai = "".
run /admcom/progr/info1037.p (output varqsai).
               
if search(varqsai) <> ?
then do:
    run /admcom/progr/envia_info_2.p("1037",varqsai,vassunto).
end.

put "Final  processamento info1037.p "
     today " "
     string(time,"hh:mm:ss") skip.
output close.

return.

