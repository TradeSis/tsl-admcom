{admcab.i}


def var vcont as int.
def var vcatcod like categoria.catcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vanalitico as log format "Analitico/Sintetico".
def var vclacod like clase.clacod.
def var vforcod like forne.forcod.
def var vetbcodi like estab.etbcod.
def var vetbcodf like estab.etbcod.
def var vfabcod like fabri.fabcod.

def  var vtipo as log format "Acumulado/Filial".


repeat:
    
    
    update vcatcod label "Departamento.."
                with frame f-dep centered side-label width 80.
    
    find categoria where categoria.catcod = vcatcod no-lock no-error.

    disp categoria.catnom no-label with frame f-dep.
    
    if categoria.catcod = 31 or
       categoria.catcod = 35
    then message "Deseja agrupar departamentos [31 - 35]" update sresp.
    else message "Deseja agrupar departamentos [41 - 45]" update sresp.


    update skip
           vdti label "Periodo......."
           "a"
           vdtf no-label with frame f-dep.

    vtipo = yes.
    update skip vanalitico label "Tipo.........."
        help "[A] Analitico [S] Sintetico"
           vtipo no-label
        help "[A] Acumulado [F] Filial"
        with frame f-dep.

    update vclacod at 01 label "Classe........" with frame f-dep.

    update skip vetbcodi label "Filial Inicial" 
           vetbcodf label "Filial Final" 
           with frame f-dep.

    update vforcod label "Fornecedor"
                with frame f-depf centered side-label color blue/cyan.
    vfabcod = vforcod.
    if vfabcod = 0
    then do:
        display "GERAL" @ fabri.fabnom with frame f-depf.
    end.
    else do:             
        find fabri where fabri.fabcod = vfabcod no-lock.
        disp fabri.fabnom no-label with frame f-depf.
    end.

    message "Confirma Resumo ? " update sresp.
    if sresp
    then do:

      if not vtipo /* Por Filial */
      then do:
      
          if opsys = "UNIX"
          then do:
              output to /admcom/relat/imp-resu.bat.
                 put "l:" skip
                     "cd relat" skip.
              output close.
          end.
                
          do vcont = vetbcodi to vetbcodf:
            
                run resujo02.p(input vcatcod,
                               input sresp,
                               input vdti,
                               input vdtf,
                               input vanalitico,
                               input vclacod,
                               input /*vetbcodi*/ vcont,
                               input /*vetbcodf*/ vcont,
                               input vforcod ).
                
                message "Arquivo da Filial " string(vcont) " gerado.".
                pause 1 no-message.
                hide message no-pause.
          end.
          
          if opsys = "UNIX"
          then do:
          
              message "Bat de impressao criado: L:\relat\imp-resu.bat".
              pause.
              
          end.
      
      end.
      else do: /* Acumulado */

                run resujo02.p(input vcatcod,
                               input sresp,
                               input vdti,
                               input vdtf,
                               input vanalitico,
                               input vclacod,
                               input vetbcodi,
                               input vetbcodf,
                               input vforcod).

      
      end.
      
    end.

end.