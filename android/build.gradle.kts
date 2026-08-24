allprojects {
    repositories {
        maven {
            url = uri("https://maven.myket.ir")
        }
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

    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {

        if (project.hasProperty("android")) {

            project.extensions.findByName("android")?.let { androidExt ->

                try {
                    val android =
                        androidExt as com.android.build.gradle.LibraryExtension

                    android.buildToolsVersion = "36.0.0"

                } catch (e: Exception) {

                    try {
                        val android =
                            androidExt as com.android.build.gradle.AppExtension

                        android.buildToolsVersion = "36.0.0"

                    } catch (_: Exception) {

                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}