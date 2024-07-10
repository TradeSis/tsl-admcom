{admcab.i}
/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}


                     /*neo_piloto*/
                    find first ttpiloto where ttpiloto.etbcod  = setbcod and
                                          ttpiloto.dtini  <= today
                        no-error.
                    if today >= wfilvirada or 
                       avail ttpiloto  
                    then do:
                        run abas/transfinclu.p ("MAN",
                                                setbcod).
                        
                        return.
                    end.    



def var p-ok as logical initial no.
run p-valsenha.
if p-ok = no then return.

def var vprocod like produ.procod.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata like pedid.peddat.

def new shared var qtd-mix as dec.
def new shared var tem-mix as log.
def new shared var pro-mix as log.

def buffer bpedid for pedid.
def buffer qliped for liped.
def temp-table tt-pedid like pedid.
def temp-table tt-liped like liped.

def new shared temp-table atu-pedid         like com.pedid.
def new shared temp-table atu-liped         like com.liped.

def var vlipcor like liped.lipcor.
def var vlipqtd like liped.lipqtd format ">>>>9".

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".
def var v-status        as char.

def var vlibera-produto as logical.

/*
input from /usr/admcom/admcom.ini no-echo.
repeat:

    set funcao parametro.
    if funcao = "PEDIDOMANUAL"
    then v-status = parametro.

end.
input close.
*/

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
repeat:

    for each tt-liped.
        delete tt-liped.
    end.
    
    for each tt-pedid.
        delete tt-pedid.
    end.
    
    vetbcod = setbcod.
    vdata   = today.
    disp vetbcod colon 18 with frame f1 side-label row 4
                centered color white/red.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame f1.
    update vdata colon 18 skip with frame f1.
    
    find last pedid where
              pedid.pedtdc = 3 and
              pedid.etbcod = setbcod  and
              pedid.pednum < 100000 no-lock no-error.
    
    /*
    find last pedid where pedid.pedtdc = 3 and
                          pedid.etbcod = estab.etbcod no-lock no-error.
    */
    if avail pedid
    then vpednum = pedid.pednum + 1.
    else vpednum = 1.
    
    create tt-pedid.
    assign tt-pedid.pedtdc    = 3 
           tt-pedid.pednum    = vpednum 
           tt-pedid.regcod    = estab.regcod 
           tt-pedid.peddat    = vdata 
           tt-pedid.pedsit    = yes 
           tt-pedid.sitped    = "E" 
           tt-pedid.modcod    = "PEDM" 
           tt-pedid.etbcod    = vetbcod.
    
    display tt-pedid.pednum colon 18 with frame f1.
    repeat:
       do on error undo, retry:
           vlipcor = "".
           vlipqtd = 0.
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
        
          find first tt-liped where tt-liped.etbcod = tt-pedid.etbcod 
                                and tt-liped.pedtdc = tt-pedid.pedtdc 
                                and tt-liped.pednum = tt-pedid.pednum 
                                and tt-liped.procod = produ.procod no-error.
          if avail tt-liped
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
              run tem-mix.p(input produ.procod,
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
                    "nao esta no MIX da filial"
                    view-as alert-box.
                  undo.    
              end.
              /*if (vqtdsug = 1 and
                  sresp = no) or
                vqtdsug = 0
              then*/
              do: 
                  find last qliped   where 
                            qliped.pedtdc = 3 and 
                            qliped.etbcod = setbcod and 
                            qliped.procod = produ.procod and
                            qliped.pednum < 100000
                            no-lock no-error.
                  if avail qliped and
                      qliped.predt >= vdata
                  then do:
                    message color red/with
                    "Produto " produ.procod produ.pronom skip
                    "ja possui pedido na data " today
                    view-as alert-box.
                    undo.    
                  end.          
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
            
           vlipqtd = vqtdsug.
           /* por solicitacao de Priscila Drebes em 30/10/2014 foi 
              solicitado que nao apareca a quantidade sugerida na 
              quantidade solicitada no pedido das filials */
           vlipqtd = 0.                 
           
           update vlipqtd column-label "Qtd"
                with frame f2 down centered color blank/cyan.
                
           /*Chamado 893 - Nede - 29/03/2012*/
           if (produ.procod = 487005 or produ.procod = 487004 or 
               produ.procod = 14384 or produ.procod = 462281) and vlipqtd > 5
           then do:
               message color red/with
                   "Quantidade nao permitida."
                    view-as alert-box.
               undo.
              
           end.   
              
                
                
                
           if   vlipqtd > 0 and tem-mix = yes and pro-mix = no
           then do:
                message color red/with
                   "Quantidade nao permitida."
                    view-as alert-box.
                 undo.
           end.
           
           if not vlibera-produto
           then do:
           
               if vlipqtd = 0 or
                   vlipqtd > vqtdsug /*+ 1*/
               then do:
                   message color red/with
                      "Quantidade nao permitida."
                       view-as alert-box.
                   undo.    
               end.
               if val-conjunto > 0 
               then do:
                   if vlipqtd >= val-conjunto   and
                     int(substr(string(vlipqtd / val-conjunto,"->>>>>>>9.99"),
                            11,2)) = 0
                   then do:
                     message color red/with 
                        " PRODUTO DE CONJUNTO " SKIP(1)
                        " Quntidade pedida " vlipqtd "sera enviada."
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
               if vlipqtd > 1 
               then do:
                    message "Quantidade Maxima do Produto excedida. ".
                    undo.
               end.

               find first tt-liped where tt-liped.etbcod = tt-pedid.etbcod 
                                  and tt-liped.pedtdc = tt-pedid.pedtdc 
                                  and tt-liped.pednum = tt-pedid.pednum 
                                  and tt-liped.procod = produ.procod no-error.
               if avail tt-liped
               then do:
                   if tt-liped.lipqtd >= 1
                   then do:
                       message "Quantidade Maxima do Produto excedida.".
                       undo.
                   end.
               end.
           end.
        
        update vlipcor column-label "Cor" with frame f2.
        
        find tt-liped where tt-liped.etbcod = tt-pedid.etbcod and
                            tt-liped.pedtdc = tt-pedid.pedtdc and
                            tt-liped.pednum = tt-pedid.pednum and
                            tt-liped.procod = produ.procod    and
                            tt-liped.lipcor = vlipcor         and
                            tt-liped.predt  = tt-pedid.peddat no-error.
        if avail tt-liped
        then tt-liped.lipqtd = tt-liped.lipqtd + vlipqtd.
        else do:
            create tt-liped.
            assign tt-liped.pednum = tt-pedid.pednum
                   tt-liped.pedtdc = tt-pedid.pedtdc
                   tt-liped.predt  = tt-pedid.peddat
                   tt-liped.etbcod = tt-pedid.etbcod
                   tt-liped.procod = produ.procod
                   tt-liped.lipqtd = vlipqtd
                   tt-liped.lipcor = vlipcor
                   tt-liped.protip = string(time).
        end.
    end.
    

    message "Confirma inclusao do pedido " update sresp.
    if sresp
    then do:
        do transaction:
        for each atu-pedid.
            delete atu-pedid.
        end.
        for each atu-liped.
            delete atu-liped.
        end.

        find first tt-liped where
                   tt-liped.procod > 0 and
                   tt-liped.lipqtd > 0
                   no-error.
        if avail tt-liped
        then do:
            find last pedid where
                      pedid.pedtdc = 3 and
                      pedid.etbcod = setbcod  and
                      pedid.pednum < 100000 no-lock no-error.
    
            if avail pedid
            then vpednum = pedid.pednum + 1.
            else vpednum = 1.
    
            create pedid.
            assign pedid.pedtdc    = 3
               pedid.pednum    = vpednum
               pedid.regcod    = estab.regcod
               pedid.peddat    = vdata
               pedid.pedsit    = yes
               pedid.sitped    = "E"
               pedid.modcod    = "PEDM"
               pedid.etbcod    = vetbcod.

    
            for each tt-liped:
                create liped.
                assign liped.pednum = pedid.pednum
                   liped.pedtdc = tt-liped.pedtdc
                   liped.predt  = tt-liped.predt
                   liped.etbcod = tt-liped.etbcod
                   liped.procod = tt-liped.procod
                   liped.lipqtd = tt-liped.lipqtd
                   liped.lipcor = tt-liped.lipcor
                   liped.protip = tt-liped.protip.
            end.
        end.
        end.
        find current pedid no-lock no-error.
        if avail pedid
        then do:
            message color red/with
                "Pedido gerado: " pedid.pednum
                view-as alert-box.
        end.         
    end.
end.

procedure atualiza-matriz.

def var vcont-pedid as int.
def var vcont-liped as int.
if connected ("com") 
then do:
    vcont-pedid = 0.
    vcont-liped = 0.
    for each atu-pedid.
        vcont-pedid = vcont-pedid + 1.
    end.
    for each atu-liped.
        vcont-liped = vcont-liped + 1.
    end.
    
    run fipedatu.p .
    vcont-pedid = 0.
    vcont-liped = 0.
    for each atu-pedid.
        vcont-pedid = vcont-pedid + 1.
    end.
    for each atu-liped.
        vcont-liped = vcont-liped + 1.
    end.
    if vcont-pedid = 0 and vcont-liped = 0
    then do:
        message "Pedido atualizado no Deposito".
        pause 3 no-message.
    end.
end.

end procedure.

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
