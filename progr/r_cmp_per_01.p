{admcab.i}

def var vct  as int.
def var vdti as date.
def var vdtf as date.
def var vinclui-rs as log format "Sim/Nao" init yes.
def var vinclui-st as log format "Sim/Nao" init yes.
def var varquivo as char.

def temp-table tt-pro
    field procod        like produ.procod
    field pronom        like produ.pronom
    field forcod        like forne.forcod
    field datent        as date
    field numero        like plani.numero
    field cfop          like plani.opccod
    field vlprod        as dec
    field platot        as dec
    field bicms         as dec
    field vicms-prod    as dec
    field vicms         as dec
    field vipi          as dec
    field bsubst        as dec
    field isubst        as dec
    field outros        as dec
    field fornom        like forne.fornom
    field uf_sai        as char
    field uf_ent        as char
    field mva           like clafis.mva_oestado1
    field codfis        as char
    field bsubst-calc   as dec decimals 2 
    field isubst-calc   as dec decimals 2
    field item          as int format ">>9"
    field movqtm        like movim.movqtm
    field movpc         like movim.movpc
    field forcgc        like forne.forcgc
    field pladat        like plani.pladat
    field ncm           as char
    field aicms        like movim.movalicms
    field bipi         as dec
    field aipi         as dec
    field cst          as char
    field chave        as char
    index i1 procod numero
    index i2 numero procod.

def var vesq as char extent 3 format "X(20)"
    init["TODAS AS ENRADAS","PRODUTOS COM ST","PRODUTOS SEM ST"]
    .

def var vindex as int init 0 no-undo.
do on error undo with frame f-data side-label width 80 1 down.
    update vdti label "Periodo de" validate (vdti <> ?, "").
    update vdtf label "Ate" validate (vdtf >= vdti, "") skip.
    /*
    update vinclui-rs label "Incluir notas do Rio Grande do Sul?" skip.
    update vinclui-st label "Incluir notas com ICMS ST informado?" skip.
    */
    disp vesq with frame fesq no-label centered.
    choose field vesq with frame fesq.
    vindex = frame-inde.
end.
    
do:
/*for each produ where /*produ.proipiper = 99*/ no-lock:
    vct = vct + 1.
    if vct mod 275 = 0
    then disp "Processando..... " procod format ">>>>>>>>9" pronom 
         with frame ff 1 down centered row 10 no-box color message no-label.
    pause 0.*/        
for each movim where movim.movtdc = 4 and
                    /* movim.procod = produ.procod and
                      */
                  /**movim.movdat >= vdti and
                     movim.movdat <= vdtf**/
                     
                     movim.datexp >= vdti and
                     movim.datexp <= vdtf
                     no-lock,
        first plani where 
              plani.etbcod = movim.etbcod and
              plani.placod = movim.placod and
              plani.movtdc = movim.movtdc
              no-lock,
        first forne where forne.forcod = plani.emite no-lock,
        first estab where estab.etbcod = plani.desti no-lock,
        first produ where produ.procod = movim.procod no-lock:

        if vindex = 2 and produ.proipiper <> 99 then next.
        if vindex = 3 and produ.proipiper = 99 then next.
        
        vct = vct + 1.
        if vct mod 275 = 0
        then disp "Processando..... " produ.procod format ">>>>>>>>9" pronom 
         with frame ff 1 down centered row 10 no-box color message no-label.
        pause 0.
        
            /*
        if vinclui-rs = no and forne.ufecod = "RS"
        then next.
        if vinclui-st = no and plani.bsubst <> 0
        then next.
        */
        
        create tt-pro.
        assign                     
            tt-pro.procod = produ.procod
            tt-pro.pronom = produ.pronom
            tt-pro.forcod = forne.forcod
            tt-pro.datent = plani.dtinclu
            tt-pro.numero = plani.numero
            tt-pro.cfop   = plani.opccod
            tt-pro.vlprod = /*((movim.movqtm * movim.movpc)
                              + movim.movipi  
                              - movim.movdes
                              + movim.movdev)*/
                           movim.movpc * movim.movqtm   
            tt-pro.platot = plani.platot
            tt-pro.bicms  = movim.movbicms /*plani.bicms*/
            tt-pro.vicms-prod = movim.movicms
            tt-pro.vicms  = movim.movicms /*plani.icms*/
            tt-pro.vipi   = plani.ipi
            tt-pro.bsubst = movim.movbsubst /*plani.bsubst*/
            tt-pro.isubst = movim.movsubst /*plani.icmssubst*/
            tt-pro.outros = plani.outras + plani.isenta
            tt-pro.fornom = forne.fornom
            tt-pro.uf_sai = forne.ufecod
            tt-pro.uf_ent = estab.ufecod
            tt-pro.codfis = string(produ.codfis)
            tt-pro.item   = movim.movseq
            tt-pro.movqtm = movim.movqtm
            tt-pro.movpc  = movim.movpc
            tt-pro.forcgc = forne.forcgc
            tt-pro.pladat = plani.pladat
            tt-pro.ncm = string(produ.codfis)
            tt-pro.aicms = movim.movalicms
            tt-pro.cst   = movim.movcsticms
            tt-pro.chave = plani.ufdes
            .
        
        tt-pro.forcgc = replace(tt-pro.forcgc,".","").
        tt-pro.forcgc = replace(tt-pro.forcgc,"/","").
        tt-pro.forcgc = replace(tt-pro.forcgc,"-","").

        if movim.movipi > 0
        then assign            
            tt-pro.bipi = movim.movpc * movim.movqtm
            tt-pro.aipi = movim.movalipi 
            tt-pro.vipi = movim.movipi
            .
        
        find first clafis where clafis.codfis = produ.codfis no-lock no-error.
        if avail clafis
        then do:
            if forne.ufecod = "RS"
            then tt-pro.mva = clafis.mva_estado1.
            else tt-pro.mva = clafis.mva_oestado1.
        
            tt-pro.bsubst-calc = tt-pro.vlprod * (1 + (tt-pro.mva / 100)).
            tt-pro.isubst-calc = (tt-pro.bsubst-calc * 0.18) - movim.movicms.
        end.
    end.                     
