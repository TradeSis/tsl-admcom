/* helio 24082024 - processa assinatura e boletagem */
/* programa inicio do processo */
propath = "/admcom/progr/,".

pause 0 before-hide.

message string(today,"99/99/9999") string(time,"HH:MM:SS") "Processos de assinatura eletronica".

/* faz primeiro a assinatura */

for each contrassin where dtproc = ? no-lock.
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
    if boletavel = yes and dtboletagem = ? 
    then do:
        message "        " contrassin.contnum "BOLETAGEM".
        run crd/boletacontrato.p (contrassin.contnum).
        run pbolet.

    end.


end.      

/* Pesquisa  contratos boletaveis, sem boleto */

for each contrassin where boletavel = yes and dtboletagem = ? no-lock.

    message "    BOLETAGEM " contrassin.contnum contrassin.dtinclu contrassin.etbcod contrassin.idbiometria.
    run crd/boletacontrato.p (contrassin.contnum).     
    run pbolet.


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
