def var varquivo    as char.
def var v-ano       as integer.
def var vsp         as char initial ";".
def var vforcod     as char initial "0".
def var vdti        as date.
def var vdtf        as date.

form
    vforcod  label "Fornecedor"  format "x(25)"  skip
    v-ano    label "Informe o Ano"  format ">>>9"  skip
    vdti     label "Periodo" format "99/99/9999"
    " a "
    vdtf no-label format "99/99/9999"
        with frame f01 side-labels row 4 centered.

assign v-ano = 2008.
    
update vforcod
       v-ano with frame f01.
       
assign vdti = date(01,01,v-ano)        
       vdtf = date(12,31,v-ano).
       
update vdti
       vdtf
         with frame f01.
         
if vforcod = "0"
then vforcod = "".         
        
assign varquivo = "/admcom/audit/list_desc_for_"
                    + trim(string(vforcod,"x(25)"))
                    + "_"
                    + string(day(vdti),"99") +
                      string(month(vdti),"99") +
                      string(year(vdti),"9999") + "_" +
                      string(day(vdtf),"99") +
                      string(month(vdtf),"99") +
                      string(year(vdtf),"9999")
                    + ".csv".

display vdti label "Verificando o Periodo "  format "99/99/9999"
        " a "
        vdtf no-label  format "99/99/9999"
           with frame f02 side-label centered width 70 no-box.

message "Processando... Por favor Aguarde...".

output to value(varquivo).

put
   "Cod.Forne"
   vsp
   "Razão Social"
   vsp
   "Título"
   vsp
   "Parcela"
   vsp
   "MT"
   vsp
   "DT. Emissao"
   vsp
   "DT. Vencimento"
   vsp
   "DT. Pagamento"
   vsp
   "VL. Cobrado"
   vsp
   "VL. Pago"
   vsp
   "VL. Desconto"
   vsp
   "Sit"
   vsp
   "Fil" skip.

if vforcod = "" or vforcod = "0"
then do:                                

    for each titulo where titulo.empcod = 19 and
                          titulo.titnat = yes    and
                          titulo.titdtemi >= vdti and
                          titulo.titdtemi <= vdtf     /*(Ex. 31/12/2008)*/
                              no-lock .
                              
        run p-total.   

    end.
    
end.
else do:
    
    for each titulo where titulo.empcod = 19 and  
                          titulo.titnat = yes    and
                          titulo.titdtemi >= vdti and
                          titulo.titdtemi <= vdtf  and /*(Ex. 31/12/2008)*/
                          titulo.clifor = integer(vforcod)
                            no-lock.
         
        run p-total.   

    end.
    
end.    

output close.

message "Arquivo Gerado em : " varquivo view-as alert-box.

procedure p-total:

     if titulo.titvldes <= 0
     then return.
                              
     if titulo.clifor =  110165     /* Descarta Cartao Presente */
         or titulo.modcod = "bon"   /* Descarta Bonus           */
     then return.

     find first forne where forne.forcod = titulo.clifor no-lock no-error. 


     put
        titulo.clifor
        vsp
        if avail forne then forne.fornom  else "Desconhecido"
                        format "x(60)"
        vsp
        titulo.titnum
        vsp
        titulo.titpar format ">>>>>>>>>9"
        vsp
        titulo.modcod
        vsp
        titulo.titdtemi
        vsp
        titulo.titdtven
        vsp
        titulo.titdtpag
        vsp
        titulo.titvlcob
        vsp
        titulo.titvlpag
        vsp
        titulo.titvldes
        vsp
        titulo.titsit
        vsp
        titulo.etbcod skip.

end procedure.



