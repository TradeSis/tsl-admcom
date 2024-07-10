{admcab.i}
/***************************************************************************/
/* 09/05/2007 - Incluir Fabricante e Fornecedor na Seleção da tela 14729   */
/*            - Virginia                                                   */
/* 14/05/2007 - Falei com Julio e ele definiu só fornecedor  na seleção    */
/* 29/05/2007 - Rafael solicita lay-out original                           */
/* 20/04/2009 - Criação de analitico clase e produto                       */
/***************************************************************************/

def var recimp   as recid.
def var vtelaf   as log format "Tela/Impressora".
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vfabcod  like produ.fabcod.
def var vforcod  like forne.forcod.
def var vfornome like forne.fornom.
def var vcusto   as   dec.
def var fila           as char.
def var varquivo       as char.
def var v-filtro-doa   as logical format "Sim/Nao" initial no.

def new shared temp-table tw-assist-ger
field clfcod         like forne.forcod
field fornome        as char format "x(25)"
field os-total       as int
field v-os-total     like plani.platot                                      
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.

def new shared temp-table tw-assist-cla no-undo
field clacod         like clase.clacod
field clanom         like clase.clanom
field os-total       as int
field v-os-total     like plani.platot 
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.

def new shared temp-table tw-assist-fabri no-undo
field fabcod         like fabri.fabcod
field fabnom         like fabri.fabnom
field os-total       as int
field v-os-total     like plani.platot 
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.

def new shared temp-table tw-assist-pro no-undo
field procod         like produ.procod
field pronom         like produ.pronom
field os-total       as int
field v-os-total     like plani.platot 
field os-pend        as int
field v-os-pen       like plani.platot
field os-sol         as int
field v-os-sol       like plani.platot 
field os-15          as int
field v-os-15        like plani.platot
field os-20          as int
field v-os-20        like plani.platot
field os-30          as int
field v-os-30        like plani.platot
field os-cli         as int
field v-os-cli       like plani.platot
field os-est         as int
field v-os-est       like plani.platot
field os-pencli      as int
field v-os-pencli    like plani.platot
field os-solcli      as int
field v-os-solcli    like plani.platot
field os-penest      as int
field v-os-penest    like plani.platot
field os-solest      as int
field v-os-solest    like plani.platot
field os-fornec      as int
field v-os-fornec    like plani.platot 
field os-fabri       as int   
field v-os-fabri     like plani.platot
field os-penfornec   as int
field v-os-penfornec like plani.platot
field os-penfabri    as int
field v-os-penfabri  like plani.platot.


repeat:
    
  for each tw-assist-pro:
        delete tw-assist-pro.
  end.
 
  for each tw-assist-cla:
        delete tw-assist-cla.
  end.           

  for each tw-assist-ger:
        delete tw-assist-ger.
  end.         

  update vetbcod label "Filial      " colon 13
                with frame f1 side-label width 80.

    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    
    update vdti label "Data Inicial" colon 13
           vdtf label "Data Final  " colon 13 with frame f1.
   
    update vfabcod label "Fabricante  " colon 13 with frame f1.
    if vfabcod > 0
    then do:
        find fabri where fabri.fabcod = vfabcod no-lock no-error.
        if not avail fabri
        then do:
            message "Fabricante invalido" view-as alert-box.
            undo.
        end.
        disp fabri.fabnom no-label with frame f1.
    end.        
    else display "GERAL" @ fabri.fabnom no-label with frame f1.

    update vforcod label "Fornecedor  " colon 13 with frame f1.
    if vforcod > 0
    then do:                 
        find forne where forne.forcod = vforcod no-lock no-error.       
        if not avail forne                                                  
        then do:
            message "Fornecedor invalido" view-as alert-box.
            undo.
        end.
        vfornome = forne.fornom.
        disp forne.fornom no-label with frame f1.  
    end.
    else do.
        vfornome = "GERAL".
        display "GERAL" @ forne.fornom no-label with frame f1.
    end.                       

    update v-filtro-doa label "DOA         " colon 13 with frame f1.
    for each estab where (if vetbcod = 0
                          then true
                          else estab.etbcod = vetbcod) no-lock,
        each asstec where asstec.etbcod = estab.etbcod and
                          asstec.dtentdep >= vdti      and
                          asstec.dtentdep <= vdtf      and
                          (if vforcod = 0
                           then true
                           else asstec.forcod = vforcod) no-lock,
        each produ where (if vfabcod = 0  then true
                             else produ.fabcod  = vfabcod) and
                             produ.procod = asstec.procod 
                           no-lock:
        if v-filtro-doa
        then do:
            if not (acha("DOA",asstec.proobs) = "Yes")
            then next.
        end.

        assign vcusto = 0.
        find first estoq where estoq.etbcod = estab.etbcod and
                               estoq.procod  = produ.procod no-lock no-error.
        if avail estoq then assign vcusto = estoq.estcusto.
        
        run pi-gera-temp ( input vforcod, produ.procod, 
                           produ.clacod, vcusto, produ.fabcod ).
    end.

    run relass_a.p (input vdti , vdtf, vforcod, vetbcod).
    
