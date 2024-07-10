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
    field uf            as char
    field mva           like clafis.mva_oestado1
    field codfis        as char
    field bsubst-calc   as dec decimals 2 
    field isubst-calc   as dec decimals 2
    field item          as int format ">>9"
    field movqtm        like movim.movqtm
    field forcgc        like forne.forcgc
    field pladat        like plani.pladat
    field gnre          as char
    index i1 procod numero
    index i2 datent numero procod.

do on error undo with frame f-data side-label width 80 1 down.
    update vdti label "Periodo de" validate (vdti <> ?, "").
    update vdtf label "Ate" validate (vdtf >= vdti, "") skip.

    update vinclui-rs label "Incluir notas do Rio Grande do Sul?" skip.
    update vinclui-st label "Incluir notas com ICMS ST informado?" skip.
end.
    
for each produ where produ.proipiper = 99 no-lock:
    vct = vct + 1.
    if vct mod 375 = 0
    then disp "Processando..... " procod format ">>>>>>>>9" pronom 
         with frame ff 1 down centered row 10 no-box color message no-label.
    pause 0.        
    for each movim where
                     movim.procod = produ.procod and
                     movim.movtdc = 4 and                     
                     
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
        forne where forne.forcod = plani.emite no-lock:

        if vinclui-rs = no and forne.ufecod = "RS"
        then next.
        if vinclui-st = no and plani.bsubst <> 0
        then next.
        
        create tt-pro.
        assign                     
            tt-pro.procod = produ.procod
            tt-pro.pronom = produ.pronom
            tt-pro.forcod = forne.forcod
            tt-pro.datent = plani.dtinclu
            tt-pro.numero = plani.numero
            tt-pro.cfop   = plani.opccod
            tt-pro.vlprod = ((movim.movqtm * movim.movpc)
                              + movim.movipi  
                              - movim.movdes
                              + movim.movdev)
            tt-pro.platot = plani.platot
            tt-pro.bicms  = plani.bicms
            tt-pro.vicms-prod = movim.movicms
            tt-pro.vicms  = plani.icms
            tt-pro.vipi   = plani.ipi
            tt-pro.bsubst = plani.bsubst
            tt-pro.isubst = plani.icmssubst
            tt-pro.outros = plani.outras + plani.isenta
            tt-pro.fornom = forne.fornom
            tt-pro.uf     = forne.ufecod
            tt-pro.codfis = string(produ.codfis)
            tt-pro.item   = movim.movseq
            tt-pro.movqtm = movim.movqtm
            tt-pro.forcgc = forne.forcgc
            tt-pro.pladat = plani.pladat.
        
        find first clafis where clafis.codfis = produ.codfis no-lock no-error.
        if avail clafis
        then do:
            if forne.ufecod = "RS"
            then tt-pro.mva = clafis.mva_estado1.
            else tt-pro.mva = clafis.mva_oestado1.
        
            tt-pro.bsubst-calc = tt-pro.vlprod * (1 + (tt-pro.mva / 100)).
            tt-pro.isubst-calc = (tt-pro.bsubst-calc * 0.18) - movim.movicms.
        end.

        find first planiaux
                      where planiaux.movtdc = plani.movtdc
                        and planiaux.etbcod = plani.etbcod
                        and planiaux.emite  = plani.emite
                        and planiaux.serie  = plani.serie
                        and planiaux.numero = plani.numero
                        and planiaux.nome_campo = "GNRE"
                      no-lock no-error.
        if avail planiaux
        then do.
            tt-pro.gnre = acha("Opcao", planiaux.valor_campo).
            if tt-pro.gnre = "1"
            then tt-pro.gnre = acha("Numero", planiaux.valor_campo).
        end.
    end.                     
end.

if opsys = "UNIX"
then varquivo = "/admcom/relat/rsubst01" + string(setbcod) + "." + string(time).
else varquivo = "..~\relat~\rsubst01" + string(setbcod) + "." + string(time).
    
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""rsubst01""
    &Nom-Sis   = """SISTEMA""" 
    &Tit-Rel   = """ PERIODO - "" +
                  string(vdti,""99/99/9999"") + "" A "" +
                  string(vdtf,""99/99/9999"")"
    &Width     = "210"
    &Form      = "frame f-cabcab"}

for each tt-pro use-index i2:
    disp tt-pro.procod column-label "Produto"
         tt-pro.pronom column-label "Descricao"     format "x(17)"
         tt-pro.item   column-label "Nro!Item"
         tt-pro.movqtm column-label "Quanti!dade"   format ">>>>9"
         tt-pro.forcod column-label "Codigo!Fornec"
         tt-pro.forcgc column-label "CNPJ!Fornecedor"
         tt-pro.pladat column-label "Data!Emissao"  format "99/99/99"
         tt-pro.datent column-label "Data!Entrada"
         tt-pro.numero column-label "Numero!Nota"   format ">>>>>>>9"
         tt-pro.cfop   column-label "CFOP"          format ">>>9"
         tt-pro.vlprod column-label "Total!Produto" format ">>>>,>>9.99"
         tt-pro.platot column-label "Total!Nota"    format ">>>>,>>9.99"
         tt-pro.bicms  column-label "Base!Icms"     format ">>>>,>>9.99"
         tt-pro.vicms  column-label "Valor!Icms"    format ">>>,>>9.99"
         tt-pro.vicms-prod column-label "Icms!Produto" format ">>>,>>9.99"
         tt-pro.vipi   column-label "Valor!IPI"     format ">>>>9.99"
         tt-pro.bsubst column-label "Base!Subst"    format ">>>,>>9.99"
         tt-pro.isubst column-label "Icms!Subst"    format ">>>>9.99"
         tt-pro.outros column-label "Valor!Outros"  format ">>>,>>9.99"
         tt-pro.fornom column-label "Razao Social"  format "x(15)"
         tt-pro.uf     column-label "UF" format "x(2)"
         tt-pro.codfis column-label "Classic!Fiscal"
         tt-pro.mva    column-label "MVA"           format ">>9.99"
         tt-pro.bsubst-calc column-label "Calc.Base!Subst" format ">>>>,>>9.99"
         tt-pro.isubst-calc column-label "Calc.Icms!Subst" format ">>>>>9.99"
         tt-pro.gnre        column-label "GNRE"     format "x(16)"
         with frame f-dd down width 270 no-box.
end.    

output close.

if opsys = "UNIX"
then run visurel.p(varquivo,"").
else do:
    {mrod.i}
end.

