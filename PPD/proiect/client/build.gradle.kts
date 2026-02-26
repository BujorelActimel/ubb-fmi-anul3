plugins {
    application
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

dependencies {
    implementation(project(":common"))
    implementation("com.google.code.gson:gson:2.10.1")
}

application {
    mainClass.set("org.example.client.Client")
    applicationDefaultJvmArgs = listOf("-Dfile.encoding=UTF-8")
}

tasks.named<JavaExec>("run") {
    workingDir = rootProject.projectDir
    val clientId = project.findProperty("clientId") ?: "Client-${System.currentTimeMillis() % 1000}"
    args = listOf("config/client.properties", clientId.toString())
    standardInput = System.`in`
}

// Task to run multiple clients
for (i in 1..10) {
    tasks.register<JavaExec>("runClient$i") {
        group = "application"
        description = "Run client $i"
        classpath = sourceSets["main"].runtimeClasspath
        mainClass.set("org.example.client.Client")
        workingDir = rootProject.projectDir
        args = listOf("config/client.properties", "Client-$i")
    }
}
