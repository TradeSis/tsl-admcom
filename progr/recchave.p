{admcab.i}

{gerxmlnfe.i}

def var vetbcod        as integer.
def var vnumero        as integer.
def var vserie         as char.
def var vmetodo        as char.
def var varquivo       as char.
def var vretorno       as char.
def var vemite-cnpj    as char.
def var v-comando      as char.
def var p-valor        as char.
def var p-data-aux     as char.

def var varquivo-ok    as char.

def new shared var varq-lista     as char.

def var vlinha         as char.

def var vok            as log.

def var vconta-tentativas as int.

/*
def new shared temp-table tt-plani like plani
         field natoper    as char.
def new shared temp-table tt-movim like movim.
*/
def temp-table tt-recupera
    field etbcod as integer
    field numero as integer
    field contador as integer
    index idx01 etbcod numero.

form vetbcod    at 03   label "Filial"         skip
     vnumero    at 05   label "Nota"         skip
     vserie     at 04   label "Serie"         skip
        with frame f01 side-label.

assign vserie = "1".

assign varq-lista = "/admcom/audit/".

update varq-lista format "x(50)" label "Arquivo"   
        with frame f05 side-labels
            title "Informe o caminho do arquivo com a lis~ta de notas".

if search(varq-lista) = ? or varq-lista = "/admcom/audit/"
then do:

    update vetbcod format ">>>9"
            with frame f01.

    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
    
        message "Estabelecimento Invalido!" view-as alert-box.
        undo,retry.
                
    end.                
                
    update vnumero format ">>>>>>9"
            with frame f01.
                
    update vserie format "x(02)"
            with frame f01.
            
    run p-recupera-nota (output vok).         

end.        
else do:

    input from value(varq-lista).

    repeat:

        import vlinha.

        if num-entries(vlinha,";") = 2
        then do:
        

            find first tt-recupera
                 where tt-recupera.etbcod = int(entry(1,vlinha,";"))
                   and tt-recupera.numero = int(entry(2,vlinha,";"))
                                    no-lock no-error.
                                    
            if not avail tt-recupera
            then do:                         
                create tt-recupera.
                assign tt-recupera.etbcod = int(entry(1,vlinha,";"))
                       tt-recupera.numero = int(entry(2,vlinha,";")).
            end.    

        end.

    end.

end.

for each tt-recupera where tt-recupera.etbcod > 0.

    find first estab where estab.etbcod = tt-recupera.etbcod
                                no-lock no-error.
            
    assign vetbcod = tt-recupera.etbcod
           vnumero = tt-recupera.numero
           vserie = "1"
           vconta-tentativas = 1.
           
    bl_recupera_nota:       
    repeat:
        
        assign vok = no.
        run p-recupera-nota (output vok).
        if not vok and vconta-tentativas <= 3
        then do:
            
            message "Arquivo Zerado, aguardando 8 segundos".
            
            pause 8.
            
            next bl_recupera_nota.
            
        end.    
        else leave bl_recupera_nota.
        
        assign vconta-tentativas = vconta-tentativas + 1.
        
    end.
    
    pause 0 no-message.                    
                        
end.

pause.

procedure p-recupera-nota:        

def output parameter par-ok as log.

assign vemite-cnpj = estab.etbcgc.
        
assign vemite-cnpj = replace(vemite-cnpj,".","").
       vemite-cnpj = replace(vemite-cnpj,"/","").
       vemite-cnpj = replace(vemite-cnpj,"-","").

/*        
assign vmetodo = "ConsultarXmlEnvioNfe".
*/

assign vmetodo = "ConsultarNfe".

/*
assign vmetodo = "ConsultarXmlDistribuicaoNfe".
*/
assign varquivo = "/admcom/nfe/ws/000/envio/"
                                 + string(vetbcod)
                                 + "_" + vmetodo + "_"
                                 + string(vnumero) + "_"
                                 + string(time).

            output to value(varquivo).
        
            geraXmlNfe(yes,
                       "cnpj_emitente",
                       vemite-cnpj,
                       no). 
                       
            geraXmlNfe(no,
                       "numero_nota",
                       string(vnumero),
                       no).
                       
            geraXmlNfe(no,
                       "serie_nota",
                       string(vserie),
                       yes).
                       
            output close.
    
            /* Apos esperar, realiza uma consulta ao NotaMax */ 
            run chama-ws3.p(input vetbcod,
                           input vnumero,
                           input "NotaMax",
                           input vmetodo,
                           input varquivo,
                           output vretorno).

assign p-valor = "".

assign par-ok = no.

run p-verifica-tamanho-arquivo (input vretorno, output par-ok).

if not par-ok
then do: 
    return.
end.

assign p-valor = "".

run /admcom/progr/le_xml.p(input vretorno,
                           input "chave_nfe",
                          output p-valor).


run /admcom/progr/le_xml.p(input vretorno,
                           input "data_autorizacao",
                           output p-data-aux).


run p-grava-chave-nfe-sefaz(input vetbcod,
                            input vnumero,
                            input p-data-aux,
                            input p-valor).
                                                    
end procedure.                    

procedure p-verifica-tamanho-arquivo:

    def input  parameter  p-arquivo as char.
    def output parameter  p-ok      as log.
    
    def var  vlinha    as  char.
    
    input from value(p-arquivo).
    
    repeat:
    
        import vlinha.
                                                           
        if vlinha = ""
        then assign p-ok = no.
        else assign p-ok = yes.
    
    end.
    
end procedure.

procedure p-grava-chave-nfe-sefaz:
                    
    def input parameter par-etbcod   as integer.
    def input parameter par-numero   as integer.
    def input parameter par-data     as char.
    def input parameter par-chave    as char.
    
    def var vdata           as date.                       
                           
    if num-entries(par-data,"-") = 3
    then assign vdata = date(int(entry(2,par-data,"-")),
                             int(entry(3,par-data,"-")),
                             int(entry(1,par-data,"-"))).

    def buffer bplani for plani.
                               
    find last bplani where bplani.etbcod = par-etbcod
                       and bplani.numero = par-numero
                /*       and bplani.serie = "1" */
                       and bplani.pladat >= vdata - 10
                       and bplani.movtdc < 9000
                            exclusive-lock no-error.
    
    display par-etbcod format ">>>>>9" label "Fil"
            par-numero format ">>>>>>>>9" label "Nota" with frame f02.
                     
    display length(bplani.ufdes) label "Chave"  with frame f02.
                                     
    if avail bplani and length(bplani.ufdes) <> 44
    then do:
        
        display "*******  Sim  ******" format "x(30)" label "Atualizado?"
                        with frame f02.
                
        assign bplani.ufdes = par-chave.
        
    end.    
                                         
end procedure.
                                         
                                         