end.           
    
procedure pi-gera-temp.
       
def input parameter p-forcod like  forne.forcod.
def input parameter p-procod like produ.procod.
def input parameter p-clacod like clase.clacod.
def input parameter p-custo  like estoq.estcusto.
def input parameter p-fabcod like fabri.fabcod.

  /* Geral */
  find first tw-assist-ger where 
             tw-assist-ger.clfcod =  p-forcod no-error.
  if not avail tw-assist-ger
  then do:
                find forne where forne.forcod = p-forcod no-lock no-error.
                create tw-assist-ger.  
                assign tw-assist-ger.clfcod = p-forcod
                       tw-assist-ger.fornom = (if p-forcod <> 0 
                                              then forne.fornom else "Geral").
  end.                                            
  
  /* Classe */
  find first tw-assist-cla where 
                    tw-assist-cla.clacod =  p-clacod no-error.
  if not avail tw-assist-cla
  then do:
                find clase where clase.clacod = p-clacod no-lock no-error.  
                create tw-assist-cla.
                assign tw-assist-cla.clacod = p-clacod
                       tw-assist-cla.clanom = clase.clanom.
   end.

  /* Fabricante */
  find first tw-assist-fabri where 
                    tw-assist-fabri.fabcod =  p-fabcod no-error.
  if not avail tw-assist-fabri
  then do:
                find fabri where fabri.fabcod = p-fabcod no-lock no-error.  
                create tw-assist-fabri.
                assign tw-assist-fabri.fabcod = p-fabcod
                       tw-assist-fabri.fabnom = fabri.fabnom.
   end.

  /* Produto */
  find first tw-assist-pro where 
             tw-assist-pro.procod =  p-procod no-error.
  if not avail tw-assist-pro
  then do:
                create tw-assist-pro.
                assign tw-assist-pro.procod  = produ.procod
                       tw-assist-pro.pronom  = produ.pronom.
   end.

   assign tw-assist-ger.os-total   = tw-assist-ger.os-total + 1
          tw-assist-ger.v-os-total = tw-assist-ger.v-os-total + p-custo
          tw-assist-cla.os-total   = tw-assist-cla.os-total + 1
          tw-assist-cla.v-os-total = tw-assist-cla.v-os-total + p-custo
          tw-assist-fabri.os-total   = tw-assist-fabri.os-total + 1
          tw-assist-fabri.v-os-total = tw-assist-fabri.v-os-total + p-custo
          tw-assist-pro.os-total   = tw-assist-pro.os-total + 1
          tw-assist-pro.v-os-total = tw-assist-pro.v-os-total + p-custo.
                
  if asstec.clicod = 0
  then do:
          assign  tw-assist-ger.os-est = tw-assist-ger.os-est + 1
                  tw-assist-ger.v-os-est = tw-assist-ger.v-os-est + p-custo
                  tw-assist-cla.os-est = tw-assist-cla.os-est + 1
                  tw-assist-cla.v-os-est = tw-assist-cla.v-os-est + p-custo
                  tw-assist-fabri.os-est = tw-assist-fabri.os-est + 1
                  tw-assist-fabri.v-os-est = tw-assist-fabri.v-os-est + p-custo
                   tw-assist-pro.os-est = tw-assist-pro.os-est + 1
                  tw-assist-pro.v-os-est = tw-assist-pro.v-os-est + p-custo.
  end.
  else do: 
          assign  tw-assist-ger.os-cli = tw-assist-ger.os-cli + 1
                  tw-assist-ger.v-os-cli = tw-assist-ger.v-os-cli + p-custo                      tw-assist-cla.os-cli = tw-assist-cla.os-cli + 1
                  tw-assist-cla.v-os-cli = tw-assist-cla.v-os-cli + p-custo
                  tw-assist-fabri.os-est = tw-assist-fabri.os-est + 1
                  tw-assist-fabri.v-os-est = tw-assist-fabri.v-os-est + p-custo
                  tw-assist-pro.os-cli = tw-assist-pro.os-cli + 1
                  tw-assist-pro.v-os-cli = tw-assist-pro.v-os-cli + p-custo.
  end. 

  if asstec.dtenvfil = ?      /* Data de envio para filial */
  then do:
            /* Pendente */
            assign tw-assist-ger.os-pend = tw-assist-ger.os-pend + 1
                   tw-assist-ger.v-os-pen = tw-assist-ger.v-os-pen + p-custo 
                   tw-assist-cla.os-pend = tw-assist-cla.os-pend + 1 
                   tw-assist-cla.v-os-pen = tw-assist-cla.v-os-pen + p-custo
                   tw-assist-fabri.os-pend = tw-assist-fabri.os-pend + 1 
                   tw-assist-fabri.v-os-pen = tw-assist-fabri.v-os-pen + p-custo
                   tw-assist-pro.os-pend = tw-assist-pro.os-pend + 1
                   tw-assist-pro.v-os-pen = tw-assist-pro.v-os-pen + p-custo. 
            if asstec.clicod = 0                
            then assign        /*  Pendente de Estoque */
                tw-assist-ger.os-penest = tw-assist-ger.os-penest + 1 
                tw-assist-ger.v-os-penest = tw-assist-ger.v-os-penest + p-custo
                tw-assist-cla.os-penest = tw-assist-cla.os-penest + 1 
                tw-assist-cla.v-os-penest = tw-assist-cla.v-os-penest + p-custo
                tw-assist-fabri.os-penest = tw-assist-fabri.os-penest + 1 
                tw-assist-fabri.v-os-penest = 
                                        tw-assist-fabri.v-os-penest + p-custo
                tw-assist-pro.os-penest = tw-assist-pro.os-penest + 1 
                tw-assist-pro.v-os-penest = tw-assist-pro.v-os-penest + p-custo.
            else assign       /*  Pendente de Cliente */
                 tw-assist-ger.os-pencli = tw-assist-ger.os-pencli + 1
                 tw-assist-ger.v-os-pencli = tw-assist-ger.v-os-pencli + p-custo
                 tw-assist-cla.os-pencli = tw-assist-cla.os-pencli + 1 
                 tw-assist-cla.v-os-pencli = tw-assist-cla.v-os-pencli + p-custo                  tw-assist-fabri.os-pencli   = tw-assist-fabri.os-pencli + 1 
                 tw-assist-fabri.v-os-pencli = 
                                      tw-assist-fabri.v-os-pencli + p-custo
                 tw-assist-pro.os-pencli = tw-assist-ger.os-pencli + 1
                 tw-assist-pro.v-os-pencli = tw-assist-ger.v-os-pencli + 1.
                 if asstec.forcod = 0
                 then assign 
                 tw-assist-ger.os-penfornec = tw-assist-ger.os-penfornec + 1
                 tw-assist-ger.v-os-penfornec = tw-assist-ger.v-os-penfornec 
                                                + p-custo
                 tw-assist-ger.os-penfabri  = tw-assist-ger.os-penfabri  + 1
                 tw-assist-ger.v-os-penfabri  = tw-assist-ger.v-os-penfabri  
                                                + p-custo
                 tw-assist-cla.os-penfornec = tw-assist-cla.os-penfornec + 1
                 tw-assist-cla.v-os-penfornec = tw-assist-cla.v-os-penfornec  
                                                + p-custo
                 tw-assist-cla.os-penfabri  = tw-assist-cla.os-penfabri  + 1
                 tw-assist-cla.v-os-penfabri  = tw-assist-cla.v-os-penfabri   
                                                + p-custo
                 tw-assist-fabri.os-penfornec = tw-assist-fabri.os-penfornec + 1
                 tw-assist-fabri.v-os-penfornec = tw-assist-fabri.v-os-penfornec                                                 + p-custo
                 tw-assist-fabri.os-penfabri  = tw-assist-fabri.os-penfabri  + 1
                 tw-assist-fabri.v-os-penfabri = tw-assist-fabri.v-os-penfabri                                                  + p-custo
                 tw-assist-pro.os-penfornec = tw-assist-pro.os-penfornec + 1
                 tw-assist-pro.v-os-penfornec = tw-assist-pro.v-os-penfornec  
                                                + p-custo
                 tw-assist-pro.os-penfabri    = tw-assist-pro.os-penfabri + 1                    tw-assist-pro.v-os-penfabri  = tw-assist-pro.v-os-penfabri 
                                                + p-custo.
  end.
  else do:  
            assign 
            tw-assist-ger.os-sol = tw-assist-ger.os-sol + 1
            tw-assist-ger.v-os-sol = tw-assist-ger.v-os-sol + p-custo
            tw-assist-cla.os-sol = tw-assist-cla.os-sol + 1
            tw-assist-cla.v-os-sol = tw-assist-cla.v-os-sol + p-custo
            tw-assist-fabri.os-sol = tw-assist-fabri.os-sol + 1
            tw-assist-fabri.v-os-sol = tw-assist-fabri.v-os-sol + p-custo
            tw-assist-pro.os-sol = tw-assist-pro.os-sol + 1
            tw-assist-pro.v-os-sol = tw-assist-pro.v-os-sol + p-custo.

            if asstec.clicod = 0
            then assign 
            tw-assist-ger.os-solest = tw-assist-ger.os-solest + 1
            tw-assist-ger.v-os-solest = tw-assist-ger.v-os-solest + p-custo 
            tw-assist-cla.os-solest = tw-assist-cla.os-solest + 1 
            tw-assist-cla.v-os-solest = tw-assist-cla.v-os-solest + p-custo
            tw-assist-fabri.os-solest = tw-assist-fabri.os-solest + 1 
            tw-assist-fabri.v-os-solest = tw-assist-fabri.v-os-solest + p-custo
            tw-assist-pro.os-solest = tw-assist-pro.os-solest + 1
            tw-assist-pro.v-os-solest = tw-assist-pro.v-os-solest + p-custo.
            else assign
            tw-assist-ger.os-solcli = tw-assist-ger.os-solcli + 1 
            tw-assist-ger.v-os-solcli = tw-assist-ger.v-os-solcli + p-custo
            tw-assist-cla.os-solcli = tw-assist-cla.os-solcli + 1 
            tw-assist-cla.v-os-solcli = tw-assist-cla.v-os-solcli + p-custo
            tw-assist-fabri.os-solcli = tw-assist-fabri.os-solcli + 1 
            tw-assist-fabri.v-os-solcli = tw-assist-fabri.v-os-solcli + p-custo
            tw-assist-pro.os-solcli = tw-assist-pro.os-solcli + 1
            tw-assist-pro.v-os-solcli = tw-assist-pro.v-os-solcli + p-custo.
            
            if (asstec.dtenvfil - asstec.dtentdep) <= 15
            then assign tw-assist-ger.os-15 = tw-assist-ger.os-15 + 1
                        tw-assist-ger.v-os-15 = tw-assist-ger.v-os-15 + p-custo
                        tw-assist-cla.os-15 = tw-assist-cla.os-15 + 1
                        tw-assist-cla.v-os-15 = tw-assist-cla.v-os-15 + p-custo
                        tw-assist-fabri.os-15 = tw-assist-fabri.os-15 + 1
                        tw-assist-fabri.v-os-15 = 
                                        tw-assist-fabri.v-os-15 + p-custo
                         tw-assist-pro.os-15 = tw-assist-pro.os-15 + 1
                        tw-assist-pro.v-os-15 = tw-assist-pro.v-os-15 + 1.

            if (asstec.dtenvfil - asstec.dtentdep) <= 20
            then assign tw-assist-ger.os-20 = tw-assist-ger.os-20 + 1
                        tw-assist-ger.v-os-20 = tw-assist-ger.v-os-20 + p-custo
                        tw-assist-cla.os-20 = tw-assist-cla.os-20 + 1
                        tw-assist-cla.v-os-20 = tw-assist-cla.v-os-20 + p-custo
                        tw-assist-fabri.os-20 = tw-assist-fabri.os-20 + 1
                        tw-assist-fabri.v-os-20 = 
                                    tw-assist-fabri.v-os-20 + p-custo
                        tw-assist-pro.os-20 = tw-assist-cla.os-20 + 1
                        tw-assist-pro.v-os-20 = tw-assist-pro.v-os-20 
                                                + p-custo.       
            if (asstec.dtenvfil - asstec.dtentdep) <= 30
            then assign tw-assist-ger.os-30 = tw-assist-ger.os-30 + 1
                        tw-assist-ger.v-os-30 = tw-assist-ger.v-os-30 + p-custo
                        tw-assist-cla.os-30 = tw-assist-cla.os-30 + 1
                        tw-assist-cla.v-os-30 = tw-assist-cla.v-os-30 + p-custo
                        tw-assist-fabri.os-30 = tw-assist-fabri.os-30 + 1
                        tw-assist-fabri.v-os-30 = tw-assist-fabri.v-os-30 
                                                                    + p-custo
                         tw-assist-pro.os-30 = tw-assist-pro.os-30 + 1
                        tw-assist-pro.v-os-30 = tw-assist-pro.v-os-30 + p-custo.
  end. 
end procedure.                                                       
