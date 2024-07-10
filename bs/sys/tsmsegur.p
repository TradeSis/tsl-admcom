/*{cabec.i}*/

/* TESTA A SEGURANCA */

def input parameter par-progcod as char.
def input parameter par-funcod  as int.
def input parameter par-mencod  as int.
def input parameter par-mensagem as log.
def output parameter vok as log init yes.

def buffer bsegur for seguranca.

/***
message sparam program-name(1).

if entry(1,sparam,";") <> "sv-ca-dbr.lebes.com.br"
then
***/
find first seguranca where
           seguranca.empcod = 19 and
           seguranca.programa = program-name(1)
           no-lock no-error.
if avail seguranca
then do:
    find first bsegur where
           bsegur.empcod = 19 and
           bsegur.funcod = par-funcod and
           bsegur.programa = program-name(1)
           no-lock no-error.
    if not avail bsegur
    then do:
        if par-mensagem
        then message color red/with
                "Usuario sem permissao de acesso " skip
                /*men-tit */
                view-as alert-box.
        vok = no.
        return.
    end.
end. 


/***Admcom
find first seguranca where 
            seguranca.empcod   = 1 and 
            seguranca.programa = par-progcod and
            seguranca.situacao
            no-lock no-error. 
if avail seguranca 
then do: 
    find func where func.funcod = par-funcod no-lock.
    find seguranca where 
            seguranca.empcod   = 1 and
            seguranca.funcod   = - func.funcao and
            seguranca.programa = par-progcod and
            seguranca.situacao
        no-lock no-error.
    if not avail seguranca
    then find seguranca where 
                seguranca.empcod   = 1 and  
                seguranca.funcod   = par-funcod  and 
                seguranca.programa = par-progcod and
                seguranca.situacao
            no-lock no-error. 
    if not available seguranca 
    then do:
        if par-mensagem 
        then do on endkey undo:  
            find first menu where menu.mencod = par-mencod  no-lock.
            pause 0. 
            disp     
                skip(3) 
                menu.mentit  
                menu.menpro 
                skip(2) 
                func.funape  
                func.funnom 
                skip (3) 
                with title " USUARIO NAO AUTORIZADO !!! "
                     row 10 centered overlay side-labels no-labels
                                    color messages
                                    frame fnaoaut.
            PAUSE 2 NO-MESSAGE. 
            hide frame fnaoaut no-pause. 
        end.  
        vok = no.
    END. 
end.
***/                
