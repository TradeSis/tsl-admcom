{admcab.i}
def input param par-abatipo like abastransf.abatipo.

def var pabtcod like abastransf.abtcod.


def var p-ok as logical initial no.

run p-valsenha.
if p-ok = no then return.

def var vabtsit as int.
def var cabtsit as char extent 3
    init ["AC","IN","SE"].
def var vtempedido  as log.

def var vprocod like produ.procod.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata like pedid.peddat.

def new shared var qtd-mix as dec.
def new shared var tem-mix as log.
def new shared var pro-mix as log.


def temp-table ttabastransf no-undo
    field abtcod    like abastransf.abtcod
    field etbcod    like abastransf.etbcod
    field dttransf  like abastransf.dttransf
    field procod    like abastransf.procod
    field abtqtd    like abastransf.abtqtd
    field lipcor    like abastransf.lipcor
    index idx is unique primary etbcod asc abtcod asc.

def var vlipcor like abastransf.lipcor.
def var vabtqtd like abastransf.abtqtd format ">>>>9".

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".
def var v-status        as char.

def var vlibera-produto as logical.

if v-status = "no" or 
   v-status = "nao"  
then do:  
    message "Loja sem permissao para incluir Pedido Manual".
    pause.
    return.
end.
find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = setbcod and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.
if not avail tbcntgen
then do:
    message color red/with  skip
    "FILIAL SEM PERMISSAO PARA PEDIDO MANUAL NESTE MENU"
    view-as alert-box.
    return.
end.
def var vmovqtm as dec.
def var val-conjunto as dec.
def var smix as log.
def buffer bestoq for estoq.

