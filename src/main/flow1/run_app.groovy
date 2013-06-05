/**
 * start.groovy
 *
 * Iterates over all folders and kickoff any commands
 * Useage: start.groovy [folder]
 */

def SORIMPORT_HOME = System.getenv()['SORIMPORT_HOME'] ?: "."

assert (args.length == 1)
new File(args[0]).listFiles().each { project ->
    project.listFiles().each { fileSet ->
        int i = fileSet.name.indexOf('.')
        String name = (i == -1) ? fileSet.name : fileSet.name[0..i]
        String script = SORIMPORT_HOME + '/src/main/flow1/' + name + '.bat'
        if (new File(script).exists()) {
            def ant = new AntBuilder()   // create an antbuilder
            try {
                ant.exec(outputproperty: "cmdOut",
                        errorproperty: "cmdErr",
                        resultproperty: "cmdExit",
                        failonerror: "true",
                        executable: script) {
                }
            } catch (Exception e) {
                println(e.message)
            }

            File f = new File(SORIMPORT_HOME, "log/flow1/${it.name}.log")
            println("Log to " + f.absolutePath)
            final FileOutputStream log = new FileOutputStream(f)
            log.write(ant.project.properties.cmdExit.getBytes())
            log.write(ant.project.properties.cmdErr.getBytes())
            log.write(ant.project.properties.cmdOut.getBytes())
            log.close()
        }
    }
}
