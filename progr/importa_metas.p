{admcab.i}
def input parameter p-mes as int.
def input parameter p-ano as int.
def var vmes as int.
def var vano as int.
vmes = p-mes.
vano = p-ano.
 
disp p-mes label "Mes"
     p-ano label "Ano"
     with frame f-top side-label color message no-box
     width 80.
def var vindex as int.      
def var v-escolhe as char format "x(18)" extent 6
     init["  VENDA",
          "  SEGURO",
          "  CREDITO PESSOAL",
          "  INADINPLENCIA",
          "  GARANTIA",
          "  RFQ"].
disp v-escolhe with frame f-esc 1 down no-label 1 column width 80.
choose field v-escolhe with frame f-esc. 
vindex = frame-index.
disp "IMPORTAR ARQUIVO METAS " trim(v-escolhe[vindex]) format "x(20)"
  with frame f-top.

def var varq-importa as char.
do on error undo:
    update varq-importa label "Arquivo" format "x(65)" 
        with frame f-arq 1 down side-label width 80.
    if search(varq-importa) = ?
    then do:
        bell.
        message "Arquivo nao encontrado."
        view-as alert-box.
        undo.
    end.
end.
def temp-table tt-dados
    field num_linha as int
    field val_linha as char
    field val_campo as char extent 10 
    index i1 num_linha
    .
def var varq-problema as log init no.
def var vlinha as char.
def var vi as int init 0.
def var vq as int init 0.
input from value(varq-importa).
repeat:
    import unformatted vlinha.
    vq = vq + 1.
    if (vindex = 2 and
        num-entries(vlinha,";") <> 3) or
       (vindex = 1 and
        num-entries(vlinha,";") <> 3) or
       (vindex = 3 and
        num-entries(vlinha,";") <> 2) or
       (vindex = 4 and
        num-entries(vlinha,";") <> 5) or
       (vindex = 5 and
        num-entries(vlinha,";") <> 2) or
       (vindex = 6 and
        num-entries(vlinha,";") <> 2) 
    then do:
        message color red/with
        "Arquivo com problema de layout."
        view-as alert-box.
        varq-problema = yes.
        leave.
    end.
    /*if vq > 1
    then*/ do:
        create tt-dados.
        tt-dados.num_linha = vq.
        tt-dados.val_linha = vlinha.
        do vi = 1 to num-entries(vlinha,";"):
            tt-dados.val_campo[vi] = entry(vi,vlinha,";").    
        end.
    end.    
end.
input close.    
if varq-problema then return.

for each tt-dados:
    disp tt-dados.val_linha no-label format "x(78)" .
end.    

sresp = no.
message "Confirma importar " v-escolhe[vindex] "?" update sresp.
if not sresp then return.


def new shared temp-table tt-metven like metven
    field vp-moveis as int
    field vp-moda   as int
    field ms-moda   as int
    field ms-moveis as int
    index i1 metano metmes etbcod .

