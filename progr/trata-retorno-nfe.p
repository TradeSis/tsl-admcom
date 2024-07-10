    {gerxmlnfe.i}.
    
    def var p-valor     as char.

    def var vnotamax as log.
    
    def input  parameter p-arq_ret         as char.
    def input  parameter p-recid           as recid.
    def input  parameter vnum-erro         as integer.
    def input  parameter p-mensagem        as char.
    def input  parameter p-idamb           as integer.
    def output parameter p-msg-retorno     as char.


    find A01_infnfe where recid(A01_infnfe) = p-recid no-lock no-error.
    find B01_IdeNFe of A01_infnfe no-lock no-error.  
    
    case (vnum-erro):

    when 9999  /*Erro na Autorização do Arquivo*/
    then do:
    
        do on error undo:
            find current B01_IdeNFe exclusive.
            B01_IdeNFe.temite = p-mensagem.
        end.
        find current B01_IdeNFe no-lock.
        
        find A01_infnfe where recid(A01_infnfe) = p-recid no-lock no-error.
        if avail A01_infnfe
        then do on error undo:
            find current A01_infnfe exclusive.
            A01_infnfe.aguardando = "Intervenção-Erro parser".
        end.
        find current A01_infnfe no-lock.

    end.
    when 2 then do:
         vnotamax = yes.
         
         assign p-msg-retorno = "NF com erro no arquivo.".

         find A01_infnfe where 
                       recid(A01_infnfe) = p-recid no-lock no-error.
         if avail A01_infnfe
         then do on error undo:
             find current A01_infnfe exclusive.
             assign A01_infnfe.sitnfe = vnum-erro  
                    A01_infnfe.situacao = ""
                  /*A01_infnfe.solicitacao = "Correcao" */
                    A01_infnfe.aguardando = "Intervenção-Erro parser".
         end.
         find current A01_infnfe no-lock.
                    
         assign p-valor = "".
         run le_xml.p(input p-arq_ret,
                      input "erro_validacao",
                      output p-valor).

         do on error undo:
             find current B01_IdeNFe exclusive.
             B01_IdeNFe.temite = p-valor.
         end.
         find current B01_IdeNFe no-lock.
         find A01_infnfe where 
                     recid(A01_infnfe) = p-recid no-lock no-error.
         if avail A01_infnfe
         then do on error undo:
             find current A01_infnfe exclusive.
             A01_infnfe.aguardando = "Intervenção-Erro parser".
         end.
         find current A01_infnfe no-lock.
                   
         leave.

    end.
    when 7 then do:

        vnotamax = yes.
        /*
        message "NF Autorizada, aguarde a impressão do DANFE".
        pause 0 no-message.                    
        */
        
        find A01_infnfe where 
                       recid(A01_infnfe) = p-recid no-lock no-error.
        if avail A01_infnfe
        then do on error undo:
            find current A01_infnfe exclusive.
            assign A01_infnfe.sitnfe = vnum-erro  
                   A01_infnfe.situacao = "Autorizada"
                   A01_infnfe.solicitacao = ""
                   A01_infnfe.aguardando = "".
            assign p-valor = "".
            run le_xml.p(input p-arq_ret,
                         input "chave_nfe",
                         output p-valor).
                           
            assign A01_infnfe.id = p-valor.
                   
        end.
        find current A01_infnfe no-lock.
                   
        if p-idamb = 1
        then do: 
            /*   
            message "atualizando estoque" program-name(3) program-n~~ame(2) program-name(1)
            program-name(4).
                       
             pause .            
            */    
                                   
            run alt_mov_nfe.p(input "Cria",
                              input rowid(A01_infnfe)).
                   
        end.
                    
        assign p-msg-retorno = "NOTA FISCAL : "
                               + string(A01_INFNFE.NUMERO) 
                               + " AUTORIZADA!".
                               
        leave.

    end.
    when 8 then do:
        vnotamax = yes.

        assign p-msg-retorno = "NF Rejeitada pelo SEFAZ.".
        
        find A01_infnfe where 
                        recid(A01_infnfe) = p-recid no-lock no-error.
        if avail A01_infnfe
        then do on error undo:
            find current A01_infnfe exclusive.
            assign
                  A01_infnfe.sitnfe = vnum-erro  
                  A01_infnfe.situacao = ""
                /*A01_infnfe.solicitacao = "Correcao"*/
                  A01_infnfe.aguardando = "Intervenção-Rejeição SEFAZ".
        end.
        find current A01_infnfe no-lock.
                   
        assign p-valor = "".
        run le_xml.p(input p-arq_ret,
                     input "erro_validacao",
                     output p-valor).
              
        do on error undo:
           find current B01_IdeNFe exclusive.
                        B01_IdeNFe.temite = p-valor.
        end.
        find current B01_IdeNFe no-lock.
        leave.

    end.
    when 9 then do:
        vnotamax = yes.
        
        assign p-msg-retorno = "NF Denegada pelo SEFAZ.".

        find A01_infnfe where 
                       recid(A01_infnfe) = p-recid no-lock no-error.
        if avail A01_infnfe
        then do on error undo:
            find current A01_infnfe exclusive. 
            assign
                  A01_infnfe.sitnfe = vnum-erro  
                  A01_infnfe.situacao = "Denegada"
                  A01_infnfe.solicitacao = ""
                  A01_infnfe.aguardando = "".
        end.
        find current A01_infnfe no-lock.
        assign p-valor = "".
        run le_xml.p(input p-arq_ret,
                     input "erro_validacao",
                     output p-valor).
              
        do on error undo:
            find current B01_IdeNFe exclusive.
                         B01_IdeNFe.temite = p-valor.
        end.
        find current B01_IdeNFe exclusive.               
                    
        leave.

    end.
    otherwise do:
        vnotamax = no.

        assign p-valor = "".
        run le_xml.p(input p-arq_ret,
                     input "erro_validacao",
                     output p-valor).

        assign p-msg-retorno = "Erro: " +  p-valor + " Verifique a situação"
                               + "da NFE ".
        
    end.                          

end case.                               

/*
procedure p-grava-chave-nfe-sefaz:

    def input parameter par-rowid as rowid.
    def input parameter par-chave as char.
    
    def buffer bA01_infnfe for A01_infnfe.

    do on error undo:
    find bA01_infnfe where rowid(bA01_infnfe) = par-rowid
                                 exclusive-lock no-error.
                                 
    if avail bA01_infnfe
    then assign bA01_infnfe.id = par-chave.
    end.
    find current bA01_infnfe no-lock.

end procedure.
*/
