def preguntar():
    while(True):
        respuesta = input("ingresa un comando ")
        palabra1,palabra2,palabra3 = respuesta.split(" ")
        if(palabra1 == "cp"):
            cp(palabra2,palabra3)
        elif(palabra1 == "mv"):
            mv(palabra1,palabra2)
        else:
            print("error,comando no encontrado")

def cp(palabra1,palabra2):
    print(palabra1 + " hice algo " + palabra2)

def mv(palabra1,palabra2):
    print(palabra1 + " hice algo 2 " + palabra2)
preguntar()