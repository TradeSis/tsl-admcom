{admcab-batch.i}

 
def input parameter par-rec as recid.
def new shared var vdata-teste-promo as date.
def new shared var v-vendedor-plano like func.funcod.

def var parametro-out as char.
def var parametro-in as char.
def var vlibera as log.
def var vpreco as dec.
def var libera-plano as log.
def var p-dtentra as date.
def var p-dtparcela as date.

def var produto-usado as log format "Sim/Nao" init no.
def var valor-produto-usado as dec.

def var vrecibdes as char extent 10.
def var vfor-promo as int.
def var vvalpremio as dec.
def var v-venger-f as log.
def var v-venger-fval as dec.
def var vvendedor as log init no.


def var detbcod like setbcod.

def new shared workfile wf-movim
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod.


def new shared temp-table tt-valpromo
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.


def buffer tp-titulo for titulo.


def var vplano-aux as int.

find plani where recid(plani) =  par-rec no-lock.
find finan where finan.fincod = plani.pedcod no-lock no-error.
vplano-aux = if avail finan
             then finan.fincod
             else 0.


vdata-teste-promo = ?.

detbcod = setbcod.
setbcod = plani.etbcod.
 
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                     no-lock.
    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ then next.
    create wf-movim.
    assign
        wf-movim.wrec = recid(produ)
        wf-movim.movqtm = movim.movqtm
        wf-movim.movpc = movim.movpc
        wf-movim.vencod = plani.vencod .
end.                      


/*** #1
    parametro-in = "CASADINHA=S|PLANO=" + string(vplano-aux) +
                   "|ALTERA-PRECO=N|".
    run promo-venda.p(input parametro-in, output parametro-out).
if acha("CARTAO-PRESENTE",parametro-out) <> ? 
then do:
end.
***/

/*****  Fim venda do cartao presente  *********/


/*******  Inicio promocao DINHEIRO-NA-MAO  *********/

parametro-out = "".
parametro-in = "DINHEIRO-NA-MAO=S|PLANO=" + string(vplano-aux) + "|"
            + "ALTERA-PRECO=N|".
run promo-venda.p(input parametro-in, output parametro-out).

def var vpromo as char.

for each tt-valpromo where tt-valpromo.tipo = 9 no-lock.
    vpromo = vpromo + string(tt-valpromo.forcod) + " ; ".
end.

if acha("PERGUNTAPRODUTOUSADO",parametro-out) <> ?
then do:
    if acha("PERGUNTAPRODUTOUSADO",parametro-out) = "S" 
    then do:
        produto-usado = no.
    end.
    else produto-usado = yes.
end.    

/****************************************************************************/
def var vtipo as char init "".
def var v-ven-fval as dec init 0.
def var v-promo-fval as dec init 0.

/** Final Promo telefonia dinheiro na mao novembro **/



/*** inicio promocoes aniversario dinheiro na mao ***/

/**
find first tp-titulo  where tp-titulo.clifor = plani.desti and
                        tp-titulo.empcod = 19 and
                        tp-titulo.titnat = yes and
                        tp-titulo.modcod = "BON" and
                        tp-titulo.moecod = "PDM" and
                        month(tp-titulo.titdtven) = month(plani.pladat) and
                        year(tp-titulo.titdtven)  = year(plani.pladat) 
                        no-lock no-error.

if avail tp-titulo 
then do:
end.
message "   fim promocoes aniversario".
 pause.
**/

vvalpremio = 0.
valor-produto-usado = 0.

if acha("BONUSVALOR",parametro-out) = "S"
then do:
    run promo-bonus-valor.
end.
 
