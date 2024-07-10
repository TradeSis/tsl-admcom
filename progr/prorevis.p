/* Programa alterado dia 24/10/2011 chamado 38644 */
{admcab.i}                    

def buffer brevista for revista.    

def temp-table wrevi-produ no-undo
    field   etbcod          like plani.etbcod
    field   procod          like produ.procod
    field   pronom          like produ.pronom
    field   vlven-movim     as dec extent 12 format ">>>,>>9.99"
    field   mes             as char extent 12
    field   ano             as char extent 12 
    field   marca-revis     as logical extent 12 format "x(12)"
    field   movpc           like movim.movpc
    field   movqtm          like movim.movqtm.

def stream          stela.
def var varquivo    as char.
def var vetbnomi    as char.
def var vetbnomf    as char.   
def var vd1         as date format "99/99/9999".
def var vd2         as date format "99/99/9999".
def var vdti        as date format "99/99/9999".
def var vdtf        as date format "99/99/9999".
def var vetbi       like estab.etbcod.
def var vetbf       like estab.etbcod.
def var j           as int initial 0.
def var v-data-aux  as date format "99/99/9999".
def var v-aux       as char.  
def var v-data-mes  as char extent 12.
def var v-data-ano  as char extent 12.
def var v-data-mov  as date.
def var v-mes-aux   as int.
def var v-ano-aux   as int.
def var vcsv        as log format "Sim/Nao". 

def var v-valm-01  as dec .
def var v-valm-02  as dec .
def var v-valm-03  as dec .
def var v-valm-04  as dec .
def var v-valm-05  as dec .
def var v-valm-06  as dec .
def var v-valm-07  as dec .
def var v-valm-08  as dec .
def var v-valm-09  as dec .
def var v-valm-10  as dec .
def var v-valm-11  as dec .
def var v-valm-12  as dec .
def var v-calc-mer as dec.

form   vdti label  "Periodo de Publicacao         "   at 3
       vdtf  label "Ate" 
       vetbi label "Filial do Movimento           "  at 3
       vetbnomi no-label format "x(20)" skip
       vetbf label " Ate " at 28 
       vetbnomf no-label format "x(20)" skip
       with frame f-dat centered title " Parametros Produtos de Revista "
       side-labels.
 
form wrevi-produ.procod 
     wrevi-produ.pronom  format "x(25)" space(2)
     wrevi-produ.movpc    
     wrevi-produ.movqtm  
     v-valm-01 format ">>>,>>9.99"
     marca-revis[1] no-label format "x(1)"
     v-valm-02 format ">>>,>>9.99"
     marca-revis[2] no-label format "x(1)"
     v-valm-03 format ">>>,>>9.99"
     marca-revis[3] no-label format "x(1)"
     v-valm-04 format ">>>,>>9.99"
     marca-revis[4] no-label format "x(1)"
     v-valm-05 format ">>>,>>9.99"
     marca-revis[5] no-label format "x(1)"
     v-valm-06 format ">>>,>>9.99"
     marca-revis[6] no-label format "x(1)"
     v-valm-07 format ">>>,>>9.99"
     marca-revis[7] no-label format "x(1)"
     v-valm-08 format ">>>,>>9.99"
     marca-revis[8] no-label format "x(1)"
     v-valm-09 format ">>>,>>9.99"
     marca-revis[9] no-label format "x(1)"
     v-valm-10 format ">>>,>>9.99"
     marca-revis[10] no-label  format "x(1)"
     v-valm-11 format ">>>,>>9.99"
     marca-revis[11] no-label  format "x(1)"
     v-valm-12 format ">>>,>>9.99"
     marca-revis[12] no-label  format "x(1)"
     with frame f-detal width 220.

assign vdti = today - 90
       vdtf = today
       vetbi = 0
       vetbf = 0
       vcsv = no.
           
