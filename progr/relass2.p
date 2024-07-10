{admcab.i}
/***************************************************************************/
/*  relass2.p -Relatório de Envio /Retorno Assitencia ténica
40310
           */
/***************************************************************************/

def var recimp   as recid.
def var vtela    as log format "Tela/Impressora".
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vforcod  like forne.forcod.
def var vfornome like forne.fornom.
def var vpnf     as   log format "Sim/Nao" init no.  
def var os-totenv      as int.
def var os-totret      as int.
def var os-envass      as int.
def var os-retass      as int.
def var fila           as char.
def var varquivo       as char.

def temp-table tt-plani
   field forcod like forne.forcod
   field numero like plani.numero
   field pladat like plani.pladat
   field procod like movim.procod
   field envass as int
   field retass as int init 0
   
   index plani is primary unique forcod numero pladat procod.

repeat:
    
    update vetbcod label "Filial      " colon 16
                with frame f1 side-label width 80.

    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
   
    update vforcod label "Fornecedor  " colon 16 with frame f1.

    if vforcod > 0
    then do:                 
        find forne where forne.forcod = vforcod no-lock no-error.       
        if avail forne                                                  
        then do:  
            vfornome = forne.fornom. 
            disp forne.fornom no-label with frame f1.
       end.
           
    end.
    else do: 
           if vforcod = 0                                               
           then do:
                  vfornome = "GERAL".
                  display "GERAL" @ forne.fornom no-label with frame f1.
                end.    
        end.

    update vpnf label "Envio por NF." colon 16
           with frame f1.
    
    /*
    if vpnf = yes
    then do:
         vdti = ?.
         vdtf = ?.
         disp vdti vdtf with frame f1.
         
    end.
    else */ do on error undo, retry:
            update vdti label "Data Inicial" colon 16
                   vdtf label "Data Final  " colon 16 with frame f1.
            if  vdti > vdtf
            then do:
                message "Data inválida".
                undo.
            end.
      end. 
    
    assign 
           os-totenv      = 0
           os-totret      = 0
           os-envass      = 0
           os-retass      = 0.

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
                assign fila = string(impress.dfimp). 
           end.
           else do:
                message "Impressora nao cadastrada".
                vtela = yes.
           end.
        end.
   
        varquivo = "../relat/relass2" + string(time).
        
        def var vauxcab as char.
        vauxcab = (if vdti = ? then ""
                 else " - " + string(vdti) + " A " + string(vdtf)).
        
       {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "110" 
            &Page-Line = "66" 
            &Nom-Rel   = ""relass2"" 
            &Nom-Sis   = """SISTEMA DEPOSITO - ASSISTENCIA TECNICA""" 
            &Tit-Rel   = """ENVIO/RECEBIMENTO ASSISTENCIA TECNICA"" +
                            vauxcab
                            " )
                           &Width     = "110"
            &Form      = "frame f-cabcab"}
     end.                    
     else do:
        assign fila = "" 
               varquivo = "l:\relat\relass2" + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "110"
            &Page-Line = "66"
            &Nom-Rel   = ""relass2"" 
            &Nom-Sis   = """SISTEMA DEPOSITO - ASSISTENCIA TECNICA""" 
            &Tit-Rel   = """ENVIO/RECEBIMENTO ASSISTENCIA TECNICA"" +
                          ""  - "" + string(vdti) + "" A "" + string(vdtf)"
            &Width     = "110"
            &Form      = "frame f-cabcab1"}
     end.
    
    /* Sem Controle de Nota -  antonio */
    if vpnf <> yes
    then
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
    
        each asstec where asstec.etbcod = estab.etbcod and
                          asstec.dtenvass >= vdti      and
                          asstec.dtenvass <= vdtf      and
                          asstec.forcod = (if vforcod = 0
                                           then asstec.forcod
                                           else vforcod)
                                           no-lock,
        first produ where produ.procod = asstec.procod 
                               no-lock
               break by asstec.forcod 
                     by asstec.dtenvass:
                      
        if first-of(asstec.forcod)
        then do:
             assign os-retass = 0
                    os-envass = 0.
                    
             find forne where forne.forcod = asstec.forcod no-lock no-error.
             put unformat skip(1)
                 "Fornecedor: " asstec.forcod " - "
                 (if avail forne then forne.fornom
                  else string(asstec.forcod))
                  skip.
        end.

        assign os-totenv = os-totenv + 1
               os-envass = os-envass + 1. 
        
        if asstec.dtretass <> ? 
        then do:
            os-retass   = os-retass + 1. 
            os-totret   = os-totret + 1.
        end.
       disp produ.procod  format ">>>>>>>9"
            produ.pronom 
            asstec.dtenvass column-label "ENV.ASSIST"
            (if asstec.dtret = ? then "" 
            else string(asstec.dtretass,"99/99/9999")) FORMAT "X(10)"
                            column-label "RETORNO"    
               with frame f-item width 98 60 down            
            .
       if last-of(asstec.forcod)
       then do:
           put unformat skip
               "---------- ----------" at 61
               "TOTAL DO FORNECEDOR: "  at 03
                (if avail forne then forne.fornom
                 else string(asstec.forcod))
                 os-envass format ">>>>>>>9" at 62
               "   "
                os-retass format ">>>>>>>9".
       end.

    end.
    
    /* Com Controle de Nota -  antonio */
    if vpnf = yes
    then do:
        for each tt-plani.
            delete tt-plani.
        end.
        
        put unformatted
         "PRODUTOS ENVIADOS PARA ASSISTENCIA NO PERIODO" skip "------------------------------------------------------------------------------" skip .
        
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,

            each plani where plani.movtdc = 16 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf and
                             plani.desti = (if vforcod = 0
                                            then plani.desti
                                            else vforcod) no-lock,     

            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
                         
            first produ where produ.procod = movim.procod no-lock
                                                          break by plani.desti 
                                                                by plani.numero
                                                                by plani.pladat:
                      
            if first-of(plani.desti)
            then do:
                 assign os-retass = 0
                        os-envass = 0.
                    
                find forne where forne.forcod = plani.desti no-lock no-error.
                put unformat skip(1)
                         "Fornecedor: " plani.desti " - "
                         (if avail forne then forne.fornom
                          else string(forne.forcod))
                    skip.  
            end.

            assign os-totenv = os-totenv + movim.movqtm
                   os-envass = os-envass + movim.movqtm. 

            create tt-plani.
            assign
                tt-plani.forcod = plani.desti
                tt-plani.numero = plani.numero
                tt-plani.pladat = plani.pladat
                tt-plani.procod = movim.procod
                tt-plani.envass = movim.movqtm.
            
            /*
            if asstec.dtretass <> ? 
            then do:
                os-retass   = os-retass + 1. 
                os-totret   = os-totret + 1.
            end.
            */
            disp produ.procod  format ">>>>>>>9"
                 produ.pronom 
                 plani.pladat column-label "ENV.ASSIST"
                 movim.movqtm column-label "Qtd" format ">>>9"
              /* (if asstec.dtret = ? then "" 
                  else string(asstec.dtretass,"99/99/9999")) FORMAT "X(10)"
                                 column-label "RETORNO"   */
                 plani.numero "Nota Fiscal"
                    with frame f-item-2 width 110 60 down .           
            if last-of(plani.desti)
            then do:
               put unformat skip
               "------" at 71
               "TOTAL DO FORNECEDOR: "  at 03
                (if avail forne then forne.fornom
                 else string(plani.desti))
                 os-envass format ">>>>>>>9" at 68.
                 
            end.

        end.
                 
        if os-envass = 0
        then
          put unformatted
              "                        (Nenhum registro encontrado)" skip.

        put unformatted
        skip(2)
