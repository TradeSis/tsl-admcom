unix silent value( "ls /admcom/nfe/linx/NF_SAIDA* > SAIDA.xxxx").
def temp-table tt   
    field arq as char format "x(60)".


for each tt.
    delete tt.
end.    
input from ./SAIDA.xxxx.
repeat transaction.
    create tt.
    import tt.
end.
input close.
def var v as char.
for each tt.
    v = substr(tt.arq,18).    
    v = v + "." + string(time).
    run /admcom/progr/linx_saidas.p (input tt.arq).
    pause 1 no-message.
    unix silent value(
        "mv " + tt.arq + " " + "/admcom/nfe/linx/bkp/" + v).
    pause 4 no-message.    
    delete tt.
end.
