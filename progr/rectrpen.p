{admcab.i}

def var vetbcod     like estab.etbcod.
def var v-conecta   as log format "Sim/Nao".
def var v-pende     as log format "Sim/Nao".
def var vclicod     like clien.clicod.
def var vcontnum    like fin.contrato.contnum.
def var ip          as char format "x(15)". 

def new shared temp-table tt-titulo    like fin.titulo
    field selecionar as logical. 
def new shared temp-table tt-contrato  like fin.contrato.


repeat:

    do on error undo:
         message fill("",79). pause 0.
        for each tt-titulo:
            delete tt-titulo.
        end.    
        update  vclicod label "Cliente" with frame f1
             centered side-labels width 75 title "Busca Contratos/Titulos".
        if vclicod = 0 then next.     
        find first clien where clien.clicod = vclicod no-lock no-error.
        if not avail clien 
        then do:
            message "Cliente Inexistente" VIEW-AS ALERT-BOX.
            undo, retry.
        end. 
        else disp clien.clinom format "x(30)" no-label with frame f1.
        update vcontnum label "Contrato" with frame f1 centered side-labels.

        update  vetbcod label "Filial" with frame f1.
                                
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao Cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame f1.
        end.
        else undo, retry.
                                     
    end.
    
    assign ip = "filial" + string(vetbcod,"999").
    update ip label "Conexao Filial" 
                     with frame f1.
                         
                         
    if connected ("finloja")
    then disconnect finloja.

    message "Conectando...".
    connect fin -H value(ip) -S sdrebfin -N tcp -ld finloja .
    
    if not connected ("finloja")
    then do:
        
        message "Banco nao conectado ! ". 
        pause 4 before-hide.
        return.
    end.
    
    if connected ("finloja")
    then run rectrpen2.p(input vclicod, input vcontnum).
    next. 
end.