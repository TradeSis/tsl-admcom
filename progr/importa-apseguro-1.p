{admcab.i}

def var vtipo-imp as char extent 2 format "x(20)".
vtipo-imp[1] = "  Faturamento".
vtipo-imp[2] = "  Cancelamentos".
disp vtipo-imp with frame f-imc no-label.
choose field vtipo-imp with frame f-imc.
if frame-index = 2
then do:
    run importa-apseguro-can.p.
    return.
end.

def var vlinha as char.
def var vcap as char extent 20.
def var vi as int.
def var vq as int.
def var vtotal as dec.
def temp-table tt-cap
    field linha as int
    field valor as char extent 20
    field dados as char
    index i1 linha.


def var varquivo as char format "x(65)".

update varquivo label "Arquivo" with frame f1 side-label 1 down width 80.

/*
    /admcom/TI/claudir/seguro-abril-confirmacao.csv.
    */

input from value(varquivo).
repeat:
    import unformatted vlinha.
    vq = vq + 1.
    create tt-cap.
    tt-cap.linha = vq.
    tt-cap.dados = vlinha.
    if num-entries(vlinha,";") <> 20
    then do:
        message color red/with
        "Arquivo com problema de layout."
        view-as alert-box.
        return.
    end.
    do vi = 1 to 20:
        tt-cap.valor[vi] = entry(vi,vlinha,";").    
    end.
end.
input close.

sresp = no.
message "Confirma importar o arquivo?" update sresp.

def var vcpf as char.
def var produto_seguro as char.
def var apolice_seguro as char.
if sresp then
for each tt-cap:
    if tt-cap.valor[1] begins "Programa" 
    then produto_seguro = entry(1,tt-cap.valor[2],"-").
    if substr(tt-cap.valor[1],1,4) = "9839"
    then do:
        tt-cap.valor[13] = replace(tt-cap.valor[13],".","").
        tt-cap.valor[13] = replace(tt-cap.valor[13],",",".").
        tt-cap.valor[14] = replace(tt-cap.valor[14],".","").
        tt-cap.valor[14] = replace(tt-cap.valor[14],",","."). 
        tt-cap.valor[15] = replace(tt-cap.valor[15],".","").
        tt-cap.valor[15] = replace(tt-cap.valor[15],",",".").   
        tt-cap.valor[16] = replace(tt-cap.valor[16],".","").
        tt-cap.valor[16] = replace(tt-cap.valor[16],",",".").  
        tt-cap.valor[17] = replace(tt-cap.valor[17],".","").
        tt-cap.valor[17] = replace(tt-cap.valor[17],",","."). 
        tt-cap.valor[7] = replace(tt-cap.valor[7],".","").
        tt-cap.valor[7] = replace(tt-cap.valor[7],"-","").
        tt-cap.valor[7] = replace(tt-cap.valor[7],"/","").
        tt-cap.valor[7] = replace(tt-cap.valor[7],",","").
        disp tt-cap with no-label. 
        pause 0.
        apolice_seguro = trim(produto_seguro) + "." + tt-cap.valor[1].
        find apseguro where apseguro.apolice = apolice_seguro
                    no-lock no-error.
        if not avail apseguro
        then do:
            create apseguro.
            assign
                apseguro.apolice = apolice_seguro
                apseguro.endosso = tt-cap.valor[2]
                apseguro.apolice_mae = tt-cap.valor[3]
                apseguro.codigo_estipulante = tt-cap.valor[6]
                apseguro.estipulante = tt-cap.valor[7]
                apseguro.segurado = tt-cap.valor[8]
                apseguro.cpf = tt-cap.valor[9]
                apseguro.processamento = date(tt-cap.valor[10])
                apseguro.inicio_vigencia = date(tt-cap.valor[11])
                apseguro.termino_vigencia = date(tt-cap.valor[12])
                apseguro.vencimento = date(tt-cap.valor[13])
                apseguro.parcela = tt-cap.valor[14]
                apseguro.premio_total = dec(tt-cap.valor[15])
                apseguro.premio_liquido = dec(tt-cap.valor[16])
                apseguro.iof = dec(tt-cap.valor[17])
                apseguro.prolabore = dec(tt-cap.valor[18])
                apseguro.comissao  = dec(tt-cap.valor[19])
                apseguro.lote = tt-cap.valor[20]
                apseguro.campo_char1 = tt-cap.dados
                apseguro.campo_log1 = yes
                .
        end.
        vtotal = vtotal + apseguro.premio_total.
    end.
end.
hide frame f1 no-pause. 
message color red/with
"Valor importado" string(vtotal,">>,>>>,>>9.99")
view-as alert-box.

