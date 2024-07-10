{admcab.i}

def var v-ban like chq.banco.
def var v-age like chq.agencia.
def var v-con like chq.conta.
def var v-num like chq.numero.

repeat: 
    v-ban = 0. 
    v-age = 0. 
    v-con = "". 
    v-num = "". 
    
    update v-ban                label "Banco  " 
           v-age format ">>>9"  label "Agencia" 
           v-con format "x(15)" label "Conta  " 
           v-num format "x(7)"  label "Numero " 
                with frame f-procura centered width 80 1 column.

    find chq where chq.banco = v-ban   and
                   chq.agencia = v-age and
                   chq.conta = v-con   and
                   chq.numero = v-num no-lock no-error.
    if not avail chq 
    then do: 
        message "cheque nao encontrado". 
        pause. 
        undo, retry.
    end.
                               
    find first chqtit of chq no-lock no-error.   
    if avail chqtit   
    then find clien where clien.clicod = chqtit.clifor no-lock no-error.

    find deposito where deposito.etbcod = chqtit.etbcod and
                        deposito.datmov = chq.datemi no-lock no-error.
    
            
    display chqtit.etbcod when avail chqtit column-label "FL" format ">99"
            clien.clicod when avail clien
            clien.clinom when avail clien format "x(30)" 
            chq.datemi column-label "Data!Emissao" 
            chq.data   column-label "Data!Venc."  
            chq.banco      
            chq.agencia format ">>>>9"    
            chq.conta   format "x(15)"     
            chq.numero  format "x(15)"  
            chq.valor  
            deposito.datcon when avail deposito label "Data Confirmacao"
                        with frame f-pro 1 column centered.
    pause.
    
end.