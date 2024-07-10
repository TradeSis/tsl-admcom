{admcab.i}

def var vcor-15 as char format "x(15)".
def var vparam as char.
def var val-price as log.

def var vv as int.
def var vok as log.
def var vsai as log.

def new shared var xopecod    as inte.

def buffer bfunc for func.

/* def var    vop       as   log format "Habilitacao/Migracao". */
def var vop        as   char format "x(1)".

def var    vclicod   like clien.clicod.
def var    vciccgc   like habil.ciccgc.
def var    vcelular  like habil.celular format "x(10)".
def var    vgercod   like habil.gercod.
def var    vvencod   like habil.vencod.
def var    vpmtcod   like habil.pmtcod.
def var vetbcod like estab.etbcod.
def var vcodviv like habil.codviv.
def var vcodtim like habil.codviv.
def var vcodxxx like habil.codviv.
def var vprocod like habil.procod.
def var vpronom like produ.pronom.
def var vhabval like habil.habval.
def var vtipviv like habil.tipviv.
def var vtiptim like habil.tipviv.
def var vtipxxx like habil.tipviv.
def var vopecod like operadoras.opecod.   
def var vestvdn like estoq.estvenda.

vsai = no.
repeat:
    vetbcod = setbcod.
    
    update vetbcod with frame f-habil.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    
    disp vetbcod label "Loja....." estab.etbnom no-label skip
         today  format "99/99/9999" label "Dt.Habil."
         with frame f-habil centered title " Habilitacao " row 5.

    assign vciccgc  = ""
           vcelular = ""
           vgercod  = 0
           vvencod  = 0
           vpmtcod  = 0
           vcodviv  = 0
           vprocod  = 0
           vhabval  = 0
           vop      = ""
       /*  scli     = 0 */
           vopecod  = 0.
           
    do on error undo.       
       update skip 
           vop     label "Operacao."
           help "[H] = Habilitacao [M] = Migracao  [P] = Portabilidade"
           with frame f-habil  side-labels.

       if vop <> "H" and vop <> "M" and vop <> "P"
       then do:
            message "Informar: [H] = Habilitacao [M] = Migracao " +
                 " [P] = Portabilidade"  view-as alert-box. 
           undo.
       end.
    end.   

    do on error undo.
    update skip 
           vciccgc label "CPF......"
           with frame f-habil  side-labels.

    find first clien where clien.ciccgc = vciccgc no-lock no-error.

    if not avail clien
    then do:

        message "Enviar Cliente ao Crediario p/ efetuar o Cadastro".
        undo.
        
    end.    
    else vclicod = clien.clicod.
   
    find clien where clien.clicod = vclicod no-lock no-error.
    vciccgc = clien.ciccgc.
    if vciccgc = ? or
       vciccgc = ""  or
       vciccgc = "00"
    then undo, retry.
    disp vciccgc with frame f-habil.
    
    disp clien.clinom no-label with frame f-habil.

    disp clien.ciinsc label "RG......." space(3)
         clien.dtnasc label "Dt.Nasc"
         clien.pai    label "Pai......"
         clien.mae    label "Mae......" skip
         clien.fone   label "Telefone." space(17)
         clien.cep[1]    label "Cep" skip
         clien.sexo   label "Sexo....."  space(17)
         clien.estciv label "Est.Civil" skip
         with frame f-habil.
    end.

        for each produ where produ.clacod = 108 or
                             produ.clacod = 193 or
                             produ.clacod = 101 or
                             produ.clacod = 102 or
                             produ.clacod = 103 or
                             produ.clacod = 107 or
                             produ.clacod = 191 or
                             produ.clacod = 201 or
                             produ.clacod = 202 no-lock:

            find last movim where movim.movtdc  = 5
                              and movim.procod  = produ.procod
                              and movim.desti   = clien.clicod
                              and movim.movdat >= (today - 5) no-lock no-error.
            if avail movim
            then do:
                find plani where plani.etbcod = movim.etbcod
                             and plani.placod = movim.placod
                             and plani.pladat = movim.movdat
                             and plani.movtdc = movim.movtdc no-lock no-error.
                
                assign vprocod = movim.procod
                       vpronom = produ.pronom
                       vhabval = movim.movpc
                       vtipviv = movim.ocnum[8]
                       vcodviv = movim.ocnum[9].
                       
                if avail plani
                then vvencod = plani.vencod.
            end.
        end.

        find func where func.etbcod = vetbcod
                    and func.funcod = vvencod no-lock no-error.
        
        find promoviv where promoviv.tipviv = vtipviv no-lock no-error.
        if avail promoviv
        then
            find operadoras where 
                 operadoras.opecod = promoviv.opecod no-lock no-error.
    
        
        disp vprocod label "Produto.."
             vpronom no-label /*format "x(22)"*/ skip
             vopecod label "Operadora" format ">>9" 
             operadoras.openom format "x(10)" no-label when avail Operadoras
             skip
             vtipxxx label "Promocao." format ">>>9" 
             vcodxxx label "Plano" format ">>>9" at 42 
             skip
             vhabval label "Valor...." skip
             vvencod label "Vendedor."
             func.funnom no-label format "x(21)" when avail func
             
             vcelular label "Celular" 
             
             with frame f-habil.
   do on error undo.
        update 
            vprocod label "Produto.." with frame f-habil.
            
        if vprocod = 0
        then do:
            message "Informe o Codigo do Produto".
            undo.
        end.
        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto Nao Cadastrado".
            undo.
        end.
        else do:
            if produ.clacod <> 108 and
               produ.clacod <> 193 and  
               produ.clacod <> 101 and
               produ.clacod <> 102 and
               produ.clacod <> 103 and
               produ.clacod <> 191 and
               produ.clacod <> 107 and
               produ.clacod <> 201 and
               produ.clacod <> 202
            then do:
                message "O Produto Informado e Invalido".
                undo.
            end.
            else vpronom = produ.pronom.
            find first estoq where
                       estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then assign vhabval = estoq.estvend.       
            else assign vhabval = 0.
            disp vhabval with frame f-habil.
        end.
        
        disp vpronom no-label /*format "x(22)"*/ skip
                with frame f-habil.
    end.

    do on error undo:
        update vopecod label "Operadora" format ">>>9" 
               with frame f-habil.
               
        assign xopecod = vopecod.  /*leva para zoom a operadora.*/     
               
        find operadoras where 
             operadoras.opecod = input vopecod no-lock no-error.
        if not avail operadoras
        then do:
                 message "Operadora nao encontrada!"
                         view-as alert-box.
                 undo, retry. 
        end.
        disp operadoras.openom format "x(10)" 
             no-label with frame f-habil.

    end.
                    
    do on error undo:
    
        update vtipxxx label "Promocao." format ">>>9"
               with frame f-habil.
               
        if vtipxxx = 0
        then do:
                message "Informe o codigo da Promocao".
                undo.
        end.
        
        find promoviv where promoviv.tipviv = vtipxxx and
                            promoviv.opecod = vopecod no-lock no-error.
        if not avail promoviv
        then do:
                message "Promocao nao cadastrada" skip
                        "ou invalida para a operadora: " + string(vopecod)
                        view-as alert-box .
                undo.
        end.
        
        assign vtipviv = vtipxxx.

    end.
  
    do on error undo:
        update vcodxxx label "Plano" format ">>>9" at 42 skip            
               with frame f-habil.
               
        if vcodxxx = 0
        then do:
            message "Informe o codigo do Plano".
            undo.
        end.
        if vcodxxx >= 1   and
           vcodxxx <= 999 and
           vopecod <> 1
        then do:
                message "Plano invalido. O plano informado pertence a VIVO"
                        view-as alert-box.
                undo.
        end.
        if vcodxxx >= 1001 and
           vcodxxx <= 2000 and
           vopecod <> 2
        then do:
                message "Plano invalido. O plano informado pertence a TIM"
                        view-as alert-box.
                undo.
        end.
        if vcodxxx >= 2001 and
           vcodxxx <= 3000 and
           vopecod <> 3
        then do:
                message "Plano invalido. O plano informado pertence a CLARO"
                        view-as alert-box.
                undo.
        end.
            
        find planoviv where planoviv.codviv = vcodxxx no-lock no-error.
        if not avail planoviv
        then do:
            message "Plano nao cadastrado".
            undo.
        end.
        if planoviv.exportado = no
        then do:
            message "Plano inativo.".
            undo.
        end.    
        assign vcodviv = vcodxxx.
    end.
    /* gerson 
    find operadoras where operadoras.opecod = promoviv.opecod no-lock no-error.
    
    disp operadoras.openom format "x(10)" label "Operadora"
                           when avail operadoras
         with frame f-habil.
    */
    do on error undo:
        
        update vhabval label "Valor...." with frame f-habil.
        if vhabval = 0
        then do:
            message "Informe o valor que foi vendido o celular.".
            undo.
        end.
    end. 
    
    do on error undo:

        update skip vvencod label "Vendedor." with frame f-habil.
        
        if vvencod = 0 then do:
            message "Informe o Codigo do Vendedor".
            undo.
        end.
        
        find func where func.etbcod = vetbcod
                    and func.funcod = vvencod no-lock no-error.
        if not avail func
        then do:
            message "Vendedor nao Cadastrado".
            undo.
        end.  
        else disp func.funnom no-label format "x(21)" with frame f-habil.
        
    end.
    
    do on error undo:
        update vcelular label "Celular" with frame f-habil.    
        if vcelular = ""
        then do:
            message "Informe o numero do celular.".
            undo.
        end.
        
        vok = yes. 
        vv = 0.

        do vv = 1 to 10:
            if substring(vcelular,vv,1)  = "0" or
               substring(vcelular,vv,1)  = "1" or 
               substring(vcelular,vv,1)  = "2" or  
               substring(vcelular,vv,1)  = "3" or  
               substring(vcelular,vv,1)  = "4" or  
               substring(vcelular,vv,1)  = "5" or  
               substring(vcelular,vv,1)  = "6" or  
               substring(vcelular,vv,1)  = "7" or  
               substring(vcelular,vv,1)  = "8" or  
               substring(vcelular,vv,1)  = "9" 
            then.
            else vok = no.
        end.

        if vop <> "P" and vop <> "M"
        and vopecod = 1
        then do:
                if vopecod = 1 and substring(vcelular,1,4) = "5195" or
                   vopecod = 1 and substring(vcelular,1,4) = "5196" or
                   vopecod = 1 and substring(vcelular,1,4) = "5197" or
                   vopecod = 1 and substring(vcelular,1,4) = "5198" or
                   vopecod = 1 and substring(vcelular,1,4) = "5199" or
                   vopecod = 1 and substring(vcelular,1,4) = "5495" or          
                   vopecod = 1 and substring(vcelular,1,4) = "5496" or
                   vopecod = 1 and substring(vcelular,1,4) = "5497" or
                   vopecod = 1 and substring(vcelular,1,4) = "5498" or
                   vopecod = 1 and substring(vcelular,1,4) = "5499" or
                   vopecod = 1 and substring(vcelular,1,4) = "5595" or
                   vopecod = 1 and substring(vcelular,1,4) = "5596" or
                   vopecod = 1 and substring(vcelular,1,4) = "5597" or
                   vopecod = 1 and substring(vcelular,1,4) = "5598" or
                   vopecod = 1 and substring(vcelular,1,4) = "5599"      
                then vok = yes.
                else vok = no.
        end.
        
        if vop <> "P" and vop <> "M"
        and vopecod = 2                      
        then do:
                if vopecod = 2 and substring(vcelular,1,4) = "5181" or
                   vopecod = 2 and substring(vcelular,1,4) = "5182" or
                   vopecod = 2 and substring(vcelular,1,4) = "5183" or
                   vopecod = 2 and substring(vcelular,1,4) = "5481" or
                   vopecod = 2 and substring(vcelular,1,4) = "5482" or
                   vopecod = 2 and substring(vcelular,1,4) = "5483" OR
                   vopecod = 2 and substring(vcelular,1,4) = "5581" or
                   vopecod = 2 and substring(vcelular,1,4) = "5582" or
                   vopecod = 2 and substring(vcelular,1,4) = "5583"     
                then vok = yes.
                else vok = no.
        end.  

        if vop <> "P" and vop <> "M"
        and vopecod = 3
        then do:
                if vopecod = 3 and substring(vcelular,1,4) = "5191" or
                   vopecod = 3 and substring(vcelular,1,4) = "5192" or
                   vopecod = 3 and substring(vcelular,1,4) = "5193" or
                   vopecod = 3 and substring(vcelular,1,4) = "5194" or
                   vopecod = 3 and substring(vcelular,1,4) = "5491" or
                   vopecod = 3 and substring(vcelular,1,4) = "5492" or
                   vopecod = 3 and substring(vcelular,1,4) = "5493" or
                   vopecod = 3 and substring(vcelular,1,4) = "5494" or
                   vopecod = 3 and substring(vcelular,1,4) = "5591" or
                   vopecod = 3 and substring(vcelular,1,4) = "5592" or
                   vopecod = 3 and substring(vcelular,1,4) = "5593" or
                   vopecod = 3 and substring(vcelular,1,4) = "5594"             
                then vok = yes.
                else vok = no.
        end. 
        
       /* if (vprocod = 408793 or vprocod = 408794) then vok = yes. */

        if vok = no 
        then do:
            message "Celular Invalido".
            pause.
            undo, retry.
        end.
        
    end.

    do on error undo, retry:
        update  vcor-15 label "Serial - ESN/IMEI" format "x(20)"
                 with frame f-habil.
        sresp = yes.
        run esn_imei.p(input vcor-15, output sresp).
        if sresp = no
        then do:
            message color red/with
                 "CAMPO OBRIGATORIO Serial - ESN/IMEI"
                 skip
                 "Favor informar os dados corretamente"
                 view-as alert-box.
            undo, retry.    
        end.        
        vparam = "".
        vparam = "TIPO=" + trim(operadora.openom) 
                                        + "|SERIAL=" + vcor-15.
        
        /*
        val-price = yes.
        run agil-price.
        if val-price = no 
        then undo, retry.
        */
    end.    
    find habil where habil.ciccgc  = vciccgc
                 and habil.celular = vcelular no-lock no-error.
    if avail habil
    then do:                            
        find func where func.etbcod = habil.etbcod
                    and func.funcod = habil.vencod no-lock.
        
        disp skip 
             habil.vencod @ vvencod
             func.funnom no-label   skip
                 with frame f-habil.          
             
        message "Habilitacao ja Cadastrada".
        pause. undo.
        
    end.
    else do:
            
        
        
        message "Confirma os Dados Informados?" update sresp.
        if sresp
        then do:
           create habil.        
           assign habil.etbcod  = vetbcod
                  habil.celular = vcelular
                  habil.habdat  = today
                  habil.ciccgc  = vciccgc
                  habil.vencod  = vvencod
                  habil.procod = vprocod
                  habil.tipviv  = vtipviv
                  habil.habval = vhabval
                  habil.codviv = vcodviv
                  habil.gercod  = (if vop = "H"
                                   then 1
                                   else if vop = "M"
                                        then 2
                                        else 5)
                  habil.pmtcod  = 0
                  habil.habsit  = vcor-15.
                  
           message "Habilitacao Incluida". pause 1 no-message.
        end.    
    end.    
    
end.                                                      
