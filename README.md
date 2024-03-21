# jenkins-container-JCasC
Dockerfile que construye un contendor de jenkins para hacer un despliegue con configuración de forma programática y automática.

# Hacer build de la imágen de Jenkins

En este repositorio existen una serie de recursos predefinidos que permiten que un comando básico de docker build como el siguiente cree la imagen sin problemas:

```bash
docker build -t jenkins:jcasc .
```

Sin embargo, si queremos podemos configurar ciertos elementos a través de **argumentos en tiempo de build de docker**. Basta con que añadamos la bandera **--build-arg** seguida de una asignación para definir ciertos argumentos como las credenciales del usuario admin de la aplicación que será creado automáticamente al hacer el build de la imagen.

Esto nos permite **predefinir variables de entorno de la instancia**, sin la necesidad de que tengamos que especificarlo cada vez creemos un contenedor de esta imagen.

```bash
docker build --build-arg jenkins_admin_id=admin_on_build --build-arg jenkins_admin_pass=secret_on_build -t jenkins:jcasc .
```

Al ejecutar el siguiente comando:

```bash
docker run --name jenkins -d -p 8080:8080 -v jenkins_home:/var/jenkins_home jenkins:jcasc
```

Jenkins comienza a ejecutarse en el puerto 8080 de la instancia de docker, bindeada con la de nuestra máquina local, por lo que al acceder a **[localhost:8080/login](http://localhost:8080/login)** en este caso, podemos comprobar que admin_on_build es el usuario creado de manera predeterminada.

![Imagen usuario creado](imgs/usuario_creado.PNG)
