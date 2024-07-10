{admcab.i }
def var varquivo as char.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var aux-custo as dec. 
def var vcatcod     like produ.catcod.
def var vicms      as dec label "%ICMS".
def var vpis       as dec label "%PIS" .
def var vcofins    as dec label "%COFINS".
def var vfixo      as log label "Percentual" Format "Fixo/Variavel".

def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def var v-desc as char.

def var aux-qtde  like hiest.hiestf.
def var aux-icms  as dec.
def var aux-liq  as dec. 
def var aux-pis  as dec.  
def var aux-cofins  as dec.
def var dtaux as date.

def var vsoma     as char format "x(1)" initial "N"
                         label "Opcao ICMS". 
def temp-table tt-custo     
    field etbcod as int COLUMN-Label "FIL"
    field catcod as int COLUMN-Label "CATEG"
    field estcusto like estoq.estcusto   COLUMN-Label "CUSTO"
    field cusicm      like estoq.estcusto  COLUMN-Label "ICMS"
    field cusliq like estoq.estcusto      COLUMN-Label "CUSTO LIQ"
    field cuspis like estoq.estcusto      COLUMN-Label "PIS"
    field cuscofins like estoq.estcusto    COLUMN-Label "COFINS"
    field cuscont  like estoq.estcusto    COLUMN-Label "EST.CONTABIL"
    index ind1 is primary unique
        etbcod 
        catcod.

   def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

form
    skip 
    vetbi  label   "Filial"  colon 15
    v-desc no-label
    vmes  label     "Mes"    colon 15
    vano  label     "Ano"    colon 15
    vfixo colon 15 "F=Fixo; V=Variavel"
    vpis   colon 15
    vcofins colon 15
    vsoma      colon 20 "A=Somar; D=Subtrair; N=Nenhum"
    with frame f-etb centered 1 down side-labels title "Dados Iniciais" 
                     color white/bronw row 3  width 70.

vmes = month(today).
vano = year(today).    
vetbi = 1.