if acha("BONUS",parametro-out) = "PAR"
then do:
    if produto-usado = yes
    then do:
            valor-produto-usado = dec(acha("VAL-BONUS-U",parametro-out)).
            if valor-produto-usado = ?
            then valor-produto-usado = 0.
            
            /**
            **valor-produto-usado = vdinheiro-namao.
            **/
            
            if valor-produto-usado > 0
            then do:
                if acha("GERA-DESPESA",parametro-out) <> ?  
                then do transaction:  
                    vfor-promo = 0.
                    vfor-promo = int(acha("FORNECEDOR",parametro-out)).
                    if vfor-promo = 0 or
                        vfor-promo = ?
                    then vfor-promo = 110745.   
                    run cria-despesa (input valor-produto-usado,
                                  input 1,
                                  input vfor-promo,
                                  input "PAG",
                                  input "CLIENTE").

                end.
                /***
                *
                if acha("EMITE-RECIBO",parametro-out) <> ?
                then do:
                    if acha("PRODUTO-USADO",parametro-out) = "S"      
                    then do:
                        assign
                            vrecibdes[1] = "RECIBO"
                            vrecibdes[2] = "RECEBI R$" + 
                                string(valor-produto-usado,">>>9.99") +
                                " REFERENTE PROMOCAO DE TROCA"
                            vrecibdes[3] = 
                                " DE UM PRODUTO USADO POR OUTRO NOVO"
                            vrecibdes[4] = ""
                            vrecibdes[5] = ""
                            vrecibdes[10] = "*".
                    end.
                    else do:
                        assign
                            vrecibdes[1] = "RECIBO"
                            vrecibdes[2] = "RECEBI R$" + 
                                string(valor-produto-usado,">>>9,99") +
                                " REFERENTE PROMOCAO " 
                            vrecibdes[3] = 
                                " MES " + string(month(today),"99") +
                                        "/" + string(year(today),"9999")
                            vrecibdes[4] = ""
                            vrecibdes[5] = ""
                            vrecibdes[10] = "*".
                    end.
                    run recibgen.p(input plani.desti,  
                       input valor-produto-usado,
                       input vrecibdes).
                end.
                ***/
            end.    
    end.
    else 
    if acha("PRODUTO-USADO",parametro-out) <> "S"
    then do:
        if acha("VALOR-PARCELA",parametro-out) <> ?
        then vvalpremio = DEC(acha("VALOR-PARCELA",parametro-out)).
        /**
        else vvalpremio = vdinheiro-namao.
        **/
        
        if vvalpremio = ?
        then vvalpremio = 0.
        if  vvalpremio > 0
        then do:
            if acha("GERA-DESPESA",parametro-out) <> ?  
            then do transaction:  
                vfor-promo = 0.
                vfor-promo = int(acha("FORNECEDOR",parametro-out)).
                if vfor-promo = 0 or
                   vfor-promo = ?
                then vfor-promo = 110745.   
                run cria-despesa (input vvalpremio,
                                  input 2,
                                  input vfor-promo,
                                  input "PAG",
                                  input "CLIENTE").

            end.
            /***
            *
            if acha("EMITE-RECIBO",parametro-out) <> ?
            then do:
                assign
                    vrecibdes[1] = "RECIBO"
                    vrecibdes[2] = "RECEBI R$" + string(vvalpremio,">>>9.99") +
                        " REFERENTE PROMOCAO " 
                    vrecibdes[3] = " MES " + string(month(today),"99") +
                                        "/" + string(year(today),"9999")
                    vrecibdes[4] = ""
                    vrecibdes[5] = ""
                    vrecibdes[10] = "*".
                run recibgen.p(input plani.desti,  
                       input vvalpremio,
                       input vrecibdes).
            end.
            **
            **/
        end.      
    end.  
end.



/** premiacao **/

def var val-vendedor as dec.
def var val-gerente as dec.
def var val-supervisor as dec.
def var val-promotor as dec.
def var cod-fornecedor like forne.forcod.
def var num-parcela as int.
assign
    val-vendedor = 0
    val-gerente = 0
    val-supervisor = 0
    val-promotor = 0
    cod-fornecedor = 0
    num-parcela = 0.

/** dinheiro-na-mao funcionarios **/

