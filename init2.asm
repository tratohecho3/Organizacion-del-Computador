.data
#GUARDA ESPACIO PARA 10 ARCHIVOS + ATRIBUTO TAMANO DEL DIRECTORIO
Directorio: .space 10564 
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
#TAMANO INICIAL DEL DIRECTORIO
sw $zero, ($t1)
loop: blez $t0, fin
#LEE NOMBRE DESDE TECLADO
li $v0, 8
la $a0, 4($t1)
li $a1, 22
syscall

#LEE TAMANO DESDE TECLADO
li $v0, 5
syscall
#GUARDA EL TAMANO
sw $v0,28($t1)
#LEE APUNTADOR SIGUIENTE DESDE TECLADO
li $v0, 5
syscall
#GUARDA EL APUNTADOR
sw $v0,32($t1)
#LEE CONTENIDO DESDE TECLADO
li $v0, 8
la $a0, 36($t1)
li $a1, 1000
syscall

#DECREMENTANDO CONTADOR
addi $t0, $t0, -1
#INICIO DEL SIGUIENTE ARCHIVO
addi $t1,$t1,1060


b loop



fin:
la $t1, Directorio
#Imprime tamano directorio
li $v0, 1
lw $a0, ($t1)
syscall

la $a0,4($t1)
la $a1,1060($t1)
jal dir_cp


#Imprime CONTENIDO 1
li $v0, 4
la $a0, 36($t1)
syscall
#Imprime contenido 2
li $v0, 4
la $a0, 1092($t1)
syscall


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
#CARGANDO LETRA DEL CONTENIDO DEL ARCHIVO 1
copiar:
lb $t0, 32($s1)
beqz $t0, terminar
sb $t0, 32($s2)                   
addi $s2, $s2, 1                 
addi $s1, $s1, 1               
j copiar
terminar:
#Convencion del llamado
move $sp, $fp
lw $fp, ($sp)
lw $s0, -4($sp)
lw $s1, -8($sp)
lw $s2, -12($sp)
lw $s3, -16($sp)
jr $ra


#FUNCION PARA BUSCAR DIRECCIONES DE NOMBRE 
buscar_direcciones:
#Convencion del llamado
sw $fp, ($sp)
move $fp, $sp
addi $sp,$sp,-4
#Inicializando
add $t0,$zero,$zero
#NOMBRE1
add $t1,$zero,$a0
#DIRECTORIO
la $t0, Directorio
#DIRECCION ARCHIVO1
la $t3, 4($t0) 
#TAMANO DIRECTORIO
lw $t4, ($t0)
addi $t4,$t4,-1

iterando_sobre_archivos:
#PARAMETROS DE COMPARADOR
move $a0,$t1
move $a1, $t3
jal comparador
#Chequeando resultado
# 0 son iguales
# 1 son diferentes
beq $t4, $zero, fin_buscar
beq $v0,$zero,encontrado 
lw $t3, 28($t3)
j iterando_sobre_archivos




encontrado:
move $v0, $t3
jr $ra

fin_buscar:
jr $ra


