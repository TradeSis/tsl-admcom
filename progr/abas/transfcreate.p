def input parameter par-abatipo like abastransf.abatipo.
def input parameter par-etbcod  like abastransf.etbcod.
def input parameter par-procod  like abastransf.procod.
def input parameter par-abtqtd  like abastransf.abtqtd.
def input parameter par-lipcor  like abastransf.lipcor.
def input parameter par-dttransf    like abastransf.dttransf.
def input parameter par-ORIGEM  as char.
def input parameter par-abtobs  like abastransf.abtobs.

def output parameter pabtcod     like abastransf.abtcod.

/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

/* 27.06.2019 */
def var vpack as int. /* substituindo conjunto.qtd */

def var vabtsit like abastransf.abtsit.

    find abastipo where abastipo.abatipo = par-abatipo no-lock.
    vabtsit = abastipo.inisit.


def var pabccod like abascompra.abccod.

def var par-recmovim        as recid init ?.
def var par-pedidoexterno   as char  init ?.

def var vcon as int.
def var vres as int.
def var vqtd    like par-abtqtd.

/* ORIGEM DIGITADO ou MOVIM=recid(movim) ou EXTERNO=numeroexterno */

if par-ORIGEM begins "DIGITADO"
then.
else if par-ORIGEM begins "MOVIM"
     then do:
        par-recmovim = int(entry(2,par-ORIGEM,"=")).
     end.
     if par-ORIGEM BEGINS "EXTERNO"
     then do:
        par-pedidoexterno = entry(2,par-ORIGEM,"=").
     end.
                                                

 
    find produ where produ.procod = par-procod no-lock no-error.  

    if produ.catcod = 31 /* 24.06.19 - Vira toda a moda */ 
                         /* portanto, so testa piloto nos moveis */
    then do:    
                 /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = par-etbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today < wfilvirada and 
                   not avail ttpiloto  /* CRIA APENAS PARA as Lojas Piloto */
                then vabtsit = "NN".
    end.    
    
    
    
    find abastwms where abastwms.abatipo = abastipo.abatipo and
                       abastwms.catcod  = if avail produ
                                          then produ.catcod
                                          else 31
                       no-lock no-error.

    /* 27.06.19 */
    find first produaux of produ where
            produaux.nome_campo = "PACK"  
       no-lock no-error.   
    vpack = (if avail produaux  
             then int(produaux.valor_campo)  
             else 0) no-error.  
    if vpack = ? or vpack = 0   
    then vpack = 1.
    /* 27.06.19 */
    
    /* 27.06.19 refactoring 
    find conjunto where conjunto.procod = par-procod no-lock no-error.
    if (avail conjunto       and 
        conjunto.qtd > 1)     and 
       (abastipo.abatipo <> "WEB" and
        abastipo.abatipo <> "NEO")
    then do:
    **/
    if vpack > 1 and
       abastipo.abatipo <> "WEB"
    then do:   
        vcon = truncate(par-abtqtd / vpack,0). 
        vres = if par-abtqtd > (vpack * vcon) 
               then par-abtqtd - (vpack * vcon) 
               else 0. 
        vqtd = vpack * vcon. 
        if vres <> 0 
        then vqtd = vqtd + vpack. 
    end.
    else do:
        vqtd = par-abtqtd.
    end.     

    find last abastransf use-index AbasTransf where 
            abastransf.etbcod =     par-etbcod 
            no-lock no-error.
    if not avail abastransf
    then pabtcod = 1.
    else pabtcod = abastransf.abtcod + 1.
    
    create abastransf.   
    abastransf.wms          = if avail abastwms
                              then abastwms.wms
                              else "PADRAO".
    abastransf.etbcod       = par-etbcod.   
    abastransf.abtcod       = pabtcod.
    
    abastransf.abtsit       = vabtsit.
    abastransf.dtInclu      = today.
    abastransf.hrInclu      = time.
    abastransf.DtTransf     = if par-dttransf = ? /*or par-dttransf < today*/
                              then today
                              else par-dttransf.
    abastransf.abatipo      = par-abatipo . 
    abastransf.procod       = par-procod.    
    abastransf.abtqtd       = vqtd . /*par-abtqtd. */
    abastransf.lipcor       = par-lipcor. 

    abastransf.pedexterno = par-pedidoexterno.

    abastransf.abtobs       = par-abtobs + 
                              if vqtd <> par-abtqtd
                              then  (" |QTDORIGINAL=" + string(par-abtqtd)) 
                              else "".
                            
    
    if par-recmovim <> ? 
    then do:
        find movim where recid(movim) = par-recmovim no-lock.
        abastransf.oriplacod    = movim.placod.
        abastransf.orietbcod    = movim.etbcod.
    end.
    
    if abastipo.abatcompra
    then do:
    
        /*abastransf.abtsit = if vabtsit = "NN"
         *                   then vabtsit
         *                   else "BL".
         */
         
        /**
        *find estoq where estoq.etbcod = 900 and 
        *                 estoq.procod = abastransf.procod
        *     no-lock no-error.
        *
        *run abas/compracreate.p (abastipo.abatipo, 
        *                         abastransf.etbcod,
        *                         abastransf.procod,
        *                         abastransf.abtqtd,
        *                         abastransf.lipcor,
        *                         if avail estoq
        *                         then estoq.estcusto
        *                         else 0,
        *                         produ.fabcod,
        *                         abastransf.dttransf,
        *                         "TRANSF=" + string(recid(abastransf)),
        *                         "",
        *                         output pabccod).
        **/
        
    end.
    
    
 