repeat :

    update  vdti  vdtf  
            vetbi vetbf    
    with frame f-dat .
       if vetbi <> 0 
       then do:
         find first estab where estab.etbcod = vetbi no-lock no-error.
         if not avail estab then do:
                message "Estabelecimento inicial nao Cadastrado" 
                view-as alert-box.
                next.                   
         end.
         else do:
                assign vetbnomi = estab.etbnom.
                disp vetbnomi with frame f-dat.
         end.
         find first estab where estab.etbcod = vetbf no-lock no-error.
         if not avail estab then do:
                message "Estabelecimento final nao Cadastrado"
                view-as alert-box.
                next.
         end.
         else do:
            assign vetbnomf = estab.etbnom.
         end.
       end.
       
       if vetbi = 0 then assign 
                               vetbf = 0
                               vetbnomi  = "Geral"
                               vetbnomf  = "Geral".
       disp vetbnomi vetbnomf with frame f-dat.

    /* Acha Meses */ 
    assign  v-data-aux = date(string("01/" + string(month(vdtf)) + "/" +
                              string(year(vdtf))))
            v-data-mes[12] = string(month(v-data-aux),"99")
            v-data-ano[12] = string(year(v-data-aux),"9999").
    do j = 1 to 11 :
       assign v-data-aux = v-data-aux - 5
              v-data-mes[12 - j] = string(month(v-data-aux),"99")
              v-data-ano[12 - j] = string(year(v-data-aux),"9999")
              v-data-aux =  date(string("01/" + string(month(v-data-aux))
                            + "/" + string(year(v-data-aux)))).
    end.
    
    
    assign  vd2 = vdtf
            vd1 = date("01/" + v-data-mes[1]+ "/" + v-data-ano[1]). 
    
    for each wrevi-produ:
        delete wrevi-produ.
    end.
    
    /* Gera temp */
    for each revista where  revista.etbcod = 0 and
                            revista.datini  >= vd1 and
                            revista.datfim  <= vd2 no-lock,
        first produ where produ.procod = revista.procod no-lock:
         
        if not can-find(wrevi-produ where wrevi-produ.procod = revista.procod)
        then do:
            create wrevi-produ.
            assign wrevi-produ.procod = produ.procod
                   wrevi-produ.pronom = produ.pronom.
                   do j = 1 to 12:
                        assign wrevi-produ.marca-revis[j] = no
                               wrevi-produ.mes[j] = v-data-mes[j]
                               wrevi-produ.ano[j] = v-data-ano[j].

                        assign v-data-aux = date(
                                int(v-data-mes[j]),01,int(v-data-ano[j])).
                        
                        find first brevista where brevista.etbcod = 0 and
                                   brevista.procod = produ.procod and
v-data-aux >= date((int(month(brevista.datini))),01,
                   (int(year(brevista.datini)))) and
v-data-aux <= date((int(month(brevista.datfim))),01,
                   (int(year(brevista.datfim)))) no-error.
                       if avail brevista 
                       then do:
                            /*
                            message "revista ini" brevista.datini skip
                                    "revista fim" brevista.datfim skip
                                    "data" v-data-aux  view-as alert-box.
                           */
                           wrevi-produ.marca-revis[j] = yes.

                       end. 
  
                   end.
        end.

        output stream stela to terminal.
        disp stream stela produ.procod
                          produ.pronom
                 with frame fffpro centered color white/red width 60.
        pause 0.
             
    end.
    
    find first wrevi-produ no-error.
    if not avail wrevi-produ then do:
            message "Sem registro de revista para estes parametros !"
            view-as alert-box.
            next.
    end.

    for each estab no-lock:
     if vetbi <> 0 then if estab.etbcod  < vetbi or estab.etbcod > vetbf
                       then next.
      
     do v-data-mov = vd1 to vd2 :
     
       disp estab.etbcod v-data-mov with 1 down row 10 centered no-box no-labels. pause 0. 

       for each plani where plani.movtdc = 5 and
                            plani.etbcod = estab.etbcod and
                            plani.pladat = v-data-mov no-lock:
           for each movim where movim.etbcod = plani.etbcod and
                            movim.placod = plani.placod and
                            movim.movtdc = plani.movtdc and
                            movim.movdat = plani.pladat
                                      no-lock:

                for each wrevi-produ where wrevi-produ.procod = movim.procod :

                assign wrevi-produ.movpc = movim.movpc. 
                
                do j = 1 to 12:
                    if  int(wrevi-produ.mes[j])  = int(month(movim.movdat)) and
                        int(wrevi-produ.ano[j])  = int(year(movim.movdat))
                    then do:
                      v-calc-mer = 0.
                      run p-calcula (input recid(movim), output v-calc-mer).
                      /*   *****  Valor Bruto ****
                      wrevi-produ.vlven-movim[j] = wrevi-produ.vlven-movim[j] +
                     (movim.movqtm * movim.movpc).
                      */
                     wrevi-produ.vlven-movim[j] = wrevi-produ.vlven-movim[j] +
                     v-calc-mer.
                     wrevi-produ.movqtm = wrevi-produ.movqtm + 
                     movim.movqtm.
                    end.
                end.
           end.
           end.
      end.
     end.    
   end.

