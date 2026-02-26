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
    implementation("org.xerial:sqlite-jdbc:3.45.1.0")
    implementation("com.google.code.gson:gson:2.10.1")
}

application {
    mainClass.set("org.example.server.Server")
    applicationDefaultJvmArgs = listOf("-Dfile.encoding=UTF-8")
}

tasks.named<JavaExec>("run") {
    workingDir = rootProject.projectDir
    args = listOf("config/server.properties")
    standardInput = System.`in`
}

tasks.register<JavaExec>("runWith5s") {
    group = "application"
    description = "Run server with 5s verification interval"
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("org.example.server.Server")
    workingDir = rootProject.projectDir
    args = listOf("config/server.properties")

    doFirst {
        val configFile = file("${rootProject.projectDir}/config/server.properties")
        val content = configFile.readText()
        configFile.writeText(content.replace(Regex("verification.interval.seconds=\\d+"), "verification.interval.seconds=5"))
    }
}

tasks.register<JavaExec>("runWith10s") {
    group = "application"
    description = "Run server with 10s verification interval"
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("org.example.server.Server")
    workingDir = rootProject.projectDir
    args = listOf("config/server.properties")

    doFirst {
        val configFile = file("${rootProject.projectDir}/config/server.properties")
        val content = configFile.readText()
        configFile.writeText(content.replace(Regex("verification.interval.seconds=\\d+"), "verification.interval.seconds=10"))
    }
}