def buffer btabaux for tabaux.
for each tt-dados:
    find first tt-metven where
               tt-metven.metano = p-ano and
               tt-metven.metmes = p-mes and
               tt-metven.etbcod = int(tt-dados.val_campo[1])
               no-error.
    if not avail tt-metven
    then do:            
        create tt-metven.
        assign
            tt-metven.metano = p-ano
            tt-metven.metmes = p-mes
            tt-metven.etbcod = int(tt-dados.val_campo[1])
            .
    end.
    if vindex = 1
    then do:
        assign
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],".","")
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],",",".")   
            tt-metven.aux-dec     = dec(tt-dados.val_campo[2])
            tt-dados.val_campo[3] = replace(tt-dados.val_campo[3],".","")
            tt-dados.val_campo[3] = replace(tt-dados.val_campo[3],",",".") 
            tt-metven.metval      = dec(tt-dados.val_campo[3])
            tt-metven.dias        = int(tt-dados.val_campo[4])
            tt-metven.aux-cha1    = tt-dados.val_campo[5]
            tt-metven.aux-cha2    = tt-dados.val_campo[6]
            .
    
        find first duplic where duplic.duppc = tt-metven.metmes and
                          duplic.fatnum = tt-metven.etbcod 
                          no-error.
        if not avail duplic
        then do:                  
            create duplic.
            assign
            duplic.duppc = tt-metven.metmes
            duplic.fatnum = tt-metven.etbcod
            .
        end.
        else 
        assign    
            duplic.dupjur = tt-metven.metval 
            duplic.dupval = tt-metven.aux-dec
            duplic.dupdia = tt-metven.dias
                       .
    end.
    else if vindex = 2
    then do:
        assign
            tt-metven.ms-moda     = int(tt-dados.val_campo[2])
            tt-metven.ms-moveis   = int(tt-dados.val_campo[3])
            .
    
        find first duplic where duplic.duppc = tt-metven.metmes and
                          duplic.fatnum = tt-metven.etbcod 
                          no-error.
        if not avail duplic
        then do:                  
            create duplic.
            assign
            duplic.duppc = tt-metven.metmes
            duplic.fatnum = tt-metven.etbcod
            .
        end.    
                
        find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") +
                                            ";" + string(duplic.duppc,"99")
                       no-error.
        if not avail tabaux
        then do:
            create tabaux.
            assign
                tabaux.tabela = "META-VENDA-31"
                tabaux.nome_campo = string(duplic.fatnum,"999") +
                                        ";" + string(duplic.duppc,"99")
                tabaux.tipo_campo = "INT"                        
                                        .
        end.                  
        else tt-metven.aux-cha1 = entry(1,tabaux.valor_campo,";").              
        tabaux.valor_campo = tt-metven.aux-cha1 + ";" +
                             string(tt-metven.ms-moveis).
        find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") +
                                ";" + string(duplic.duppc,"99")
                       no-error.
        if not avail btabaux
        then do:
            create btabaux.
            assign
                btabaux.tabela = "META-VENDA-41"
                btabaux.nome_campo = string(duplic.fatnum,"999") +
                                        ";" + string(duplic.duppc,"99")
                btabaux.tipo_campo = "INT" .
        end.        
        else tt-metven.aux-cha2 = entry(1,btabaux.valor_campo,";").
        btabaux.valor_campo = tt-metven.aux-cha2 + ";" +
                              string(tt-metven.ms-moda).
        duplic.dupven = today.
    end.
    else if vindex = 3
    then do:
        find tabmeta where tabmeta.codtm  = vindex and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = tt-metven.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
        if not avail tabmeta
        then do:
            create tabmeta.
            assign
                tabmeta.codtm  = vindex
                tabmeta.anoref = p-ano
                tabmeta.mesref = p-mes
                tabmeta.diaref = 0
                tabmeta.etbcod = tt-metven.etbcod
                tabmeta.funcod = 0
                tabmeta.clacod = 0
            .
        end.
        assign
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],".","")
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],",",".")   
            tabmeta.val_meta = dec(tt-dados.val_campo[2])
            .
    end.
    else if vindex = 4
    then do:
        find tabmeta where tabmeta.codtm  = vindex and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = tt-metven.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
        if not avail tabmeta
        then do:
            create tabmeta.
            assign
                tabmeta.codtm  = vindex
                tabmeta.anoref = p-ano
                tabmeta.mesref = p-mes
                tabmeta.diaref = 0
                tabmeta.etbcod = tt-metven.etbcod
                tabmeta.funcod = 0
                tabmeta.clacod = 0
            .
        end.
        assign
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],".","")
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],",",".")   
            tabmeta.ValMeta4[1]   = dec(tt-dados.val_campo[2])
            tt-dados.val_campo[3] = replace(tt-dados.val_campo[3],".","")
            tt-dados.val_campo[3] = replace(tt-dados.val_campo[3],",",".") 
            tabmeta.ValMeta5[1]   = dec(tt-dados.val_campo[3])
            tt-dados.val_campo[4] = replace(tt-dados.val_campo[4],".","")
            tt-dados.val_campo[4] = replace(tt-dados.val_campo[4],",",".") 
            tabmeta.ValMeta4[2]   = dec(tt-dados.val_campo[4])
            tt-dados.val_campo[5] = replace(tt-dados.val_campo[5],".","")
            tt-dados.val_campo[5] = replace(tt-dados.val_campo[5],",",".") 
            tabmeta.ValMeta5[2]   = dec(tt-dados.val_campo[5])
            tabmeta.val_meta = dec(tt-dados.val_campo[2]) +
                                dec(tt-dados.val_campo[4]).
    end.
    else if vindex = 5
    then do:
        find tabmeta where tabmeta.codtm  = vindex and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = tt-metven.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
        if not avail tabmeta
        then do:
            create tabmeta.
            assign
                tabmeta.codtm  = vindex
                tabmeta.anoref = p-ano
                tabmeta.mesref = p-mes
                tabmeta.diaref = 0
                tabmeta.etbcod = tt-metven.etbcod
                tabmeta.funcod = 0
                tabmeta.clacod = 0
            .
        end.
        assign
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],".","")
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],",",".")   
            tabmeta.val_meta = dec(tt-dados.val_campo[2])
            .
    end.
    else if vindex = 6
    then do:
        find tabmeta where tabmeta.codtm  = vindex and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = tt-metven.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
        if not avail tabmeta
        then do:
            create tabmeta.
            assign
                tabmeta.codtm  = vindex
                tabmeta.anoref = p-ano
                tabmeta.mesref = p-mes
                tabmeta.diaref = 0
                tabmeta.etbcod = tt-metven.etbcod
                tabmeta.funcod = 0
                tabmeta.clacod = 0
            .
        end.
        assign
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],".","")
            tt-dados.val_campo[2] = replace(tt-dados.val_campo[2],",",".")   
            tabmeta.val_meta = dec(tt-dados.val_campo[2])
            .
    end.
