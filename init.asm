.data
#GUARDA ESPACIO PARA 10 ARCHIVOS
Directorio: .space 520 
#INDICA EL NUMERO DE ARCHIVOS
Contador: .word 2
#NOMBRE DEL ARCHIVO
Nombre: .asciiz ""
Contenido: .asciiz ""

.text
dir_init:
#NUMERO  DE VECES A ITERAR
lw $t0, Contador
#DIRECCION DEL DIRECTORIO
la $t1, Directorio

loop: blez $t0, fin
#LEE NOMBRE DESDE TECLADO
li $v0, 8
la $a0, ($t1)
li $a1, 20
syscall

#LEE TAMANO DESDE TECLADO
li $v0, 5
syscall
#GUARDA EL TAMANO
sw $v0,8($t1)
#LEE APUNTADOR SIGUIENTE DESDE TECLADO
li $v0, 5
syscall
#GUARDA EL TAMANO
sw $v0,12($t1)
#LEE CONTENIDO DESDE TECLADO
li $v0, 8
la $a0, 16($t1)
li $a1, 100
syscall

#DECREMENTANDO CONTADOR
addi $t0, $t0, -1
#INICIO DEL SIGUIENTE ARCHIVO
addi $t1,$t1,56
b loop



fin:
la $t1, Directorio

la $a0,($t1)
la $a1,56($t1)
jal dir_cp


#Imprime mensaje
li $v0, 4
la $a0, 16($t1)
syscall
#Imprime mensaje
li $v0, 4
la $a0, 72($t1)
syscall
#Imprime mensaje
#li $v0, 1
#lw $a0, 72($t1)
#syscall

li $v0,10
syscall


dir_cp:
#Convencion del llamado
sw $fp, ($sp)
sw $s0, -4($sp)
sw $s1, -8($sp)
sw $s2, -12($sp)
sw $s3, -16($sp)
move $fp, $sp
addi $sp,$sp,-20
#Inicializando
add $s0,$zero,$zero
#DIRECCION ARCHIVO 1
add $s1,$zero,$a0
#DIRECCION ARCHIVO 2
add $s2,$zero,$a1
#CARGANDO CONTENIDO DEL ARCHIVO 1
lw $s3, 16($s1)
sw $s3, 16($s2)

#Convencion del llamado
move $sp, $fp
lw $fp, ($sp)
lw $s0, -4($sp)
lw $s1, -8($sp)
lw $s2, -12($sp)
lw $s3, -16($sp)

jr $ra