repeat:
    for each tt-custo:
        delete tt-custo.
    end.
    update vetbi
           with frame f-etb.
    if vetbi = 0
    then v-desc = "Geral".
    else do:
         find estab where estab.etbcod = vetbi no-lock no-error.
         if not avail estab then next.
         v-desc = estab.etbnom.
         
    end.
 
    disp v-desc
         with frame f-etb.           

    update vmes
                validate(vmes > 0 and vmes <= 13," Mes invalido") 
           vano validate(vano > 0, "Ano invalido")
           vfixo
                     with frame f-etb.
    if vfixo /* date(vmes,1,vano) < 01/01/2009 */
    then assign vpis = .65
                vcofins = 3.
    else assign vpis = 0
                 vcofins = 0.
                     
    disp v-desc
         vpis 
         vcofins with frame f-etb.
          
    if vfixo
    then update vpis 
                vcofins with frame f-etb. 

    update vsoma with frame f-etb.
    
    if vmes = 2       
    then dtaux = date(vmes,28,vano).
    else dtaux = date(vmes,28,vano).

  def var v-i as int.       

  for each tt-estab: delete tt-estab. end.

  v-i = 0.
   
  for each estab  where if vetbi = 0 
                         then true
                     else (estab.etbcod = vetbi) 
                     no-lock:
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
   end.

   for each produ no-lock:

       v-i = v-i + 1 .  /* if v-i > 500 then leave. */
       
       run busca-ali.

        find last movim where movim.procod = produ.procod
                               and movim.movtdc = 4
                               and movim.movdat <= dtaux
                            no-lock no-error.
      
       if v-i modulo 100 = 0
       then do: 
            disp  produ.procod  format ">>>>>>>>>>9" 
                  v-i format ">>>>>>9" Label "Lidos"
                    with frame fffpla 
                 centered color white/red.
            pause 0.
       end. 

       for each tt-estab no-lock:

            find hiest where hiest.etbcod = tt-estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes and
                             hiest.hieano = vano no-lock no-error.
            if not avail hiest
            then do:
                 if not can-find( first hiest
                                   where hiest.etbcod = tt-estab.etbcod and
                                         hiest.procod = produ.procod and
                                         hiest.hieano <= vano)
                 then next.

                 find last hiest  use-index i-ano-mes 
                                 where hiest.etbcod = tt-estab.etbcod and
                                       hiest.procod = produ.procod and
                                       hiest.hieano = vano         and
                                       hiest.hiemes <= vmes 
                                       no-lock no-error.
            end.
            if not avail hiest
            then find last hiest use-index i-ano-mes 
                           where hiest.etbcod = tt-estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hieano <= vano 
                                            no-lock no-error.
             if not avail hiest 
             then next.

             if hiest.hiestf = ? then next.
             
             if hiest.hiestf < 0
             then aux-qtde = 0.
             else aux-qtde = hiest.hiestf.

            find first tt-custo where tt-custo.etbcod = tt-estab.etbcod 
                             /* and tt-custo.catcod = produ.catcod */
                            no-error.
            if not avail tt-custo
            then do:
                 create tt-custo.
                 assign tt-custo.etbcod = /* (if vetbi = 0 then 0
                                           else tt-estab.etbcod) */
                                           tt-estab.etbcod
                    /*    tt-custo.catcod = produ.catcod */.
            end.
            
            if avail movim and movim.movalicms <> ?
            then assign vicms = movim.MovAlICMS.
            
            find estoq where estoq.etbcod = tt-estab.etbcod and
                       estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            if estoq.estcusto = ? 
            then next.
        
            if vfixo /* vano < 2009 */
            then .
            else do:
                if int(produ.codfis) = 0
                then assign vpis = 1.65
                            vcofins = 7.6.  
                else do:
                    find clafis where clafis.codfis = produ.codfis
                         no-lock no-error.
                    if not avail clafis
                    then assign vpis = 0
                                vcofins = 0.
                    else do:
                          assign vpis    = clafis.pissai
                                 vcofins = clafis.cofinssai.
                    end.                 
                end.
            end.

            if hiest.hieano = vano and
               hiest.hiemes = vmes 
            then aux-custo = aux-qtde * hiest.hiepcf. 
            else aux-custo = aux-qtde * estoq.estcusto.
                 
            assign 
                   aux-icms  = aux-custo * (vicms / 100)
                   aux-liq  = aux-custo - aux-icms
                   aux-pis  = ((if vano <= 2008 then aux-liq else aux-custo)
                                 * (vpis / 100))
                 aux-cofins = ((if vano <= 2008 then aux-liq else aux-custo)
                                 * (vcofins / 100)).

            assign tt-custo.estcusto = tt-custo.estcusto + aux-custo
                                     + (if vsoma = "A" then aux-icms
                                        else if vsoma = "D" 
                                            then (aux-icms * -1)
                                            else 0)
                   tt-custo.cusicm  = tt-custo.cusicm + aux-icms
                   tt-custo.cusliq  = tt-custo.cusliq + aux-liq
                   tt-custo.cuspis  = tt-custo.cuspis + aux-pis
                   tt-custo.cuscofins = tt-custo.cuscofins + aux-cofins
                   tt-custo.cuscont  = tt-custo.cuscont 
                                     + (aux-custo - aux-icms - aux-pis - 
                                            aux-cofins)
                                     + (if vsoma = "A" then aux-icms 
                                        else if vsoma = "D" 
                                             then (aux-icms * -1)
                                             else  0)       
                                            .

          end.
    end.
  hide frame fffpla no-pause.
  
 if opsys = "UNIX"
 then varquivo = "/admcom/relat/estccont" + string(time).
 else varquivo = "..~\relat~\estccont" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCCONT""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CALCULO PIS COFINS ""
                            + ""   -  Mes/Ano "" 
                            + string(vmes,""99"") + ""/""
                            + string(vano,""9999"")
                            + ""     "" + vsoma "
            &Width     = "100"
            &Form      = "frame f-cabcab"}
  
    for each tt-custo where tt-custo.estcusto > 0
                      break
                      by tt-custo.etbcod
                      by tt-custo.catcod:
        
        disp tt-custo.etbcod format ">>9"
           /*  tt-custo.catcod format ">9" */
             tt-custo.estcusto (total /*  by tt-custo.etbcod */ )
                                format "->>>>>>,>>9.99"
             tt-custo.cusicm (total /* by tt-custo.etbcod */ )
                                format "->>>>,>>9.99"
             tt-custo.cusliq (total /* by tt-custo.etbcod */ )
                                format "->>>>>>,>>9.99"    
             tt-custo.cuspis (total /* by tt-custo.etbcod */ ) 
                        format "->>>>,>>9.99"   
             tt-custo.cuscofins (total /* by tt-custo.etbcod */ )
                        format "->>>>,>>9.99"   
             tt-custo.cuscont (total /* by tt-custo.etbcod */ )
                        format "->>,>>>,>>9.99"   
             
             with frame f-imp width 108 down.
    end.
    put skip(3).
                                                            output close.     

 if opsys = "UNIX"
 then run visurel.p(input varquivo, input "").
 else do:
      {mrod.i}
 end. 

    
end.

procedure busca-ali:
   def var vali as char.
        
       if produ.proipiper = 17 or
          produ.proipiper = 0
       then vali = "01".
       if produ.proipiper = 12.00 or
          produ.pronom begins "Computa"
       then vali = "FF".
       if produ.pronom begins "Pneu" or
          produ.proipiper = 99
       then vali = "FF".
       if produ.proseq = 1
          then vali = "03".
    
        if vali = "01"
        then vicms = 17.
        else if vali = "02"
             then vicms = 12.
             else if vali = "03"
                  then vicms = 7.
                  else if vali = "04"
                       then vicms = 25.
                       else vicms = 0.
                                    
end procedure.


 
