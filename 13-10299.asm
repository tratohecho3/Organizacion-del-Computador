.data
mensaje: .asciiz "Hola 13-10299" # Sustituya XX-XXXXX con su carnet
.space 299 # ultimos tres digitos de su carnet
nombre: .asciiz "Organizacion del Computador"
nombre2: .asciiz ""
pregunta: .asciiz "\n Por favor escribe tu nombre \n"
pregunta2: .asciiz "\n Por favor escribe tu edad \n"
respuesta: .asciiz "Tu nombre es "
respuesta2: .asciiz "y tu edad es "
edad: .word 
linea: .asciiz "\n"
.text
main:
li $v0, 4
la $a0, mensaje
syscall
li $v0, 4
la $a0, nombre
syscall
la $a0, linea
syscall
li $t0, 10
sll $a0, $t0, 2
li $v0, 1
syscall
#Modificacion
li $v0, 4
la $a0, pregunta
syscall
li $v0, 8
la $a0, nombre2
li $a1, 41
syscall
li $v0, 4
la $a0, pregunta2
syscall
li $v0, 5
syscall
move $t0, $v0
sw $t0, edad
li $v0, 4
la $a0, respuesta
syscall
li $v0, 4
la $a0, nombre2
syscall
li $v0, 4
la $a0, respuesta2
syscall
li $v0, 1
lw $a0, edad
syscall

li $v0,10
syscall
