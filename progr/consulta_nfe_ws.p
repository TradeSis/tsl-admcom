{admcab.i new}

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

def var vok            as log.

form vetbcod    at 03   label "Filial"         skip
     vnumero    at 05   label "Nota"         skip
     vserie     at 04   label "Serie"         skip
        with frame f01 side-label.

assign vserie = "1".

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

find first a01_infnfe where a01_infnfe.etbcod = vetbcod
                        and a01_infnfe.numero = vnumero
                        and a01_infnfe.serie = "1" no-lock.
                        
if avail a01_infnfe
then do:

    run p-trata-retorno(input rowid(a01_infnfe),
                  input vretorno).

end.

if vok
then message "Nota Recuperada com Sucesso!"
                    view-as alert-box.
                    
                    
procedure p-trata-retorno:
                    
def input parameter par-rowid       as rowid.
def input parameter par-arq-retorno as char.
                         
def buffer bA01_infnfe for A01_infnfe.
                                
assign p-valor = "".
run /admcom/progr/le_xml.p(input par-arq-retorno,
                           input "status_nfe_notamax",
                           output p-valor).
                                                        
find last bA01_infnfe where rowid(bA01_infnfe) = par-rowid
                    exclusive-lock no-error.
                    
   case p-valor:
                       
    when "14" then do:
    
    if avail bA01_infnfe
    then assign bA01_infnfe.sitnfe = integer(p-valor)
                bA01_infnfe.situacao = "Cancelada"
                bA01_infnfe.solicitacao = "".

    /*
    if v-tpamb = 1
    then run /admcom/progr/alt_mov_nfe.p(input "Cancela",
                                         input rowid(bA01_infnfe)).
    */
    
    end.
    
   
   end case.
                    
end procedure.                    
