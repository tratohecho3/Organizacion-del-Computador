.data

.text

main:






dir_cp:
#Convencion del llamado
sw $fp, ($sp)
move $fp, $sp
addi $sp,$sp,-4
#Inicializando
add $t0,$zero,$zero
#DIRECCION ARCHIVO 1
add $t1,$zero,$a0
#DIRECCION ARCHIVO 2
add $t2,$zero,$a1
#CARGANDO CONTENIDO DEL ARCHIVO 1
la $t3, 16($t1)
sw $t3, 16($t2)


