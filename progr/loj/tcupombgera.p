/* helio 28032023 - adequacao tipocupom ao projetoi cashback pagamentos */
/* #012023 helio cupom desconto b2b */
/* programa responsavel pela geracao de cupons */

{admcab.i}

def var vsel as int.
def var vabe as dec.
def var petbcod             like cupomb2b.etbcod no-undo.
def var pcatcod             like cupomb2b.catcod no-undo.
def var pcla2-cod             like cupomb2b.clacod no-undo label "Cod Mercadologico".
def var pvalorDesconto      like cupomb2b.valorDesconto no-undo.
def var ppercentualDesconto like cupomb2b.percentualDesconto.
def var pdataValidade       like cupomb2b.dataValidade no-undo.
def var pquantidadeTotal    like cupomb2b.quantidadeTotal no-undo.
def var psequencia          like cupomb2b.sequencia.
def var pdataCriacao        like cupomb2b.dataCriacao.
def var phoraCriacao        like cupomb2b.horaCriacao.
def var pidcupom            like cupomb2b.idcupom.

def var cmercadologico as char label "Nivel Mercadologico" format "x(10)" extent 4 init
    ["Setor","Grupo","Classe","SubClasse"].

def buffer bcupomb2b for cupomb2b.
def var pfim as log no-undo.
pfim = no.

repeat with frame fcab
    centered 1 down 1 col
    title "geracao de descontos b2b".

    update petbcod label "filial"
        help "filial ou zero para geral".
    if petbcod <> 0 then do:
        find estab where estab.etbcod = petbcod no-lock no-error.
        if not avail estab then do:
            message "filial" petbcod "nao cadastrada".
            undo.
        end.
    end.
    update pcatcod.
    if pcatcod <> 0 then do:
        find categoria where categoria.catcod = pcatcod no-lock no-error.
        if not avail categoria then do:
            message "categoria" petbcod "nao cadastrada".
            undo.
        end.
        pcla2-cod = 0.
    end.
    else do:
        update pcla2-cod.
        if pcla2-cod <> 0 then do:
            find clase where clase.clacod = pcla2-cod no-lock no-error.
            if not avail clase then do:
                message "mercadologico" petbcod "nao cadastrado".
                undo.
            end.

            disp cmercadologico[clase.clagrau].
            
            disp clase.clanom label "Mercadologico".
        
        
        end.
    end.
            
    update pvalorDesconto.
    if pvalorDesconto = ? then pvalorDesconto = 0.
    if pvalorDesconto = 0
    then do:    
        update ppercentualDesconto.
        if ppercentualDesconto = ? then ppercentualDesconto = 0.
        if ppercentualDesconto = 0
        then do:
            message "preencha o valor do desconto ou o percentual do desconto".
            undo.
        end.    
    end.        
    update pdataValidade.
    if pdataValidade < today then do:
        message "data de validade invalida".
        undo.
    end.    
    update pquantidadeTotal.
    if  pquantidadeTotal = ? then  pquantidadeTotal = 0.
    if  pquantidadeTotal = 0
    then do:
        message "informe a quantidade total de cupons a serem gerados".
        undo.
    end.

    pfim = yes.     
    leave.    
    
end.
if not pfim then return.
sresp = yes.
message "confirma a geracao de" pquantidadeTotal ("cupo" + if pquantidadeTotal = 1 then "m" else "ns") "conforme parametros acima" update sresp.

if not sresp then return.

pdataCriacao    = today.
phoraCriacao    = time.

def var pcodigo as int.
def var pdigito as int.
def var pnovoidcupom as int.

do psequencia = 1 to pquantidadeTotal:
    
    pcodigo =  next-value(idcupomb2b).

    run /admcom/progr/dvmod11.p (pcodigo , output pdigito).

    pnovoidcupom = int(string(pcodigo) + string(pdigito)).

    create cupomb2b.
    cupomb2b.tipoCupom          = "". /* helio 28032023 - adequacao cashback */
    cupomb2b.idCupom            = pnovoidcupom.
    cupomb2b.catcod             = pcatcod.
    cupomb2b.clacod             = pcla2-cod.
    cupomb2b.valorDesconto      = pvalorDesconto.
    cupomb2b.percentualDesconto = ppercentualDesconto.
    cupomb2b.dataValidade       = pdataValidade.
    cupomb2b.etbcod             = petbcod.
    cupomb2b.dataTransacao      = ?.
    cupomb2b.numeroComponente   = ?.
    cupomb2b.nsuTransacao       = ?.
    cupomb2b.dataCriacao        = pdataCriacao.
    cupomb2b.horaCriacao        = phoraCriacao.
    cupomb2b.sequencia          = psequencia.
    cupomb2b.quantidadeTotal    = pquantidadeTotal.
END.

