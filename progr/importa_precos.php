<?php
$dataini = date('r');

require"conexao.php";
$registro = '';
$vamos = mysql_query("select cod_produtos from publi_produtos");
$max = mysql_num_rows($vamos);

for ($n=0;$n<$max;$n++){

$cod = mysql_result($vamos,$n,'cod_produtos');
//echo "$cod <br> ";

shell_exec("rm -rfv /var/www/drebes/publi/php/preco.txt");

shell_exec("sudo /var/www/drebes/progress/precos.sh $cod");

//echo "sudo /var/www/drebes/progress/precos.sh $cod";
	//ENVIA PARA TODOS




$html .= "<center><b>$cod</b></center>";





$fp = fopen("preco.txt", "r");
error_reporting(0); 

$contador = 0;
$cont=0;

while (!feof($fp))
{

$string = fgets($fp, 500);
$produ = explode (";", $string);

$estab = $produ[0];
$estab = trim($estab);

$codigo = $produ[1];
$codigo = trim($codigo);
$produ[7] = trim($produ[7]);

if(($produ[7] == '0.00')or($produ[7] == '1.00')){
//echo "-Vista $vista ->(0) $produ[0] - (1) $produ[1] - (2) $produ[2] - (3) $produ[3] - (4) $produ[4] - (5) $produ[5] - (6) $produ[6] - (7) $produ[7] igual a zero ->$produ[7]<- <br>";
$vista = $produ[3];
//$vista = trim($vista);
//$vista = number_format($vista,'2',',','.');


}else{
//echo "$produ[7] $vista<br>";

$vista = $produ[7];
//$vista = trim($vista);
//$vista = number_format($vista,'2',',','.');
//echo "Vista $vista ->(0) $produ[0] - (1) $produ[1] - (2) $produ[2] - (3) $produ[3] - (4) $produ[4] - (5) $produ[5] - (6) $produ[6] - (7) $produ[7] diferente >$produ[7]<-<br>";
}

$prazo_qd = $produ[8];
$prazo_qd = trim($prazo_qd);


$prazo_qt = $produ[9];
$prazo_qt = trim($prazo_qt);


$prazo_os = $produ[10];
$prazo_os = trim($prazo_os);

$prazo_oo = $produ[11];
$prazo_oo = trim($prazo_oo);

if($estab <> ''){
//echo "foiii -->$estab<--";

$stgsql = "SELECT cod_preco FROM publi_precos where cod_produtos = $cod and cod_filial = $estab";
//	 echo "$stgsql <br>";
	 
  $existe = mysql_query($stgsql);
  $qtd = mysql_num_rows($existe) ;
  
 // echo "$codigo <br>";
			
		
  
  
  
  if($qtd >= 1){

$update = "UPDATE publi_precos
		    SET  vista = '$vista',
				 prazo_qd = '$prazo_qd',
	             prazo_qt = '$prazo_qt',
				 prazo_oo = '$prazo_oo',
	             prazo_os = '$prazo_os'
	    	 WHERE cod_produtos = $codigo and cod_filial = $estab";
			
			
			 
			 
// agora  $registro .= "<br>Atualização $codigo : A Vista ($vista), 42 ($prazo_qd), 43 ($prazo_qt), 87 ($prazo_os), 88 ($prazo_oo) <br>";	
 	 
//	echo "$update <br>";
					 
$hum = mysql_query($update);
		 
			 }else{
			 
$link = "insert into publi_precos(cod_produtos, cod_filial, vista, prazo_qd, prazo_qt, prazo_os, prazo_oo)
		 values($codigo, $estab, '$vista', '$prazo_qd', '$prazo_qt', '$prazo_os', '$prazo_oo')" ;

//	echo "$insert <br>";		 
// agora  $registro .= "Inserção $codigo : A Vista ($vista), 42 ($prazo_qd), 43 ($prazo_qt), 87 ($prazo_os), 88 ($prazo_oo) <br>";	

$hum = mysql_query($link);		 
			 
			 }
			 
		}else{

//FAZ NADA NEH

}	 
			 
			 
    
}



fclose($fp);





}
$datafim = date('r');


//ENVIA PARA TODOS


$titulo = "Atualização Etiquetas";
$headers = "Content-Type: text/html; charset=iso-8859-1\n";  
$headers.="From: etiq@lebes.com.br <etiq@lebes.com.br>\n"; 
$headers.="Reply-To: etiq@lebes.com.br\n";
$headers.="Erros-To: etiq@lebes.com.br\n";

$html .= "<center><b>Atualizado com Sucesso</b></center>";
$html .= "<center><b>Hora Inicio: $dataini</b></center>";
$html .= "<center><b>Hora Final: $datafim</b></center>";
$html .= "<center><b>$registro</b></center>";

$resultadomail = "joao@lebes.com.br";
mail ($resultadomail, $titulo, "
$html
", "$headers");



$titulo = "Atualização Etiquetas $cod";
$headers = "Content-Type: text/html; charset=iso-8859-1\n";  
$headers.="From: etiq@lebes.com.br <etiq@lebes.com.br>\n"; 
$headers.="Reply-To: etiq@lebes.com.br\n";
$headers.="Erros-To: etiq@lebes.com.br\n";
$resultadomail = "joao@lebes.com.br";
mail ($resultadomail, $titulo, "
$html
", "$headers");


?>