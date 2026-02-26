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

subprojects {
    val fixNamespace = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val namespaceMethod = android.javaClass.getMethod("getNamespace")
                val currentNamespace = namespaceMethod.invoke(android)
                if (currentNamespace == null) {
                    var ns = project.group.toString()
                    if (ns.isEmpty()) {
                        ns = "dev.flutter.plugins.${project.name.replace('-', '_')}"
                    }
                    val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespaceMethod.invoke(android, ns)
                }
            } catch (e: Exception) {
                // Handle missing namespace reflectively
            }
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate { fixNamespace() }
    }
}

subprojects {
    // Force compileSdk = 36 for all subprojects (e.g. isar_flutter_libs) that
    // ship with an older compileSdkVersion and cause "lStar not found" errors.
    val forceCompileSdk = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val setCompileSdkMethod = android.javaClass.getMethod("compileSdk", Int::class.java)
                setCompileSdkMethod.invoke(android, 36)
            } catch (_: Exception) {
                try {
                    val setCompileSdkVersionMethod = android.javaClass.getMethod("setCompileSdkVersion", Int::class.java)
                    setCompileSdkVersionMethod.invoke(android, 36)
                } catch (_: Exception) { /* ignore */ }
            }
        }
    }
    if (project.state.executed) {
        forceCompileSdk()
    } else {
        project.afterEvaluate { forceCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
