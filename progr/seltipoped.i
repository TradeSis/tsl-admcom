{setbrw.i}

/*** colocar no programa principal 
def temp-table tt-tipoped no-undo
    field marca as char
    field codigo as char
    field nome   as char
    index i1 codigo.
***/

for each tt-tipoped: delete tt-tipoped. end.
def var vok-tipo as log.
for each tbgenerica where tbgenerica.TGTabela = "TP_PEDID" NO-LOCK by 
                                                tbgenerica.tgint.

    vok-tipo = no.
    for each tt-estab where tt-estab.sim = yes:
        find first xpedid where xpedid.etbcod = tt-estab.etbcod 
                       and xpedid.pedtdc = com.pedid.pedtdc 
                       and xpedid.sitped = "E" 
                       and xpedid.peddat >= today - 45 
                       and xpedid.peddat <= today 
                       and xpedid.modcod = tbgenerica.TGCodigo
                       no-lock no-error.
        if avail xpedid
        then do:
            vok-tipo = yes.
            leave.
        end.               
    end.                   
    if vok-tipo
    then do:
        create tt-tipoped.
        assign
            tt-tipoped.marca  = "*"
            tt-tipoped.codigo = tbgenerica.TGCodigo
            tt-tipoped.nome   = tbgenerica.tgdescricao
            .
    end.
end.

form  tt-tipoped.marca  format "x" no-label
      tt-tipoped.codigo column-label "Tipo"
      tt-tipoped.nome   column-label "Descricao" format "x(25)"
      with frame {1} {2} {3} {4} {5} {6} {7} {8} {9} 
      title " marcar tipos de pedidos "
      .
      
assign
        a-seeid = -1 a-recid = -1 a-seerec = ?  .
        
message "Atenção: Mesmo selecionando os tipos de pedidos, a ordem de prioridade de atendimento será mantida!".

l1: repeat:

    {sklclstb.i  
        &color = with/cyan
        &file = tt-tipoped   
        &cfield = tt-tipoped.nome
        &noncharacter = /* 
        &ofield = " tt-tipoped.marca
                    tt-tipoped.codigo "  
        &aftfnd1 = " 
        "
        &where  = " true "
        &aftselect1 = " 
                      if tt-tipoped.marca = ""*""
                      then tt-tipoped.marca = """".
                      else tt-tipoped.marca = ""*"".
                      disp tt-tipoped.marca with frame f-linha.
                      a-recid = recid(tt-tipoped).
                      next l1. 
                        "
        &go-on = TAB 
        &naoexiste1 = " 
                        bell.
                        message color red/with
                        ""Nenhum pedido disponivel para corte.""
                        view-as alert-box.
                        leave l1. " 
        &otherkeys1 = " 
        message
        ""Atenção: Mesmo selecionando os tipos de pedidos, a ordem de prioridade de atendimento será mantida!"".
        "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        sresp = no.
        message "Confirma tipos de pedidos marcados?" update sresp.
        if sresp = no
        then for each tt-tipoped: delete tt-tipoped. end.
        leave l1.       
    END.
end.



