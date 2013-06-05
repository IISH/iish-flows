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
        String script = (i == -1) ? fileSet.name : fileSet.name[0..i]
        def ant = new AntBuilder()   // create an antbuilder
        try {
            ant.exec(outputproperty: "cmdOut",
                    errorproperty: "cmdErr",
                    resultproperty: "cmdExit",
                    failonerror: "true",
                    executable: args[1]) {
                arg(line: """$line""")
            }
        } catch (Exception e) {
            println(e.message)
        }

        File f = new File( "log/flow1/${it.name}.log"  )
        println("Log to " + f.absolutePath)
        final FileOutputStream log = new FileOutputStream(f)
        log.write(ant.project.properties.cmdExit.getBytes())
        log.write(ant.project.properties.cmdErr.getBytes())
        log.write(ant.project.properties.cmdOut.getBytes())
        log.close()
    }
}
