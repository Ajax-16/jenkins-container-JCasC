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

# Integración GitLab - Jenkins

Dentro de este repositorio se encuentra un archivo docker-compose.yaml que nos permite crear una red de contendores docker con Jenkins y GitLab para poder lanzar Jobs a través de WebHooks dentro de la misma red local. Vamos a ver como podemos configurar nuestros proyectos de jenkins y repositorios de GitLab para hacer esto posible.

## Configuración para GitLab

Primeramente, debemos iniciar sesión con el usuario predefinido que hemos creado y permitir a GitLab que pueda recibir peticiones desde la red local de webhooks e integraciones, elemento que está deshabilitado por defecto por motivos de seguridad, pero para poder tener un sistema interno de integración entre GitLab y Jenkins, vamos a necesitar que esté activo. Para ello accedemos a la siguiente página dentro de la pestaña de administración:

http://localhost:30080/admin/application_settings/network

Buscamos el apartado de Outbound requests, clicamos sobre él y habilitamos la opción de: **"Allow requests to the local network from webhooks and integrations"** y añadimos la dirección de la máquina donde se está ejecutando jenkins en la red interna a la lista de IPs permitidas. Por defecto, dentro de la red de docker esta sería http://jenkins:8080.

Ahora, para integrar un repositorio de GitLab con un job de jenkins, seleccionamos cualquiera de nuestro repositorios que hayamos creado y en el menú de la izquierda clicamos sobre **"Settings"** en la sección de **"Integrations"**. Existen diferentes integraciones a las que podemos asociar nuestro proyecto de GitLab, pero nosotros debemos buscar entre todas ellas aquella que se llama **"Jenkins"**. Clicamos sobre ella y comenzamos a configurar los activadores de los webhook (al hacer push, al hacer merge request...). Posteriormente, especificamos la URL del servidor de Jenkins, la cual es la misma que hemos especificado anteriormente: http://jenkins:8080, el nombre del Job al que se va a enviar el webhook y, por último, las credenciales (usuario y contraseña) de un usuario de jenkins que tenga permisos sobre dicho job.

Guardamos los cambios, y ya tendríamos completada nuestra configuración en GitLab, sin embargo, aún debemos configurar Jenkins para poder aceptar las peticiones de job entrantes desde nuestro servidor de GitLab.

## Configuración para Jenkins

De manera predeterminada, la imagen de Jenkins que es creada por el dockerfile integra el plugin de GitLab, el cual vamos a necesitar para poder crear la conexión entre estos servicios.

Para poder usar el plugin, primeramente tenemos que configurar un GitLab Connections dentro de el panel de administración de Jenkins. Para ello accdemos a la URL http://localhost:8080/manage/configure y bajamos hasta la sección de **"GitLab Connections"**. Nombramos la conexión (por ejemplo, gitlab) y esecificamos la URL del servidor donde lo tenemos corriendo. En este caso, al igual que cuando referenciabamos la máquina de Jenkins en el otro contenedor, debemos utilizar el DNS que docker aplica por defecto dentro de la misma red para referenciar a la máquina de GitLab, es decir: http://gitlab:30080.

Finalmente, especificamos unas credenciales de GitLab, en este caso utilizaremos un API Token que conseguiremos en la siguiente dirección, dentro del panel de un usuario con privilegios de GitLab: http://localhost:30080/-/user_settings/personal_access_tokens. Copiamos el códgio que aparece con el nombre de **"Feed Token"** y lo pegamos al añadir un nuevo GitLab API Token de Jenkins.

Guardamos los cambios y solo quedaría especificar en la configuración del job con el que hemos estado trabajando, que el código fuente proviene de la URL de nuestro repositorio de GitLab y crear unas credenciales con el usuario y contraseña que tiene acceso a dicho repositorio.

Finalmente, en la sección de Disparadores de ejecuciones, habilitamos la opción de **"Build when a change is pushed to GitLab."** y ajustamos según nuestros requerimientos los casos en los que se va a lanzar el job automáticamente.

Guardamos los cambios y, ¡ya tendríamos una configuración básica para usar WebHooks de GitLab con Jenkins! 