"------------------------------------------------------------------------------" skip            "PRODUTOS RETORNADOS DE ASSISTENCIA NO PERIODO" skip
"------------------------------------------------------------------------------"
 skip .
 
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,

            each plani where plani.movtdc = 15 and
                             plani.etbcod = estab.etbcod and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf and
                             plani.emite = (if vforcod = 0
                                            then plani.emite
                                            else vforcod) no-lock,
        
            each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,
                         
            first produ where produ.procod = movim.procod no-lock
                                                          break by plani.emite
                                                                by plani.numero
                                                                by plani.pladat:
                          
            if first-of(plani.emite)
            then do:
                assign os-retass = 0.

                find forne where forne.forcod = plani.emite no-lock no-error.
               
                put unformat skip(1)
                    "Fornecedor: " plani.emite " - "
                    (if avail forne then forne.fornom
                     else string(forne.forcod))
                skip.
             end.

            find first tt-plani where tt-plani.forcod = plani.emite
                                  and tt-plani.procod = movim.procod
                                  and tt-plani.retass = 0
                                no-error.
            if not avail tt-plani
            then do:
                create tt-plani.
                assign
                    tt-plani.forcod = plani.desti
                    tt-plani.numero = plani.numero
                    tt-plani.pladat = plani.pladat
                    tt-plani.procod = movim.procod.
            end.
            tt-plani.retass = tt-plani.retass + movim.movqtm.
   
            os-retass   = os-retass + movim.movqtm.
            os-totret   = os-totret + movim.movqtm.
                                       
            disp produ.procod  format ">>>>>>>9"
                 produ.pronom
                 plani.pladat column-label "RET.ASSIST"
                 movim.movqtm column-label "Qtd" format ">>>9"
                 plani.numero "Nota Fiscal"
                          with frame f-item-3 width 110 60 down.

            if last-of(plani.emite)
            then do:
                put unformat skip
                    "------" at 71
                    "TOTAL DO FORNECEDOR: "  at 03
                    (if avail forne then forne.fornom
                     else string(plani.emite))
                    os-retass format ">>>>>>>9" at 68.
            end.
        end. /* estab */

        /*** 40310 ***/
        put unformatted
            skip(2)
            fill("-",78)
            skip
            "PRODUTOS NAO RETORNADOS DE ASSISTENCIA NO PERIODO"
            skip
            fill("-",78)
            skip.

        for each tt-plani where tt-plani.envass <> tt-plani.retass
                            and tt-plani.envass - tt-plani.retass > 0
                          no-lock
                          break by tt-plani.forcod
                                by tt-plani.numero
                                by tt-plani.pladat:
            find produ of tt-plani no-lock.

            if first-of(tt-plani.forcod)
            then do:
                assign os-envass = 0.

                find forne where forne.forcod = tt-plani.forcod no-lock.                
                put unformat skip(1)
                    "Fornecedor: " tt-plani.forcod " - "
                    (if avail forne then forne.fornom
                     else string(forne.forcod))
                skip.
            end.
            os-envass = os-envass + (tt-plani.envass - tt-plani.retass). 
            disp produ.procod  format ">>>>>>>9"
                 produ.pronom
                 tt-plani.pladat column-label "ENV.ASSIST"
                 (tt-plani.envass - tt-plani.retass) column-label "Qtd" format "->>9"
                 tt-plani.numero "Nota Fiscal"
                 with frame f-item-4 width 110 60 down.
                          
            if last-of(tt-plani.forcod)
            then do:
                put unformat skip
                    "------" at 71
                    "TOTAL DO FORNECEDOR: "  at 03
                    (if avail forne then forne.fornom
                     else string(tt-plani.forcod))
                    os-envass format ">>>>>>>9" at 68.
            end.
        end.
        /*** ***/

    end. /* vpnf */
    
/***
    if os-totret = 0
    then put unformatted
                "                        (Nenhum registro encontrado)" skip(2).
***/

    put unformat skip
               "---------- ---------" at 61
               "TOTAL GERAL: "  at 03
                 os-totenv format ">>>>>>>9" at 62
               "   "
                os-totret format ">>>>>>>9" skip(3).

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
    
