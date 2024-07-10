/* ---------------------------------------------------------------------------
*  Nome.....: crm20-rel01.p
*  Funcao...: Relatorio de clientes que consumiram nos ultimos 6 meses
*  Data.....: 20/12/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */
{admcab.i}

def var vetbcod like estab.etbcod.
def var varquivo    as     char.
def var vfiltro     as     char.

def var vtotcli     as     deci form ">>>,>>9.99" init 0.
def var vtotger     as     deci form ">>>,>>9.99" init 0.

def var ict         as     inte  init 0.
def var iconta      as     inte form ">>>>>>>>>>>>>>>9"  init 0. 
def var irfv        like   ncrm.rfv  init 555.
def var d_dtaini    like   plani.pladat.
def var d_dtafin    like   plani.pladat.

assign d_dtaini = today - 180
       d_dtafin = today.

def temp-table tt-clicrm        no-undo
    field etbcod       like estab.etbcod
    field clicod       like clien.clicod
    field clinom       like clien.clinom
    index ch-etbcod    etbcod clicod
    index ch-etbcli    etbcod 
    index ch-clicod    clicod.

def temp-table tt-produtos      no-undo
    field clicod       like clien.clicod  
    field procod       like produ.procod
    field pronom       like produ.pronom
    field movpc        like movim.movpc
    index ch-prods     clicod.

for each tt-produtos:
   delete tt-produtos.
end.   
for each tt-clicrm:
   delete tt-clicrm.
end.
    
update vetbcod    label "Estabelecimento" skip
       irfv       label "RFV............" skip
       d_dtaini   label "Data Inicial..." skip
       d_dtafin   label "Data Final....."     
       with frame f-upd side-label 1 down width 80
            title "RELATORIO DE CONSUMO DE CLIENTES".
       
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:

        disp estab.etbcod format ">>>>>9"
             with frame f-proc. pause 0.
                          
        for each plani where plani.movtdc =  5   
                         and plani.etbcod =  estab.etbcod 
                         and plani.pladat >= d_dtaini 
                         and plani.pladat <= d_dtafin no-lock:
    
           disp plani.desti  format ">>>>>>>>>9" 
                plani.pladat format "99/99/9999"
                with frame f-proc centered 1 down
                              row 10 title "PROCESSANDO".

           pause 0 no-message.
   
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:


                find ncrm where ncrm.clicod = plani.desti no-lock no-error.
                if avail ncrm
                then do:
                    create tt-clicrm.
                    assign tt-clicrm.etbcod = plani.etbcod
                           tt-clicrm.clicod = ncrm.clicod
                           tt-clicrm.clinom = ncrm.nome.
        
                    find produ where 
                         produ.procod = movim.procod no-lock no-error.

                    create tt-produtos.
                    assign tt-produtos.clicod = ncrm.clicod
                           tt-produtos.procod = movim.procod
                           tt-produtos.pronom = produ.pronom
                           tt-produtos.movpc  = movim.movpc.
                end.           
                
            end.
        end.
    end.

    hide frame f-rel no-pause.

    /* DREBES */
    if opsys = "UNIX"
    then do:
            assign varquivo   = "/admcom/relat/crm20-rel01." + string(time).
    end. 
    else do:
            assign varquivo   = "l:~\relat~\crm20-rel01." + string(time).
    end.

/*    message "Montando relatorio...". */
    
    assign iconta   = 0.

    {mdadmcab.i
         &Saida     = "value(varquivo)"
         &Page-Size = "0"
         &Cond-Var  = "130"
         &Page-Line = "0"
         &Nom-Rel   = ""CRM20-REL01.P""
         &Nom-Sis   = """SISTEMA GERENCIAL"""
         &Tit-Rel   = """RELATORIO DE CONSUMO CLIENTES  "" + 
                         vfiltro"
         &Width     = "130"
         &Form      = "frame f-rel01"}

    for each tt-clicrm no-lock,
        each tt-produtos where
             tt-produtos.clicod = tt-clicrm.clicod no-lock
             break by tt-clicrm.etbcod
                   by tt-clicrm.clicod
                   by tt-produtos.clicod:

           find estab where estab.etbcod = tt-clicrm.etbcod no-lock no-error.
           if not avail estab
           then message tt-clicrm.etbcod view-as alert-box.
           
           if first-of(tt-clicrm.etbcod)
           then
               disp estab.etbcod label "Estabelecimento" form ">>>>>>>9"
                    estab.etbnom no-label
                    with frame f-etb side-labels.
             
           if first-of(tt-clicrm.clicod)
           then do:
                  disp space(3)
                       tt-clicrm.clicod label "Cliente"  form ">>>>>>>>>>>9"
                       tt-clicrm.clinom no-label skip
                       with frame f-cli side-labels.
           end.

           disp space(06)
                tt-produtos.procod 
                tt-produtos.pronom  form "x(40)"
                tt-produtos.movpc  (total by tt-clicrm.clicod)
                 form ">,>>>,>>9.99" label "Preco"
                with width 130 frame f-pro down.
           down with frame f-pro.                 

           /*
           put  space(02)
                tt-produtos.procod  form ">>>>>>>>>>>>>9"
                space(01)
                tt-produtos.pronom  form "x(40)"   
                space(01)
                tt-produtos.movpc   form ">>>,>>>,>>9.99"
                skip.  

          if last-of(tt-clicrm.clicod)
          then do:
                  put "Total: "
                      skip.
          end.
          */
            
    end.    
    
    output close.

    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.
