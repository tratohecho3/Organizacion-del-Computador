.data
	fout: .asciiz "C:/Users/Daniel/Documents/programacion/mars_ejercicios/prueba2.txt"    #Nombre archivo
	buffer: .space 1024
	newLine: .asciiz "\n"
	msg_error1: .asciiz "Error: FORMATO DE ARCHIVO INIT INCORRECTO"
	num_init_archivos: .space 2
	nombre_init_archivos: .space 22
	num_lineas_contenido: .space 3
	contenido_init_archivos: .space 1024
	resultado: .space 20
	str1: .asciiz "\n numero de archivos iniciales: "
	str2: .asciiz "\n nombre del archivo: "
	str3: .asciiz "\n numero de lineas de contenido: "
	str4: .asciiz "\n contenido del archivo: "
	contador: .space 3
.text
	main:
	#INICIALIZACION
	lb $s1, newLine
	la $s2, num_init_archivos
	la $s3, nombre_init_archivos
	li $s4, 1
	la $t7, num_lineas_contenido
	la $s5, contenido_init_archivos
	
	# Abrir archivo
  	li   $v0, 13       
  	la   $a0, fout     
  	li   $a1, 0        # Modo Lectura
  	li   $a2, 0        # Modo Ignorado
  	syscall            # $v0 contiene el File descriptor
  	move $t6, $v0      
	
	#Leer archivo
	li   $v0, 14       
	move $a0, $t6      # Cargo el file descriptor 
	la   $a1, buffer   
	li   $a2, 1024     
	syscall           
	move $t5, $v0 	  
	
	# IMPRIME EL CONTENIDO (PRUEBA)
	li	$v0, 4			
	la	$a0, buffer		# el buffer contiene el contenido del archivo
	la 	$s0, buffer		# Guardo el contenido en $s0 para manipularlo
	syscall				# print int
	
	#INICIALIZACION PRUEBA
	#la $t4, resultado
	#lb $s1, newLine
	#la $t3, resultado
 	
	# Cerrar Archivo 
	li   $v0, 16         
	move $a0, $t5     
	syscall   	         
	
	#Toma la primera para inicializar el numero de archivos
primera_linea:
	lb $t1, ($s0)
	addi $s0, $s0, 1
	beqz $t1, Error_leer_archivo
	beq $t1, $s1, Iterar_caracter
	#Mostrar caracter
	#move $a0, $t1
	#li $v0, 11
	#syscall
	#Guarda en num_archivos_init el el num de archivos
	sb $t1, ($s2)			#S2 contiene el num de archivos
	addi $t2, $t2, 1
	j primera_linea
	
	
#Lee el contenido a partir	
Iterar_caracter:	
	lb $t1, ($s0)
	beq $t1, $s1, lineas_siguientes	#Encuentra un salto de linea
	beqz $t1, Fin
	beqz $s4, cantidad_lineas_contenido	#$s4 Variable condicion
	sb $t1, ($s3)		# $s3 tiene el nombre del archivo
	addi $s3, $s3, 1
	addi $s0, $s0, 1
	j Iterar_caracter
	
	lineas_siguientes:
	addi $s0, $s0, 1
	li $s4, 0
	j Iterar_caracter
	
	cantidad_lineas_contenido:
	sb $t1, ($t7)
	addi $s0, $s0, 1
	addi $t7, $t7, 1
	lb $t2, ($s0)
	beq $t2, $s1, cargar_contenido
	j Iterar_caracter
	
	cargar_contenido:
	li $t6, 48		#CONTADOR
	li $s4, 1		#Reactivo la var condicion
	continue:
	la $t4, num_lineas_contenido
	lb $t5, ($t4)
	#lb $t6, ($t7)
	beqz $t6, Fin #NO NECESARIO
	beq $t6,$t5, Fin
	addi $s0, $s0, 1
	lb $t3, ($s0)
	beq $t3, $s1, contar_1_al_contador
	sb $t3, ($s5)
	addi $s5, $s5, 1
	j continue
	
	
	contar_1_al_contador:
	addi $t6, $t6, 1
	#sb $t6, ($t7)
	j continue
	
	
	
Siguiente_linea: 
	addi $s0, $s0, 1
	j Iterar_caracter
	
	
#############################################################################################
#En num_init_archivos esta el NUMERO de archivos  INICIALIZAR -> pasar a la variable de cesar
#############################################################################################
Fin:
	li $v0 4
	la $a0, str1
	syscall
	li $v0 4 
	la $a0, num_init_archivos	
	syscall
	li $v0 4
	la $a0, str2
	syscall
	li $v0 4 
	la $a0, nombre_init_archivos	
	syscall
	li $v0 4
	la $a0, str3
	syscall
	li $v0 4
	la $a0, num_lineas_contenido
	syscall
	li $v0 4
	la $a0, str4
	syscall
	li $v0 4
	la $a0, contenido_init_archivos
	syscall
	#b Vaciar_nombre
	li $v0 10
	syscall

Vaciar_nombre:
	li $t0, 0	#contador
	li $t2, 0	#Sustituo " " 
	continuar_nombre:
	beq $t0, 2, Vaciar_contenido
	la $t5, nombre_init_archivos
	sb $t2, ($t5)
	addi $t5, $t5, 1
	addi $t0, $t0, 1
	j continuar_nombre
	
Vaciar_contenido:
	li $t0, 0	#contador
	li $t2, 0	#Sustituo " " 
	continuar_contenido:
	beq $t0, 10, Vaciar_num_cont
	la $t5, contenido_init_archivos
	sb $t2, ($t5)
	addi $t5, $t5, 1
	addi $t0, $t0, 1
	j continuar_contenido
	
Vaciar_num_cont:
	li $t0, 0	#contador
	li $t2, 0	#Sustituo " "
	addi $s0, $s0, 1 
	continuar_num_cont:
	beq $t0, 3, Iterar_caracter
	la $t5, num_lineas_contenido
	sb $t2, ($t5)
	addi $t5, $t5, 1
	addi $t0, $t0, 1	
	j continuar_num_cont

	
Error_leer_archivo:
	li $v0, 4
	la $a0, msg_error1
	syscall