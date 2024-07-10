{admcab.i}

def var v-op as char format "x(15)" extent 3
    init["EMISSAO","PROCESSADAS","PENDENTES"].
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.   
def var vindex as int.
def var vconecta-filial as logical format "Sim/Nao".
def var v-ip    as char.

if setbcod = 988 or
   setbcod = 995 or
   setbcod = 998 or
   setbcod = 993 or
   setbcod = 980 or
   setbcod = 22  or
   setbcod = 900 or
   sremoto
then v-op[1] = "".   
/***
connect /dados/bases/nfe -N tcp -S sdrebnfe -H linux no-error.

if connected ("nfe")
then do:
    assign vconecta-filial = no.
***/
    
    DISP v-op with frame f1 centered 1 down no-label.
    choose field v-op with frame f1.
    vindex = frame-index.
    if vindex = 2 or vindex = 3
    then do:
        if setbcod = 999
        then update vetbcod label "Filial" with frame f2 side-label.
        else vetbcod = setbcod.

        find estab where estab.etbcod = vetbcod no-lock.
        disp vetbcod estab.etbnom no-label with frame f2.
        update vdti  label "Emissao Inicio"
               vdtf  label "Fim"
               with frame f2.
/***        
        find first func where func.etbcod = setbcod
                          and func.funcod = sfuncod no-lock no-error.
                          
        if vetbcod < 189 and
           sremoto = no and 
           (sfuncod = 101 or func.funfunc = "CONTABILIDADE")
        then do:
            assign vconecta-filial = no.
            
            message "Deseja desconectar da Matriz e conectar na Filial? "
            update vconecta-filial.
            
            if vconecta-filial 
            then do:
                if vetbcod < 100
                then assign v-ip = "FILIAL" + string(vetbcod,"99").
                else assign v-ip = "FILIAL" + string(vetbcod,"999").

                disconnect nfe.
                disconnect com.
                
                message "Desconectando da Matriz e conectando"
                        " na Filial, Por favor Aguarde!!".
                
                connect nfe -H value(v-ip) -S sdrebnfe -N tcp -ld nfe.
                connect com -H value(v-ip) -S sdrebcom -N tcp -ld com.

                message "Conectado com sucesso, Por favor, aguarde a leitura"
                        " das Notas!".
            end.
        end.
***/
    end.
    if vindex = 1 and
       v-op[1] <> ""
    then do:
        run emis_nfe.p.
    end.
    else if vindex = 1 and v-op[1] = ""
    then do:
        message "Opção Inválida." view-as alert-box.
        undo, retry.
    end.    
    else do:
        run man_nfe.p(v-op[vindex], vetbcod, vdti, vdtf, vconecta-filial).

/***
        if vconecta-filial
        then do:
            message "Desconectando da Filial e conectando novamente"
                    " na Matriz, Por favor aguarde!".
            
            disconnect nfe.
            disconnect com.
                    
            connect /dados/bases/nfe -N tcp -S sdrebnfe -H linux.
            connect /dados/bases/com -N tcp -S sdrebcom -H linux.
        end.
***/
    end.
/*
end.
if connected ("nfe")
    then disconnect nfe.
*/
