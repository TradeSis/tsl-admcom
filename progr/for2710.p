{admcab.i new}                                          
def var recimp as recid.
def var fila as char.

def var v-icmsubst like plani.platot.
def var v-custotal like plani.platot.

def new shared var v-im as log format "Tela/Impressora".

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.
    
def buffer xclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def var vclacod like clase.clacod.
def var vclasup like clase.clasup.
def new shared temp-table tt-produ
    field procod like produ.procod
    field fabcod like produ.fabcod
    field pronom like produ.pronom.
    
    
def var vdt like plani.pladat.
def var x as i.
def var vimp as log format "80/132" label "Impressao".
def var vmovqtmcar as char format "x(4)".
def var vtotger as i.
def buffer cestoq for estoq.
def var vtotest     like estoq.estatual.
def var vmargen     as dec format "->>9".
def var vultcomp    as date format "99/99/9999".
def var vmovqtm     like movim.movqtm.
def var i           as int.
def var vaux        as int.
def var vano        as int.
def var vtotcomp    like himov.himqtm extent 12.
def var vforcod     like fabri.fabcod.
def var vcatcod     like categoria.catcod.
def var vlin        as int initial 0.
def var varquivo    as char format "X(20)". 
def buffer bestoq   for estoq.
def var vcomcod     like compr.comcod.

define            variable vmes  as char format "x(03)" extent 12 initial
    ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].

def var vmes2 as char format "x(3)" extent 12.

def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.



def temp-table ttfor
        field pronom   like produ.pronom format "x(36)"
        field procod   like produ.procod
        field clacod   like clase.clacod
        field clanom   like clase.clanom
        field estvenda like estoq.estvenda format ">>>9"
        field datexp   like estoq.datexp   format "99/99/9999"
        field totest   like vtotest format "->>>9"
        field margen   like vmargen
        field ultcomp  like vultcomp format "99/99/9999"
        field estcusto like estoq.estcusto format ">>>9.99"
        field custotal like plani.platot 
        field icmsubst like plani.platot
        field movqtmcar like vmovqtmcar format "x(4)" 
        field totcomp like himov.himqtm format ">>>9" extent 12.

def stream stela.

for each tt-produ:
    delete tt-produ.
end.

update vforcod label "Fornecedor" colon 15
                        with frame f-for centered side-label
                                                    color white/red row 4.
find fabri where fabri.fabcod = vforcod no-lock.
disp fabri.fabnom no-label with frame f-for.
update vcatcod label "Departamento" colon 15 with frame f-for.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom no-label with frame f-for.

vdt = today - 365.
update vdt label "Ultima Compra" colon 15 with frame f-for.

update vclacod at 01 label "Classe" with frame f-dat side-label.
if vclacod = 0
then display "GERAL" @ xclase.clanom with frame f-dat.
else do:
    find xclase where xclase.clacod = vclacod no-lock.
    display xclase.clanom no-label with frame f-dat.
end.

update vcomcod at 3 label "Comprador" format ">>>9"
               with frame f1 centered color blue/cyan row 12 side-labels.

find first compr where compr.comcod = vcomcod
                   and vcomcod > 0  no-lock no-error.
                   
if avail compr then display compr.comnom format "x(27)" no-label
                         with frame f1.
else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                             with frame f1.
else do:
                            
     message "Comprador não encontrado!" view-as alert-box.
     undo, retry.
     
end.
  
 
if opsys = "UNIX"
then do:
    v-im = yes.
    message "Gerar relatorio em tela ou impressora? " update v-im.
    if not v-im
    then do:
        /*********
        disp " Prepare a Impressora para Imprimir Relatorio e pressione ENTER"
                            with frame f-imp centered row 10.
        pause.
        message "Imprimindo Relatorio... Aguarde".

        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)
        **********/
        
        varquivo = "/admcom/relat/for" + string(time).

        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.    
    
    
    end. 
    else assign varquivo = "/admcom/relat/for" + string(time)
                fila = "".
end.
else assign fila = ""
            varquivo = "l:\relat\for" + string(time).

for each tt-clase:
    delete tt-clase.
end.    

for each ttfor. delete ttfor. end. 

find first clase where clase.clasup = vclacod no-lock no-error.
if avail clase
then
    run cria-tt-clase.
else do:
    create tt-clase. 
    assign tt-clase.clacod = vclacod 
           tt-clase.clanom = xclase.clanom when avail xclase.
