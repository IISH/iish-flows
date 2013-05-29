/**
 * run_app.groovy
 *
 * Conventional run of a command for each name of a folder in a foldername
 *
 * Usage: groovy run_app.groovy [folder] [executable] [arg]
 */

assert (args.length > 1)

new File(args[0]).listFiles().each {
    if (it.isDirectory() && it.name[0] != '.') {
        String line = (args.length < 3) ? it.name : it.name + ' ' + args[2..-1].join(" ")
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

        File f = new File( "log/flow2/${it.name}.log"  )
        println("Log to " + f.absolutePath)
        final FileOutputStream log = new FileOutputStream(f)
        log.write(ant.project.properties.cmdExit.getBytes())
        log.write(ant.project.properties.cmdErr.getBytes())
        log.write(ant.project.properties.cmdOut.getBytes())
        log.close()
    }
}