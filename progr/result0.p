
def var vpropath        as char format "x(150)".
def var varqdg          as char format "x(50)".

def var varqlog         as char. 

input from /admcom/linux/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".

define stream str-txt-log. 

{admcab.i new}
{result.i new}

   def var varquivo as char.
   def var vdti as date.
   def var vdtf as date.

   /*
   assign vdti = date(month(date(month(today),1,year(today)) - 1)
                   ,1,
                   year(date(month(today),1,year(today)) - 1)). 
   */
              
     update vdti format "99/99/9999" no-label
            " a " 
            vdtf format "99/99/9999" no-label
                        with frame f-dat centered color blue/cyan row 8
                                    title " Informe o Periodo ".

   if opsys = "UNIX"
   then varqlog = "/admcom/relat-auto/Encerra/resultado" + string(year(vdti),"9999")
                     + string(month(vdti),"99") + "." + string(time,"999999").
   else varqlog = "l:\relat-auto\Encerra\resultado" + string(year(vdti),"9999")
                     + string(month(vdti),"99") + "." + string(time,"999999").
                     
   output stream str-txt-log to value(varqlog).
                        
   put stream str-txt-log unformatted
   "FASE 1 - Iniciando geração..." skip.
   
   put stream str-txt-log unformatted
   "FASE 2 - Periodo informado: " vdti " a " vdtf "..." skip.
        
   if opsys = "UNIX"
   then varquivo = "../relat-auto/Encerra/resultado" + string(year(vdti),"9999")                        + string(month(vdti),"99") + ".txt". 
   else varquivo = "l:\relat-auto\Encerra\resultado"
                       + string(year(vdti),"9999"). 
   
   if connected ("banfin")
   then disconnect banfin.
   
  find first tt-result where tt-result.dtresult = vdti no-lock no-error.
  if not avail tt-result
  then do:
       create tt-result.
       assign tt-result.dtresult = vdti.
   end.
   
   if search(varquivo) <> ?
   then do:
        input from value(varquivo).
        import tt-result.
   end.
   input close.     

   assign tt-result.dtresult = vdti.
