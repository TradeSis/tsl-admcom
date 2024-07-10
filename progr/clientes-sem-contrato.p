/****
- CPF/CNPJ
- Tipo de liente (PF/PJ)
- Data do cadastro (tanto o rápido quanto o completo)
- Registro SPC (resultado da consulta realizada no SPC)
- Renda
- Data de nascimento
*****/
{admcab.i}
def var vdti as date.
def var vdtf as date.
update vdti label "Periodo cadastro"
       vdtf no-label
       with frame f1 width 80 side-label.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.
   
def var vtippes as char.
def var vspc as char.
def var vdata as date.
def var vok as log.
def var vc as char.
def var vn as char.
def var va as char.
vn = "A;a;B;b;C;c;D;d;E;e;F;f;G;g;H;h;I;i;J;j;K;k;L;l;M;m;N;n;O;o;P;p;Q;q;R;r;S;s;T;t;U;u;V;v;X;x;Y;y;Z;z;W;w".
vc = "1;2;3;4;5;6;7;8;9;0".
def var vi as int.
def var varquivo as char.
varquivo = "/admcom/relat/clienscontrato.csv".
output to value(varquivo).
put "CPF/CNPJ;Tipo;Cadastro;SPC;Renda;Nascimento" skip.
do vdata = vdti to vdtf:
for each clien where clien.dtcad = vdata no-lock:
    find first contrato where 
            contrato.clicod = clien.clicod 
            no-lock no-error.
    if avail contrato
    then next.        
    if ciccgc = ? or
       ciccgc = ""
    then next.        
    va = substr(string(clien.clinom),1,1).
    vok = no.
    do vi = 1 to num-entries(vn,";"):
        if va = entry(vi,vn,";")
        then do:
            vok = yes.
            leave.
        end.  
    end.
    if vok = no then next.
    va = substr(clien.ciccgc,1,1).
    vok = no.
    do vi = 1 to num-entries(vc,";"):
        if va = entry(vi,vc,";")
        then do:
            vok = yes.
            leave.
        end.
    end.
    if vok = no then next.
    
    vspc = "".
    if acha("OK",clien.entrefcom[2]) <> ?
    then do:
        if acha("OK",clien.entrefcom[2]) = "SIM"
        then vspc = "Nada Consta".
        else vspc = "Consta".
    end.    
    if clien.tippes
    then vtippes = "PF".
    else vtippes = "PJ".
    put unformatted
         /*clien.clicod ";"
         clien.clinom ";" */
         clien.ciccgc ";"
         vtippes ";"
         clien.dtcad  format "99/99/9999"  ";"
         vspc         format "x(15)"     ";"
         clien.prorenda[1]               ";"
         clien.dtnasc format "99/99/9999"
         skip
         .
end.
end.
output close.
message color red/with
"Arquivo gerado: " varquivo
view-as alert-box.


