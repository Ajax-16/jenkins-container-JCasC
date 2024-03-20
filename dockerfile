# Imagen predeterminada de jenkins que hace uso de jdk11
FROM jenkins/jenkins:lts-jdk11

# Bloquea la instalación por SetupWizard para que no salte la primera vez que se inicia Jenkins.
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Especifica un archivo que posteriormete copiaremos en la instancia como referencia para la configuración de Jenkins.
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

# Copia un txt con los plugins que queramos que tenga nuestro Jenkins al iniciarse.
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Ejecuta el cli de Jenkins para instalar los plugins especificados en el archivo anterior.
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

ARG jenkins_admin_id=admin
ARG jenkins_admin_pass=secret

ENV JENKINS_ADMIN_ID $jenkins_admin_id
ENV JENKINS_ADMIN_PASSWORD $jenkins_admin_pass

# Copiamos el .yaml de configuración en la instancia.
COPY config/casc.yaml /var/jenkins_home/casc.yaml