/* Atualiza Labels */
assign v-aux = string(string(v-data-mes[1],"99") + "/" + string(v-data-ano[1])).
run pi-troca-label(input v-valm-01:handle, input v-aux).
assign v-aux = string(string(v-data-mes[2],"99") + "/" + string(v-data-ano[2])).
run pi-troca-label(input v-valm-02:handle, input v-aux).
assign v-aux = string(string(v-data-mes[3],"99") + "/" + string(v-data-ano[3])).
run pi-troca-label(input v-valm-03:handle, input v-aux).
assign v-aux = string(string(v-data-mes[4],"99") + "/" + string(v-data-ano[4])).
run pi-troca-label(input v-valm-04:handle, input v-aux).
assign v-aux = string(string(v-data-mes[5],"99") + "/" + string(v-data-ano[5])).
run pi-troca-label(input v-valm-05:handle, input v-aux).
assign v-aux = string(string(v-data-mes[6],"99") + "/" + string(v-data-ano[6])).
run pi-troca-label(input v-valm-06:handle, input v-aux).
assign v-aux = string(string(v-data-mes[7],"99") + "/" + string(v-data-ano[7])).
run pi-troca-label(input v-valm-07:handle, input v-aux).
assign v-aux = string(string(v-data-mes[8],"99") + "/" + string(v-data-ano[8])).
run pi-troca-label(input v-valm-08:handle, input v-aux).
assign v-aux = string(string(v-data-mes[9],"99") + "/" + string(v-data-ano[9])).
run pi-troca-label(input v-valm-09:handle, input v-aux).
assign v-aux = string(string(v-data-mes[10],"99") + "/" + string(v-data-ano[10])).
run pi-troca-label(input v-valm-10:handle, input v-aux).
assign v-aux = string(string(v-data-mes[11],"99") + "/" + string(v-data-ano[11])).
run pi-troca-label(input v-valm-11:handle, input v-aux).
assign v-aux = string(string(v-data-mes[12],"99") + "/" + string(v-data-ano[12])).
run pi-troca-label(input v-valm-12:handle, input v-aux).
/**/

if opsys = "UNIX"
then varquivo = "../relat/produrevis" + string(time).
else varquivo = "..\relat\produrevis" + string(time).
output to value(varquivo) page-size 62.

for each wrevi-produ :

            assign  v-valm-01 = vlven-movim[1]
                    v-valm-02 = vlven-movim[2]
                    v-valm-03 = vlven-movim[3]
                    v-valm-04 = vlven-movim[4]
                    v-valm-05 = vlven-movim[5]
                    v-valm-06 = vlven-movim[6]
                    v-valm-07 = vlven-movim[7]
                    v-valm-08 = vlven-movim[8]
                    v-valm-09 = vlven-movim[9]
                    v-valm-10 = vlven-movim[10]
                    v-valm-11 = vlven-movim[11]
                    v-valm-12 = vlven-movim[12].

            disp wrevi-produ.procod          column-label "Produto"                             wrevi-produ.pronom          column-label "Descricao"
                 
                 wrevi-produ.movpc             column-label "Vl.Unitario"
                 wrevi-produ.movqtm            column-label "Qtd Vend."
                 
                 v-valm-01   when vlven-movim[1] <> 0
                 wrevi-produ.marca-revis[1]   format "*/"
                 v-valm-02   when vlven-movim[2] <> 0        
                 wrevi-produ.marca-revis[2]   format "*/"
                 v-valm-03   when vlven-movim[3] <> 0
                 wrevi-produ.marca-revis[3]   format "*/"
                 v-valm-04   when vlven-movim[4] <> 0
                 wrevi-produ.marca-revis[4]   format "*/"
                 v-valm-05   when vlven-movim[5] <> 0
                 wrevi-produ.marca-revis[5]   format "*/"
                 v-valm-06   when vlven-movim[6] <> 0
                 wrevi-produ.marca-revis[6]   format "*/"
                 v-valm-07   when vlven-movim[7] <> 0
                 wrevi-produ.marca-revis[7]   format "*/"
                 v-valm-08   when vlven-movim[8] <> 0
                 wrevi-produ.marca-revis[8]   format "*/"
                 v-valm-09   when vlven-movim[9] <> 0
                 wrevi-produ.marca-revis[9]   format "*/"
                 v-valm-10  when vlven-movim[10] <> 0
                 wrevi-produ.marca-revis[10]  format "*/"
                 v-valm-11  when vlven-movim[11] <> 0
                 wrevi-produ.marca-revis[11]  format "*/"
                 v-valm-12  when vlven-movim[12] <> 0
                 wrevi-produ.marca-revis[12]  format "*/"
                 with frame f-detal down.
        down with frame f-detal.
