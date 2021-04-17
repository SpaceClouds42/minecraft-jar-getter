@file:Repository("https://jitpack.io")
@file:DependsOn("com.github.FabricMC:stitch:030b281b18")
@file:Repository("https://repo.maven.apache.org/maven2")
@file:DependsOn("org.ow2.asm:asm:9.1")
@file:DependsOn("org.ow2.asm:asm-tree:9.1")

import net.fabricmc.stitch.merge.JarMerger
import java.io.File

val jar1 =
    if (args.contains("-a")) {
        File(args[args.indexOf("-a") + 1])
    } else {
        throw IllegalArgumentException("Missing first jar's path argument (-a)")
    }
val jar2 =
    if (args.contains("-b")) {
        File(args[args.indexOf("-b") + 1])
    } else {
        throw IllegalArgumentException("Missing second jar's path argument (-b)")
    }

val out =
    if (args.contains("-o")) {
        File(args[args.indexOf("-o") + 1])
    } else {
        throw IllegalArgumentException("Missing output jar's path argument (-o)")
    }

val merger = JarMerger(jar1, jar2, out)
merger.merge()
merger.close()