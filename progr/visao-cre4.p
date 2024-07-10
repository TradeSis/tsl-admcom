{admcab.i}
def var varquivo as char format "x(30)".

def var ii as i.
def var vv as date.
def var vdtimp                  like plani.pladat.
def var dt     like plani.pladat.
def var acum-c like plani.platot.
def var acum-m like plani.platot.
def var vdia as int format ">9".
def var meta-c like plani.platot.
def var meta-m like plani.platot.
def var vcon like plani.platot.
def var vmov like plani.platot.
def buffer cmovim for movim.
def var vcat like produ.catcod initial 41.
def var lfin as log.
def var lcod as i.
def var vok as l.
def var vldev like plani.vlserv.
def buffer bmovim for movim.
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".

def var vdtirecebimento    as date format "99/99/9999".     
def var vdtfrecebimento    as date format "99/99/9999".     
def var vdtivendas    as date format "99/99/9999".     
def var vdtfvendas    as date format "99/99/9999".     

def var elegivel as dec.          
def var inadimplente as dec.      
def var percentual as dec.        


def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vdtultatu   as date format "99/99/9999" no-undo.
def stream stela.
def buffer bcontnf for contnf.
repeat:
   
       update vetbi label "Estabelecimento"
           vetbf no-label
            with frame f-etb centered color blue/cyan row 08
                                    title " Filial " side-label.
   
    
     update "Vendas:" vdtivendas no-label
           "a"
           vdtfvendas no-label with frame f-dat centered color blue/cyan row 12
                                    title " Periodo Vendas ".

   update "Parcelas:" vdtirecebimento no-label                                                     
             "a"                                                               
                       vdtfrecebimento no-label with frame f-dat centered color blue/cyan row 14    
                       title "Informe Periodo de Vendas e Recebimento de Parceças".                        
                                   

        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.
        
 varquivo = "/admcom/relat/visaocre-4" + string(time). 

        
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""conf-4""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """INADIMPLENCIA DO MES REFERENTE A VENDA DO MES ANTERIOR """
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    

            display estab.etbcod column-label "Fl" format ">>9"
                                    with frame f-a down width 140.

    

  for each plani where movtdc = 5 and pladat >= 05/01/2016 and pladat <=        
  05/31/2016 and plani.etbcod = estab.etbcod no-lock.                           
      find first contnf where contnf.etbcod = plani.etbcod                    
                                                                                    
                               and contnf.placod = plani.placod no-lock no-error. 
                                                                              
                                                                                              if not avail contnf                                           
                              then next.                                                    
                                    for each titulo where                                 
                                           titulo.empcod = 19  and                      
                                         titulo.titnat = no   and                     
                                       titulo.modcod = "CRE" and                    
                                     titulo.etbcod = plani.etbcod and             
                                   titulo.clifor = plani.desti and              
                                 titulo.titnum = string(contnf.contnum) and   
                                                                  (titulo.titdtven >= 06/01/2016 and           
                                  titulo.titdtven <= 06/28/2016)              
                                                        no-lock.                                                
    
    
                                                                              
                                                                                                      elegivel= elegivel + titvlcob.                    
                                                                                                
                                         if titsit = "LIB" then do:                       
                                    inadimplente = inadimplente + titvlcob.         
                                                   end.                       
                                                                                                                             
                                                                                                                       
                                                    if titsit = "PAG" and titulo.titdtpag >= 06/28/2016 then do: 
                         inadimplente = inadimplente + titvlcob.          
                                                  end.                                             
                                                                                          
                                                                                                                                     pause 0.               
                                                                     /*  disp plani.Desti titnum titdtemi titdtven titsit titvlcob titpar.   
  */                                                                         
  end.                                                                         
  end.                                                                         
                percentual = inadimplente / elegivel.                          
                              percentual = percentual * 100.                                 
                 put  estab.etbcod ";" elegivel format ">>>>>>>>>9.99" ";" inadimplente   
format ">>>>>>>>>>>>9.99" ";" percentual format ">>>>>>>9.99" skip.          
                                                                             
    
    
    
    
    
    
    
    
    output close.

    
    
    
    
    run visurel.p (input varquivo, input "").
  
    /* {mrod.i}  */
end.
 