end.   
output close.

run visurel.p (varquivo,"").
sresp = no.
message "Deseja imprimir o relatorio?" update sresp.
if sresp = no then leave.

 /* impressao */

{mdad_l.i
 &Saida     = "value(varquivo)"
 &Page-Size = "0"
 &Cond-Var  = "130"
 &Page-Line = "66"
 &Nom-Rel   = ""prorevis""
 &Nom-Sis   = """SISTEMA GERENCIAL"""
 &Tit-Rel   = """PRODUTOS PUBLICADOS/MOVIMENTO EM REVISTA DE "" +
                string(vdti,""99/99/9999"") + "" A "" +
                string(vdtf,""99/99/9999"")"
 &Width     = "130"
 &Form      = "frame f-cabcab"}

             
for each wrevi-produ :
             assign  v-valm-01 = vlven-movim[1]
                    v-valm-02 = vlven-movim[2]
                    v-valm-03 = vlven-movim[3]
                    v-valm-04 = vlven-movim[4]
                    v-valm-05 = vlven-movim[5]
                    v-valm-06 = vlven-movim[6]
                    v-valm-07 = vlven-movim[7]
                    v-valm-08 = vlven-movim[8]
                    v-valm-09 = vlven-movim[9]
                    v-valm-10 = vlven-movim[10]
                    v-valm-11 = vlven-movim[11]
                    v-valm-12 = vlven-movim[12].

            disp wrevi-produ.procod          column-label "Produto"                             wrevi-produ.pronom          column-label "Descricao"
                 
                 wrevi-produ.movpc             column-label "Vl.Unitario"
                 wrevi-produ.movqtm            column-label "Qtd Vend."
                 
                 v-valm-01   when vlven-movim[1] <> 0
                 wrevi-produ.marca-revis[1]   format "*/"
                 v-valm-02   when vlven-movim[2] <> 0        
                 wrevi-produ.marca-revis[2]   format "*/"
                 v-valm-03   when vlven-movim[3] <> 0
                 wrevi-produ.marca-revis[3]   format "*/"
                 v-valm-04   when vlven-movim[4] <> 0
                 wrevi-produ.marca-revis[4]   format "*/"
                 v-valm-05   when vlven-movim[5] <> 0
                 wrevi-produ.marca-revis[5]   format "*/"
                 v-valm-06   when vlven-movim[6] <> 0
                 wrevi-produ.marca-revis[6]   format "*/"
                 v-valm-07   when vlven-movim[7] <> 0
                 wrevi-produ.marca-revis[7]   format "*/"
                 v-valm-08   when vlven-movim[8] <> 0
                 wrevi-produ.marca-revis[8]   format "*/"
                 v-valm-09   when vlven-movim[9] <> 0
                 wrevi-produ.marca-revis[9]   format "*/"
                 v-valm-10  when vlven-movim[10] <> 0
                 wrevi-produ.marca-revis[10]  format "*/"
                 v-valm-11  when vlven-movim[11] <> 0
                 wrevi-produ.marca-revis[11]  format "*/"
                 v-valm-12  when vlven-movim[12] <> 0
                 wrevi-produ.marca-revis[12]  format "*/"
                 with frame f-detal down.
        down with frame f-detal.
end.   
    
output close.
if opsys = "UNIX"
then do:
        run visurel.p (input varquivo, input "").
end.
else do:
        {mrod.i}.
end.


end.
procedure Pi-troca-label.       
 
def input parameter  par-handle as handle.
def input parameter par-label  as char.
                                                             
if par-label = "NO-LABEL"                           
then par-handle:label    = ?.                       
else par-handle:label    = "  " + par-label.               
                                                         
end procedure.             

procedure p-calcula.

def input parameter  p-recid as recid.  
def output parameter p-valor like plani.platot.

def buffer bp-movim for movim.
def var val_fin as dec.
def var val_des as dec.
def var val_dev as dec.
def var val_acr as dec.
def var val_com as dec.
               
val_fin = 0.                   
val_des = 0.  
val_dev = 0.  
val_acr = 0. 

find first bp-movim where recid(bp-movim) = p-recid no-lock no-error.
                         
val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
if val_acr = ? then val_acr = 0.
val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
            plani.descprod.
if val_des = ? then val_des = 0.
val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
            plani.vlserv.
if val_dev = ? then val_dev = 0.
                
if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
then
val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
           (plani.platot - plani.vlserv - plani.descprod))
          * plani.biss) - ((movim.movpc * movim.movqtm) -  val_dev - val_des).
if  val_fin = ? then val_fin = 0.

val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + val_fin. 

if val_com = ? then val_com = 0.

assign p-valor = val_com.
  
end procedure.


/* Verifica se deve exportar o arquivo no formato csv */
vcsv = no.
message "Deseja gerar o arquivo csv?" update vcsv.
if vcsv = no then leave.

    
    if opsys = "UNIX"
    then varquivo = "../relat/produrevis" + string(time) + ".csv".
    else varquivo = "..\relat\produrevis" + string(time).
    output to value(varquivo).
    
    put unformatted
        "PRODUTO"
        ";"
        "DESCRICAO"
        ";"
        "VL.UNITARIO"
        ";"
        "QTD VEND."
        ";"
        string(string(v-data-mes[1],"99") + "/" + string(v-data-ano[1]))
        ";"
        string(string(v-data-mes[2],"99") + "/" + string(v-data-ano[2]))
        ";"
        string(string(v-data-mes[3],"99") + "/" + string(v-data-ano[3]))
        ";"
        string(string(v-data-mes[4],"99") + "/" + string(v-data-ano[4]))
        ";"
        string(string(v-data-mes[5],"99") + "/" + string(v-data-ano[5]))
        ";"
        string(string(v-data-mes[6],"99") + "/" + string(v-data-ano[6]))
        ";"
        string(string(v-data-mes[7],"99") + "/" + string(v-data-ano[7]))
        ";"
        string(string(v-data-mes[8],"99") + "/" + string(v-data-ano[8]))
        ";"
        string(string(v-data-mes[9],"99") + "/" + string(v-data-ano[9]))
        ";"
        string(string(v-data-mes[10],"99") + "/" + string(v-data-ano[10]))
        ";"
        string(string(v-data-mes[11],"99") + "/" + string(v-data-ano[11]))
        ";"
        string(string(v-data-mes[12],"99") + "/" + string(v-data-ano[12]))
    skip.
    
    
    for each wrevi-produ :

        assign  v-valm-01 = vlven-movim[1]
                v-valm-02 = vlven-movim[2]
                v-valm-03 = vlven-movim[3]                            
                v-valm-04 = vlven-movim[4]
                v-valm-05 = vlven-movim[5]
                v-valm-06 = vlven-movim[6]
                v-valm-07 = vlven-movim[7]
                v-valm-08 = vlven-movim[8]
                v-valm-09 = vlven-movim[9]
                v-valm-10 = vlven-movim[10]
                v-valm-11 = vlven-movim[11]
                v-valm-12 = vlven-movim[12].

        put unformatted
            wrevi-produ.procod                      
            ";"                                                                             wrevi-produ.pronom          
            ";"
            wrevi-produ.movpc            
            ";"
            wrevi-produ.movqtm                       
            ";"
            v-valm-01
            ";"
            v-valm-02
            ";"
            v-valm-03
            ";"
            v-valm-04
            ";"
            v-valm-05
            ";"
            v-valm-06
            ";"
            v-valm-07
            ";"
            v-valm-08
            ";"
            v-valm-09
            ";"
            v-valm-10
            ";"
            v-valm-11
            ";"
            v-valm-12
        skip.
    end.   
message "Arquivo gerado com sucesso." varquivo view-as alert-box.
 
