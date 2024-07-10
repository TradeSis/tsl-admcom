/* 05012022 helio iepro */

def input param precid      as recid.
def input param pdtacao     as date.
def input param pacaooper   as char.
def input param premessa    as int.
    do on error undo:

        find titprotesto where recid(titprotesto) = precid exclusive-lock.

        titprotesto.dtacao      = pdtacao. 
        titprotesto.acaooper    = pacaooper.    
        if premessa <> ? and titprotesto.remessa = ?
        then do:
            for each titprotparc of titprotesto.
                titprotparc.remessa = premessa.
            end.
            titprotesto.ATIVO = "ATIVO".     
            titprotesto.remessa = premessa.
        end.    
                        
            find first titprothist where 
                    titprothist.operacao = titprotesto.operacao and
                    titprothist.nossonumero  = titprotesto.nossonumero  and
                    titprothist.dthist    = today and
                    titprothist.hrhist    = time 
                no-lock no-error.
            if avail titprothist then pause 1 no-message.
            create titprothist.
            titprothist.operacao = titprotesto.operacao.
            titprothist.nossonumero = titprotesto.nossonumero.
            titprothist.remessa  = titprotesto.remessa.
            titprothist.dthist   = today.
            titprothist.hrhist   = time.
            titprothist.situacao = titprotesto.situacao.
            titprothist.acao     = titprotesto.acao.
            titprothist.ativo    = titprotesto.ativo.
            titprothist.acaooper = titprotesto.acaooper.
            
            titprothist.codocorrencia   =  titprotesto.codocorrencia.
            titprothist.codirreg        =  titprotesto.codirreg.
            titprothist.pagaCustas      =  titprotesto.pagaCustas.            
            
    end.


