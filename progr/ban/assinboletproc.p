/* helio 24082024 - processa assinatura e boletagem */
/* programa inicio do processo */

def input param petbini as int.
def input param petbfim as int.
pause 0 before-hide.


find first contrassin where dtproc = ? and 
            contrassin.etbcod >= petbini and 
            contrassin.etbcod <= petbfim 
      no-lock no-error.
if avail contrassin 
then do:     
    message "      -> " string(today,"99/99/9999") string(time,"HH:MM:SS") "Processos de assinatura eletronica e Boletagem".
    for each contrassin where dtproc = ? and 
            contrassin.etbcod >= petbini and 
            contrassin.etbcod <= petbfim 
            no-lock.
    
        message "    " contrassin.contnum contrassin.dtinclu contrassin.etbcod contrassin.idbiometria.
        if contrassin.hash1 = ?
        then do:
            run crd/geraassin.p (recid(contrassin),"HASH1").
        end.            
        if contrassin.hash2 = ?
        then do:
            run crd/geraassin.p (recid(contrassin),"HASH2").
        end.            
        if contrassin.hash1 <> ? and contrassin.hash2 <> ?
        then do:
            run api/crdassinatura.p (contrassin.contnum). 
        end.
        run passin.

        /* se for boletavel, já gera os boletos */
        if boletavel = yes and dtboletagem = ? and contrassin.dtproc <> ? /* helio 27092024 - para boletar precisa assinar */
        then do:
            message "        " contrassin.contnum "BOLETAGEM".
            run ban/boletacontrato.p (contrassin.contnum).
            run pbolet.
        end.
    end.
end.      

/* Pesquisa  contratos boletaveis, sem boleto */
find first contrassin where boletavel = yes and dtboletagem = ? and
                contrassin.etbcod >= petbini and
                contrassin.etbcod <= petbfim
            no-lock no-error.
if avail contrassin
then do:
    message "      -> " string(today,"99/99/9999") string(time,"HH:MM:SS") "Processos de Boletagem".
    for each contrassin where boletavel = yes and dtboletagem = ? and
                    contrassin.etbcod >= petbini and 
                    contrassin.etbcod <= petbfim
                                    
            no-lock.
        message "    BOLETAGEM " contrassin.contnum contrassin.dtinclu contrassin.etbcod contrassin.idbiometria.
        run ban/boletacontrato.p (contrassin.contnum).     
        run pbolet.
    end.      
end.      
      
pause before-hide.

procedure passin.
      
    find current contrassin no-lock.
    message "      " contrassin.contnum  " Assinado = " string(contrassin.dtproc = ?,"Nao/Sim") " " contrassin.urlpdf contrassin.urlpdfass.          
      
end procedure.      

procedure pbolet.
      
    find current contrassin no-lock.
    message "      " contrassin.contnum " Boletado = " string(contrassin.dtboletagem = ?,"Nao/Sim") .          
      
end procedure.      
