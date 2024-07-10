def input parameter p-etbcod like estab.etbcod.
def input parameter pro-chama as char.
def output parameter p-ok as log.

def var vretorno as log format "Sim/Nao" init no.
def var vmotivo as char.
def var cod-libera as char.

p-ok = yes.
find first A01_infnfe where A01_infnfe.solicitacao <> ""  and
                            A01_infnfe.solicitacao <> "Re-envio Email" and
                            A01_infnfe.etbcod = p-etbcod
                            no-lock no-error.
if avail A01_infnfe
then p-ok = no.
/*
p-ok = yes.
*/
if p-ok = no
then do:

    vmotivo = "Exite NFe pendente. !Entre em contato com SETOR CONTABIL" +
          "!    para providenciar liberação."  .

    run mensagem.p (input-output vretorno,
                           input vmotivo
                              +  "!! ",
                                 input " NFe Bloqueada ",
                                 input "", 
                                 input "").
 
    if vretorno = yes
    then repeat:
    
        update cod-libera label "Codigo liberação NFe"
            "     Código fornecido pelo SETOR CONTÁBIL" 
            with frame f-lib 1 down
            width 80 color message row 20
            side-label no-box overlay.
        hide frame f-lib.  

        find first tbcntgen where
                   tbcntgen.tipcon = 8 and 
                   tbcntgen.etbcod = p-etbcod and
                   tbcntgen.numini = "" and
                   tbcntgen.numfim = ""
                   no-lock no-error.
        if avail tbcntgen and
                 tbcntgen.validade >= today
        then do:
            if tbcntgen.campo1[1] = cod-libera
            then do:
                if tbcntgen.quantidade = 0 
                then p-ok = yes.
                else if int(tbcntgen.valor) > int(time)
                    then p-ok = yes.
            end. 
        end.
        if p-ok = yes
        then leave.
        
        message "Codigo invalido ou perdeu a validade, solicite novamente."                             view-as alert-box.
        pause.
        
    end.
     
end.
                                                         