/*   
disp tt-result with 3 col.   
  */

   run geral_c.p (input vdti,
                  input vdtf). 
   
   
   find first tt-result where tt-result.dtresult = vdti no-lock no-error.
   /*
   disp tt-result with 3 col title "Retornou geral".
   */
   
   connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
   
   if connected ("banfin")
   then put stream str-txt-log unformatted
        "FASE 3 - Banco BanFin conectado com sucesso..." skip.
   else put stream str-txt-log unformatted
        "FASE 3 - Atenção!! Banco BanFin não está Conectado!!!" skip.
   
   run pag_gru2.p (input vdti, input vdtf).
   
   if connected ("banfin")
   then disconnect banfin.
   
   find first tt-result where tt-result.dtresult = vdti no-error.
   assign tt-result.ded-venda   = (tt-result.imposto + tt-result.devolucao)
          tt-result.rec-liquida = (tt-result.rec-bruta - tt-result.ded-venda)
          tt-result.luc-bruto  = (tt-result.rec-liquida - tt-result.cus-produ)
          tt-result.des-oper = (tt-result.encargos - 
                                tt-result.imposto -
                                tt-result.irpj)
          tt-result.luc-oper = (tt-result.luc-bruto - tt-result.des-oper) +
                               (tt-result.rec-oper * 1000)
          tt-result.res-liquida = tt-result.luc-oper - tt-result.irpj.
     /*
   disp tt-result with 3 col.
       */
   output to value (varquivo).
   export tt-result.
   output close.    
   /*
   output stream str-txt-log to value(varqlog).
   */
   /**** divide por 1000 */
  
   /********* envia mail *******/
   def var vx-arq as char.
   if opsys = "UNIX"
   then vx-arq = "/admcom/relat/resultado" + string(year(vdti),"9999") 
                   + string(month(vdti),"99")+ string(time) + ".xls". 
   else vx-arq = "l:\relat\resultado" + string(year(vdti),"9999") 
                   + string(month(vdti),"99") + string(time) + ".xls".
                   
   output to value(vx-arq).
   put unformat 
      "DEMONSTR.RESULT.;" month(vdti) "/" year(vdti) ";" "%" skip
      "RECEITA BRUTA;" string(tt-result.rec-bruta / 1000,"->>>>>>>>9") 
        ";" 100 skip
      "(-)Deduções de Vendas;" string(tt-result.ded-venda / 1000,">>>>>>>>9")
          ";" STRING((tt-result.ded-venda * 100 /                      tt-result.rec-bruta),"->>9.999")
          skip
      "   Impostos;" string(tt-result.imposto / 1000,">>>>>>>>9")
          ";" STRING((tt-result.imposto * 100 / 
                    tt-result.rec-bruta),"->>9.999")
            skip
      "   Devoluções;" string(tt-result.devolucao / 1000,">>>>>>>>9")
          ";" STRING((tt-result.devolucao * 100 / 
                tt-result.rec-bruta),"->>9.999")
           skip
      "Custo Devoluções;" string(tt-result.cus-devol / 1000,">>>>>>>>9")
            ";" STRING((tt-result.cus-devol * 100 /
                tt-result.rec-bruta),"->>9.999")
           skip
      "RECEITA LÍQUIDA;" string(tt-result.rec-liquida / 1000,">>>>>>>>9")
          ";" STRING((tt-result.rec-liquida * 100 / 
                tt-result.rec-bruta),"->>9.999")
           skip
      "(-)Custo Merc.Vendida;" string((tt-result.cus-produ -                             tt-result.cus-devol) / 1000,">>>>>>>>9")
          ";" STRING(((tt-result.cus-produ - tt-result.cus-devol) * 100 / 
                tt-result.rec-bruta),"->>9.999")
           skip
      "   LUCRO BRUTO;" string(tt-result.luc-bruto / 1000,">>>>>>>>9")
          ";" STRING((tt-result.luc-bruto * 100 /                 tt-result.rec-bruta),"->>9.999")
           skip
      "(-)Desp.Operac./Admin.;" string(tt-result.des-oper / 1000,">>>>>>>>9")
          ";" STRING((tt-result.des-oper * 100 / 
                    tt-result.rec-bruta),"->>9.999")
           skip
      "Rec.Operac.;" string(tt-result.rec-oper, ">>>>>>>>9")
           ";" STRING(((tt-result.rec-oper * 1000)* 100 / 
                      tt-result.rec-bruta),"->>9.999")
            skip
      "   LUCRO OPERAC.;" string(tt-result.luc-oper / 1000,"->>>>>>>>9")
           ";" STRING((tt-result.luc-oper * 100 /
                            tt-result.rec-bruta),"->>9.999")
            skip
      "(-)IRPJ/Contr.Social;" string(tt-result.irpj / 1000,"->>>>>>>>9")
           ";" STRING((tt-result.irpj * 100 / tt-result.rec-bruta),"->>9.999")
            skip
      "   RESULT.LÍQUIDO;" string(tt-result.res-liquida / 1000,"->>>>>>>>9") 
           ";" STRING((tt-result.res-liquida * 100 /
                  tt-result.rec-bruta),"->>9.999")
            skip(2).
   /*  
   output close.
/*   run visurel.p (input vx-arq, input ""). */

   output stream str-txt-log to value(varqlog).
     */
     def var v-assunto as char.
     def var aux-mail as char. 
     def var vmeses as char extent 12 init
 ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"]
         .

     def VAR vresumo as char.
     def var varqres as char.
     if opsys = "UNIX"
     then varqres = "/admcom/relat/resultado" + string(year(vdti),"9999") 
                   + string(month(vdti),"99") + ".txt". 
     else varqres = "l:\relat\resultado" + string(year(vdti),"9999") 
                   + string(month(vdti),"99") + ".txt".
     output to value(varqres).
      vresumo = vmeses[month(tt-result.dtresult)] + "/" 
               +  string(year(date(today - 1)))   +  
               string(tt-result.res-liquida / 1000,"->>>>>>>>9") +
               "   " + 
               STRING((tt-result.res-liquida * 100 /
                        tt-result.rec-bruta),"->>9.99") + "%".
       put unformat skip 
          vresumo                   
          skip(3).

 
 run p-envia-mail("joao@lebes.com.br"). 

 put stream str-txt-log unformatted
 "FASE 4 - Processo encerrado normalmente..." skip.
        
 output close.

procedure p-envia-mail.
     def input parameter vmail as char.
     
 if vmail <> "joao@lebes.com.br"
 then do:     
    unix silent value("/admcom/progr/mail.sh "
                             + "~"RESULTADO ENCERRAMENTO MENSAL MES: ~""
                             + string(month(tt-result.dtresult),"99")
                             + " ~""
                             + vx-arq
                             + "~" "
                             + vmail
                             + " "
                             + "guardian@lebes.com.br"
                             + " "
                             + "~"zip~""
                             + " > "
                             + "/admcom/logs/mail.sh-resultado-" +
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time)
                              + " 2>&1 ").                                   
 pause(1) no-message.    
end.

 /* segundo mail */

     /* Servico Novo - Antonio */
     
     varqdg = "/admcom/progr/mail.sh " 
                        + "~"" + substring(vresumo,1,9) + "~"" + " ~"" 
                        + varqres + "~"" + " ~"" 
                        + vmail + "~"" 
                        + " ~"guardian@lebes.com.br~"" 
                        + " ~"text/html~"". 
     unix silent value(varqdg).


     /*****  Servico Antigo 
     unix silent value("/usr/bin/metasend -b -s "
                    + "~"" 
                    + substring(vresumo,1,9) 
                    + "~""
                    + " -F guardian@lebes.com.br -f " 
                    + varqres                                
                    + " -m text/html -t " 
                    + vmail).
     *******/
     
end procedure.    

