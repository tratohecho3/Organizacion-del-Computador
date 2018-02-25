
.data
	Directorio: .space 520	# Estructura Estatica?
	Contador: .word 10	# Contador del numero de archivos existentes
	Head: .space 4 		# Almacena la direccion de la cabeza
	fout: .asciiz "C:\Users\Daniel\Documents\programacion\mars_ejercicios\prueba3.txt"    #Nombre archivo
	buffer: .space 1024
	newLine: .asciiz "\n"
	palabra: .space 20
	
.text
	main:
		     #open a file for writing
  li   $v0, 13       # system call for open file
  la   $a0, fout     # output file name
  	li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
  	li   $a2, 0        # mode is ignored
  	syscall            # open a file (file descriptor returned in $v0)
  	move $s6, $v0      # save the file descriptor 
	
	#Leer archivo
	li   $v0, 14       
	move $a0, $s6      # Cargo el file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1024       # hardcoded buffer length
	syscall            # read from file
	move $s5, $v0 	   # Guardo el numero arrojado
	
	# IMPRIME EL CONTENIDO
	li	$v0, 4			# 1=print int
	la	$a0, buffer		# buffer contains the int
	la 	$t0, buffer
	syscall				# print int
	
	addi $s4, $zero, 0 
	lb $t2, newLine
Iterar_caracter:
	lb $t1, ($t0)
	beq $t1, $t2, Siguiente_linea
	move $a0, $t1 
	li $v0, 11
	syscall
	
	la $t3, palabra
	
	sb $t1, ($t3)
	addi $t3, $t3, 1
	addi $t0, $t0, 1
	j Iterar_caracter
	
Siguiente_linea:
	############## ERROR ######### $S4 deberia tener la linea una completa
	la $t8, palabra
	
	li $v0 4 
	la $a0, palabra
	syscall
	
	# Cerrar Archivo 
	li   $v0, 16       #  
	move $a0, $s5      # File
	syscall            # close file