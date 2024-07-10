{admcab.i new}

if not connected ("dragao")
then connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao.

if not connected ("dr")
then connect /admcom/backup/dados_dragao/db/dr -1.

def var v-acao as log format "Migrar/Deletar".
def var vetbcod as integer.
def var vdir    as char.

def temp-table tt-fil
    field etbcod as integer.
    
assign vdir = "/admcom/backup/dados_dragao/".

assign v-acao = true.

message "Deseja Migrar os dados ou Deletar?" update v-acao .

bl_etbcod:
repeat:

    for each tt-fil no-lock by tt-fil.etbcod :
    
        display tt-fil.etbcod label "Fil"  skip
            with frame f201 overlay down col 60.
        pause 0.
    
    end.

    update vetbcod label "Filial" format ">>>9"  skip
               go-on(F4) 
               with frame f-etbcod side-label centered.

    if keyfunction(lastkey) = "end-error"
    then leave bl_etbcod.
    
    if vetbcod > 0
    then do:
        
        find first tt-fil where tt-fil.etbcod = vetbcod no-lock no-error.
        
        if not avail tt-fil
        then do:
        
            create tt-fil.
            assign tt-fil.etbcod = vetbcod.
        
        end.
    end.
end.




if v-acao = true
then do:

assign sresp = no.

update 
       sresp label "Realizar Backup da tabela CLISPC?" colon 36
       "   "
       "Escolha Sim apenas na primeira "
       "execução do dia pois esse backup "   colon 44
       "não depende de filiais"              colon 44
         with frame f-pro side-label width 80.


for each tt-fil no-lock:       
       
    display "Fil: " string(tt-fil.etbcod) format "x(3)" no-label
                   "Executando Backups " colon 10
                      string(time,"HH:MM:SS") colon 60 skip
                    with frame f-exporta no-box side-label. pause 0.
                                       
    run p-gera-bkp-dragao.p (input tt-fil.etbcod,
                             input vdir,
                             input sresp).   
                                       

    display "Fil: " string(tt-fil.etbcod) format "x(3)" no-label
            "Migrando os dados " colon 10
             string(time,"HH:MM:SS") colon 60              skip
                    with frame f-exporta no-box side-label.
    pause 0.

                                         
    run p-valida-dragao.p (input tt-fil.etbcod,
                           input vdir).

                                         
                                  
    display "Fil: " string(tt-fil.etbcod) format "x(3)" no-label
            "Marcando os títulos de Renovação no banco FIN " colon 10
            string(time,"HH:MM:SS") colon 60 skip
                    with frame f-exporta no-box side-label.
    pause 0.
                                           
    run p-marca-tit-lp.p (input tt-fil.etbcod).
                                           
end. 

end.

else do:

    /******* Deletando *********/


    for each tt-fil no-lock.
    
        run p-del-dragao.p (input tt-fil.etbcod).
    
    
    end.


end.


if connected ("dr")
then disconnect "dr".

if connected ("dragao")
then disconnect "dragao".



