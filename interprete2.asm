.data
mensaje: .asciiz "Ingresa tu comando \n"
comando: .asciiz ""

.text

.globl mi_funcion

mi_funcion:
#Convencion del llamado
sw $fp, ($sp)
sw $s1, -4($sp)
move $fp, $sp
addi $sp,$sp,-8
#parametros
move $s1,$a0
#Imprime comando leido
li $v0, 4
la $a0, ($s1)
syscall
#Convencion del llamado
move $sp, $fp
lw $fp, ($sp)
lw $s1, -4($sp)
jr $ra



