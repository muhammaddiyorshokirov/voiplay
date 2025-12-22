allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build direktoriyasini sozlash
val customBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(customBuildDir)

subprojects {
    val subProjectBuildDir = customBuildDir.dir(project.name)
    project.layout.buildDirectory.value(subProjectBuildDir)
    
    // Evaluation tartibini to'g'irlash (Recursion oldini olish uchun)
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }

    // Namespace xatosini tuzatish (afterEvaluate'siz xavfsiz usul)
    plugins.withType<com.android.build.gradle.BasePlugin> {
        val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
        if (android.namespace == null) {
            android.namespace = project.group.toString()
        }
    }
}

// Clean vazifasini sozlash
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
