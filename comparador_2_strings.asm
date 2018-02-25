.data
msg1:.asciiz "Ingresa una palabra: "
msg2:.asciiz "\n No son iguales"
msg3:.asciiz "\n Son iguales"
str1: .space 15
str2: .space 15
#.include "interprete2.asm"
.text

main:

#Imprimir msg1
li $v0,4
la $a0,msg1
syscall
#Obtener palabra1
li $v0,8
la $a0,str1
addi $a1,$zero,20
syscall 


#Imprimir msg1  
li $v0,4
la $a0,msg1
syscall
#Obtener palabra2
li $v0,8
la $a0,str2
addi $a1,$zero,20
syscall 
#Parametros para comparador
la $a0,str1  
la $a1,str2  
jal comparador  
#Chequeando resultado
# 0 son diferentes
# 1 son iguales
beq $v0,$zero,ok 
#Imprime msg2
li $v0,4
la $a0,msg2
syscall
#Salir
j exit

ok:
#Imprime msg3
li $v0,4
la $a0,msg3
syscall

exit:
#Salir
li $v0,10
syscall

comparador:
#Convencion del llamado
sw $fp, ($sp)
move $fp, $sp
addi $sp,$sp,-4
#Inicializando
add $t0,$zero,$zero
add $t1,$zero,$a0
add $t2,$zero,$a1

loop:
#Cargando una letra de la palabra
lb $t3,($t1)  
lb $t4,($t2)
#Revisa final de la cadena
beqz $t3,chequeo2 
beqz $t4,termina
#Compara las letras
# 1 son diferentes
# 0 son iguales
slt $t5,$t3,$t4  
bnez $t5,termina
#Proxima letra
addi $t1,$t1,1  
addi $t2,$t2,1
j loop

termina: 
#Return de comparador
addi $v0,$zero,1
j final_funcion

chequeo2:
bnez $t4,termina
add $v0,$zero,$zero

final_funcion:
#Regreso a main
jr $ra
