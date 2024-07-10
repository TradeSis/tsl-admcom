{admcab.i}

def var v-op as char format "x(15)" extent 4
    init["EMISSAO","PROCESSADAS","PENDENTES","CONFIGURACOES"].
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.   
def var vindex as int.

def var p-valor as char.
p-valor = "".
run le_tabini.p (setbcod, 0,
            "NFE - AMBIENTE", OUTPUT p-valor) .
if p-valor = "PRODUCAO"
THEN v-op[4] = "".

if connected ("nfe")
then do on error undo:
    DISP v-op with frame f1 centered 1 down no-label.
    choose field v-op with frame f1.
    vindex = frame-index.
    if v-op[vindex] = ""
    then undo.
    if vindex = 2 or vindex = 3
    then do:
        if setbcod = 999
        then do:
        update vetbcod label "Filial" with frame f2 side-label.
        end.
        else vetbcod = setbcod.
        disp vetbcod 
            estab.etbnom no-label with frame f2.
        find estab where estab.etbcod = vetbcod no-lock.
        update vdti  label "Emissao Inicio"
               vdtf  label "Fim"
               with frame f2.
    end.
    if vindex = 4 
    then do:
        run tab_ini_ssh.p("NFE").
    end.
    else if vindex = 1
    then do:
        run emis_nfe_ssh.p.
    end.
    else do:
        run man_nfe_ssh.p(v-op[vindex], vetbcod, vdti, vdtf).
    end.
end.
else do:
    message color red/with
        "Banco NFE não esta conectado."
        view-as alert-box.
end.
