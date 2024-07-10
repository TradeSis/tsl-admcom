/* ---------------------------------------------------------------------------
*  Nome.....: invret01.p
*  Funcao...: integracao ADMCOM e AUTOMATEC  RET999AAAAMMDD.TXT
*  Data.....: 28/03/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */
{admcab.i}

pause 0 no-message.

/* ------------------------------------------------------------------------- */

def temp-table tt-ret                                no-undo
    field proCod        as      char    form "x(14)"
    field proNom        as      char    form "x(50)"
    field estAtual      as      char    form "x(06)"
    field estColet      as      char    form "x(06)"
    field dfAtuClt      as      char    form "x(06)"
    field obsErro       as      char    form "x(60)"
    index chProcod      is primary procod.

/* ------------------------------------------------------------------------- */

def var lconfirma       as logi form "Sim/Nao"      init no         no-undo.
def var rRecid          as recid                                    no-undo.
def var cCaminho        as char form "x(100)"       init ""         no-undo.
def var cArqgera        as char form "x(60)"        init ""         no-undo.
def var cArqinte        as char form "x(160)"       init ""         no-undo.
def var ilinfra         as inte                     init 0          no-undo.
def var cdata           as char form "x(08)"        init ""         no-undo.
def var ddtainv         as date form "99/99/9999"   init today      no-undo.
def var cProCod         as char form "x(006)"       init ""         no-undo.
def var clinha1a        as char form "x(200)"       init ""         no-undo.
def var cArqExis        as char form "x(200)"       init ""         no-undo.
 
def var cClaNom         like clase.clanom                           no-undo.
def var iestCusto       like estoq.estcusto                         no-undo.
def var iestatual       like estoq.estatual                         no-undo.
def var vetbcod         like estab.etbcod                           no-undo.
def var varquivo as char.

def button btn-inv label "IMPORTA INVENTARIO".
def button btn-pro label "PROCESSA".  
def button btn-pes label "PESQUISA". 
def button btn-sai label "SAIR".

def query q_ret  for tt-ret
    fields(tt-ret.procod
           tt-ret.pronom
           tt-ret.estatual
           tt-ret.estcolet
           tt-ret.dfAtuClt
           tt-ret.obserro)
           scrolling.

def browse b_ret query q_ret no-lock
    display tt-ret.procod     column-label "Codigo"
            tt-ret.pronom     column-label "Nome"
            tt-ret.estatual   column-label "Est Teorico"
            tt-ret.estcolet   column-label "Est Coleta"
            tt-ret.dfAtuClt   column-label "Diferenca"
            tt-ret.obserro    column-label "Erro identificado" 
    with width 60 5 down no-row-markers.
    
def frame f-browse
    b_ret                                            at 10
    skip(1)
    btn-inv                                          at 01
    btn-pro                                          at 23
    btn-sai                                          at 72
    with side-labels width 80 col 1 row 2
         title "MANUTENCAO INVENTARIO - INTRET01".
          
&scoped-define frame-name f-browse
&scoped-define open-query open query q_ret for each tt-ret no-lock
&scoped-define list-1 btn-inv btn-pro btn-sai

/* ------------------------------------------------------------------------- */

def frame f-inf1
          skip
          vetbcod                 label "Estabelecimento"    
          ddtainv                 label "Data Inventario"    skip
          cCaminho                label "Caminho"
          cArqGera                label "Arquivo"            
          with row 16 col 1 width 80
          title "INFORME ESTABELECIMENTO" side-labels.   

/* ------------- MAIN ------------------------------------------------------- */

on choose of btn-pro in frame {&frame-name} /* Processa */
do:

   hide frame f-inf1.

   message "Indisponivel no momento!" view-as alert-box. 

   hide frame f-msg1.   
   run pi-atualiza.
end.   

on choose of btn-inv in frame {&frame-name} /* Importa inventario */
do:

   update skip
          vetbcod                 label "Estabelecimento" 
          ddtainv                 label "Data Inventario"       at 51
          with frame f-inf1.

   assign cdata = string(day(ddtainv),"99")   +
                  string(month(ddtainv),"99") +
                  string(year(ddtainv),"9999").
 
   if opsys = "UNIX"
   then do:
           assign cCaminho  = "/admcom/coletor-aud/"
                  cArqGera  = "ret" + string(vetbcod,"999") + 
                              cdata + ".txt".
   end. 
   else do:
           assign cCaminho  = "c:~\temp~\"
                  cArqGera  = "ret" + string(vetbcod,"999") + 
                              cdata + ".txt".
   end.
             
   update cCaminho  form "x(68)"              label "Caminho"
          cArqGera  form "x(68)"              label "Arquivo"   at 01
          with frame f-inf1. 

   if opsys = "UNIX"
   then do:
           assign cArqInte  = trim(cCaminho) + trim(cArqGera).
   end. 
   else do:
           assign cArqInte  = trim(cCaminho) + trim(cArqGera).
   end.

   message "Confirma a importacao do arquivo inventario" skip
           trim(cArqInte)
           view-as alert-box buttons yes-no title "IMPORTA"
           update lconfirma.

   if lconfirma = yes
   then do:
       varquivo = carqInte.
       if substr(string(varquivo),1,3) = "c:~\" and
        opsys = "UNIX"
       then do:
            scabrel = varquivo.
            schave = "ftp".
            varquivo = "/admcom/relat/".
            run editarqr.p(varquivo).
            varquivo = sparam.
            carqInte = varquivo.
            sparam = "".
        end.

            assign cArqExis = search(carqInte).
            if cArqExis = ?
            then do:
                    message "Arquivo nco encontrado, favor verificar!"
                            view-as alert-box.
                    undo, retry.
            end.
           
            input from value(cArqInte).
              repeat:
                import unformatted cLinha1a.
                if substring(cLinha1a,14,1) <> ""
                then do:
                      create tt-ret.
                      assign tt-ret.procod   = substring(cLinha1a,01,14)
                             tt-ret.estatual = substring(cLinha1a,15,06)
                             tt-ret.estcolet = substring(cLinha1a,21,06)
                             tt-ret.dfatuclt = substring(cLinha1a,27,06).
                    
                      find first produ where
                                 produ.procod = inte(substring(cLinha1a,01,14)) 
                                 no-lock no-error.
                      if avail produ
                      then do:
                              assign tt-ret.pronom = produ.pronom.
                      end.
                      else do:
                              assign tt-ret.obserro = "Produto nco encontrado".                        end.           
                      put screen "Gerando arquivo!" 
                          color messages col 20 row 15.
                end.
              end.   
            input close.
            put screen "                " 
                       col 20 row 15.
            
            hide frame f-inf1.
            
            run pi-atualiza.               

            message "Operacao concluida" view-as alert-box.
   end.
end.

on choose of btn-sai in frame {&frame-name} /* Sair */
do:
    apply "window-close" to current-window.
end.

/* ------------------------------------------------------------------------- */  procedure pi-atualiza:

  {&open-query}.

   enable b_ret 
          {&list-1} with frame {&frame-name}.

end procedure.
   
   
     
{&open-query}.

enable b_ret 
       {&list-1} with frame {&frame-name}.
apply "value-changed" to browse b_ret.

wait-for window-close of current-window.