for each tt-valpromo where tt-valpromo.tipo = 1 no-lock:
    if tt-valpromo.valor > 0  and  
       acha("GERA-DESPESA",parametro-out) <> ?
    then do:
        num-parcela = num-parcela + 1.
        
        run cria-despesa(input tt-valpromo.valor,
                             input num-parcela + 50,
                             input tt-valpromo.forcod,
                             input "LIB",
                             input tt-valpromo.nome).
        if tt-valpromo.nome = "VENDEDOR"
        then  val-vendedor = val-vendedor + tt-valpromo.valor.
        if tt-valpromo.nome = "GERENTE"
        then  val-gerente = val-gerente + tt-valpromo.valor.
        if tt-valpromo.nome = "SUPERVISOR"
        then  val-supervisor = val-supervisor + tt-valpromo.valor.
        if tt-valpromo.nome = "PROMOTOR"
        then  val-promotor = val-promotor + tt-valpromo.valor.
    end.
    
end.

def var valor-p as dec.

for each tt-valpromo where tt-valpromo.tipo = 2 no-lock:
    if tt-valpromo.valor > 0  and  
       acha("GERA-DESPESA",parametro-out) <> ?
    then do:
        
        num-parcela = num-parcela + 1.
        valor-p = tt-valpromo.valor.
        run cria-despesa(input valor-p,
                             input num-parcela + 50,
                             input tt-valpromo.forcod,
                             input "LIB",
                             input tt-valpromo.nome).
        if tt-valpromo.nome = "VENDEDOR"
        then val-vendedor = val-vendedor + tt-valpromo.valor
                    /*(plani.platot * (tt-valpromo.valor / 100))*/.
        if tt-valpromo.nome = "GERENTE"
        then val-gerente = val-gerente + tt-valpromo.valor
                    /*(plani.platot * (tt-valpromo.valor / 100))*/.
        if tt-valpromo.nome = "SUPERVISOR"
        then val-supervisor = val-supervisor + tt-valpromo.valor
                    /*(plani.platot * (tt-valpromo.valor / 100))*/.
        if tt-valpromo.nome = "PROMOTOR"
        then val-promotor = val-promotor + tt-valpromo.valor 
                    /*(plani.platot * (tt-valpromo.valor / 100))*/.
    end.
    
end.



procedure cria-despesa:
    def input parameter p-valor like titulo.titvlcob.
    def input parameter p-titpar  like titulo.titpar.
    def input parameter p-fornecedor like titulo.clifor.
    def input parameter p-titsit like titluc.titsit.
    def input parameter p-quem as char.
    do transaction: 
            find func where func.etbcod = setbcod and
                            func.funcod = plani.vencod
                            no-lock.
                find titluc where titluc.empcod = 19  
                              and titluc.titnat = yes  
                              and titluc.modcod = "COM"  
                              and titluc.etbcod = setbcod  
                              and titluc.clifor = p-fornecedor 
                              and titluc.titnum = string(plani.numero) 
                              and titluc.titpar = p-titpar
                            NO-LOCK no-error.
                if not avail titluc
                then do:
                    create titluc.  
                    assign titluc.empcod   = 19  
                           titluc.titnat   = yes  
                           titluc.modcod   = "COM"  
                           titluc.etbcod   = setbcod  
                           titluc.clifor   = p-fornecedor
                           titluc.titnum   = string(plani.numero)
                           titluc.titpar   = p-titpar  
                           titluc.titdtemi = today 
                           titluc.titdtven = today
                           titluc.titvlcob = p-valor
                           titluc.cobcod   = 1  
                           titluc.datexp = today
                           titluc.evecod = 4
                           .
                   if p-titsit = "PAG"
                   then do:        
                       assign    
                           titluc.titdtpag = today
                           titluc.titvlpag = titluc.titvlcob
                           titluc.titsit   = "PAG"  
                           titluc.cxacod   = scxacod  
                           titluc.cxmdat   = today  
                           titluc.etbcobra = setbcod  
                           titluc.titobs[2] = "NOTA: "
                                            + string(plani.numero).
                   end.
                   else do:
                       assign
                           titluc.titsit = "LIB"
                           titluc.vencod =  if p-quem = "VENDEDOR" and
                                                v-vendedor-plano > 0
                                            then v-vendedor-plano
                                            else if p-quem = "VENDEDOR"    
                                            THEN func.funcod
                                            else if p-quem = "GERENTE"
                                                then 99 else 0    
                           titluc.cxacod = 1
                           titluc.titobs[1] = if p-quem = "VENDEDOR"
                                    THEN func.funnom else p-quem
                           titluc.titobs[2] = "NOTA=" + string(plani.numero)
                           + "|PREMIO=" + 
                           if v-vendedor-plano > 0
                           then "CREDIARISTA PLANO BIS"
                           else string(p-quem,"x(20)") 
                           + "|".
                    
                        if today >= 01/01/2010
                        then do:
                            if p-quem = "GERENTE" or
                               p-quem = "VENDEDOR" or
                               p-quem = "RECARGA" or
                               p-quem = "PROMOTOR"
                            then titluc.titsit = "BLO" .
                            
                            assign
                                titluc.cxacod = scxacod
                                titluc.cobcod = 1
                                titluc.evecod = 5 .
                        end.
                   end.
                end.
                find current titluc no-lock no-error.
    end.
