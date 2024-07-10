def input param precid as recid.
def input param pdtbaixa as date.  

find titprotparc where recid(titprotparc) = precid no-lock no-error.
if not avail titprotparc then return.
find titprotesto of titprotparc no-lock no-error.
if not avail titprotesto then return.

if titprotesto.ativo = "ATIVO" 
then do on error undo, return:
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "" and
                   titprotesto.pagacustas
                then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.acao   = "DESISTENCIA".
                            titprotesto.situacao = "PAGO".
                            titprotesto.dtbaixa  = pdtbaixa. 
                            titprotesto.ativo = "BAIXADO".
                            run iep/bproatualiza.p (recid(titprotesto), ?, "", ?).

                        end.    
                end.
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "" and
                   titprotesto.pagacustas = no
                then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.acao   = "AUT.DESISTENCIA".
                            titprotesto.situacao = "PAGO".
                            titprotesto.dtbaixa  = pdtbaixa. 
                            
                            titprotesto.ativo = "BAIXADO".

                            run iep/bproatualiza.p (recid(titprotesto), ?, "", ?).
                            
                        end.    
                end.

                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "PROTESTADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas
                then do on error undo:   
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.acao   = "CANCELAMENTO".
                            titprotesto.situacao = "PAGO".
                            titprotesto.dtbaixa  = pdtbaixa. 
                            
                            titprotesto.ativo = "BAIXADO".
                            
                            run iep/bproatualiza.p (recid(titprotesto), ?, "", ?).
                            
                        end.    
                end.
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "PROTESTADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas = no
                then do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.acao   = "AUT.CANCELAMENTO".
                            titprotesto.situacao = "PAGO".
                            titprotesto.dtbaixa  = pdtbaixa. 
                            
                            titprotesto.ativo = "BAIXADO".
                            
                            run iep/bproatualiza.p (recid(titprotesto), ?, "", ?).
                            
                        end.    
                end.
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "CONFIRMADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas
                then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.acao   = "DESISTENCIA".
                            titprotesto.situacao = "PAGO".
                            titprotesto.dtbaixa  = pdtbaixa. 
                            
                            titprotesto.ativo = "BAIXADO".

                            run iep/bproatualiza.p (recid(titprotesto), ?, "", ?).

                        end.    
                end.
                if titprotesto.operacao = "IEPRO" and
                   titprotesto.situacao = "CONFIRMADO" and
                   titprotesto.dtacao   <> ? and
                   titprotesto.pagacustas = no
                then  do on error undo:
                        find current titprotesto exclusive no-wait no-error.
                        if avail titprotesto
                        then do:
                            titprotesto.acao   = "AUT.DESISTENCIA".
                            titprotesto.situacao = "PAGO".
                            titprotesto.dtbaixa  = pdtbaixa. 
                            
                            titprotesto.ativo = "BAIXADO".

                            run iep/bproatualiza.p (recid(titprotesto), ?, "", ?).
                            
                        end.    
                end.
        
end. 