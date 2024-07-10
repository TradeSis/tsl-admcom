{admcab.i new}
/***************************************************************************/
/* 09/05/2007 - Incluir Fabricante e Fornecedor na Seleção da tela 14729   */
/*            - Virginia                                                   */
/* 14/05/2007 - Falei com Julio e ele definiu só fornecedor  na seleção    */
/* 29/05/2007 - Rafael solicita lay-out original                           */
/***************************************************************************/

def var recimp   as recid.
def var vtela    as log format "Tela/Impressora".
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vfabcod  like fabri.fabcod.
def var vforcod  like forne.forcod.
def var vfornome like forne.fornom.
def var os-total       as int.
def var os-pendente    as int.
def var os-solucionado as int.
def var os-15          as int.
def var os-20          as int.
def var os-30          as int.
def var os-cli         as int.
def var os-est         as int.
def var os-solcli      as int.
def var os-solest      as int.
def var os-pencli      as int.
def var os-penest      as int.
def var os-fornec      as int.
def var os-fabri       as int.
def var os-penfornec   as int.
def var os-penfabri    as int.
def var fila           as char.
def var varquivo       as char.

repeat:
    
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
    find fabri where fabri.fabcod = vfabcod no-lock no-error.
    if avail fabri
    then do:
        disp fabri.fabnom no-label with frame f1.
    end.    
    else do:
           if vfabcod = 0
           then display "GERAL" @ fabri.fabnom no-label with frame f1.
            message "Fabricante não Cadastrado !!" view-as alert-box. 
         end.  

    update vforcod label "Fornecedor  " colon 13 with frame f1.                 
    find forne where forne.forcod = vforcod no-lock no-error.       
     if avail forne                                                  
     then do:  
            vfornome = forne.fornom.                                                         disp forne.fornom no-label with frame f1.                                      end.                                                            
     else do: 
           if vforcod = 0                                               
           then do:
                  vfornome = "GERAL".
                  display "GERAL" @ forne.fornom no-label with frame f1.
                end.    
         /*  message "Fornecedor nao Cadastrado !!" view-as alert-box. 
            undo. */                                                                   end.                                                            
    
    assign os-total       = 0 
           os-pendente    = 0
           os-solucionado = 0
           os-15          = 0
           os-20          = 0
           os-30          = 0
           os-cli         = 0
           os-est         = 0
           os-pencli      = 0
           os-solcli      = 0
           os-penest      = 0
           os-solest      = 0
           os-fornec      = 0
           os-fabri       = 0
           os-penfornec   = 0
           os-penfabri    = 0.
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
                         
        each asstec where asstec.etbcod = estab.etbcod and
                          asstec.dtentdep >= vdti      and
                          asstec.dtentdep <= vdtf      and
                          if vforcod = 0
                          then true
                          else asstec.forcod = vforcod 
                          no-lock,
        each produ of asstec no-lock                  :
        
        os-total = os-total + 1.
        
        if asstec.clicod = 0
        then os-est = os-est + 1.
        else os-cli = os-cli + 1.
        
        if asstec.dtenvfil = ?      /* Data de envio para filial */
        then do:
            os-pendente   = os-pendente + 1.     /* Pendente */
            if asstec.clicod = 0                
            then os-penest = os-penest + 1.      /* Pendente de Estoque */
            else os-pencli = os-pencli + 1.      /* Pendente de Cliente */
            
            if asstec.forcod = 0
            then assign 
                     os-penfornec = os-penfornec + 1
                     os-penfabri  = os-penfabri  + 1.
        end.
        else do:
            os-solucionado = os-solucionado + 1.
            
            if asstec.clicod = 0
            then os-solest = os-solest + 1.     /* Solucionados de Estoque */
            else os-solcli = os-solcli + 1.     /* Solucionados de Clientes */
            
            if (asstec.dtenvfil - asstec.dtentdep) <= 15
            then os-15 = os-15 + 1.

            if (asstec.dtenvfil - asstec.dtentdep) <= 20
            then os-20 = os-20 + 1.

            if (asstec.dtenvfil - asstec.dtentdep) <= 30
            then os-30 = os-30 + 1.
        end.
    end.

    if opsys = "unix" 
    then do:
        vtela = yes.
        message "Saida do relatorio [T]Tela [I]Impressora? " update vtela.
        
        if not vtela
        then do:
           find first impress where impress.codimp = setbcod no-lock no-error. 
           if avail impress
           then do:
                run acha_imp.p (input recid(impress), 
                                output recimp).
                find impress where recid(impress) = recimp no-lock no-error.
                assign fila = string(impress.dfimp) 
                       varquivo = "/admcom/relat/asstec" + string(time).
           end.
           else undo.
        end.
        else varquivo = "/admcom/relat/asstec" + string(time).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "120" 
            &Page-Line = "66" 
            &Nom-Rel   = ""relass"" 
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO""" 
            &Tit-Rel   = """RESUMO DE ASSISTENCIA TECNICA"" +  
                          "" FILIAL ""  + string(vetbcod) +
                          "" Data: "" + string(vdti) + "" A "" +                                           string(vdtf)"               
            &Width     = "120"
            &Form      = "frame f-cabcab"}
     end.                    
     else do:
        assign fila = "" 
               varquivo = "l:\relat\aud" + string(time).
     
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""asstec""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
            &Tit-Rel   = """RESUMO DE ASSISTENCIA TECNICA "" +
                        "" Data: "" + string(vdti) + "" A "" +
                            string(vdtf)"
            &Width     = "100"
            &Form      = "frame f-cabcab1"}
     end.
    
    
    display os-total       label "Total Geral                " at 5
            vfornome    NO-LABEL   format "X(25)"
            os-cli         label "Produtos de Cliente        " at 5
            ((os-cli / os-total) * 100) no-label format ">99.99%" 
            os-est         label "Produtos de Estoque        " at 5 
            ((os-est / os-total) * 100) no-label format ">99.99%" 
            os-pendente    label "Total Pendente             " at 5
            ((os-pendente / os-total) * 100) no-label format ">99.99%" 
            os-solucionado label "Total Solucionado          " at 5
            ((os-solucionado / os-total) * 100) no-label format ">99.99%" 
            os-15          label "Solucionados de 0 a 15 dias" at 5
            ((os-15 / os-solucionado) * 100) no-label format ">99.99%" 
            os-20          label "Solucionados de 0 a 20 dias" at 5
            ((os-20 / os-solucionado) * 100) no-label format ">99.99%" 
            os-30          label "Solucionados de 0 a 30 dias" at 5
            ((os-30 / os-solucionado) * 100) no-label format ">99.99%" 
            os-solcli      label "Solucionados de Clientes   " at 5
            ((os-solcli / os-solucionado) * 100) no-label format ">99.99%" 
            os-solest      label "Solucionados de Estoque    " at 5
            ((os-solest / os-solucionado) * 100) no-label format ">99.99%" 
            os-pencli      label "Pendentes    de Clientes   " at 5
            ((os-pencli / os-pendente) * 100) no-label format ">99.99%" 
            os-penest      label "Pendentes    de Estoque    " at 5
            ((os-penest / os-pendente) * 100) no-label format ">>9.99%"
             os-penfornec  label "Pendentes    de Fornecedor " at 5      
            ((os-penfornec / os-pendente) * 100) no-label format ">>9.99%"   
/*           os-penfabri   label "Pendentes    de Fabricante " at 5      
            ((os-penfabri / os-pendente) * 100) no-label format ">>9.99%"  */
                with frame f2 centered side-label title "FECHAMENTO".
    
    output close.
    
    if opsys = "unix"
    then do:
        if vtela
        then run visurel.p (input varquivo, input "").
        else os-command silent lpr value(fila + " " + varquivo).
    end.
    else do:
        {mrod_l.i}
    end.

end.           
    