end procedure.

vvalpremio = 0.     


procedure promo-bonus-valor:

    def var vb as int.
    def var vacha-par as char.
    def var vacha-val as char.
    
    if produto-usado = yes
    then do:
        vacha-par = "BONUSVALORUSADO".
        do vb = 1 to 10:
            vacha-val = vacha-par + string(vb,"99").
            if acha(vacha-val, parametro-out) <> ?
            then do:
                valor-produto-usado = dec(acha(vacha-val, parametro-out)).
                if valor-produto-usado = ?
                then valor-produto-usado = 0.
        
                if valor-produto-usado > 0
                then do:
                    vacha-val = vacha-par + "DESPESA" + string(vb,"99").
                    if acha(vacha-val, parametro-out) <> ?  
                    then do transaction:  
                        vfor-promo = 0.
                        vfor-promo = int(acha(vacha-val, parametro-out)).
                        if vfor-promo = 0 or
                            vfor-promo = ?
                        then vfor-promo = 110745.   
                        run cria-despesa (input valor-produto-usado,
                                  input 1,
                                  input vfor-promo,
                                  input "PAG",
                                  input "CLIENTE").
                    end.
                    /***
                    *
                    vacha-val = vacha-par + "RECIBO" + string(vb,"99").
                    if acha(vacha-val, parametro-out) <> ?
                    then do:
                        if acha(vacha-val, parametro-out) = "S"      
                        then do:
                                assign
                                    vrecibdes[1] = "RECIBO"
                                    vrecibdes[2] = "RECEBI R$" + 
                                        string(valor-produto-usado,">>>9.99") +
                                        " REFERENTE PROMOCAO DE TROCA"
                                    vrecibdes[3] = 
                                        " DE UM PRODUTO USADO POR OUTRO NOVO"
                                    vrecibdes[4] = ""
                                    vrecibdes[5] = ""
                                    vrecibdes[10] = "*".
                        end.
                    end.
                    else do:
                            assign
                                vrecibdes[1] = "RECIBO"
                                vrecibdes[2] = "RECEBI R$" + 
                                string(valor-produto-usado,">>>9.99") +
                                " REFERENTE PROMOCAO " 
                                vrecibdes[3] = 
                                    " MES " + string(month(today),"99") +
                                        "/" + string(year(today),"9999")
                                vrecibdes[4] = ""
                                vrecibdes[5] = ""
                                vrecibdes[10] = "*".
                    end.
                    run recibgen.p(input plani.desti,  
                            input valor-produto-usado,
                            input vrecibdes).
                    *
                    *
                    **/
                end.    
            end.
        end.        
    end.
    vacha-par = "BONUSVALORVALOR".
    if acha(vacha-par, parametro-out) <> ? and
       acha(vacha-par, parametro-out) = "S"
    then do:
        do vb = 1 to 10:
            vacha-val = vacha-par + string(vb,"99").
            if acha(vacha-val, parametro-out) <> ?
            then do:
                vvalpremio = dec(acha(vacha-val, parametro-out)).
                if vvalpremio = ?
                then vvalpremio = 0.
                if vvalpremio > 0
                then do:
                    vacha-val = vacha-par + "DESPESA" + string(vb,"99").
                    if acha(vacha-val, parametro-out) <> ?  
                    then do transaction:  
                        vfor-promo = 0.
                        vfor-promo = int(acha(vacha-val, parametro-out)).
                        if vfor-promo = 0 or
                        vfor-promo = ?
                        then vfor-promo = 110745.   
                        run cria-despesa (input vvalpremio,
                                  input 2,
                                  input vfor-promo,
                                  input "PAG",
                                  input "CLIENTE").
                    end.
                    /***
                    *
                    *
                    vacha-val = vacha-par + "RECIBO" + string(vb,"99").
                    if acha(vacha-par, parametro-out) <> ? and
                       acha(vacha-val, parametro-out) = "S"
                    then do:
                        assign
                            vrecibdes[1] = "RECIBO"
                            vrecibdes[2] = "RECEBI R$" + 
                                   string(vvalpremio,">>>9.99") +
                                " REFERENTE PROMOCAO " 
                            vrecibdes[3] = " MES " + 
                                string(month(today),"99") +
                                        "/" + string(year(today),"9999")
                            vrecibdes[4] = ""
                            vrecibdes[5] = ""
                            vrecibdes[10] = "*".
                        run recibgen.p(input plani.desti,  
                                        input vvalpremio,
                                        input vrecibdes).
                    end.
                    *
                    **/
                end. 
            end.
        end.                        
    end. 
    vacha-par = "BONUSVALORRECARGA".
    if acha(vacha-par, parametro-out) <> ? and
       acha(vacha-par, parametro-out) = "S"
    then  do vb = 1 to 10:
        vacha-val = vacha-par + string(vb,"99").
        vvalpremio = dec(acha(vacha-val,parametro-out)).
        if vvalpremio = ?
        then vvalpremio = 0.
        if vvalpremio > 0
        then do:
            vacha-val = vacha-par + "DESPESA" + string(vb,"99").
            if acha(vacha-val, parametro-out) <> ?  
            then do transaction:  
                vfor-promo = 0.
                vfor-promo = int(acha(vacha-val, parametro-out)).
                if vfor-promo = 0 or
                   vfor-promo = ?
                then vfor-promo = 0.
                if vfor-promo > 0
                then do:             
                    run cria-despesa (input vvalpremio,
                                  input 3,
                                  input vfor-promo,
                                  input "PAG",
                                  input "CLIENTE").
                    
                    /***
                    *
                    *
                    vacha-val = vacha-par + "RECIBO" + string(vb,"99").
                    if acha(vacha-val, parametro-out) <> ?
                    then do:
                        assign
                            vrecibdes[1] = "RECIBO"
                            vrecibdes[2] = "RECEBI R$" + 
                                        string(vvalpremio,">>>9.99") +
                                        " REFERENTE PROMOCAO " 
                            vrecibdes[3] = " MES " + 
                                            string(month(today),"99") +
                                        "/" + string(year(today),"9999")
                            vrecibdes[4] = "RECARGA - " + cel-numero
                            vrecibdes[5] = ""
                            vrecibdes[10] = "*".
                        run recibgen.p(input plani.desti,  
                           input vvalpremio,
                           input vrecibdes).
                    end.
                    *
                    *
                    **/
                end.
            end.
            else do:
                /***
                *
                
                if acha("EMITE-RECIBO",parametro-out) <> ?
                then do:
                    assign
                        vrecibdes[1] = "RECIBO"
                        vrecibdes[2] = "RECEBI R$" + 
                                    string(vvalpremio,">>>9.99") +
                                    " REFERENTE PROMOCAO " 
                        vrecibdes[3] = " MES " + 
                                        string(month(today),"99") +
                                        "/" + string(year(today),"9999")
                        vrecibdes[4] = "RECARGA - " + cel-numero
                        vrecibdes[5] = ""
                        vrecibdes[10] = "*".

                    run recibgen.p(input plani.desti,  
                           input vvalpremio,
                           input vrecibdes).
                end.
                *
                *
                **/
            end.
        end.
    end.
end procedure.

