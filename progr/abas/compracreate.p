def input parameter par-abatipo like abascompra.abatipo.
def input parameter par-etbcod  like abascompra.etbcod.
def input parameter par-procod  like abascompra.procod.
def input parameter par-abcqtd  like abascompra.abcqtd.
def input parameter par-lipcor  like abascompra.lipcor.
def input parameter par-lippreco like abascompra.lippreco.
def input parameter par-forcod  like abascompra.forcod.
def input parameter par-dtpreventrega    like abascompra.dtpreventrega.
def input parameter par-ORIGEM  as char.
def input parameter par-abcobs  like abascompra.abcobs[1].

def output parameter pabccod     like abascompra.abccod.

def var par-rectransf       as recid init ?.
def var par-pedidoexterno   as char  init ?.
def var vabcsit     like    abascompra.abcsit.

/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

    find abastipo where abastipo.abatipo = par-abatipo no-lock.
    vabcsit = "AB".                            
    /** 25.06.19 - sem validacao piloto 
    
                 /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = par-etbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today < wfilvirada and 
                   not avail ttpiloto  /* CRIA APENAS PARA as Lojas Piloto */
                then vabcsit = "NN".

    **/
    
/* ORIGEM DIGITADO ou TRANSF=recid(abastransf) ou EXTERNO=numeroexterno */

     if par-ORIGEM begins "TRANSF"
     then do:
        par-rectransf = int(entry(2,par-ORIGEM,"=")).
     end.
     if par-ORIGEM BEGINS "EXTERNO"
     then do:
        par-pedidoexterno = entry(2,par-ORIGEM,"=").
     end.
                                                

 
    find produ where produ.procod = par-procod no-lock no-error.  
    find forne where forne.forcod = par-forcod no-lock no-error.

    find last abascompra where 
            abascompra.etbcod =     par-etbcod 
            no-lock no-error.
    if not avail abascompra
    then pabccod = 1.
    else pabccod = abascompra.abccod + 1.

    create abascompra.   
    abascompra.etbcod       = par-etbcod.   
    abascompra.abccod       = pabccod. 
    
    abascompra.abcsit       = vabcsit.
    
    abascompra.dtInclu      = today.
    abascompra.hrInclu      = time.
    abascompra.dtpreventrega     = if par-dtpreventrega = ? or par-dtpreventrega < today
                              then today
                              else par-dtpreventrega.
    abascompra.abatipo      = par-abatipo . 
    abascompra.procod       = par-procod.    
    abascompra.forcod       = if avail forne
                              then forne.forcod
                              else if avail produ
                                   then produ.fabcod
                                   else 0.
    abascompra.qtdORI       = par-abcqtd. 

    abascompra.abcqtd       = par-abcqtd. 
    abascompra.lipcor       = par-lipcor. 
    abascompra.lippreco     = par-lippreco.

    abascompra.pedexterno = par-pedidoexterno.

    abascompra.abcobs[1]       = par-abcobs.
    
    if par-rectransf <> ? 
    then do:
        find abastransf where recid(abastransf) = par-rectransf no-lock.
        abascompra.abtcod       = abastransf.abtcod.
    end.
    
    
    
    
    
    
 
