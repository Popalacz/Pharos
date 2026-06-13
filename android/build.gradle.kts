plugins {
    // Usuwamy wersje z tych dwóch linii, ponieważ Flutter dostarcza je globalnie (w wersji 8.11.1):
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false

   id("com.google.gms.google-services") version "4.4.4" apply false
}



// --- Reszta Twojego kodu poniżej (keystoreProperties, allprojects itp.) zostaje BEZ ZMIAN ---
val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}
rootProject.extra.set("keystoreProperties", keystoreProperties)

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}