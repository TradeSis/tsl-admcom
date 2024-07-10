/* 05012022 helio iepro */

def input param precid      as recid.

    find titprotesto where recid(titprotesto) = precid no-lock.
    do on error undo:
                
            find first titprothist where 
                    titprothist.operacao = titprotesto.operacao and
                    titprothist.contnum  = titprotesto.contnum  and
                    titprothist.titpar   = titprotesto.titpar and
                    titprothist.dthist    = today and
                    titprothist.hrhist    = time 
                no-lock no-error.
            if avail titprothist then pause 1 no-message.
            create titprothist.
            titprothist.operacao = titprotesto.operacao.
            titprothist.contnum  = titprotesto.contnum.
            titprothist.titpar   = titprotesto.titpar.
            titprothist.dthist   = today.
            titprothist.hrhist   = time.
            titprothist.sstatus  = titprotesto.situacao.
            titprothist.acao     = titprotesto.acao.
            titprothist.ativo    = titprotesto.ativo.

        end.
    end.