end.

def var varq-csv as char.
varq-csv = "r_cmp_per_01" + string(setbcod) + "_" + string(time) + ".csv".
varquivo = "/admcom/relat/" + varq-csv.

output to value(varquivo).
put "Numero;Emissao;CFOP;UFE;UFS;Razao Social;C.N.P.J;Produto;Descricao;NCM;"
    "Total Nota;Quant;Unitario;Total Item;Base Icms;Aliq Icms;Valor Icms;"
    "Base IPI;Aliq IPI;Valor IPI;Base ST;MVA;Icms!ST;CST;Chave" skip.

for each tt-pro use-index i2:
    put unformatted
         tt-pro.numero  ";"
         tt-pro.pladat  ";"
         tt-pro.cfop    ";"
         tt-pro.uf_ent   ";"
         tt-pro.uf_sai   ";"
         /*tt-pro.forcod ";"*/
         tt-pro.fornom ";"
         tt-pro.forcgc ";"
         tt-pro.procod ";"
         tt-pro.pronom ";"
         tt-pro.ncm    ";"
         tt-pro.platot ";"
         tt-pro.movqtm ";"
         tt-pro.movpc  ";"
         tt-pro.vlprod ";"
         tt-pro.bicms  ";"
         tt-pro.aicms  ";"
         tt-pro.vicms  ";"
         tt-pro.bipi   ";"
         tt-pro.aipi   ";"
         tt-pro.vipi   ";"
         tt-pro.bsubst ";"
         tt-pro.mva    ";"
         tt-pro.isubst ";"
         tt-pro.cst    ";"
         tt-pro.chave
         skip.
end.    

output close.

message color red/with
    "Arquivo CSV gerado: l:~\relat~\" + varq-csv
    view-as alert-box.
    
varquivo = "/admcom/relat/r_cmp_per_01" 
                + string(setbcod) + "." + string(time).
    
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""r_cmp_per_01""
    &Nom-Sis   = """SISTEMA""" 
    &Tit-Rel   = """ RELATORIO DE COMPRAS POR PERIODO - "" +
                  string(vdti,""99/99/9999"") + "" A "" +
                  string(vdtf,""99/99/9999"")"
    &Width     = "400"
    &Form      = "frame f-cabcab"}

for each tt-pro use-index i2:
    disp tt-pro.numero   column-label "Numero"   format ">>>>>>>9"
         tt-pro.pladat   column-label "Emissao"  format "99/99/99"
         tt-pro.cfop     column-label "CFOP"          format ">>>9"
         tt-pro.uf_ent   column-label "UFE" format "x(2)"
         tt-pro.uf_sai   column-label "UFS" format "x(2)"
         /*tt-pro.forcod column-label "Fornecedor"*/
         tt-pro.fornom column-label "Razao Social" format "x(25)"
         tt-pro.forcgc column-label "C.N.P.J"
         tt-pro.procod column-label "Produto"
         tt-pro.pronom column-label "Descricao"  format "x(20)"
         tt-pro.ncm    column-label "NCM" format "x(9)"
         tt-pro.platot column-label "Total Nota"    format ">>>>,>>9.99"
         tt-pro.movqtm column-label "Quantidade"
         tt-pro.movpc  column-label "Unitario"
         tt-pro.vlprod column-label "Total Item" format ">>>>,>>9.99"
         tt-pro.bicms  column-label "Base Icms"     format ">>>>,>>9.99"
         tt-pro.aicms  column-label "Aliq Icms"     format ">9.99"
         tt-pro.vicms  column-label "Valor Icms"    format ">>>,>>9.99"
         tt-pro.bipi   column-label "Base IPI"      format ">>>,>>9.99"
         tt-pro.aipi   column-label "Aliq IPI"      format ">9.99"
         tt-pro.vipi   column-label "Valor IPI"     format ">>>,>>9.99"
         tt-pro.bsubst column-label "Base ST"    format ">>>>,>>9.99"
         tt-pro.mva    column-label "MVA"           format ">>9.99"
         tt-pro.isubst column-label "Icms ST"    format ">>>>>9.99"
         tt-pro.cst    column-label "CST" format "x(5)"
         tt-pro.chave  column-label "Chave Acesso" format "x(44)"
         with frame f-dd down width 400 no-box.
end.    

output close.

if opsys = "UNIX"
then run visurel.p(varquivo,"").
else do:
    {mrod.i}
end.

