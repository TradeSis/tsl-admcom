propath = "/admcom/progr/,".

message string(today,"99/99/9999") string(time,"HH:MM:SS") "Processos de assinatura eletronica".

for each contrassin where dtproc = ? no-lock.
    message contrassin.contnum contrassin.dtinclu contrassin.etbcod contrassin.idbiometria.
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
    run p.
end.      
      
      
procedure p.
      
    find current contrassin no-lock.
    message " Assinado = " string(contrassin.dtproc = ?,"Nao/Sim") " " contrassin.urlpdf contrassin.urlpdfass.          
      
end procedure.      
