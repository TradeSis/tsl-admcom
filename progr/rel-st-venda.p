{admcab.i}

def temp-table tt-venda no-undo
    field etbcod like plani.etbcod
    field numero like plani.numero
    field serie  like plani.serie
    field pladat like plani.pladat
    field procod like movim.procod
    field pronom like produ.pronom
    field ncm    like clafis.codfis
    field mva    like clafis.mva_estado1
    field valcusto like movim.movpc
    field valicmsp like movim.movicms
    field pcticmsp like movim.movalicms
    field valsubst like movim.movsubst
    field valvenda like movim.movpc
    field tipvenda as char
    field valacres as dec
    index i1 etbcod pladat
    .
    
update vetbcod like estab.etbcod label "Filial"
            with frame f1 1 down width 80 side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial nao cadatrada."
        view-as alert-box.
        undo.
    end.    
    disp estab.etbnom no-label with frame f1.
end.
else disp "todas as filiais" @ estab.etbnom with frame f1.
        
update vdti as date at 1 format "99/99/9999" label "Periodo venda"
       vdtf as date format "99/99/9999" label "a"  
       with frame f1.
       
if vdti = ? or
   vdtf = ? or
   vdti > vdtf
then do:
   bell.
   message color red/with
   "Informe novamente o periodo."
   view-as alert-box.
   undo.
end.
   
def var vdata as date.
            
def buffer bmovim for movim.

for each estab where (if vetbcod > 0
                      then estab.etbcod = vetbcod else true)
                      no-lock:
    disp estab.etbcod 
         with frame f-disp 1 down width 80 color message row 10 
         side-label no-box.
         pause 0.
         
    do vdata = vdti to vdtf:
        disp vdata label "Data" with frame f-disp.
        pause 0.
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdata 
                             no-lock,
            each movim where movim.etbcod    = plani.etbcod and
                             movim.placod    = plani.placod and
                             movim.movtdc    = plani.movtdc and
                             movim.movdat    = plani.pladat and
                             movim.movalicms = 0
                             no-lock,
            first produ where produ.procod = movim.procod no-lock:
            if not avail produ then next.
            
            if produ.catcod <> 31 then next.
            
            if produ.pronom matches "*recarga*" or
               produ.pronom matches "*chip*" or
               produ.pronom matches "*cartao*"
            then next.
            
            if produ.proipiper = 98 then next.
            if produ.codfis = 0 then next.
            
            create tt-venda.
            assign
                tt-venda.etbcod = movim.etbcod
                tt-venda.numero = plani.numero
                tt-venda.serie  = plani.serie
                tt-venda.pladat = movim.movdat
                tt-venda.procod = movim.procod
                tt-venda.pronom   = produ.pronom
                tt-venda.ncm      = produ.codfis
                tt-venda.valvenda = movim.movpc * movim.movqtm
                .
                
            find clafis where clafis.codfis = produ.codfis no-lock no-error.
            if avail clafis
            then tt-venda.mva  = clafis.mva_estado1.
            
            if plani.crecod = 2
            then do:
                tt-venda.tipvenda = "Prazo".
                if plani.biss > plani.platot - plani.vlserv
                then tt-venda.valacre = (plani.biss - 
                    (plani.platot - plani.vlserv)) * 
                    ((movim.movpc * movim.movqtm) / 
                    (plani.platot)).
            end.
            else tt-venda.tipvenda = "Vista".

            find last bmovim where bmovim.procod = movim.procod and
                                   bmovim.movtdc = 4 and
                                   bmovim.movdat < movim.movdat
                       no-lock no-error.
            if avail bmovim
            then do:
                assign 
                    tt-venda.valcusto = bmovim.movpc
                    tt-venda.valicmsp = bmovim.movicms / bmovim.movqtm
                    tt-venda.pcticmsp = bmovim.movalicms
                    tt-venda.valsubst = bmovim.movsubst / bmovim.movqtm
                    .

            end.

        end.
    end.                    
end.

    def var varquivo as char.
    def var varquivo-csv as char.
    varquivo = "/admcom/relat/relstvenda." + string(time).
    
    varquivo-csv = "/admcom/relat/relstvenda.csv".
    
    output to value(varquivo-csv).
    put "Filial;Data Venda;Produto;Descricao;NCM;MVA;Valor Custo;% ICMS;Valor Icms;Valor Subst;Total Vemda;Tipo Venda;Acrescimo" skip.
    for each tt-venda.
        put unformatted
             tt-venda.etbcod
             tt-venda.pladat
             tt-venda.procod 
             tt-venda.pronom 
             tt-venda.ncm 
             tt-venda.mva
             tt-venda.valcusto 
             tt-venda.pcticmsp
             tt-venda.valicmsp
             tt-venda.valsubst
             tt-venda.valvenda
             tt-venda.tipvenda
             tt-venda.valacres
             skip.
    end.        
    output close.

    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "170" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relstvenda""
                &Nom-Sis   = """""""" 
                &Tit-Rel   = """ VENDAS ST """ 
                &Width     = "170"
                &Form      = "frame f-cabcab"}

    disp with frame f1.
     
    for each tt-venda.
        disp tt-venda.etbcod column-label "Fil"
             tt-venda.numero column-label "Venda"  format ">>>>>>>>9"
             tt-venda.serie  column-label "Serie"  format "x(3)"
             tt-venda.pladat column-label "Data!Venda"
             tt-venda.procod column-label "Produto"
             tt-venda.pronom column-label "Descricao"  format "x(30)"
             tt-venda.ncm    column-label "NCM"
             tt-venda.mva    column-label "MVA"
             tt-venda.valcusto column-label "Valor!Custo"
             tt-venda.pcticmsp column-label "% ICMS"
             tt-venda.valicmsp column-label "Valor!ICMS"
             tt-venda.valsubst column-label "Valor!Subst"
             tt-venda.valvenda column-label "Total!Venda"
             tt-venda.tipvenda column-label "Tipo!Venda"
             tt-venda.valacres column-label "Acrescimo!Venda"
             with frame f-dis down width 180. 
    end.        
    output close.

    run visurel.p(varquivo,"").


