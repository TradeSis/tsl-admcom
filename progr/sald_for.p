def var varquivo    as char.
def var varquivo2   as char.
def var vdt-aux     as date.
def var v-ano       as integer.
def var vsp         as char initial ";".
def var vforcod     as char initial "0".

def temp-table tt-forne
    field forcod as integer
    field fornom as char
    field saldo as decimal
    index idx01 forcod.

form
    vforcod  label "Fornecedor"  format "x(25)"  skip
    v-ano    label "Informe o Ano"  format ">>>9"
        with frame f01 side-labels row 4 centered.

assign v-ano = 2008.
    
update vforcod
       v-ano
        with frame f01.
        
assign vdt-aux = date(int("12"),int("31"),v-ano).        

if vforcod = "0"
then vforcod = "".

assign varquivo = "/admcom/audit/fornecedores/list_sald_for_"
                    + trim(string(vforcod,"x(25)"))
                    + "_"
                    + string(v-ano,"9999")
                    + "___"
                    + string(time)
                    + ".csv".

assign varquivo2 = ("/admcom/audit/fornecedores/list_sald_geral_"
                    + string(v-ano)
                    + "______"
                    + string(time)
                    + ".csv").


display vdt-aux label "Verificando a Data"  format "99/99/9999" at 05  with frame f02 no-box side-label centered.

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
                          titulo.titdtemi <= vdt-aux and
                          (titulo.titdtpag >  vdt-aux or
                           titulo.titdtpag = ?)   /*(Ex. 31/12/2008)*/
                              no-lock .
        
        if titulo.titsit = "EXC"                              
        then next.
                              
        run p-total.   

        run p-carrega-tt.

    end.
    
end.
else do:
    
    for each titulo where titulo.empcod = 19 and  
                          titulo.titnat = yes    and
                          titulo.titdtemi <= vdt-aux and
                          (titulo.titdtpag >  vdt-aux or
                           titulo.titdtpag = ?) and /*(Ex. 31/12/2008)*/
                          titulo.clifor = integer(vforcod)
                            no-lock.
        
        if titulo.titsit = "EXC"                              
        then next.
        
        run p-total.

    end.
    
end.    

output close.

run p-gera-arquivo-sintetico.

message "Arquivo Gerado em : " varquivo view-as alert-box title "ATENÇÃO!!!".

procedure p-total:

                              
     if titulo.clifor =  110165     /* Descarta Cartao Presente */
         or titulo.modcod = "bon"   /* Descarta Bonus           */
     then return.

     find first forne where forne.forcod = titulo.clifor no-lock no-error. 


     put
        titulo.clifor
        vsp
        if avail forne then trim(forne.fornom) else "Desconhecido"
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

procedure p-carrega-tt.

    if titulo.clifor =  110165     /* Descarta Cartao Presente */
        or titulo.modcod = "bon"   /* Descarta Bonus           */
    then return.
 
    find first tt-forne where tt-forne.forcod = titulo.clifor
                            exclusive-lock no-error.
                            
    find first forne where forne.forcod = titulo.clifor no-lock no-error.

    if not avail tt-forne
    then do:
        
        create tt-forne.
        assign tt-forne.forcod = titulo.clifor
               tt-forne.fornom = if avail forne then forne.fornom
                                    else "Desconhecido".
        
    end.                        
    
    assign tt-forne.saldo = tt-forne.saldo + titulo.titvlcob.
    

end procedure.


procedure p-gera-arquivo-sintetico:

    output to value(varquivo2).

    for each tt-forne no-lock by tt-forne.forcod.

        put tt-forne.forcod format ">>>>>>>>>>>>>>9"
            ";"
            tt-forne.fornom format "x(40)"
            ";"
            tt-forne.saldo format "->>>,>>>,>>>,>>>,>>9.99" skip.

    end.
    
    output close.
    
    message "Arquivo SINTETICO gerado em: " varquivo2 view-as alert-box title "ATENÇÃO!".
   
end procedure.