end.    
for each tt-metven. delete tt-metven. end.
def buffer btt-metven for tt-metven.
create btt-metven.
assign
    btt-metven.metano = vano
    btt-metven.metmes = vmes
    btt-metven.etbcod = 0
    .

for each duplic where 
         duplic.duppc = vmes no-lock:
    create tt-metven.
    assign
        tt-metven.metano = vano
        tt-metven.metmes = vmes
        tt-metven.etbcod = duplic.fatnum
        tt-metven.metval = duplic.dupjur
        tt-metven.aux-dec = duplic.dupval
        tt-metven.dias = duplic.dupdia .
    btt-metven.metval =  btt-metven.metval + duplic.dupjur.
    btt-metven.aux-dec = btt-metven.aux-dec + duplic.dupval.
    btt-metven.dias = btt-metven.dias + duplic.dupdia.
    find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(duplic.fatnum,"999") +
                                   ";" + string(vmes,"99") 
               no-lock no-error.
    if avail tabaux and tabaux.valor_campo <> ""
    then do:
        if num-entries(tabaux.valor_campo,";") = 1
        then do:
            tt-metven.aux-cha1 = tabaux.valor_campo.
            btt-metven.aux-cha1 = string(int(btt-metven.aux-cha1) +
                    int(tabaux.valor_campo)).
        end.
        else do:
            tt-metven.aux-cha1 = entry(1,tabaux.valor_campo,";").
            tt-metven.ms-moveis = int(entry(2,tabaux.valor_campo,";")).
            btt-metven.ms-moveis = btt-metven.ms-moveis +
                        int(entry(2,tabaux.valor_campo,";")).
            btt-metven.aux-cha1 = string(int(btt-metven.aux-cha1) +
                    int(entry(1,tabaux.valor_campo,";"))).
        end.
    end.                
    find first tabaux where
               tabaux.tabela = "META-VENDA-41" and
               tabaux.nome_campo = string(duplic.fatnum,"999") +
                            ";" + string(vmes,"99")
               no-lock no-error.
    if avail tabaux and tabaux.valor_campo <> ""
    then do:
        if num-entries(tabaux.valor_campo,";") = 1
        then do:
            tt-metven.aux-cha2 = tabaux.valor_campo.
            btt-metven.aux-cha2 = string(int(btt-metven.aux-cha2) +
                            int(tabaux.valor_campo)).
        end.    
        else do:
            tt-metven.aux-cha2 = entry(1,tabaux.valor_campo,";").
                tt-metven.ms-moda = int(entry(2,tabaux.valor_campo,";")).
                btt-metven.ms-moda = btt-metven.ms-moda +
                                int(entry(2,tabaux.valor_campo,";")).
                btt-metven.aux-cha2 = string(int(btt-metven.aux-cha2) +
                    int(entry(1,tabaux.valor_campo,";"))).
        end.
    end.
    find first tvendfil where
               tvendfil.anoref = vano and
               tvendfil.mesref = vmes and
               tvendfil.etbcod = duplic.fatnum
               no-lock no-error.
    if avail tvendfil
    then assign
             tt-metven.vp-moveis  = tvendfil.moveis
             btt-metven.vp-moveis = btt-metven.vp-moveis + tvendfil.moveis
             tt-metven.vp-moda    = tvendfil.moda
             btt-metven.vp-moda   = btt-metven.vp-moda + tvendfil.moda   
             .
end. 

message color red/with
"Arquivo importado." view-as alert-box.

hide frame f-arq no-pause.
hide frame f-esc no-pause.
