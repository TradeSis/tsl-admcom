{admcab.i}
def var vtipo as char extent 4 format "x(15)".
assign
    vtipo[1] = "Localidades"
    vtipo[2] = "Bairros"
    vtipo[3] = "Logradouros"
    vtipo[4] = "Ordem CEP"
    .
disp vtipo with frame f-tipo 1 down centered no-label.
choose field vtipo with frame f-tipo.
def var vindex as int.
vindex = frame-index.
    
if vindex = 4
then do:
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm .
    
    if connected ("crm")
    then  run imcepord.p.
    if connected ("crm")
    then disconnect crm.
                        
    return.
end.
def var varquivo as char.
if opsys = "UNIX"
then.
else do:
    varquivo = sel-arq01().
end.
update varquivo label "Arquivo" format "x(69)"
            with frame f-arquivo 1 down
             side-label.

if search(varquivo) = ?
then do:
    message color red/with
    "Arquivo nao encontrado."
    view-as alert-box.
    undo.
end.
def var sconf as log format "Sim/Nao".
sconf = no.
message "Confirma importar arquivo de " vtipo[vindex] update sconf.
if not sconf then undo.

def var varquivo1 as char.
varquivo1 = varquivo + string(time).
if opsys = "UNIX"
then unix silent value("quoter -d % " +  varquivo  + " > " + varquivo1).
else dos   value("c:\dlc\bin\quoter -d % " +  varquivo  + " > " + varquivo1).

def var vlinha as char.
def var vi as int.
def var vj as int.
def var vcoluna as char extent 20.
input from value(varquivo1).
repeat:
    import vlinha.
    do vi = 1 to num-entries(vlinha,"@"):
    end.
    vj = 0.
    vcoluna = "".
    if vindex = 1
    then assign 
            vcoluna[9] = substr(vlinha,155,7)
            vcoluna[3] = substr(vlinha,20,71)
            vcoluna[2] = substr(vlinha,152,2)
            vcoluna[1] = substr(vlinha,6,6)
            vcoluna[6] = substr(vlinha,136,1)
            vcoluna[8] = substr(vlinha,100,36)
            vcoluna[4] = substr(vlinha,92,8)
            .
    /*
    do vj = 1 to vi - 1.
        vcoluna[vj] = entry(vj,vlinha,"@").    
    end.
    */
    if vindex = 1
    then run inc-localidades.
    else if vindex = 2
    then run inc-bairros.
    else if vindex = 3
    then run inc-logradouros.
end.
input close.

procedure inc-localidades:
    if vcoluna[2] <> "" and
       vcoluna[3] <> ""
    then do:
       
       find first munic where munic.ufecod = vcoluna[2] and
                              munic.cidnom = vcoluna[3]
                              no-error.
       if avail munic
       then do:
           if munic.cidcod = ? 
           then do:
               if int(vcoluna[9]) > 0
               then  munic.cidcod = int(vcoluna[9]).
               else munic.cidcod  = ?.
           end.
           
           assign
               munic.loc_num = int(vcoluna[1])
               munic.loc_in_sit = int(vcoluna[5])
               munic.loc_in_tip = vcoluna[6]
               munic.loc_num_sub = int(vcoluna[7])
               munic.loc_no_abrev = vcoluna[8]
               munic.loc_cep = vcoluna[4]
                .
       end.
       else do:
           create munic.
           if int(vcoluna[9]) > 0
           then  munic.cidcod = int(vcoluna[9]).
           else munic.cidcod  = ?.
           
           assign
               /*munic.cidcod = int(vcoluna[9])*/ /* 155-162 */
               munic.cidnom = caps(vcoluna[3])      /* 20-91 */
               munic.ufecod = vcoluna[2]            /* 152-153 */
               munic.loc_num = int(vcoluna[1])      /* 6-11 */
               munic.loc_in_sit = int(vcoluna[5])   /*  */
               munic.loc_in_tip = vcoluna[6]        /* 136 */
               munic.loc_num_sub = int(vcoluna[7])  /* */
               munic.loc_no_abrev = vcoluna[8]      /* 100-135 */
               munic.loc_cep = vcoluna[4]           /* 92-99 */
                .
       end. 
    end.
end procedure.
procedure inc-bairros:
    if vcoluna[2] <> "" and
       vcoluna[4] <> ""
    then do:
        find first bairro where bairro.ufecod = vcoluna[2] and
                                bairro.nome   = vcoluna[4]
                                no-error.
        if not avail bairro
        then do:
            create bairro.
            assign
                bairro.codbai = int(vcoluna[1])
                bairro.nome   = caps(vcoluna[4])
                bairro.ufecod = vcoluna[2]
                .
        end.                             
        else do:
            assign
                bairro.loc_num = int(vcoluna[3])
                bairro.bainom_abrev = vcoluna[5]
                .
       end.
    end.   

end procedure.
procedure inc-logradouros:
    if vcoluna[1] <> "" and
       vcoluna[2] <> "" and
       vcoluna[6] <> ""
    then do:
        find ceplog where ceplog.log_num = int(vcoluna[1]) no-error.
        if not avail ceplog
        then do:
            create ceplog.
            assign
                ceplog.log_num = int(vcoluna[1])
                ceplog.ufecod  = vcoluna[2]
                ceplog.loc_num = int(vcoluna[3])
                ceplog.bai_num_ini = int(vcoluna[4])
                ceplog.bai_num_fim = int(vcoluna[5])
                ceplog.log_no = vcoluna[6]
                ceplog.log_compl = vcoluna[7]
                ceplog.log_cep = vcoluna[8]
                ceplog.tlo_tx = vcoluna[9]
                ceplog.log_sta_tlo = vcoluna[10]
                ceplog.log_no_abrev = vcoluna[11]
                .
        end.
    end.   
end procedure.