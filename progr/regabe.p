{admcab.i}

def var ii as int.
def var vimp   as char format "x(130)".
def var vtraco as char format "x(130)".
def var vtipo   as char format "x(15)" extent 4
        initial["Inventario","Entrada","Saida","ICMS"].
def var vdata   like plani.pladat.
def var vetbcod like estab.etbcod.
def var vord    as int format ">99".
def var vnumi   as int format ">99".
def var vnumf   as int format ">99".
def var vext    as char format "x(40)".
def var vnirc   as char format "9999999999-9".

def var varquivo as char.

repeat:

    update vetbcod label "Filial" colon 15 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod.

    display estab.etbnom no-label with frame f1.

    vnumi = 1.
    update vord label "N§ de Ordem"  colon 15
           vnumi label "Folha Inicial" colon 15
           vnumf label "Folha Final"
           vext no-label
               with frame f1.

    vnirc = string(estab.estcota).
    update vnirc label "N.I.R.C" colon 15 with frame f1.

    estab.estcota = dec(vnirc).                    
    
    display vtipo no-label with frame f-choose centered row 15.
    choose field vtipo with frame f-choose.
    
    if frame-index = 1
    then assign vimp  = "L I V R O   D E   R E G I S T R O   D E   " +
                         "I N V E N T A R I O"
                vtraco = "------------------------------------------" +
                         "-------------------". 
    if frame-index = 2
    then assign vimp  = "L I V R O   D E   R E G I S T R O   D E   " +
                         "E N T R A D A S"
                vtraco = "------------------------------------------" +
                         "---------------". 
    
    if frame-index = 3
    then assign vimp   = "L I V R O   D E   R E G I S T R O   D E   " +
                         "S A I D A S"                                
                vtraco = "-----------------------------------------"  +
                         "-----------". 
    
    if frame-index = 4
    then assign vimp = "L I V R O   D E   R E G I S T R O   D E   "  +
                       "A P U R A C A O   D O   I C M S" 
                vtraco = "------------------------------------------" +
                         "-------------------------------". 


    
            
    message "Deseja imprimir" update sresp.
    if not sresp
    then undo, retry.
        

    varquivo = "l:\relat\regabe.txt" .

    
    {mdad_l2.i
        &Saida     = "printer"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "0"
        &Nom-Rel   = ""regabe.p""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """LIVRO DE REGISTRO"""
        &Width     = "135"
        &Form      = "frame f-cabcab"}
    
    
    put skip(04)
        "Folha: 001" to 70 skip(2).
    
    put unformatted
        vimp   to 70 skip
        vtraco to 70 skip(04)
        "N§ DE ORDEM: "                    to 47 
        vord                                      skip(02)
        "T  E  R  M  O    D  E    A  B  E  R  T  U  R  A " to 65  skip
        "----------------------------------------------- " to 65  skip(02)
        "   Contem este livro " at 10 vnumf  "  ( ".
        
        
    put unformatted vext.
    put " ) folhas numeradas" skip
        "por processamento, do N§ " at 10
         vnumi " ao N§ " vnumf 
         " e servira para o" skip
         "lancamento das operacoes proprias do estabelecimento do "
         at 10 skip
         "contribuinte abaixo identificado:" at 10.
         
    put skip(02) 
        "Nome............: " at 15 estab.etbnom   skip(01)
        "Endereco........: " at 15 estab.endereco skip(01)
        "Municipio.......: " at 15 estab.munic    skip(01)
        "Estado..........: RS        " at 15      skip(01)
        "Inscr.Estadual..: " at 15 estab.etbinsc  skip(01)
        "C.N.P.J N§......: " at 15 estab.etbcgc   skip(01)
        "N.I.R.C.........: " at 15 vnirc          skip(06).
         
    put estab.munic at 20
        " , 01 de janeiro de " (year(today) - 1) format "9999"
        "." skip(05).
       
       
    put "_______________________________________________________" at 13 skip
        "(assinatura do contribuinte ou seu representante legal)" at 13.
    
    

    /*
    do ii = 1 to 67:
    
        put "" skip.

    end.    
    */

    put skip(9).
    
    
    put unformatted skip(04)
        "Folha: " to 70 vnumf format "999" skip(2).
    
    put unformatted
         vimp   to 70 skip
         vtraco to 70 skip(04)
        "N§ DE ORDEM: "                    to 47 
        vord                                      skip(02)
        "T  E  R  M  O    D  E    E  N  C  E  R  R  A  M  E  N  T  O " 
        to 69  skip
        "----------------------------------------------------------- " 
        to 69  skip(02)
        "   Contem este livro " at 10 vnumf  "  ( ".
    put unformatted vext.
    put " ) folhas numeradas" skip
     
        "por processamento, do N§ " at 10
         vnumi " ao N§ " vnumf 
         " e serviu para o" skip
         "lancamento das operacoes proprias do estabelecimento do"
         at 10 skip
         "contribuinte abaixo identificado:" at 10.
         
    put skip(02) 
        "Nome............: " at 15 estab.etbnom   skip(01)
        "Endereco........: " at 15 estab.endereco skip(01)
        "Municipio.......: " at 15 estab.munic    skip(01)
        "Estado..........: RS " at 15             skip(01)
        "Inscr.Estadual..: " at 15 estab.etbinsc  skip(01)
        "C.N.P.J N§......: "  at 15 estab.etbcgc  skip(01)
        "N.I.R.C.........: " at 15 vnirc          skip(06).
         
    put estab.munic at 20
        " , 31 de dezembro de " (year(today) - 1) format "9999"
        "." skip(05).
       
       
    put "_______________________________________________________" at 13 skip
        "(assinatura do contribuinte ou seu representante legal)" at 13.
     
    
    output close.

    
    /*{mrod2.i}*/

end.    
    