do:

    for each ttabastransf.
        delete ttabastransf.
    end.
    
    vetbcod = setbcod.
    vdata   = today.
    
    disp vetbcod colon 18 with frame f1 side-label row 4
                centered color white/red.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame f1.
    update vdata colon 18 skip with frame f1.
    
    repeat:
       do on error undo, retry:
           vlipcor = "".
           vabtqtd = 0.
           vprocod = 0.
        
          update vprocod  /*validate(vprocod <> 407585 or
                                 setbcod = 85,  
                 "Produto bloqueado para pedido manual")*/
                 column-label "Codigo"
                        with no-validate frame f2.
          find produ where produ.procod = vprocod no-lock no-error.
          if not avail produ
          then do:
              message "produto nao cadastrado.".
              pause. 
              undo.
          end.
        
          if produ.proipival = 1
          then do:
              message 
              "Bloqueado pedido manual para produto de pedido especial.".
              pause.
              undo.
          end.    
        
          find first ttabastransf where 
                                ttabastransf.procod = produ.procod no-error.
          if avail ttabastransf
          then do:
              message "Produto ja incluido.".
              pause.
              undo.
          end.
        
          assign vlibera-produto = no. 

          /* Alguns produtos devem passar direto sem validar */
          if vprocod = 14384
              or vprocod = 487005
              or vprocod = 487004
              or vprocod = 479260
              or vprocod = 462281
          then assign vlibera-produto = yes.
          else assign vlibera-produto = no.
            
            
          if not vlibera-produto    
          then do:
                  
              {tbcntgen6.i today}
              if avail tbcntgen
              then do:
                  bell.
                  message color red/with
                  "Produto bloqueado para distribuicao."
                  view-as alert-box.
                  undo.    
              end.
              find bestoq where
                   bestoq.etbcod = 900 and
                   bestoq.procod = produ.procod no-lock no-error.
              if not avail bestoq or
                bestoq.estatual <= 0
              then find bestoq where
                        bestoq.etbcod = 981 and
                        bestoq.procod = produ.procod no-lock no-error.
              if not avail bestoq or
                  bestoq.estatual <= 0
              then do:
                  message color red/with
                  "Nao sera possivel fazer pedido de produto com estoque "
                  " zerado no CD"
                    view-as alert-box.
                  undo. 
              end.
              
              find estoq where estoq.procod = produ.procod and
                               estoq.etbcod = setbcod no-lock.
              def var vqtdsug as int.
              sretorno = "".
              val-conjunto = 0.
              smix = no.        
              run abas/tem-mix.p(input produ.procod,
                          output smix).
              if smix = no
              then do:
                  message color red/with
                    "Produto " produ.procod
                    "nao esta no MIX da filial, pedido manual nao permitido"
                    view-as alert-box.
                  undo. 
              end.
        
              run vercobertura1.p(input produ.procod,
                               input 0,
                               output sresp,
                               output vqtdsug,
                               output vmovqtm,
                               output val-conjunto).
              if vqtdsug = -1
              then do:
                  vqtdsug = 0.
                  message color red/with
                    "Produto " produ.procod
                    "nao tem COBERTURA para a filial"
                    view-as alert-box.
                  undo.    
              end.

              vtempedido = no.
              do vabtsit = 1 to 3. 
                for each abastipo no-lock. 
                    for each abastransf where 
                        abastransf.abtsit   = cabtsit[vabtsit] and  
                        abastransf.abatipo  = abastipo.abatipo and 
                        abastransf.etbcod = setbcod and
                        abastransf.procod = vprocod and
			abastransf.dttransf >= vdata
                        no-lock.
                       if avail abastransf then do:
		       vtempedido = yes.
                       end.
			 leave.
                    	
			end.
                end.
              end.                            
              if vtempedido = yes
              then do:
                    message color red/with
                    "Produto " produ.procod produ.pronom skip
                    "ja possui pedido na data " today
                    view-as alert-box.
                    undo.    
               end.          
          end. /* if not vlibera-produto */
       end.
       
       display produ.pronom format "x(30)" 
               estoq.estatual format "->>9" column-label "Est."
                                when avail estoq
               int(sretorno) format ">>9" column-label "Cob."
               vmovqtm format ">>9" column-label "Venda!30dias"
        with frame f2.
       if val-conjunto > 0 
       then do:
                message color red/with 
                    " PRODUTO DE CONJUNTO " SKIP(1)
                    " CONJUNTO com " val-conjunto "unidades."
                    view-as alert-box title "".
       end.

       do on error undo:
            
           vabtqtd = vqtdsug.
           /* por solicitacao de Priscila Drebes em 30/10/2014 foi 
              solicitado que nao apareca a quantidade sugerida na 
              quantidade solicitada no pedido das filials */
           vabtqtd = 0.                 
           
           update vabtqtd column-label "Qtd"
                with frame f2 down centered color blank/cyan.
                
           /*Chamado 893 - Nede - 29/03/2012*/
           if (produ.procod = 487005 or produ.procod = 487004 or 
               produ.procod = 14384 or produ.procod = 462281) and vabtqtd > 5
           then do:
               message color red/with
                   "* Quantidade nao permitida."
                    view-as alert-box.
               undo.
              
           end.   
              
                
                
                
           if   vabtqtd > 0 and tem-mix = yes and pro-mix = no
           then do:
                message color red/with
                   "** Quantidade nao permitida."
                    view-as alert-box.
                 undo.
           end.
           
           if not vlibera-produto
           then do:
           
               if vabtqtd = 0 or
                   vabtqtd > vqtdsug 
               then do:
                   message color red/with
                      "*** Quantidade nao permitida. " 
                       view-as alert-box.
                   undo.    
               end.
               if val-conjunto > 0 
               then do:
                   if vabtqtd >= val-conjunto   and
                     int(substr(string(vabtqtd / val-conjunto,"->>>>>>>9.99"),
                            11,2)) = 0
                   then do:
                     message color red/with 
                        " PRODUTO DE CONJUNTO " SKIP(1)
                        " Quntidade pedida " vabtqtd "sera enviada."
                        view-as alert-box title "".
                   end.
                   else do:
                      message color red/with
                      "Quantidade nao permitida." skip
                      "PRODUTO DE CONJUNTO" SKIP
                      "QUANTIDADE DEVE SER MULTIPLA DE " VAL-CONJUNTO
                         view-as alert-box.
                      undo.
                   end.     
               end.
           end.         
        
           end.

           if produ.procod = 406723 or
               produ.procod = 406724
           then do: 
               if vabtqtd > 1 
               then do:
                    message "Quantidade Maxima do Produto excedida. ".
                    undo.
               end.

               find first ttabastransf where 
                                  ttabastransf.etbcod = vetbcod and  
                                  ttabastransf.procod = produ.procod no-error.
               if avail ttabastransf
               then do:
                   if ttabastransf.abtqtd >= 1
                   then do:
                       message "Quantidade Maxima do Produto excedida.".
                       undo.
                   end.
               end.
           end.
        
        update vlipcor column-label "Cor" with frame f2.
        
        find ttabastransf where 
                            ttabastransf.etbcod = vetbcod and
                            ttabastransf.procod = produ.procod    and
                            ttabastransf.lipcor = vlipcor         and
                            ttabastransf.dttransf  = vdata 
                            no-error.
        if avail ttabastransf
        then ttabastransf.abtqtd = ttabastransf.abtqtd + vabtqtd.
        else do:
            create ttabastransf.
            assign ttabastransf.dttransf  = vdata
                   ttabastransf.etbcod = vetbcod
                   ttabastransf.procod = produ.procod
                   ttabastransf.abtqtd = vabtqtd
                   ttabastransf.lipcor = vlipcor.
        end.
    end.
    

    find first ttabastransf no-error.
    if not avail ttabastransf
    then return.
    
    message "Confirma inclusao do pedido " update sresp.
    if sresp
    then do:
        do transaction:
            for each ttabastransf:
            
                    run abas/transfcreate.p (par-abatipo, 
                                                ttabastransf.etbcod,
                                                ttabastransf.procod,
                                                ttabastransf.abtqtd,
                                                ttabastransf.lipcor,
                                                ttabastransf.dttransf,
                                                "DIGITADO",  /* ORIGEM DIGITADO,MOVIM,EXTERNO*/
                                                "",
                                                output pabtcod).
            
            end.
        end.
        do:
            message color red/with
                "Pedidos gerados! "
                view-as alert-box.
        end.         
    end.
end.


procedure p-valsenha:
     def var vfuncod like func.funcod.
     def var vsenha like func.senha.
     def var vetbcod like estab.etbcod.
     
     def buffer bfunc for func.
     
     vfuncod = 0. vsenha = "". 
     
     update vfuncod label "Matricula"
            vsenha  label "Senha" blank
            with frame f-senha side-label centered color message.
     
     find bfunc where bfunc.etbcod = setbcod
                  and bfunc.funcod = vfuncod no-lock no-error.
     if not avail bfunc
     then do:
         message "Funcionario Invalido".
         sresp = no.
         undo, retry.
     end.
     if bfunc.funmec = no
     then do:
        message "Funcionario nao e gerente".
        sresp = no.
        undo, retry.
     end.
     if vsenha <> bfunc.senha
     then do:
         message "Senha invalida".
         sresp = no.
         undo, retry.
     end.
     else p-ok = yes.
end procedure.
