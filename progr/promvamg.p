{admcab.i}
def var vestoq as dec.
def var vindsubst as log format "Sim/Nao".
def var vdtultent as date.
def var vestvenda as dec.
def var vmovpc as dec.
def var vmovalicms as dec.
def var vmva as dec.
def buffer bclasse for clase. 
def var varquivo as char.
def temp-table tt-mva
    field clafis as int  format ">>>>>>>>9"
    field mvaint as dec
    field mvaext as dec
    .
def var v as char format "x(15)".
def var vlinha as char.
def var varqlog as char.
varqlog = "/admcom/logs/importa-mva-arquivo-margem-" + string(time) 
            + ".log".

output to value(varqlog).

input from /admcom/custom/novomva1.csv.
repeat:
    import unformatted vlinha.
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(3,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/ferramentas.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/ferra.csv.
repeat:
    import unformatted vlinha.
    find first tt-mva where
               tt-mva.clafis = int(entry(1,vlinha,";"))
               no-error.
    if not avail tt-mva
    then do:     
        create tt-mva.
        tt-mva.clafis = int(entry(1,vlinha,";")).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(3,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/eletronicos-eletroeletronicos.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.
 
input from /admcom/custom/eletro.csv.
repeat:
    import unformatted vlinha.
    find first tt-mva where
               tt-mva.clafis = int(entry(1,vlinha,";"))
               no-error.
    if not avail tt-mva
    then do: 
        create tt-mva.
        tt-mva.clafis = int(entry(1,vlinha,";")).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(3,vlinha,";")) / 100.
    end.
end.
input close.   
input from /admcom/custom/produtoscuston.csv.
repeat:
    import unformatted vlinha.
    find first tt-mva where
               tt-mva.clafis = int(entry(4,vlinha,";"))
               no-error.
    if not avail tt-mva
    then do: 
        create tt-mva.
        tt-mva.clafis = int(entry(4,vlinha,";")).
        tt-mva.mvaint = dec(entry(5,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(6,vlinha,";")) / 100.
    end.
end.
input close.
input from /admcom/custom/produtoscustom.csv.
repeat:
    import unformatted vlinha.
    find first tt-mva where
               tt-mva.clafis = int(entry(4,vlinha,";"))
               no-error.
    if not avail tt-mva
    then do: 
        create tt-mva.
        tt-mva.clafis = int(entry(4,vlinha,";")).
        tt-mva.mvaint = dec(entry(5,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(6,vlinha,";")) / 100.
    end.
end.
input close.   

input from /admcom/custom/Claudir/MVA/instrumentos-musicais.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/mat-construcao.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/mat-eletricos.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/prod-alimenticios.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/artefatos-domesticos.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/artigos-papelasria.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/bicicletas-acessorios.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/brinquedos.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/colchoaria.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

input from /admcom/custom/Claudir/MVA/cosmeticos-perf-higiene-pessoal.csv.
repeat:
    import unformatted vlinha.
    vlinha = replace(vlinha,"%","").
    v = (entry(1,vlinha,";")).
    v = replace(v,".","").
    find first tt-mva where
               tt-mva.clafis = int(v)
               no-error.
    if not avail tt-mva
    then do:           
        create tt-mva.
        tt-mva.clafis = int(v).
        tt-mva.mvaint = dec(entry(2,vlinha,";")) / 100.
        tt-mva.mvaext = dec(entry(2,vlinha,";")) / 100.
    end.
end.
input close.

output close.


create tt-mva.
assign
    tt-mva.clafis = 87120010
    tt-mva.mvaint = 45
    tt-mva.mvaext = 45
    .
create tt-mva.
assign
    tt-mva.clafis = 95030010
    tt-mva.mvaint = 44
    tt-mva.mvaext = 44
    .
create tt-mva.
assign
    tt-mva.clafis = 94042000
    tt-mva.mvaint = 65.16
    tt-mva.mvaext = 75.85
    .

def temp-table tt-produ
    field catcod like produ.catcod
    field procod like produ.procod format ">>>>>>>9"
    field pronom like produ.pronom
    field indsubst as log
    field clacod like clase.clacod
    field clanom like clase.clanom
    field subcod like clase.clacod
    field subnom like clase.clanom
    field fabcod like fabri.fabcod format ">>>>>>>>9"
    field fabnom like fabri.fabnom
    field ultent as date           format "99/99/9999"
    field mva as dec               
    field estatual like estoq.estatual   format ">>>>>9"
    field estvenda like estoq.estvenda
    field estcusto like estoq.estcusto
    field ICMSEnt  as dec
    field ICMSSai  as dec
    field PisEnt   as dec
    field PisSai   as dec
    field Cofinsent as dec
    field Cofinssai as dec
    field q-venda90 as dec format ">>>>>9"
    field v-venda90 as dec format ">>>,>>>,>>9.99"
    field pipi as dec
    index i1 catcod procod.
    
def var val-venda90 as dec.
def var qtd-venda90 as dec.
def var vqtd as int.    
def var vestcusto like estoq.estcusto.
def var vp-ipi as dec.

varquivo = "/admcom/relat/promvamg" + string(time) + ".csv".

update varquivo label "Arquivo gerar" format "x(60)"
        with side-label width 80.
                
if varquivo = ""
then return.

sresp = no.

message "Confirma gerar gerar arquivo ? " update sresp.
if not sresp then return.

for each produ /* where produ.proipiper = 99 and
        produ.procod = 2098*/ no-lock:
    vestoq = 0.
    vestvenda = 0.
    if produ.catcod <> 31 and
       produ.catcod <> 41
    then next.   
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase then next.
    find bclasse where bclasse.clacod = clase.clasup no-lock no-error.
    if not avail bclasse then next.
    find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
    if not avail fabri then next.
    find clafis where clafis.codfis = produ.codfis no-lock no-error.
    if not avail clafis then next.
 
    disp "processando...." produ.procod produ.pronom
        with frame f-disp 1 down row 10 centered no-box
        color message no-label.
    pause 0.    
    vestcusto = 0.
    for each estab no-lock:
    
        for each estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod
                         no-lock:
            vestoq = vestoq + estoq.estatual.
            if estoq.etbcod = 1
            then do:
                vestvenda = estoq.estvenda.
                /*
                if estoq.estprodat <> ? and
                   estoq.estprodat >= today
                then vestvenda = estoq.estproper.    
                */
                if estoq.estbaldat <> ? and
                   estoq.estprodat <> ?
                then do:
                    if estoq.estbaldat <= today and
                       estoq.estprodat >= today
                    then vestvenda = estoq.estproper.
                end.
                else do:
                    if estoq.estprodat <> ?
                    then if estoq.estprodat >= today
                            then vestvenda = estoq.estproper.
                end.
            end.
            if estoq.estcusto > vestcusto
            then vestcusto = estoq.estcusto.
        end.
    end.    
    if vestoq <= 0
    then next.

    vindsubst = no.
    if produ.proipiper = 99
    then vindsubst = yes.                                
    vmovpc = 0.
    vmovalicms = 0.
    vdtultent = ?.
    vp-ipi = 0.
    find last movim where movim.procod = produ.procod and
                          movim.movtdc = 4 no-lock no-error.
    if avail movim 
    then assign
            vmovpc = movim.movpc
            vmovalicms = movim.movalicms
            vdtultent = movim.movdat
            vp-ipi = movim.movalipi
            .
    if vestcusto > 0
    then vmovpc = vestcusto.
    
    if vmovpc = 0
    then assign
            vmovpc = vestcusto
            vmovalicms = 12.        
    
    find first estoq of produ no-lock no-error.
    if not avail estoq then next.
    vestcusto = estoq.estcusto.
    vmva = 0.
    find forne where forne.forcod = movim.emite no-lock no-error.
    if not avail forne
    then find forne where forne.forcod = produ.fabcod no-lock no-error.
    if avail forne  and produ.proipiper = 99
    then do:
        find first tt-mva where 
               tt-mva.clafis = clafis.codfis no-error.
        if not avail tt-mva
        then find first tt-mva where
                  tt-mva.clafis = int(substr(string(clafis.codfis),1,6))
                                no-error.
        if not avail tt-mva
        then find first tt-mva where
                  tt-mva.clafis = int(substr(string(clafis.codfis),1,5))
                                no-error.
        if not avail tt-mva
        then find first tt-mva where
                  tt-mva.clafis = int(substr(string(clafis.codfis),1,4))
                                no-error.
 
        if avail tt-mva
        then do:
            if forne.ufecod = "RS"
            then vmva = tt-mva.mvaint.
            else vmva = tt-mva.mvaext.
        end.            
    end.
 
    val-venda90 = 0.
    qtd-venda90 = 0.
    for each movim where movim.movtdc = 5 and
                         movim.procod = produ.procod and
                         movim.movdat >= today - 90
                         no-lock.
        val-venda90 = val-venda90 + (movim.movpc * movim.movqtm).
        qtd-venda90 = qtd-venda90 + movim.movqtm.
    end.                     
    find first tt-produ where
               tt-produ.catcod = produ.catcod and
               tt-produ.procod = produ.procod
               no-error.
    if not avail tt-produ
    then do:
        create tt-produ.
        assign
            tt-produ.catcod = produ.catcod
            tt-produ.procod = produ.procod
            tt-produ.pronom = produ.pronom
            tt-produ.indsubst = vindsubst    
            tt-produ.clacod = bclasse.clacod
            tt-produ.clanom = bclasse.clanom
            tt-produ.subcod = clase.clacod
            tt-produ.subnom = clase.clanom
            tt-produ.fabcod = fabri.fabcod
            tt-produ.fabnom = fabri.fabnom
            tt-produ.ultent = vdtultent
            tt-produ.mva    = vmva
            tt-produ.estatual = vestoq
            tt-produ.estvenda = vestvenda
            tt-produ.estcusto = vestcusto
            tt-produ.icmsent = vmovalicms
            tt-produ.icmssai = produ.proipiper
            tt-produ.pisent  = clafis.pisent
            tt-produ.pissai  = clafis.pissai
            tt-produ.cofinsent = clafis.cofinsent
            tt-produ.cofinssai = clafis.cofinssai
            tt-produ.v-venda90 = val-venda90
            tt-produ.q-venda90 = qtd-venda90
            tt-produ.pipi = vp-ipi
            .
    end.
    /*
    vqtd = vqtd + 1.
    if vqtd = 50
    then leave.
    */
end.
/*    
message "Arquivo". pause.
*/

/*
varquivo = "/admcom/relat/arq-margem-" + string(time) + ".csv".
*/

output to value(varquivo).
do:
put skip(2)
    "Categoria;" 
    "Codigo;"
    "Descricao;"
    "Subst;"
    "Classe;" 
    "Nome;"
    "Sub-Classe;"
    "Nome;"
    "Fabricante;" 
    "Nome;"
    "UltEnt;"
    "MVA;"
    "Estoque;"
    "Venda;"
    "Nota;" 
    "ICMSCompra;"
    "ICMSenda;"
    "PisEnta;"
    "PisSai;"
    "CofinsEnt;"
    "CofinsSai;"
    "QtdVenda90;"
    "ValVenda90;" 
    "% IPI;" 
         skip.
end.
for each tt-produ no-lock:

    put  tt-produ.catcod ";"
         tt-produ.procod ";"
         tt-produ.pronom ";"
         tt-produ.indsubst ";"
         tt-produ.subcod ";"
         tt-produ.subnom ";"
         tt-produ.clacod   ";"
         tt-produ.clanom   ";"
         tt-produ.fabcod  ";"
         tt-produ.fabnom  ";"
         tt-produ.ultent  ";"
         tt-produ.mva          ";"
         tt-produ.estatual     ";"
         tt-produ.estvenda     ";"
         tt-produ.estcusto    ";"
         tt-produ.icmsent    ";"
         tt-produ.icmssai ";"
         tt-produ.pisent   ";"
         tt-produ.pissai   ";"
         tt-produ.cofinsent ";"
         tt-produ.cofinssai ";"
         tt-produ.q-venda90 ";"
         tt-produ.v-venda90 ";" 
         tt-produ.pipi ";"
          skip.
end.

output close.

message color red/with
 "Arquivo gerado: " varquivo
view-as alert-box .

/*
run visurel.p(varquivo,"").
*/

         
                                        
