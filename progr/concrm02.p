/* --------------------------------------------------------------------------- 
*  Nome.....: concrm02.p                                                      
*  Funcao...: Consulta CRM por Cliente - Sol 14671               
*  Data.....: 21/06/2007                                                       
*  Autor....: Virgínia Alencastro                                              
--------------------------------------------------------------------------- */ 
{admcab.i}

def var vclicod     like    clien.clicod.
def var varquivo    as      char.              
def var vdti        as      date format "99/99/9999".
def var vdtf        as      date format "99/99/9999".


repeat:

  /* DREBES */                                                           
  if opsys = "UNIX"                                                   
  then do:
        assign varquivo   = "/admcom/relat/concrm" 
                          + string(time)
                          + ".txt".  
  end.                                                           
  else do:                                                            
        assign varquivo   = "l:\relat\concrm"
                          + string(time)
                          + ".txt".
  end.                                                           

/******* Bloco Principal **********/

/* Código Cliente */
update vClicod with frame f-cli 1 down  side-label.            

find clien where clien.clicod = vclicod no-lock no-error.
if avail clien                                                 
then display clien.clinom  no-label                            
       with frame f-cli.                                 
else do:                                                       
        message "Cliente nao Cadastrado!" view-as alert-box.  
end.                                                      

find rfvcli where rfvcli.setor = 0 and
            rfvcli.clicod = clien.clicod no-lock no-error.
            
{mdadmcab.i                                                    
  &Saida     = "value(varquivo)"                                 
  &Page-Size = "64"                                              
  &Cond-Var  = "80"                                             
  &Page-Line = "66"                                              
  &Nom-Rel   = ""CONCRM02""                                       
  &Nom-Sis   = """CRM"""                               
  &Tit-Rel   = """CONSULTA CRM POR CLIENTE """ /* +
                   string(vdti,""99/99/9999"") + "" A "" +       
                   string(vdtf,""99/99/9999"") " */                 
  &Width     = "80"                               
  &Form      = "frame f-cabcab"}                 
 
  hide frame f-cli.

  disp "Cliente:" clien.clicod
        clien.clinom with frame f-rcli no-label.                                 if avail rfvcli
  then disp rfvcli.nota label "Nota atual" with frame f-rcli side-label
  width 100.          
               
  find first acao-cli where 
             acao-cli.clicod = vClicod no-lock  no-error.
  if not avail acao-cli
  then do:                                         
         disp "Cliente nao possui Acoes de CRM !"  
         with frame f-3 width 80 down.            
  end.                                             
  else do:           
    for each acao-cli where
               acao-cli.clicod = vClicod no-lock:

        find first ncrm where
                   ncrm.clicod = acao-cli.clicod no-lock no-error.
    
        find first acao where
                   acao.acaocod = acao-cli.acaocod no-lock no-error.
                  
        disp acao-cli.acaocod
              ncrm.rfv                            when avail ncrm
              ncrm.etbcod   column-label "Filial" when avail ncrm
              with frame f-2 width 80 down.
              
        if avail acao 
        then do:
                disp acao.descricao column-label "Descricao" format "x(30)"
                     acao.DtIni
                     acao.DtFin
                     with frame f-2 width 80 down.
        end.              end.
end.         
output close.                                        
                                                     
if opsys = "UNIX"                                    
then do:                                             
       run visurel.p (input varquivo, input "").  
end.                                            
else do:
    {mrod.i}.                                       
end.
end.