end.
 

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "64"
        &Nom-Rel   = ""for0506""
        &Nom-Sis   = """SISTEMA DE ESTOQUE - ENTRADAS"""
        &Tit-Rel   = """INFORMACOES P/ COMPRA - FORNECEDORES: "" +
                        string(fabri.fabcod,"">>>>>9"") + "" "" + 
                        string(fabri.fabnom,""x(25)"")"
        &Width     = "181"
        &Form      = "frame f-cab"}


vaux    = month(today).
vano    = year(today).
do i = 1 to 12:
    vaux = vaux - 1.
    if vaux = 0
    then do:
        vmes2[i] = "DEZ".
        vaux = 12.
        vano = vano - 1.
    end.
    vmes2[i] = vmes[vaux].
    vnummes[i] = vaux.
    vnumano[i] = vano.
end.

put
"DESCRICAO                                  CODIGO   "
".................................."
skip.

for each tt-clase no-lock,

    each produ where produ.catcod = (if vcatcod <> 0
                                     then vcatcod
                                     else produ.catcod)
                 and produ.fabcod = (if vforcod <> 0
                                     then vforcod
                                     else produ.fabcod)
                 and produ.clacod = tt-clase.clacod no-lock
                            break by tt-clase.clacod
                                  by tt-clase.clanom
                                  by produ.pronom
                                  by produ.procod.
    
    if vcomcod > 0
    then do:
        release liped.
        release pedid.
        find last liped where liped.procod = produ.procod
                          and liped.pedtdc = 1
                                no-lock use-index liped2 no-error.

        find first pedid of liped no-lock no-error.
      
        if (avail pedid and pedid.comcod <> vcomcod)
            or not avail pedid
        then next.
                    
    end.
         
    /****
    if first-of(tt-clase.clacod)
    then do: 
        vlin = vlin + 2.
        disp tt-clase.clacod
             tt-clase.clanom no-label with frame f-fab side-label.
    end.
    ****/

    vultcomp = 01/01/1999.
    
    find last movim where movim.movtdc = 4 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim
    then vultcomp = movim.movdat.
        
    find last movim where movim.movtdc = 1 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim 
    then do:     
        if movim.movdat > vultcomp and 
           vultcomp <> ?
        then vultcomp = movim.movdat.
    end. 

    if produ.fabcod = 5027
    then do:
        find last movim where movim.movtdc = 6
                          and movim.procod = produ.procod
                          and movim.emite = 22
                          and (movim.desti = 996 or
                               movim.desti = 995) no-lock no-error.
        if avail movim
        then vultcomp = movim.movdat.
    end.
    
    if vultcomp = ? or 
       vultcomp < vdt
    then do:
        find first tt-produ where tt-produ.procod = produ.procod no-error.
        if not avail tt-produ
        then do: 
            create tt-produ.
            assign tt-produ.procod = produ.procod
                   tt-produ.pronom = produ.pronom
                   tt-produ.fabcod = produ.fabcod.
        end.
        next.
    end.    
        
    vtotest = 0.
    for each estab no-lock:
        for each bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock.
            vtotest = vtotest + bestoq.estatual.
        end.
    end.    
    find last estoq of produ no-lock no-error. 
    if not avail estoq 
    then next. 

    /*
    find last movim where movim.movtdc = 4 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim
    then vultcomp = movim.movdat.
             
    find last movim where movim.movtdc = 1 and
                          movim.procod = produ.procod no-lock no-error.
    if avail movim 
    then do: 
        if movim.movdat > vultcomp and vultcomp <> ?
        then vultcomp = movim.movdat.
    end. 
    */
    /* antonio - Custo da Substituicao Tributaria */
    assign v-icmsubst = 0
           v-custotal = 0.
    run Pi-acha-icm-substitu(output v-icmsubst).   
    /**/
    
    vmovqtm = 0.
    
    for each estab where estab.etbcod >= /*94*/ 993 no-lock:
    
        if estab.etbcod >= 900 and estab.etbcod < 993 then next.
    
        find himov where himov.etbcod = estab.etbcod and
                         himov.procod = produ.procod and
                         himov.movtdc = 4            and
                         himov.himmes = month(today) and
                         himov.himano = year(today) no-lock no-error.
        if not avail himov
        then next.
        vmovqtm = vmovqtm + HIMOV.HIMQTM.
    end.


    VTOTGER = 0. 
    do i = 1 to 12: 
        vtotcomp[i] = 0.
    
        for each estab where estab.etbcod >= /*94*/ 993 no-lock:
        
            if estab.etbcod >= 900 and estab.etbcod < 993 then next.

            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]   and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.

            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            VTOTGER = VTOTGER + HIMOV.HIMQTM.
        end.
    
    end.
    
    
    if produ.fabcod = 5027
    then do:
       do i = 1 to 12: 
            vtotcomp[i] = 0.
 
            for each movim where movim.procod = produ.procod
                             and movim.movtdc = 6
                             and movim.emite = 22
                             and movim.desti = 995 no-lock:

                if month(movim.movdat) = vnummes[i] and
                   year(movim.movdat)  = vnumano[i]
                then 
                    vtotcomp[i] =  vtotcomp[i] + movim.movqtm.
            
                vtotger = vtotger + movim.movqtm.
            
            end.
            for each movim where movim.procod = produ.procod
                             and movim.movtdc = 6
                             and movim.emite = 22
                             and movim.desti = 996 no-lock:

                if month(movim.movdat) = vnummes[i] and
                   year(movim.movdat)  = vnumano[i]
                then 
                    vtotcomp[i] =  vtotcomp[i] + movim.movqtm.
            
                vtotger = vtotger + movim.movqtm.
            
            end.

       end. 
    end.
    
    if vforcod = 5412
    then do:
        if vtotest = 0 and
           vultcomp = ? and
           vtotger  = 0
        then next.
    end.        


    /****output stream stela close.****/
    
    vlin = vlin + 1.
    vmargen = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
    if vmovqtm <= 0
    then vmovqtmcar = " ".
    else vmovqtmcar = string(vmovqtm).
          
    
    find first ttfor where ttfor.procod = produ.procod no-error.
    if not avail ttfor
    then do:
        create ttfor.
        assign ttfor.procod = produ.procod
               ttfor.pronom = produ.pronom
               ttfor.clacod = tt-clase.clacod
               ttfor.clanom = tt-clase.clanom
               ttfor.estvenda = estoq.estvenda
               ttfor.datexp = estoq.datexp
               ttfor.totest = vtotest
               ttfor.margen = vmargen
               ttfor.ultcomp = vultcomp
               ttfor.icmsubst = v-icmsubst
               ttfor.custotal = estoq.estcusto + v-icmsubst
               ttfor.estcusto = estoq.estcusto
               ttfor.movqtmcar = vmovqtmcar
               ttfor.totcomp[1] = vtotcomp[1]
               ttfor.totcomp[2] = vtotcomp[2]
               ttfor.totcomp[3] = vtotcomp[3]
               ttfor.totcomp[4] = vtotcomp[4]
               ttfor.totcomp[5] = vtotcomp[5]
               ttfor.totcomp[6] = vtotcomp[6]
               ttfor.totcomp[7] = vtotcomp[7]
               ttfor.totcomp[8] = vtotcomp[8]
               ttfor.totcomp[9] = vtotcomp[9]
               ttfor.totcomp[10] = vtotcomp[10]
               ttfor.totcomp[11] = vtotcomp[11]
               ttfor.totcomp[12] = vtotcomp[12].
    
    end.
    
end.

    for each ttfor break by ttfor.clacod
                         by ttfor.clanom
                         by ttfor.pronom
                         by ttfor.procod:
                         
        if first-of(ttfor.clacod)
        then do: 
            disp ttfor.clacod
                 ttfor.clanom no-label with frame f-fab side-label.
        end.

        
        put skip 
            ttfor.pronom format "x(50)"
            ttfor.procod space(1) 
          /*  ttfor.estvenda format ">>>9" space(1) 
            ttfor.datexp   format "99/99/9999" space(1)
            ttfor.totest format "->>>9" space(1)
            ttfor.margen space(1)
            ttfor.ultcomp format "99/99/9999" space(1)
            ttfor.estcusto format ">>>9.99" space(1)
            ttfor.movqtmcar   format "x(4)" space(1)
            ttfor.icmsubst    format ">>>9.99" space(1)
            ttfor.custotal    format ">>>9.99" space(1)
            ttfor.totcomp[1]  format ">>>>9" space(1)
            ttfor.totcomp[2]  format ">>>>9" space(1)
            ttfor.totcomp[3]  format ">>>>9"  space(1)
            ttfor.totcomp[4]  format ">>>>9"  space(1)
            ttfor.totcomp[5]  format "->>>9"  space(1)
            ttfor.totcomp[6]  format ">>>>9"  space(1)
            ttfor.totcomp[7]  format ">>>>9"  space(1)
            ttfor.totcomp[8]  format ">>>>9"  space(1)
            ttfor.totcomp[9]  format ">>>>9"  space(1)
            ttfor.totcomp[10] format ">>>>9" space(1)
            ttfor.totcomp[11] format ">>>>9" space(1)
            ttfor.totcomp[12] format ">>>>9" */ .
                             
                         
    end.                         

output close.


/* 
output close.
run visurel.p (input varquivo, input "").
*/

if opsys = "unix"
then do:
    if v-im 
    then run visurel.p (input varquivo, input "").
    else os-command silent lpr value(fila + " " + varquivo).
end.
else do:
    
    {mrod.i}.

    /* os-command silent type value(varquivo) > prn. */
end.

message "Deseja Imprimir todos os produtos" update sresp.
if sresp
then do:
    find first tt-produ no-error.
    if avail tt-produ
    then run for0507.p(input vimp).  
end.


procedure cria-tt-clase.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-clase where tt-clase.clacod = gclase.clacod no-error.
                             if not avail tt-clase
                             then do:
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom.
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.    


Procedure Pi-acha-icm-substitu.

def output parameter p-icm-subst like plani.platot.
def var v-item like plani.protot.

find last movim where movim.movtdc = 4 and
                      movim.procod = produ.procod no-lock no-error.
if not avail movim then leave.

find first plani where plani.etbcod = movim.etbcod and
                       plani.placod = movim.placod and
                       plani.movtdc = movim.movtdc and
                       plani.pladat = movim.movdat
                       no-lock no-error.
if not avail plani then leave.

v-item = movim.movpc * movim.movqtm.
 
p-icm-subst = (v-item * plani.icmssubst) / plani.protot.

p-icm-subst = p-icm-subst / movim.movqtm.


end.    
